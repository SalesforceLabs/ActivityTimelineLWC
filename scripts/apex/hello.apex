// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

/*Timeline_Configuration__c conf = [ select Id,Object__c,Display_Relative_Dates__c,
                                                    (SELECT Date_Field__c,Fields_to_Display__c,Icon_Image_Url__c,
                                                            Icon_Name__c,Id,Name,Object_Color__c,Object__c,Relationship_Name__c,
                                                            Title_Field__c,LWC_Ui_Api_Not_Supported__c,Data_Provider_Type__c,
                                                            Provider_Apex_Classname__c,Reference_Field_Name__c,
                                                            Where_Clause__c,Display_Object_Name__c,Title_link_Navigate_to__c,
                                                            Overdue_Field__c,Include_All_Records__c
                                                    FROM Timeline_Child_Objects__r)
                                                    from Timeline_Configuration__c
                                                    where (Id='a004T000001HvKFQA0')
                                                ];
String recordId='0014T000002xVTxQAM';
List<String> log = new List<String>();
TimelineSOQLUtils.getSOQLForTimeline(conf,recordId,null,log);
System.debug('>>>>>>>>');
for(String logStr : log){
    System.debug('>>>>>>>> '+logStr);
}
System.debug('>>>>>>>>');*/
List<Task> allTasks = [select Id,Subject from Task ALL ROWS];
//RecordTimelineDataProvider.getTimelineItemChildData('ActivityHistory','Subject,Status,Priority','00T4T00000BzO31UAF');