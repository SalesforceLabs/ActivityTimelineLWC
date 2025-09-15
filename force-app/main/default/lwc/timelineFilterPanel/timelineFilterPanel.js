import { LightningElement,track,api } from 'lwc';
import Filter from '@salesforce/label/c.Filter';
import Refresh_data from '@salesforce/label/c.Refresh_Data';
import Apply from '@salesforce/label/c.Apply';
import Date_Range from '@salesforce/label/c.Date_Range';
import Select_Objects from '@salesforce/label/c.Select_Objects';
import Filter_Results from '@salesforce/label/c.Filter_Results';
import All_Time from '@salesforce/label/c.All_Time';
import Last_7_days from '@salesforce/label/c.Last_7_days';
import Next_7_days from '@salesforce/label/c.Next_7_days';
import Last_30_days from '@salesforce/label/c.Last_30_days';
import All_Types from '@salesforce/label/c.All_Types';
import Filters from '@salesforce/label/c.Filters';
import Expand_All from '@salesforce/label/c.Expand_All';
import Collapse_All from '@salesforce/label/c.Collapse_All';

export default class TimelineFilterPanel extends LightningElement {
    @track showFilter=false;
    @api dateFilterSelection;
    @api objectFilters;
    @api availableObjects;
    @track expandAll=false;
    @api dateFilterOptions;
    @api showExpandCollapse=false;

    label = {
        Filter,Refresh_data,Apply,Date_Range,Select_Objects,Filter_Results,Filters
    }
    get filterStyles() {
        let filterStyle = '';
        if (this.showFilter) {
            filterStyle += 'display:block;';
        } else {
            filterStyle += 'display:none;';
        }
        return filterStyle;
    }
    showHideFilters() {
        this.showFilter = !this.showFilter;
    }


    expandCollapseAll(){
        this.expandAll=!this.expandAll;
        const expandAllEvent = new CustomEvent('expandcollapse', {
            detail: {
                "expanded":this.expandAll
            }
        });
        this.dispatchEvent(expandAllEvent);
    }

    get expandCollapseIcon(){
        return this.expandAll?'utility:collapse_all':'utility:expand_all';
    }

    get expandCollapseAltText(){
        return this.expandAll?Collapse_All:Expand_All;
    }

    get filterAltText(){
       /* var allFilters = [
            { label:All_Time, value: 'all_time' },
            { label: Last_7_days, value: 'last_7_days' },
            { label: Next_7_days, value: 'next_7_days' },
            { label: Last_30_days, value: 'last_30_days' },
        ];*/
        var allFilters = this.dateFilterOptions;
        var that = this;
        
        var currentFilterLabel='';
        var dateOptionArray = String(that.dateFilterSelection).replace(';', ',').split(',');
        
        for (let i = 0; i < dateOptionArray.length; i++) {
            if (dateOptionArray[i].length != 0 ) {
                var FilterLabel = allFilters.find(function(dtFilter){
                    return dtFilter.value === dateOptionArray[i];
				});
                currentFilterLabel +=  FilterLabel.label + ';';
            }
        }

        console.log('that.currentFilterLabel' + currentFilterLabel);
        
        var selectedObjects="";
        if(!this.objectFilters || this.objectFilters.length == this.availableObjects.length ){
            selectedObjects = All_Types;
        }else{
            selectedObjects = this.objectFilters.join(';');
        }
        return `${Filters}: ${currentFilterLabel} • ${selectedObjects}`;
    }
    /*get dateFilterOptions() {
        return [
            { label:All_Time, value: 'all_time' },
            { label: Last_7_days, value: 'last_7_days' },
            { label: Next_7_days, value: 'next_7_days' },
            { label: Last_30_days, value: 'last_30_days' },
        ];
    }*/

    get objectFilterOptions() {
        return this.availableObjects;
    }

    handleDateFilterChange(event) {
        this.dateFilterSelection = event.detail.value;
    }

    handleObjectFilterChange(event) {
        this.objectFilters= event.detail.value;
    }

    applyFilters(){
        this.expandAll=false;
        this.showFilter=false;
        const filterChangeEvent = new CustomEvent('change', {
            detail: {
                "dateFilter":this.dateFilterSelection,
                "objectFilter":this.objectFilters
            }
        });
        this.dispatchEvent(filterChangeEvent);

    }

    
}