public class EventList extends sObjectList
{
    private RecordTypeList eventRecordTypes;

    public EventList(List<sObject> eventList)
    {
        super(eventList);
    }

    public EventList(sObjectList eventList)
    {
        super(eventList);
    }

    public List<Event> getEvents()
    {
        return (List<Event>) JSON.deserialize(JSON.serialize(super.getAllObjects()), List<Event>.class);
    }

    public Event getEvent(Integer index)
    {
        return (Event) super.get(index);
    }

    public List<Event> getChangedEvents()
    {
        return (List<Event>) JSON.deserialize(JSON.serialize(super.getChangedObjects()), List<Event>.class);
    }

    public RecordTypeList getRecordTypes()
    {
        if(eventRecordTypes == null)
        {
            loadRecordTypes();
        }

        return eventRecordTypes;
    }

    public void loadRecordTypes()
    {
        if(eventRecordTypes == null)
        {
            List<Id> recordTypeIds = (List<Id>) JSON.deserialize(JSON.serialize(getFieldValues('RecordTypeId')), List<Id>.class);

            Map<Id, RecordType> recordTypes = new Map<Id, RecordType>([
                SELECT DeveloperName
                FROM RecordType
                WHERE Id IN :recordTypeIds
            ]);

            if(recordTypes.size() > 0)
            {
                Map<Integer, RecordType> rtsByEventIndex = new Map<Integer, RecordType>();
                for (Integer x : getAllIndices())
                {
                    Event e = getEvent(x);
                    rtsByEventIndex.put(x, recordTypes.get(e.RecordTypeId));
                }

                eventRecordTypes = new RecordTypeList(rtsByEventIndex.values());
                eventRecordTypes.setChildren(this, 'RecordTypeId');
            }
            else
            {
                eventRecordTypes = new RecordTypeList(new List<RecordType>());
            }
        }
    }

    public void closesCallEvents()
    {
        for(Integer x : getAllIndices())
        {
            Event ev = getEvent(x);
            ev.StartDate = null;
            ev.EndDate = null;
            put(x, ev);
        }
    }
}