global class TimelineQuickActionPicklist extends VisualEditor.DynamicPickList{
    
    VisualEditor.DesignTimePageContext context;

    global TimelineQuickActionPicklist(VisualEditor.DesignTimePageContext context) {
       this.context = context;
    }

    global override VisualEditor.DataRow getDefaultValue() {
        return null;
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows values = new VisualEditor.DynamicPickListRows();
        List<QuickAction.DescribeAvailableQuickActionResult> resultList = QuickAction.DescribeAvailableQuickActions(context.entityName);  
        for (QuickAction.DescribeAvailableQuickActionResult result : resultList) {
            system.debug(result);
            if (result.getType() == 'Create' || result.getType() == 'LogACall') {
                String name = result.getName();
                String label = result.getLabel();
                if (!result.getName().startsWith(context.entityName)) {
                    // global action, add global prefix
                    name = 'Global.'+name;
                } else {
                    // object specific, add prefix to label
                    label = context.entityName + ' - ' + label;
                }
                //system.debug(name);
                //system.debug(label);
                values.addRow(new VisualEditor.DataRow(label, name));
            }
        }
        return values;
    }

}