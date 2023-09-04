public with sharing class AddChildObjectToConfigController {
    
    @AuraEnabled(cacheable=true)
    public static string getObjectApiName(Id recordId){
        if(areObjectAndFieldsAccessible()){
            Timeline_Configuration__c conf = [select Object__c 
                                                        from Timeline_Configuration__c
                                                        where Id=:recordId ];
            return conf.Object__c;

        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<ApexDescribeUtils.FieldData> getFieldsForObject(String objectApiName){
        return ApexDescribeUtils.getFieldsForObject(objectApiName);
    }


    @AuraEnabled(cacheable=false)
    public static List<SObject> runSoql(String soqlQuery){
        return Database.query(soqlQuery);
    }


    private static Boolean areObjectAndFieldsAccessible(){
        return (Timeline_Configuration__c.sObjectType.getDescribe().isAccessible() &&
                Timeline_Child_Object__c.sObjectType.getDescribe().isAccessible() &&
                Schema.sObjectType.Timeline_Configuration__c.fields.Object__c.isAccessible() && 
                Schema.sObjectType.Timeline_Child_Object__c.fields.Date_Field__c.isAccessible() &&
                Schema.sObjectType.Timeline_Child_Object__c.fields.Fields_to_Display__c.isAccessible() &&
                Schema.sObjectType.Timeline_Child_Object__c.fields.Icon_Image_Url__c.isAccessible() &&
                Schema.sObjectType.Timeline_Child_Object__c.fields.Icon_Name__c.isAccessible() &&
                Schema.sObjectType.Timeline_Child_Object__c.fields.Object_Color__c.isAccessible() &&
                Schema.sObjectType.Timeline_Child_Object__c.fields.Object__c.isAccessible() &&
                Schema.sObjectType.Timeline_Child_Object__c.fields.Relationship_Name__c.isAccessible() &&
                Schema.sObjectType.Timeline_Child_Object__c.fields.Title_Field__c.isAccessible()
        );
    }
    


}