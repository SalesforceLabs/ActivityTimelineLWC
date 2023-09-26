/*
 *  Copyright (c) 2018, salesforce.com, inc.
 *  All rights reserved.
 *  SPDX-License-Identifier: BSD-3-Clause
 *  For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 *  @description    This sample apex dataprovider returns the tasks related to an account
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class SampleApexDataProvider extends AbstractTimelineDataProvider {

    /**
     * @description The child object name
     * @return  String
     */
    global override String getObjectName() {
        return 'Task';
    }

    /**
     * @description The label of the relationshipname of the child object
     * @return  String
     */
    global override String getRelationshipName() {
        return 'OpenTasks';
    }

    /**
     * @description The field that is used as the title (flow step: Title field)
     * @return  String
     */
    global override String getTitleField() {
        return 'Subject';
    }

    /**
     * @description The field that is used as reference date (flow step: Date field)
     * @return  String
     */
    global override String getDateField() {
        return 'ActivityDate';
    }

    /**
     * @description The fields that are showed when expanded (flow step: Display fields)
     * @return  List<String>
     */
    global override List<String> getFieldsToDisplay() {
        return new List<String>{'Subject', 'CreatedDate', 'ActivityDate', 'IsClosed'};
    }

    /**
     * @description Defines the label and the type of the fields to display
     *              Only needed when it's no salesforce object
     * @return  List<TimelineFieldType>
     */
    global override List<TimelineFieldType> getFieldsToDisplayWithTypes() {
        List<TimelineFieldType> fieldTypes= new List<TimelineFieldType>();
        /*fieldTypes.add(TimelineFieldType.newInstance('Subject', 'Subject', Schema.DisplayType.STRING));
        fieldTypes.add(TimelineFieldType.newInstance('Created Date', 'CreatedDate', Schema.DisplayType.STRING));
        fieldTypes.add(TimelineFieldType.newInstance('Activity Date', 'ActivityDate', Schema.DisplayType.STRING));
        fieldTypes.add(TimelineFieldType.newInstance('Is Closed', 'IsClosed', Schema.DisplayType.BOOLEAN));*/
        return fieldTypes;
    }

    /**
     * @description To put in another base url than the current salesforce instance
     * @return  String
     */
    global override String getBaseUrlForRecordDetail() {
        return '';
    }

    /**
     * @description The field that represents the record Id
     * @return  String
     */
    global override String getRecordIdentifierField() {
        return 'Id';
    }

    /**
     * @description This method returns the set of data
     * @param   recordId    The id of the parent record (in this case an Account Id)
     * @param   dateFilter  The dateFilter coming from the filters in the panel
     * @return  List<Object>
     */
    @SuppressWarnings('PMD.ApexSOQLInjection')
    global override List<Object> getData(Id recordId, String dateFilter) {
        List<Object> result = new List<Object>();
        if (Schema.sObjectType.Task.isAccessible()) {
            String dateFilterStr;
            if(dateFilter != null) {
                switch on dateFilter {
                    when 'last_7_days' {
                        dateFilterStr = 'LAST_N_DAYS:7';
                    }
                    when 'last_30_days' { 
                        dateFilterStr = 'LAST_N_DAYS:30';
                    }
                    when 'next_7_days' {
                        dateFilterStr = 'NEXT_N_DAYS:7';
                    }
                }
            }
            // build query
            String query = 'Select Id, Subject, CreatedDate, ActivityDate, IsClosed ,OwnerId, Owner.Name, WhoId, Who.Name';
            query += ' From Task';
            // specify which lookup field to use
            query += ' Where WhatId = \''+String.escapeSingleQuotes(recordId)+'\'';
            if (dateFilterStr != null) {
                query +=' And ' + this.getDateField() + ' = '+dateFilterStr;
            }
            query += ' WITH USER_MODE';
            query += ' Order By ' + this.getDateField() + ' Desc';
            for (Task item : Database.query(query)) {
                // return every record as a map
                Map<String,Object> obj = new Map<String,Object>();
                obj.put('Id', item.Id);
                obj.put('Subject', item.Subject);
                obj.put('CreatedDate', item.CreatedDate);
                obj.put('ActivityDate', item.ActivityDate);
                obj.put('IsClosed', item.IsClosed);
                // for activities, lookup and master detail fields need to be added as follows for showing
                // 'This user' had a task with 'This contact' 
                Map<String, String> ownerNameMap = new Map<String,String>();
                ownerNameMap.put('Name', item.Owner.Name);
                obj.put('OwnerId', item.OwnerId);
                obj.put('Owner', ownerNameMap);
                Map<String, String> whoNameMap = new Map<String,String>();
                whoNameMap.put('Name', item.Who.Name);
                obj.put('WhoId', item.WhoId);
                obj.put('Who', whoNameMap);
                result.add(obj);
            }
        }
        return result;
    }

    /**
     * @description Returns if the child object is a salesforce object
     * @return  Boolean
     */
    global override Boolean isSalesforceObject() {
        return true;
    }

    /**
     * @description Returns if UI api is not supported (like with Task)
     * @return  String
     */
    global override Boolean isUiApiNotSupported() {
        return true;
    }
   
}