public class AccountTriggerServices extends GASTriggerServices
{
    private AccountList newAccounts;
    private AccountList oldAccounts;

    /**
     * Each of these sObjectLists will be filled in the "planAction" stage and then used in the "runServices" stage
     */
    AccountList acctsNeedingUpdateNoteHistory = new AccountList();
    OpportunityList opptsNeedingUpdateEmailOptOut = new OpportunityList();
    OpportunityList opptsNeedingUpdateHubEmail = new OpportunityList();
    EventList callEventsOnOpportunitiesNeedingClose = new EventList();

    public AccountTriggerServices()
    {
        super(Account.class);
        newAccounts = new AccountList(newObjects);
        oldAccounts = new AccountList(oldObjects);
    }

    public void findIndicesNeedingUpdateNoteHistory()
    {
        if(isUpdate())
        {
            /**
             * Get all accounts where Latest_Customer_Note__c has changed
             */
            AccountList acctsWithDifferentLatestCustomerNote = new AccountList(
                newAccounts 
                .getSubset()
                .compareTo(oldAccounts)
                .whereMyField('Latest_Customer_Note__c')
                .notEqualsTheirField('Latest_Customer_Note__c')
                .execute()
            );

            /**
             * From the above list, get all accounts where Latest_Customer_Note__c is not empty
             * This has the effect of giving us a list of all Accounts where someone entered a value in the blank "Latest_Customer_Note__c" field
             */
            acctsNeedingUpdateNoteHistory = new AccountList(
                acctsWithDifferentLatestCustomerNote 
                .getSubset()
                .whereMyField('Latest_Customer_Note__c')
                .notEmpty()
                .execute()
            );
        }
    }

    public void findOpportunitiesNeedingUpdateEmailOptOut()
    {
        if(isUpdate())
        {
            /**
             * Find all opportunities attached to the accounts where the two email opt out fields differ
             */
            opptsNeedingUpdateEmailOptOut = new OpportunityList(
                newAccounts.getChildOpportunities()
                .getSubset()
                .compareToParents()
                .whereMyField('Email_Opt_Out__c')
                .notEqualsTheirField('Is_Do_Not_Email__c')
                .execute()
            );
        }
    }

    public void findOpportunitiesNeedingUpdateHubEmail()
    {
        if(isInsertOrUpdate())
        {
            /**
             * Get all accounts where the Delivery Location field has changed
             */
            AccountList acctsDeliveryLocationChanged = new AccountList(
                newAccounts
                .getSubset()
                .compareTo(oldAccounts)
                .whereMyField('Delivery_Location__c')
                .notEqualsTheirField('Delivery_Location__c')
                .execute()
            );

            /**
             * Get all opportunities related to the accounts with changed Delivery Location fields, where the opp is not closed
             */
            opptsNeedingUpdateHubEmail = new OpportunityList(
                acctsDeliveryLocationChanged.getChildOpportunities()
                .getSubset()
                .whereMyField('StageName')
                .notEqualsSet(new Set<Object>{'Closed Cancelled', 'Closed Won', 'Delivery Complete'})
                .execute()
            );
        }
    }

    public void syncAccountFieldsOnAccountObjects()
    {
        /** 
         * Sync the PersonEmail field to the UniqueEmailAddress__c field (both on Account)
         */
        syncFieldOnObject('PersonEmail', 'UniqueEmailAddress__c');

        /** 
         * Sync the Carvana_Id__c field to the Carvana_Id__pc field
         */
        syncFieldOnObject('Carvana_Id__c', 'Carvana_Id__pc');
    }

