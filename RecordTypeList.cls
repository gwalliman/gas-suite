public class RecordTypeList extends sObjectList
{
    public RecordTypeList(List<sObject> recordTypeList)
    {
        super(recordTypeList);
    }

	public RecordTypeList(sObjectList recordTypeList)
    {
        super(recordTypeList);
    }

    public List<RecordType> getRecordTypes()
	{
		return (List<RecordType>) JSON.deserialize(JSON.serialize(super.getAllObjects()), List<RecordType>.class);
	}

	public RecordType getRecordType(Integer index)
	{
		return (RecordType) super.get(index);
	}

	public List<RecordType> getChangedRecordTypes()
	{
		return (List<RecordType>) JSON.deserialize(JSON.serialize(super.getChangedObjects()), List<RecordType>.class);
	}
}