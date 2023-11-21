/**
 * @description		This Util class contains methods for handling the dynamic picklists
 */
public class TimelineQuickActionPicklistUtil {
    
    /**
     * @description		Method to retrieve the valid quick action values for the dynamic picklist
     * @param   entityName      The name of the object related to the recordpage
     * @param   actionType      The type of action we want to retrieve
     * @return  Intance of DynamicPicklistRows
     */
    public static VisualEditor.DynamicPickListRows getValues(String entityName, String actionType) {
	    VisualEditor.DynamicPickListRows values = new VisualEditor.DynamicPickListRows();
        List<QuickAction.DescribeAvailableQuickActionResult> resultList = QuickAction.DescribeAvailableQuickActions(entityName);  
        for (QuickAction.DescribeAvailableQuickActionResult result : resultList) {
            if (result.getType() == actionType) {
                String name = result.getName();
                String label = result.getLabel();
                if (entityName != null) {
                    // entityName can become null in community context when selecting a value
                    if (!result.getName().startsWith(entityName)) {
                        // global action, add global prefix
                        name = 'Global.'+name;
                    } else {
                        // object specific, add prefix to label
                        label = entityName + ' - ' + label;
                    }
                }
                values.addRow(new VisualEditor.DataRow(label, name));
            }
        }
        return values;
    }
    
}