/**
 * @description		This implementation of the DynamicPicklist class returns all Create quick actions
 */
global class TimelineQuickActionPicklist extends VisualEditor.DynamicPickList {
    
    VisualEditor.DynamicPickListRows values;

    global TimelineQuickActionPicklist(VisualEditor.DesignTimePageContext context) {
        this.values = TimelineQuickActionPicklistUtil.getValues(context.entityName, 'Create');
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