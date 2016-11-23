public class AccountTriggerHandler
{
    public class Before implements IGASTrigger
    {
        public AccountTriggerServices ats = new AccountTriggerServices();

        public void planAction()
        {
            /**
             * Find all accounts that have a new value in the "Latest_Customer_Note__c" field
             */
            LogSuite.log('GASAccountHandler', 'FINDING INDICES NEEDING UPDATE NOTE HISTORY');
            ats.findIndicesNeedingUpdateNoteHistory();
        }

        public void runServices()
        {
            /**
             * These two functions are utilities for:
             * 1. Keeping two fields in sync on the Account object itself (syncAccountFieldsOnAccountObjects)
             * 2. Inserting values into specific fields on the Account object when another field on Account has changed in a certain way (syncAccountFieldsOnAccountFieldChanges)
             */
            ats.syncAccountFieldsOnAccountObjects();
            ats.syncAccountFieldsOnAccountFieldChanges();

            /**
             * For all accounts with a new value in "Latest_Customer_Note__c" field, append that value to "Customer_Notes__c" textbox and clear "Latest_Customer_Note__c"
             */
            LogSuite.log('GASAccountHandler', 'UPDATING NOTE HISTORIES');
            ats.updateNoteHistories();

            /**
             * This is an example of performing an update on all Accounts in Trigger.new
             */
            LogSuite.log('GASAccountHandler', 'UPDATING CONTENT LAST MODIFIED DATE');
            ats.updateContentLastModifiedDate();
        }

        /**
         * We usually don't commit anything in a Before class. Most of the time I only commit data to the database in After triggers
         */
        public void commitChanges() {}
    }

    public class After implements IGASTrigger
    {
        public AccountTriggerServices ats = new AccountTriggerServices();

        public void planAction()
        {
            /**
             * Find all Opportunities linked to the Accounts in which the email opt out fields are different between the two
             * We do this in code instead of using a formula field so that we can trigger based off of email opt out changes on Opportunity
             */
            LogSuite.log('GASAccountHandler', 'FINDING OPPORTUNITY INDICES NEEDING UPDATE EMAIL OPT OUT');
            ats.findOpportunitiesNeedingUpdateEmailOptOut();

            /**
             * Find all Opportunities linked to the Accounts in which the Hub Email (based on the Account's Delivery Location) needs to be updated
             */
            LogSuite.log('GASAccountHandler', 'FINDING OPPORTUNITY INDICES NEEDING UPDATE HUB EMAIL');
            ats.findOpportunitiesNeedingUpdateHubEmail();

            /**
             * When Do Not Call is set to TRUE, close all Call events
             */
            LogSuite.log('GASAccountHandler', 'FINDING CALL EVENTS NEEDING CLOSE DUE TO DO NOT CALL');
             ats.findCallEventsNeedingCloseForDoNotCall();
        }

        public void runServices()
        {
            /**
             * For all opportunities needing a new value in Email Opt Out, set up those values here
             */
            LogSuite.log('GASAccountHandler', 'UPDATING OPPORTUNITIES SYNC EMAIL OPT OUT');
            ats.updateOpportunitiesSyncEmailOptOut();

            /**
             * For all opportunities needing a new Hub Email, set up those values here
             */
            LogSuite.log('GASAccountHandler', 'UPDATING OPPORTUNITIES SYNC HUB EMAIL');
            ats.updateOpportunitiesSyncHubEmail();
        }

        public void commitChanges()
        {
            /**
             * Save child opportunities to the database
             */
            LogSuite.log('GASAccountHandler', 'COMMITTING CHILD OPPORTUNITIES');
            ats.commitChildOpportunities();

            /**
             * Save child events (of child opportunities) to the database
             */
            LogSuite.log('GASAccountHandler', 'COMMITTING CHILD EVENTS');
            ats.commitChildEvents();
        }
    }
}