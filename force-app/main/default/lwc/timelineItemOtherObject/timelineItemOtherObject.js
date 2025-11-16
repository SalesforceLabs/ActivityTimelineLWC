import { LightningElement, api, track, wire } from 'lwc';
import getTimelineItemChildData from '@salesforce/apex/RecordTimelineDataProvider.getTimelineItemChildData';
import { loadScript } from 'lightning/platformResourceLoader';
import MOMENT_JS from '@salesforce/resourceUrl/moment_js';
import CURRENT_USER_ID from '@salesforce/user/Id';
import TimeZoneSidKey from '@salesforce/schema/User.TimeZoneSidKey';
import Toggle_Details from '@salesforce/label/c.Toggle_details';
import LANG from '@salesforce/i18n/lang';
import LOCALE from '@salesforce/i18n/locale';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import {
    subscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import timelineItemState from '@salesforce/messageChannel/TimelineItemState__c';

export default class TimelineItemOtherObject extends LightningElement {

    @api title;
    @api object;
    @api dateValue;
    @api subTitle;
    @api subTitleLabel;
    @api expandedFieldsToDisplay;
    @api fieldData;
    @api recordId;
    isDataFromExternalService;
    @api externalData;
    @api externalDataFieldTypes;
    @api baseUrlForRecordDetail;
    @api navigationBehaviour="Record Detail";
    @api displayRelativeDates;
    @api isOverdue=false;
    @api expanded;
    @api themeInfo;
    @api isSalesforceObject = false; // Value can still be set by a parent component, but no longer used within this component
    @api currentUserTimezone;
    @track dataLoaded = false;
 
    label = {
        Toggle_Details
    }

    @wire(MessageContext)
    messageContext;
    subscription;

    connectedCallback() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                timelineItemState,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
        Promise.all([
            loadScript(this, MOMENT_JS),
        ]).then(() => {
            //moment.lang(LANG);
            moment.locale(LOCALE);

        })
        .catch(error => {
            console.log('TimelineItemOtherObject: MomentJS not loaded');
        });
    }

    @wire(getRecord, {recordId: CURRENT_USER_ID, fields: [TimeZoneSidKey]}) 
    wireuser({error,data}) {
        if (error) {
            this.error = error; 
        } else if (data) {
            if (data.fields.TimeZoneSidKey.value != null) {
                this.currentUserTimezone=data.fields.TimeZoneSidKey.value;
            }
        }
    }

    @api 
    get isExternalServiceData() {
        // Check if externalData is populated (if it is then we know it's an external service)
        if (this.externalData) {
            return true;
        }
        // Otherwise, return the value set by the setter (this can be passed in via other parent components)
        return this.isDataFromExternalService;
    }

    set isExternalServiceData(value) {
        this.isDataFromExternalService = value;
    }

    get hasIconName() {
        return this.themeInfo.iconName != null;
    }

    get objectThemeColor() {
        return (this.themeInfo.color && this.themeInfo.color.length>0)?`background-color: #${this.themeInfo.color}`:'';
    }

    get itemStyle() {
        return this.expanded ? "slds-timeline__item_expandable slds-is-open" : "slds-timeline__item_expandable";
    }

    get totalFieldsToDisplay() {
        return this.expandedFieldsToDisplay.length;
    }

    get shouldNavigateToRecord(){
        return this.navigationBehaviour!='None';
    }

    get hasSubTitle(){
        return this.subTitle!=null && this.subTitle.length > 0;
    }

    handleMessage(message) {
        this.expanded = message.expanded;
        this.handleToggleDetail();
    }

    toggleDetailSection() {
        this.expanded = !this.expanded;
        this.handleToggleDetail();
    }

    handleToggleDetail(){
        if (this.expanded && !this.dataLoaded && !this.isExternalServiceData) {
            getTimelineItemChildData({
                objectApiName: this.object,
                fieldsToExtract: this.expandedFieldsToDisplay,
                recordId: this.recordId
            })
            .then(data => {
                this.dataLoaded=true;
                this.fieldData = this.populateFieldData(data.data,data.fieldMetadata);
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            });
        }
        //Data loaded via a Apex data provider so just display the data from the `externalData` attribute
        if (this.isExternalServiceData) {
            this.dataLoaded = true;
            this.fieldData = this.populateFieldData(this.externalData,this.externalDataFieldTypes);
        }
    }

    populateFieldData(data,fieldMetadata){
        moment.locale(LOCALE);
        moment.lang(LANG);
        let fieldData = new Array();
        for (let i = 0; i < fieldMetadata.length; i++) {
            let fld = fieldMetadata[i];
            let fldData = {};
            fldData.apiName = fld.apiName;
            fldData.fieldLabel = fld.fieldLabel;
            fldData.dataType = fld.extraTypeInfo?fld.extraTypeInfo.toUpperCase():fld.dataType;
            if (fld.dataType.toUpperCase() === "REFERENCE" && fldData.fieldLabel.endsWith(' ID')) { 
                fldData.fieldLabel = fldData.fieldLabel.substr(0, fldData.fieldLabel.length-3);
            }
            fldData.fieldValue = data[fld.apiName];
            if(fld.isNamePointing && data[fld.relationshipName]){
                fldData.fieldValue=data[fld.relationshipName]['Name'];
                fldData.isHyperLink=true;
                fldData.hyperLinkToId=data[fld.relationshipName]['Id'];
            }else if(fld.dataType.toUpperCase() === "REFERENCE" && data[fld.relationshipName]){
                fldData.fieldValue=data[fld.relationshipName][fld.referenceToApiName];
                fldData.isHyperLink=true;
                fldData.hyperLinkToId=data[fld.relationshipName]['Id'];
            }
            fldData.isBoolean = fld.dataType.toUpperCase() === "Boolean".toUpperCase();
            if(fldData.isBoolean){
                fldData.isBooleanTrue = fldData.fieldValue;
            }
            if(fldData.dataType.toUpperCase() === "Date".toUpperCase()) {
                fldData.isDate=true;
            } 
            
            if (fldData.dataType.toUpperCase() === "DateTime".toUpperCase()){
                /*if (fldData.fieldValue != null) {
                    fldData.fieldValue =  moment(fldData.fieldValue).format("dddd, MMMM Do YYYY, h:mm:ss a");
                }*/
                fldData.timezone = this.currentUserTimezone;
                fldData.isDateTime=true;
            }
 
            if(fldData.dataType.toUpperCase() === "RICHTEXTAREA".toUpperCase() || 
                fldData.dataType.toUpperCase() === "TEXTAREA".toUpperCase() || 
                fldData.dataType.toUpperCase() === "PLAINTEXTAREA".toUpperCase()) {
                fldData.isRichText=true;
            }

            if (fldData.fieldValue == null) {
                fldData.isNull = true;
            } else {
                fldData.isNull = false;
            }
             
            fieldData.push(fldData);
        } 
        return fieldData;       
    }

}