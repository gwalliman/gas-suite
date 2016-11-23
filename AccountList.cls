public class AccountList extends sObjectList
{
    private OpportunityList opportunitiesLinkedToAccounts;

    public AccountList() {}

    public AccountList(List<sObject> acctList)
    {
        super(acctList);
    }

    public AccountList(sObjectList acctList)
    {
        super(acctList);
    }

    public List<Account> getAccounts()
    {
        return (List<Account>) JSON.deserialize(JSON.serialize(super.getAllObjects()), List<Account>.class);
    }

    public AccountList getAccountSuperset()
    {
        return (AccountList) getSuperset();
    }

    public Account getAccount(Integer index)
    {
        return (Account) super.get(index);
    }

    public List<Account> getChangedAccounts()
    {
        return (List<Account>) JSON.deserialize(JSON.serialize(super.getChangedObjects()), List<Account>.class);
    }

    public OpportunityList getChildOpportunities()
    {
        if(opportunitiesLinkedToAccounts == null)
        {
            loadChildOpportunities();
        }

        return opportunitiesLinkedToAccounts;
    }

    /**
     * Loads the child OPPORTUNITIES of this ACCOUNTLIST
     * Note that we "setParents" at the very end!
     *
     * If you want to see us load PARENTS instead of CHILDREN, check out CaseList
     */
    public void loadChildOpportunities()
    {
        if(opportunitiesLinkedToAccounts == null)
        {
            if(getAccountSuperset() != null)
            {
                opportunitiesLinkedToAccounts = new OpportunityList(
                    getSupersetChildsObjects(getAccountSuperset().getChildOpportunities(), 'AccountId')
                );
            }
            else
            {
                List<Id> accountIds = (List<Id>) JSON.deserialize(JSON.serialize(getFieldValues('Id')), List<Id>.class);
                List<Opportunity> opps = [
                        SELECT Id, AccountId, StageName, IsDeleted, IsClosed
                        FROM Opportunity
                        WHERE AccountId IN :accountIds
                ];

                opportunitiesLinkedToAccounts = new OpportunityList(opps);
                opportunitiesLinkedToAccounts.setParents(this, 'AccountId');
            }
        }
    }

    public void updateNoteHistories()
    {
        for(Integer x : getAllIndices())
        {
            Account a = getAccount(x);
            a = updateNoteHistory(a);
            put(x, a);
        }
    }

    /**
     * For each account needing note history updated, append a formatted note to "Customer_Notes__c" and clear out "Latest_Customer_Note__c"
     */
    private Account updateNoteHistory(Account a)
    {
        //Format it nicely
        String newEntry = String.format(
            '{0} - {1}\n{2}',
            new List<String> {
                DateTime.now().format('MM/dd/yyy h:mm a'),
                UserInfo.getName(),
                a.Latest_Customer_Note__c
            }
        );

        //Either insert it or append it to the Customer_Notes__c field
        if(String.isEmpty(a.Customer_Notes__c))
        {
            a.Customer_Notes__c = newEntry;
        }
        else
        {
            a.Customer_Notes__c = newEntry + '\n\n' + a.Customer_Notes__c;
        }

        a.Latest_Customer_Note__c = null;

        return a;
    }

    public void updateContentLastModifiedDate(Datetime dt)
    {
        for(Integer x = 0; x < getAccounts().size(); x++)
        {
            Account a = getAccount(x);
            a.ContentLastModifiedDate__c = dt;
            put(x, a);
        }
    }
}