public class CaseList extends sObjectList
{
    private AccountList accountsLinkedToCase;

    public CaseList() {}

    public CaseList(List<sObject> caseList)
    {
        super(caseList);
    }

    public CaseList(sObjectList caseList)
    {
        super(caseList);
    }

    public List<Case> getCases()
    {
        return (List<Case>) JSON.deserialize(JSON.serialize(super.getAllObjects()), List<Case>.class);
    }

    public CaseList getCaseSuperset()
    {
        return (CaseList) getSuperset();
    }

    public Case getCase(Integer index)
    {
        return (Case) super.get(index);
    }

    public List<Case> getChangedCases()
    {
        return (List<Case>) JSON.deserialize(JSON.serialize(super.getChangedObjects()), List<Case>.class);
    }

    public AccountList getParentAccounts()
    {
        if(accountsLinkedToCase == null)
        {
            loadParentAccounts();
        }

        return accountsLinkedToCase;
    }

    /**
     * Load all Accounts that this CaseList references
     * Note that we call "setChildren" at the end.
     * If you want to see us load CHILDREN instead of PARENTS, check out AccountList or OpportunityList
     */
    public void loadParentAccounts()
    {
        if(accountsLinkedToCase == null)
        {
            if(getCaseSuperset() != null)
            {
                accountsLinkedToCase = new CaseList(
                    getSupersetParentsObjects(getCaseSuperset().getParentAccounts(), 'AccountId')
                );
            }
            else
            {
                List<Id> accountIds = (List<Id>) JSON.deserialize(JSON.serialize(getFieldValues('AccountId')), List<Id>.class);
                List<Account> accts = [
                        SELECT Id, Name
                        FROM Account 
                        WHERE Id IN :accountIds
                ];

                accountsLinkedToCase = new AccountList(accts);
                accountsLinkedToCase.setChildren(this, 'AccountId');
            }
        }
    }
}