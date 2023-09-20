/**
 * @description		This implementation of the DynamicPicklist class returns all LogACall quick actions
 */
global class TimelineQuickActionPicklistLogACall extends VisualEditor.DynamicPickList {
	
    VisualEditor.DynamicPickListRows values;

    global TimelineQuickActionPicklistLogACall(VisualEditor.DesignTimePageContext context) {
        this.values = TimelineQuickActionPicklistUtil.getValues(context.entityName, 'LogACall');
    }

    global override VisualEditor.DataRow getDefaultValue() {
        return null;
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        return this.values;
    }

    global override boolean isValid(Object attr) {
        return true;
    }
    
}