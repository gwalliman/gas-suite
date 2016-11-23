@isTest
public class Test_AccountTriggerHandler 
{
    static testmethod void callAccountTriggerTestCreateNoteHistoryDontCreateNotesWhenEmpty()
    {
        TestFactory.createAndExecuteTest(AccountTriggerTests.AccountTriggerTestCreateNoteHistoryDontCreateNotesWhenEmpty.class);
    }

    static testmethod void callAccountTriggerTestCreateNoteHistoryNoPreviousNotes()
    {
        TestFactory.createAndExecuteTest(AccountTriggerTests.AccountTriggerTestCreateNoteHistoryNoPreviousNotes.class);
    }

    static testmethod void callAccountTriggerTestCreateNoteHistoryHasPreviousNotes()
    {
        TestFactory.createAndExecuteTest(AccountTriggerTests.AccountTriggerTestCreateNoteHistoryHasPreviousNotes.class);
    }

    static testmethod void callAccountTriggerTestLastContentChangeInsert()
    {
        TestFactory.createAndExecuteTest(AccountTriggerTests.AccountTriggerTestLastContentChangeInsert.class);
    }

    static testmethod void callAccountTriggerTestLastContentChangeUpdate()
    {
        TestFactory.createAndExecuteTest(AccountTriggerTests.AccountTriggerTestLastContentChangeUpdate.class);
    }

    static testmethod void callAccountTriggerTestSyncHubEmailInsert()
    {
        TestFactory.createAndExecuteTest(AccountTriggerTests.AccountTriggerTestSyncHubEmailInsert.class);
    }

    static testmethod void callAccountTriggerTestSyncHubEmailUpdate()
    {
        TestFactory.createAndExecuteTest(AccountTriggerTests.AccountTriggerTestSyncHubEmailUpdate.class);
    }

    static testmethod void callAccountTriggerTestAssignPersonContactIdOnAccountInsert()
    {
        TestFactory.createAndExecuteTest(AccountTriggerTests.AccountTriggerTestAssignPersonContactIdOnAccountInsert.class);
    }

    static testmethod void callAccountTriggerTestDoNotEmailSyncInsert()
    {
        TestFactory.createAndExecuteTest(AccountTriggerTests.AccountTriggerTestDoNotEmailSyncInsert.class);
    }

    static testmethod void callAccountTriggerTestDoNotEmailSyncUpdate()
    {
        TestFactory.createAndExecuteTest(AccountTriggerTests.AccountTriggerTestDoNotEmailSyncUpdate.class);
    }

    static testmethod void callAccountTriggerTestCustomerWDYHAUAdvocate()
    {
        TestFactory.createAndExecuteTest(AccountTriggerTests.AccountTriggerTestCustomerWDYHAUAdvocate.class);
    }

    static testmethod void callAccountTriggerTestContactTransferCarvanaID()
    {
        TestFactory.createAndExecuteTest(AccountTriggerTests.AccountTriggerTestContactTransferCarvanaID.class);
    }

    static testmethod void callAccountTriggerTestPFDetectionDateCapture()
    {
        TestFactory.createAndExecuteTest(AccountTriggerTests.AccountTriggerTestPFDetectionDateCapture.class);
    }
}