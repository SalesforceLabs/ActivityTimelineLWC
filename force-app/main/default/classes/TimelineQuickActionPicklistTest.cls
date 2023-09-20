@IsTest
public class TimelineQuickActionPicklistTest {

    @IsTest
    static void testQuickActionPicklistController() {
        VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
        context.entityName = 'Account';
        context.pageType = 'RecordPage';

        TimelineQuickActionPicklist controller1 = new TimelineQuickActionPicklist(context);
        VisualEditor.DataRow defaultRow = controller1.getDefaultValue();
        system.assertEquals(null, defaultRow, 'defaultRow should be null');
        VisualEditor.DynamicPickListRows picklistRows = controller1.getValues();
        system.assert(controller1.isValid(defaultRow), 'should always return true');
        
        TimelineQuickActionPicklistLogACall controller2 = new TimelineQuickActionPicklistLogACall(context);
		defaultRow = controller2.getDefaultValue();
        system.assertEquals(null, defaultRow, 'defaultRow should be null');
        picklistRows = controller2.getValues();
        system.assert(controller2.isValid(defaultRow), 'should always return true');
        
        TimelineQuickActionPicklistSendEmail controller3 = new TimelineQuickActionPicklistSendEmail(context);
		defaultRow = controller3.getDefaultValue();
        system.assertEquals(null, defaultRow, 'defaultRow should be null');
        picklistRows = controller3.getValues();
        system.assert(controller3.isValid(defaultRow), 'should always return true');
    }

}