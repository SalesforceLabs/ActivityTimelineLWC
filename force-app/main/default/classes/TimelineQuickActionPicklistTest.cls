@IsTest
public class TimelineQuickActionPicklistTest {

    @IsTest
    static void testQuickActionPicklistController() {
        VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
        context.entityName = 'Account';
        context.pageType = 'RecordPage';
        TimelineQuickActionPicklist controller = new TimelineQuickActionPicklist(context);
        VisualEditor.DataRow defaultRow = controller.getDefaultValue();
        system.assertEquals(null, defaultRow, 'defaultRow should be null');
        VisualEditor.DynamicPickListRows picklistRows = controller.getValues();
    }

}