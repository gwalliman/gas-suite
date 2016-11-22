public virtual class AccountList extends sObjectList
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
}