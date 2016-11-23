public virtual class GASTriggerServices 
{
    protected sObjectList newObjects;
    protected sObjectList oldObjects;

    public GASTriggerServices(Type type)
    {
        if(hasTriggerNew())
        {
            this.newObjects = new sObjectList(Trigger.new);
        }

        if(hasTriggerOld())
        {
            this.oldObjects = new sObjectList(Trigger.old);
        }

        if(!hasTriggerNew())
        {
            List<sObject> newObjs = new List<sObject>();
            for(Integer x = 0; x < this.oldObjects.getAllIndices().size(); x++)
            {
                newObjs.add((sObject) type.newInstance());
            }
            this.newObjects = new sObjectList(newObjs);
        }

        if(!hasTriggerOld())
        {
            List<sObject> oldObjs = new List<sObject>();
            for(Integer x = 0; x < this.newObjects.getAllIndices().size(); x++)
            {
                oldObjs.add((sObject) type.newInstance());
            }
            this.oldObjects = new sObjectList(oldObjs);
        }
    }

    public static boolean hasTriggerNew()
    {
        return isInsertOrUpdate();
    }

    public static boolean hasTriggerOld()
    {
        return isUpdateOrDelete();
    }

    public static boolean isInsertOrUpdate()
    {
        Boolean isInsert = Trigger.isInsert != null ? Trigger.isInsert : false;
        Boolean isUpdate = Trigger.isUpdate != null ? Trigger.isUpdate : false;

        return isInsert || isUpdate;
    }

    public static boolean isUpdateOrDelete()
    {
        Boolean isUpdate = Trigger.isUpdate != null ? Trigger.isUpdate : false;
        Boolean isDelete = Trigger.isDelete != null ? Trigger.isDelete : false;

        return isUpdate || isDelete;
    }

    public static boolean isInsert()
    {
        return Trigger.isInsert != null ? Trigger.isInsert : false;
    }

    public static boolean isUpdate()
    {
        return Trigger.isUpdate != null ? Trigger.isUpdate : false;
    }

    public static boolean isDelete()
    {
        return Trigger.isDelete != null ? Trigger.isDelete : false;
    }

    public static void syncFieldOnObject(String fromFieldName, String toFieldName)
    {
        for(Integer x = 0; x < Trigger.new.size(); x++)
        {
            sObject newObj = Trigger.new.get(x);
            Object fromFieldValue = (String) newObj.get(fromFieldName);
            Object toFieldValue = (String) newObj.get(toFieldName);

            if(fromFieldValue != toFieldValue)
            {
                newObj.put(toFieldName, fromFieldValue);
            }
        }   
    }

    public static Map<Id, sObject> recordValueOnFieldChange(List<sObject> newObjs, List<sObject> oldObjs, List<GASTriggerServices.GASFieldMapping> configs)
    {
        Map<Id, sObject> updatedObjects = new Map<Id, sObject>();

        for(Integer x = 0; x < newObjs.size(); x++)
        {
            sObject newObj = newObjs.get(x);

            for(GASTriggerServices.GASFieldMapping config : configs)
            {
                String changedFieldName = config.changedFieldName;
                Object changedFieldValue = config.changedFieldValue;
                Boolean checkAgainstFieldValue = config.checkAgainstFieldValue;
                Object actualFieldValue = newObj.get(changedFieldName);

                if(
                    (
                        oldObjs == null &&
                        actualFieldValue != null &&
                        actualFieldValue != '' &&
                        actualFieldValue != false 
                    ) ||
                    (
                        oldObjs != null &&
                        newObj.get(changedFieldName) != oldObjs.get(x).get(changedFieldName) &&
                        (
                            !checkAgainstFieldValue ||
                            newObj.get(changedFieldName) == changedFieldValue
                        )
                    )
                )
                {
                    Map<String, String> mappings = config.fieldsToUpdateMappings;
                    for(String fieldName : mappings.keySet())
                    {
                        String fieldType = mappings.get(fieldName);
                        Boolean changed = false;
                        if(fieldType.toLowerCase() == 'fullname')
                        {
                            newObj.put(fieldName, UserInfo.getFirstName() + ' ' + UserInfo.getLastName());
                            changed = true;
                        }
                        else if(fieldType.toLowerCase() == 'date')
                        {
                            newObj.put(fieldName, Date.today());
                            changed = true;
                        }
                        else if(fieldType.toLowerCase() == 'datetime')
                        {
                            newObj.put(fieldName, Datetime.now());
                            changed = true;
                        }
                        else if(fieldType.toLowerCase() == 'null')
                        {
                            newObj.put(fieldName, null);
                            changed = true;
                        }
                        else if(fieldType.toLowerCase() == 'true')
                        {
                            newObj.put(fieldName, true);
                            changed = true;
                        }
                        else if(fieldType.toLowerCase() == 'false')
                        {
                            newObj.put(fieldName, false);
                            changed = true;
                        }

                        if(changed && newObj.Id != null)
                        {
                            updatedObjects.put(newObj.Id, newObj);
                        }
                    }
                }
            }
        }

        return updatedObjects;
    }

    public class GASFieldMapping 
    {
        public String changedFieldName;
        public Object changedFieldValue;
        public Boolean checkAgainstFieldValue;
        public Map<String, String> fieldsToUpdateMappings;

        public GASFieldMapping(String changedFieldName, Object changedFieldValue, Boolean checkAgainstFieldValue, Map<String, String> fieldsToUpdateMappings)
        {
            this.changedFieldName = changedFieldName;
            this.changedFieldValue = changedFieldValue;
            this.checkAgainstFieldValue = checkAgainstFieldValue;
            this.fieldsToUpdateMappings = fieldsToUpdateMappings;
        }
    }
}