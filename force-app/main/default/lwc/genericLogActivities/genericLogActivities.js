import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class GenericLogActivities extends NavigationMixin (LightningElement) {
    @api recordId;
    @api newTaskAction;
    @api newEventAction;
    @api newCallAction;
    @api objectName;
    
    handleCall(event) {
        this[NavigationMixin.Navigate]({
            type: "standard__quickAction",
            attributes: {
                apiName: this.newCallAction
            },
            state: {
                objectApiName: this.objectName,
                recordId: this.recordId
            }
        });
    }

    handleTask(event) {
        this[NavigationMixin.Navigate]({
            type: "standard__quickAction",
            attributes: {
                apiName: this.newTaskAction
            },
            state: {
                objectApiName: this.objectName,
                recordId: this.recordId
            }
        });
    }

    handleEvent(event) {
        this[NavigationMixin.Navigate]({
            type: "standard__quickAction",
            attributes: {
                apiName: this.newEventAction
            },
            state: {
                objectApiName: this.objectName,
                recordId: this.recordId
            }
        });
    }


}
