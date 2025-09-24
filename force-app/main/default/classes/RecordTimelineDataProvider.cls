/*
 *  Copyright (c) 2018, salesforce.com, inc.
 *  All rights reserved.
 *  SPDX-License-Identifier: BSD-3-Clause
 *  For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
public with sharing class RecordTimelineDataProvider {
    @AuraEnabled(cacheable=false)
    public static TimelineDataResponse getTimelineItemData(String confIdOrName,String recordId,String dateFilter) {
        List<String> log = new List<String>();
        TimelineDataResponse resp = new TimelineDataResponse();

        if (dateFilter == null){
            dateFilter = 'all_time';
        }
        log.add('confIdOrName='+confIdOrName+', record Id:'+recordId+',dateFilter:'+dateFilter);

        // We don't continue, if we are missing the record Id or the configuration Name/external key
        if (recordId == null || confIdOrName == null){
            log.add('ConfId and/or record Id is null');
            resp.logs = log;
            return resp;
        }

        // We also don't continue, if we don't have access to timeline configuration data.
        if (!areObjectAndFieldsAccessible()){
            log.add('Fields are not accessible');
            resp.logs = log;
            return resp;
        }

        // If we reached this far, we can query the configuration data for processing
        // But if we don't get anything, there is nothing to do, and we don't continue.
        Timeline_Configuration__c conf = getTimeLineConfigurationWithLines(confIdOrName);
        if (conf.Timeline_Child_Objects__r.isEmpty()){
            log.add('Child Objects are empty');
            resp.logs = log;
            return resp;
        }

        String soqlToExec = TimelineSOQLUtils.getSOQLForTimeline(conf, recordId,dateFilter,log);
        log.add(soqlToExec);
        SObject theObject;
        if(soqlToExec !=null){
            // An error will be thrown in the data query, if one uses Data Provider Type = Related Record
            // and there are multiple Timeline Child Object records, which use the same Relationship Name.
            // [ System.QueryException ] : Cannot follow the same aggregate relationship twice: <relationship name>
            List<SObject> result = Database.query(soqlToExec);
            log.add('After SOQL query: result = '+JSON.serialize(result));
            theObject= result[0];
        }

        Map<String,TimelineDataResponse.ApexConfigAndData> apexData = getDataFromApexProviders(conf, recordId, datefilter);
        resp = new TimelineDataResponse(conf,theObject,apexData);

        List<ObjectNote> relatedNotes = getNotes(conf,recordId,dateFilter,log);
        if(relatedNotes !=null){
            log.add('Related Notes# = '+relatedNotes.size());
            resp.addOtherData('ContentDocumentLink',relatedNotes);
        }
        resp.objectLabels = getChildObjectLabels(conf);
        resp.logs = log;
        return resp;
    }

    private static Boolean areObjectAndFieldsAccessible(){
        return (Timeline_Configuration__c.sObjectType.getDescribe().isAccessible() &&
                Timeline_Child_Object__c.sObjectType.getDescribe().isAccessible() &&
                Schema.sObjectType.Timeline_Configuration__c.fields.Object__c.isAccessible() &&
                Schema.SObjectType.Timeline_Configuration__c.fields.Display_Relative_Dates__c.isAccessible() &&  
                Schema.SObjectType.Timeline_Configuration__c.fields.External_Key__c.isAccessible() && 
                Schema.sObjectType.Timeline_Child_Object__c.fields.Date_Field__c.isAccessible() &&
                Schema.sObjectType.Timeline_Child_Object__c.fields.Fields_to_Display__c.isAccessible() &&
                Schema.sObjectType.Timeline_Child_Object__c.fields.Icon_Image_Url__c.isAccessible() &&
                Schema.sObjectType.Timeline_Child_Object__c.fields.Icon_Name__c.isAccessible() &&
                Schema.sObjectType.Timeline_Child_Object__c.fields.Object_Color__c.isAccessible() &&
                Schema.sObjectType.Timeline_Child_Object__c.fields.Object__c.isAccessible() &&
                Schema.sObjectType.Timeline_Child_Object__c.fields.Relationship_Name__c.isAccessible() &&
                Schema.sObjectType.Timeline_Child_Object__c.fields.Title_Field__c.isAccessible() &&
                Schema.SObjectType.Timeline_Child_Object__c.fields.Data_Provider_Type__c.isAccessible() &&
                Schema.SObjectType.Timeline_Child_Object__c.fields.LWC_Ui_Api_Not_Supported__c.isAccessible() &&
                Schema.SObjectType.Timeline_Child_Object__c.fields.Provider_Apex_Classname__c.isAccessible() && 
                Schema.SObjectType.Timeline_Child_Object__c.fields.Title_link_Navigate_to__c.isAccessible() &&
                Schema.SObjectType.Timeline_Child_Object__c.fields.Overdue_Field__c.isAccessible() &&
                Schema.SObjectType.Timeline_Child_Object__c.fields.Include_All_Records__c.isAccessible() && 
                Schema.SObjectType.Timeline_Child_Object__c.fields.Sub_Title_Fields__c.isAccessible() &&
                Schema.SObjectType.Timeline_Child_Object__c.fields.Subtitle_Label__c.isAccessible());
    }


    @AuraEnabled(cacheable=true)
    public static Object getEmailDetails(String taskId) {
        String query = 'Select Id, ActivityId, Subject, FromName, FromAddress, ToAddress, CcAddress, TextBody, ';
        query += '(Select RelationId,Relation.Name,RelationObjectType,RelationType ';
        query += 'From EmailMessageRelations ';
        query += 'Where RelationType In (\'FromAddress\',\'ToAddress\') ';
        query += 'Order By RelationType ASC) ';
        query += 'From EmailMessage ';
        query += 'Where ActivityId = \'' +String.escapeSingleQuotes(taskId) + '\'';
        try {
            List<Object> msgs = Database.query(query);
            if(!msgs.isEmpty()){
                return msgs[0];
            }
        } catch (Exception e) {
            // maybe in future provide information about enabling Enhanced Email
        }
        return null;
    }


    @AuraEnabled(cacheable=true)
    public static TimelineDataResponse getTimelineItemChildData(String objectApiName,String fieldsToExtract,String recordId) {
        //Get all the fields so that we can get labels and type
        List<String> fieldsToQuery = fieldsToExtract.split(',');
        List<String> newFieldsToQuery = new List<String>();

        List<ApexDescribeUtils.FieldData> retFieldMetaData = ApexDescribeUtils.getFieldsForObject(objectApiName,fieldsToQuery);
        for(ApexDescribeUtils.FieldData fld:retFieldMetaData){
            if(fld.isNamePointing){
                newFieldsToQuery.add(fld.apiName);
                newFieldsToQuery.add(fld.relationshipName+'.Name');
            }else if(fld.dataType.equalsIgnoreCase('REFERENCE')){
                newFieldsToQuery.add(fld.apiName);
                for(ApexDescribeUtils.FieldData relFldMeta : ApexDescribeUtils.getFieldsForObject(fld.referenceTo)){
                    if(relFldMeta.isNameField){
                        fld.referenceToApiName=relFldMeta.apiName;
                        fld.fieldLabel=relFldMeta.fieldLabel;
                        newFieldsToQuery.add(fld.relationshipName+'.'+relFldMeta.apiName);
                        break;
                    }
                }
            }else if(fld.dataType.equalsIgnoreCase('PICKLIST') || fld.dataType.equalsIgnoreCase('MULTIPICKLIST') ){
                //Add the tolabel() for picklists so that it returns translated values
                newFieldsToQuery.add('tolabel('+fld.apiName+')');
            }else{
                newFieldsToQuery.add(fld.apiName);
            }
        }
        //get the data from the record
        String soqlStmt ='';
        if(objectApiName != 'ActivityHistory' && objectApiName != 'Task' && objectApiName != 'Event'){
            soqlStmt ='select Id,'+String.join(newFieldsToQuery,',')+' from '+objectApiName+' where Id=:recordId';
        }else{
            // make sure that the activity objects are queried with ALL ROWS to retrieve archived records also
            soqlStmt ='select Id,'+String.join(newFieldsToQuery,',')+' from '+objectApiName+' where Id=:recordId ALL ROWS';

        }
         
        List<SObject> result = Database.query(soqlStmt);
        if(!result.isEmpty()){
            TimelineDataResponse response = new TimelineDataResponse(null,result[0],null);
            response.fieldMetadata=retFieldMetaData;
            return response;
        }else{
            return null;
        }
    }

    private static List<ObjectNote> getNotes(Timeline_Configuration__c conf,String linkedEntityId,String datefilter,List<String> log){
        List<ObjectNote> notes;
        for(Timeline_Child_Object__c childObjConf: conf.Timeline_Child_Objects__r){
            if(childObjConf.Object__c == 'ContentDocumentLink'){
                notes = new List<ObjectNote>();
                List<Id> docIds = new List<Id>();
                for(ContentDocumentLink attachNote:[select Id,ContentDocumentId from ContentDocumentLink where LinkedEntityId=:linkedEntityId]){
                    docIds.add(attachNote.ContentDocumentId);

                }


                String soqlToExecute = 'SELECT Id,Content,CreatedDate,TextPreview,Title,CreatedBy.Name,FileType FROM ContentNote where Id in :docIds ';
                String dateFilterStr=null;
                if(dateFilter!=null){
                    switch on dateFilter{
                        when 'last_7_days'{
                            dateFilterStr='LAST_N_DAYS:7';
                        }
                        when 'last_30_days'{
                            dateFilterStr='LAST_N_DAYS:30';
                        }
                        when 'next_7_days'{
                            dateFilterStr='NEXT_N_DAYS:7';
                        }
                    }
                    if (dateFilterStr != null){
                        soqlToExecute += ' and CreatedDate='+dateFilterStr;
                    }
                }
                log.add('Notes SOQL:'+ soqlToExecute);
                for(ContentNote noteDetail : Database.query(soqlToExecute)){
                    notes.add(new ObjectNote(   noteDetail.TextPreview,noteDetail.Content.toString(),
                                                noteDetail.CreatedBy.Name,noteDetail.CreatedBy.Id, noteDetail.CreatedDate,
                                                noteDetail.Id,
                                                noteDetail.Id
                                            )
                            );
                }
                break;
            }
        }
        return notes;
        
    }
    private static Map<String,TimelineDataResponse.ApexConfigAndData> getDataFromApexProviders(Timeline_Configuration__c conf,String recordId,String datefilter){
        Map<String,TimelineDataResponse.ApexConfigAndData> apexData = new Map<String,TimelineDataResponse.ApexConfigAndData>();
        for (Timeline_Child_Object__c childObjConf: conf.Timeline_Child_Objects__r){
            if (childObjConf.Data_Provider_Type__c == 'Apex class'){
                Type providerClass = Type.forName(childObjConf.Provider_Apex_Classname__c);
                AbstractTimelineDataProvider provider = (AbstractTimelineDataProvider)providerClass.newInstance();
                TimelineDataResponse.ApexConfigAndData apexResp = new TimelineDataResponse.ApexConfigAndData();
                apexResp.apexData=provider.getData(recordId, dateFilter);
                apexResp.recordIdentifierField=provider.getRecordIdentifierField();
                apexResp.baseUrlForRecordDetail=provider.getBaseUrlForRecordDetail();
                apexResp.fieldsWithTypes=provider.getFieldsToDisplayWithTypes();
                apexResp.isSalesforceObject=provider.isSalesforceObject();
                apexResp.isUiApiNotSupported=provider.isUiApiNotSupported();
                apexData.put(childObjConf.Id, apexResp);
            }
        }

        return apexData;
    }

    private static Map<String,String> getChildObjectLabels(Timeline_Configuration__c conf){
        List<String> childObjects = new List<String>();
        for(Timeline_Child_Object__c childObjConf: conf.Timeline_Child_Objects__r){
            if(childObjConf.Data_Provider_Type__c ==null || childObjConf.Data_Provider_Type__c != 'Apex class'){
                childObjects.add(childObjConf.Object__c);
            }
        }
        
        Map<String,String> childObjLabels = new Map<String,String>();
        for(Schema.DescribeSObjectResult childObjDesc: Schema.describeSObjects(childObjects)){
            childObjLabels.put(childObjDesc.getName(),childObjDesc.getLabel());

        }
        return childObjLabels;
    }

    private static Timeline_Configuration__c getTimeLineConfigurationWithLines(String confIdOrName){
        return [SELECT Id, Object__c, Display_Relative_Dates__c,
                (SELECT Date_Field__c,Fields_to_Display__c,Icon_Image_Url__c,
                        Icon_Name__c,Id,Name,Object_Color__c,Object__c,Relationship_Name__c,
                        Title_Field__c,LWC_Ui_Api_Not_Supported__c,Data_Provider_Type__c,
                        Provider_Apex_Classname__c,Reference_Field_Name__c,
                        Where_Clause__c,Display_Object_Name__c,Title_link_Navigate_to__c,
                        Overdue_Field__c,Include_All_Records__c, Sub_Title_Fields__c,
                        Subtitle_Label__c,External_Key__c 
                FROM Timeline_Child_Objects__r)
                FROM Timeline_Configuration__c
                WHERE (Id =: confIdOrName OR Name =: confIdOrName OR External_Key__c =: confIdOrName)
                LIMIT 1
        ];
    }
}