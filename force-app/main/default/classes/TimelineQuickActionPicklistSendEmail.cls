/**
 * @description		This implementation of the DynamicPicklist class returns all SendEmail quick actions
 */
global class TimelineQuickActionPicklistSendEmail extends VisualEditor.DynamicPickList {
	
    VisualEditor.DynamicPickListRows values;

    global TimelineQuickActionPicklistSendEmail(VisualEditor.DesignTimePageContext context) {
        this.values = TimelineQuickActionPicklistUtil.getValues(context.entityName, 'SendEmail');
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