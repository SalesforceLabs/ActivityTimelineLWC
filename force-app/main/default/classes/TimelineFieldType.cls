/*
 *  Copyright (c) 2018, salesforce.com, inc.
 *  All rights reserved.
 *  SPDX-License-Identifier: BSD-3-Clause
 *  For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

global class TimelineFieldType {
    @AuraEnabled
    public String fieldLabel {get; set;}
    @AuraEnabled
    public String apiName {get; set;}
    @AuraEnabled
    public String dataType {get; set;}

    public TimelineFieldType(){

    }
    public TimelineFieldType(String fldLabel,String apiName,Schema.DisplayType fldType) {
        this.fieldLabel=fldLabel;
        this.apiName=apiName;
        this.dataType=fldType.name();
    }
    public TimelineFieldType(String fldLabel,String apiName,String fldType) {
        this.fieldLabel=fldLabel;
        this.apiName=apiName;
        this.dataType=fldType;
    }

    global static TimelineFieldType newInstance(String fldLabel,String apiName,Schema.DisplayType fldType){
        return new TimelineFieldType(fldLabel,apiName,fldType);
    }
    global static TimelineFieldType newInstance(String fldLabel,String apiName,String fldType){
        return new TimelineFieldType(fldLabel,apiName,fldType);
    }
}