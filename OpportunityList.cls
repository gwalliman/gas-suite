public class OpportunityList extends sObjectList
{
    private EventList eventsLinkedToOpportunities;

    public OpportunityList() {}

    public OpportunityList(List<sObject> opptList)
    {
        super(opptList);
    }

    public OpportunityList(sObjectList opptList)
    {
        super(opptList);
    }

    public List<Opportunity> getOpportunities()
    {
        return (List<Opportunity>) JSON.deserialize(JSON.serialize(super.getAllObjects()), List<Opportunity>.class);
    }

    public OpportunityList getOpportunitySuperset()
    {
        return (OpportunityList) getSuperset();
    }

    public Opportunity getOpportunity(Integer index)
    {
        return (Opportunity) super.get(index);
    }

    public List<Opportunity> getChangedOpportunities()
    {
        return (List<Opportunity>) JSON.deserialize(JSON.serialize(super.getChangedObjects()), List<Opportunity>.class);
    }

    public EventList getChildEvents()
    {
        if(eventsLinkedToOpportunities == null)
        {
            loadChildEvents();
        }

        return eventsLinkedToOpportunities;
    }

    public void loadChildEvents()
    {
        if(eventsLinkedToOpportunities == null)
        {
            if(getOpportunitySuperset() != null)
            {
                eventsLinkedToOpportunities = new EventList(
                    getSupersetChildsObjects(getOpportunitySuperset().getChildEvents(), 'WhatId')
                );
            }
            else
            {
                List<Id> opportunityIds = (List<Id>) JSON.deserialize(JSON.serialize(getFieldValues('Id')), List<Id>.class);

                List<Event> events = [
                    SELECT Id, WhatId, RecordType.DeveloperName
                    FROM Event
                    WHERE WhatId IN :opportunityIds
                ];

                eventsLinkedToOpportunities = new EventList(events);
                eventsLinkedToOpportunities.setParents(this, 'WhatId');
            }
        }
    }
}