    public void syncAccountFieldsOnAccountFieldChanges()
    {
        /**
         * There are two bits of behavior here:
         * 1. When Lead_Source_Details__c is changed away from null, note the full name of the user who did it in the "WDYHAU Advocate" field
         * 2. When Is_Potential_Fraud__c is marked as true, note the datetime in the Potential_Fraud_Detected_Date__c field
         */
        recordValueOnFieldChange(Trigger.new, Trigger.old, 
            new List<GASTriggerServices.GASFieldMapping>{
                new GASTriggerServices.GASFieldMapping(
                    'Lead_Source_Details__pc',
                     null, 
                     false, 
                     new Map<String, String>{
                        'WDYHAU_Advocate__c' => 'fullname'
                    }
                ),
                new GASTriggerServices.GASFieldMapping(
                    'Is_Potential_Fraud__c',
                     true, 
                     true, 
                     new Map<String, String>{
                        'Potential_Fraud_Detected_Date__c' => 'datetime'
                    }
                )
            }
        );
    }

    public void findCallEventsNeedingCloseForDoNotCall()
    {
        /**
         * Get all accounts where DoNotCall has changed
         */
        AccountList acctsDoNotCallChanged = new AccountList(
            newAccounts
            .getSubset()
            .whereMyField('DoNotCall')
            .notEqualsMyField('DoNotCall')
            .execute()
        );

        /** 
         * Get all accounts where DoNotCall has changed to TRUE
         */
        AccountList acctsDoNotCallTrue = new AccountList(
            acctsDoNotCallChanged 
            .getSubset()
            .whereMyField('DoNotCall')
            .equals(true)
            .execute()
        );

        //Load all opportunities from the aforementioned list of accounts
        OpportunityList opptsWithEventsNeedingClosed = acctsDoNotCallTrue.getChildOpportunities();

        //Load all events from the aforementioned list of opportunities
        EventList allEventsOnOpportunities = opptsWithEventsNeedingClosed.getChildEvents();

        //Get the record types of all the events in "allEventsOnOpportunities"
        RecordTypeList recordTypeListOfEvents = eventsWithPotentialFraudChanged.getRecordTypes();

        /**
         * Get a list of Events (in this case, children of RecordTypeList) with "CallEvent" record types
         */
        EventList allCallEventsOnOpportunities = new EventList(
            recordTypeListOfEvents 
            .getSubset()
            .whereMyField('DeveloperName')
            .equals('CallEvent')
            .execute()
            .getChildren()
        );

        /**
         * Of the call events we've identified, get only the ones where StartDate is not already null
         */
        callEventsOnOpportunitiesNeedingClose = new EventList(
            recordTypeListOfEvents 
            .getSubset()
            .whereMyField('StartDate')
            .notEquals(null)
            .execute()
        ); 
    }

    public void updateNoteHistories()
    {
        if(acctsNeedingUpdateNoteHistory.size() > 0)
        {
            acctsNeedingUpdateNoteHistory.updateNoteHistories();
        }
    }

    public void updateContentLastModifiedDate()
    {
        if(isInsertOrUpdate() && !isCurrentUserBulkLoadUser())
        {
            newAccounts.updateContentLastModifiedDate(Datetime.now());
        }
    }

    public void updateOpportunitiesSyncEmailOptOut()
    {
        if(opptsNeedingUpdateEmailOptOut.size() > 0)
        {
            opptsNeedingUpdateEmailOptOut.updateEmailOptOutFromParentAccounts();
        }
    }

    public void updateOpportunitiesSyncHubEmail()
    {
        if(opptsNeedingUpdateHubEmail.size() > 0)
        {
            opptsNeedingUpdateHubEmail.updateHubEmails();
        }
    }

    public void updateCallEventsNeedingClose()
    {
        if(callEventsOnOpportunitiesNeedingClose.size() > 0)
        {
            callEventsOnOpportunitiesNeedingClose.closeCallEvents(); 
        } 
    }

    public void commitChildOpportunities()
    {
        newAccounts.getChildOpportunities().updateChanged();
    }

    public void commitChildEvents()
    {
        newAccounts.getChildOpportunities().getChildEvents().updateChanged();
    }
}