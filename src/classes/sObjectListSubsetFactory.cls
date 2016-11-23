public class sObjectListSubsetFactory
{
    private Integer EQUALS_ONE = 0;
    private Integer NOT_EQUALS_ANY = 1;

    private sObjectList myList;
    private sObjectList theirList;
    private String myField;
    private String myField2;
    private String theirField;
    private Integer comparison;
    private Set<Object> compareValues = new Set<Object>();

    public sObjectListSubsetFactory(sObjectList myList)
    {
        this.myList = myList;
    }

    public sObjectListSubsetFactory whereMyField(String myField)
    {
        this.myField = myField;
        return this;
    }

    public sObjectListSubsetFactory compareTo(sObjectList theirList)
    {
        this.theirList = theirList;
        return this;
    }

    public sObjectListSubsetFactory compareToParents()
    {
        List<sObject> parentsList = new List<sObject>();
        for(Integer x : myList.getAllIndices())
        {
            Integer parentIndex = myList.getParentIndexFromChildIndex(x);
            parentsList.add(myList.getParents().get(parentIndex));
        }

        this.theirList = new sObjectList(parentsList);
        return this;
    }

    public sObjectListSubsetFactory equals(Object value)
    {
        this.compareValues.add(value);
        return this.compareEquals();
    }

    public sObjectListSubsetFactory notEquals(Object value)
    {
        this.compareValues.add(value);
        return this.compareNotEquals();
    }

    public sObjectListSubsetFactory equalsSet(Set<Object> values)
    {
        this.compareValues.addAll(values);
        return this.compareEquals();
    }

    public sObjectListSubsetFactory notEqualsSet(Set<Object> values)
    {
        this.compareValues.addAll(values);
        return this.compareNotEquals();
    }

    public sObjectListSubsetFactory equalsMyField(String myField2)
    {
        this.myField2 = myField2;
        return this.compareEquals();
    }

    public sObjectListSubsetFactory notEqualsMyField(String myField2)
    {
        this.myField2 = myField2;
        return this.compareNotEquals();
    }

    public sObjectListSubsetFactory isEmpty()
    {
        this.compareValues.add(null);
        this.compareValues.add('');
        return this.compareEquals();
    }

    public sObjectListSubsetFactory notEmpty()
    {
        this.compareValues.add(null);
        this.compareValues.add('');
        return this.compareNotEquals();
    }

    public sObjectListSubsetFactory equalsTheirField(String theirField)
    {
        this.theirField = theirField;
        return this.compareEquals();
    }

    public sObjectListSubsetFactory notEqualsTheirField(String theirField)
    {
        this.theirField = theirField;
        return this.compareNotEquals();
    }

    public sObjectList execute()
    {
        if(myList.size() == 0)
        {
            return myList;
        }

         /**
          * 1. Check whether we have a "otherList". If so, compare to them. If not, compare to ourselves
          * 2. Check that we have "myValue" and "theirValue"
          * 3. If all works, run the comparison and return the subset
          *
          */

         /**
          * Possibilities:
          * - Compare one of my fields to values
          * - Compare two of my fields to one another
          * - Compare two fields from two different lists
          */

        Set<Integer> myIndices = myList.getAllIndices();

        Map<Integer, Object> myValues = new Map<Integer, Object>();
        List<List<Object>> valuesToCompare = new List<List<Object>>();

        for(Integer x : myIndices)
        {
            sObject obj = myList.get(x);
            myValues.put(x, obj.get(myField));
        }

        if(compareValues.size() > 0)
        {
            for(Integer x : myIndices)
            {
                valuesToCompare.add(new List<Object>(compareValues));
            }
        }
        else if(myField2 != null)
        {
            for(Integer x : myIndices)
            {
                sObject obj = myList.get(x);
                List<Object> valuesToCompareList = new List<Object>{obj.get(myField2)};
                valuesToCompare.add(valuesToCompareList);
            }
        }
        else if(theirList != null && theirField != null && theirList.size() == myList.size())
        {
            Set<Integer> theirIndices = theirList.getAllIndices();
            for(Integer x : theirIndices)
            {
                sObject theirObj = theirList.get(x);
                List<Object> valuesToCompareList = new List<Object>{theirObj.get(theirField)};
                valuesToCompare.add(valuesToCompareList);
            }
        }
        else
        {
            //TODO: throw error - this was not configured right
        }

        //Map<Integer, sObject> sObjectsToKeep = new Map<Integer, sObject>();
        Set<Integer> indicesToKeep = new Set<Integer>();
        for(Integer x : myIndices)
        {
            Object myValue = myValues.get(x);
            List<Object> valuesToCompareList = valuesToCompare.get(0);
            Object matchedValue = null;
            Boolean matchedNull = false;

            for(Object vc : valuesToCompareList)
            {
                if(myvalue == vc)
                {
                    matchedValue = myValue;
                    if(matchedValue == null)
                    {
                        matchedNull = true;
                    }
                }
            }

            if(
                (comparison == EQUALS_ONE && (matchedValue != null || matchedNull == true))
                || (comparison == NOT_EQUALS_ANY && (matchedValue == null && matchedNull == false))
            )
            {
                //sObjectsToKeep.put(x, myList.get(x));
                indicesToKeep.add(x);
            }

            valuesToCompare.remove(0);
        }

        /*sObjectList sObjectListToKeep = new sObjectList(sObjectsToKeep);
        sObjectListToKeep.setSuperset(myList);

        Set<Integer> changedIndices = myList.getChangedIndices();
        for(Integer x : changedIndices)
        {
            if(!sObjectsToKeep.keySet().contains(x))
            {
                changedIndices.remove(x);
            }
        }
        sObjectListToKeep.setChangedIndices(changedIndices);

        Map<Integer, Integer> parentToChildIndices = myList.getParentToChildIndices();
        for(Integer x : parentToChildIndices.keySet())
        {
            if(!sObjectsToKeep.keySet().contains(x))
            {
                parentToChildIndices.remove(x);
            }
        }
        sObjectListToKeep.setParents(myList.getParents(), parentToChildIndices);

        return sObjectListToKeep;*/

        return myList.getSubset(indicesToKeep);
    }

    private sObjectListSubsetFactory compareEquals()
    {
        this.comparison = EQUALS_ONE;
        return this;
    }

    private sObjectListSubsetFactory compareNotEquals()
    {
        this.comparison = NOT_EQUALS_ANY;
        return this;
    }
}