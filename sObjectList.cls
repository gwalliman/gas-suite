public virtual class sObjectList
{
    private String uuid;
    private Map<Integer, sObject> objMap = new Map<Integer, sObject>();
    private sObjectList parentsObjectList;
    private Map<Integer, Integer> parentIndicesByChildIndex = new Map<Integer, Integer>();
    private sObjectList childsObjectList;
    private Map<Integer, Integer> childIndicesByParentIndex = new Map<Integer, Integer>();
    private sObjectList supersetsObjectList;
    private Set<Integer> changedIndices = new Set<Integer>();

    public sObjectList()
    {
        this.uuid = generateUUID();
        this.objMap = new Map<Integer, sObject>();
    }

    public sObjectList(List<sObject> objList)
    {
        this.uuid = generateUUID();
        this.objMap = new Map<Integer, sObject>();
        for(Integer x = 0; x < objList.size(); x++)
        {
            this.objMap.put(x, objList.get(x));
        }
    }

    public sObjectList(Map<Id, sObject> objMap)
    {
        this.uuid = generateUUID();
        this.objMap = new Map<Integer, sObject>();
        List<sObject> objList = objMap.values();
        for(Integer x = 0; x < objList.size(); x++)
        {
            this.objMap.put(x, objList.get(x));
        }
    }

    public sObjectList(Map<Integer, sObject> objMap)
    {
        this.uuid = generateUUID();
        this.objMap = new Map<Integer, sObject>();

        for(Integer x : objMap.keySet())
        {
            this.objMap.put(x, objMap.get(x));
        }
    }

    public sObjectList(Set<sObject> objSet)
    {
        this.uuid = generateUUID();
        this.objMap = new Map<Integer, sObject>();
        Integer x = 0;
        for(sObject obj : objSet)
        {
            this.objMap.put(x, obj);
            x++;
        }
    }

    public sObjectList(sObjectList oldsObjectList)
    {
        if(oldsObjectList != null)
        {
            this.uuid = generateUUID();
            this.objMap = new Map<Integer, sObject>();

            Set<Integer> oldIndices = oldsObjectList.getAllIndices();
            for(Integer x : oldIndices)
            {
                this.objMap.put(x, oldsObjectList.get(x));
            }

            setChangedIndices(oldsObjectList.getChangedIndices());
            setSuperset(oldsObjectList.getSuperset());
            setParents(oldsObjectList.getParents(), oldsObjectList.getParentToChildIndices());
            setChildren(oldsObjectList.getChildren(), oldsObjectList.getChildToParentIndices());
        }
    }

    public virtual sObject get(Integer index)
    {
        return objMap.get(index);
    }

    public void put(Integer index, sObject obj)
    {
        objMap.put(index, obj);
        changedIndices.add(index);

        if(supersetsObjectList != null)
        {
            supersetsObjectList.put(index, obj);
            changedIndices.add(index);
        }
    }

    public Integer size()
    {
        return objMap.size();
    }

    public virtual List<sObject> getAllObjects()
    {
        return objmap.values();
    }

    public void setObjMap(Map<Integer, sObject> objMap)
    {
        this.objMap = objMap;
    }

    public virtual List<sObject> getChangedObjects()
    {
        List<sObject> changedObjects = new List<sObject>();
        for(Integer x : changedIndices)
        {
            changedObjects.add(objMap.get(x));
        }

        return changedObjects;
    }

    public Set<Integer> getAllIndices()
    {
        return objMap.keySet().clone();
    }

    public Set<Integer> getChangedIndices()
    {
        return changedIndices.clone();
    }

    public Integer getParentIndexFromChildIndex(Integer x)
    {
        return parentIndicesByChildIndex.get(x);
    }

    public Map<Integer, Integer> getParentToChildIndices()
    {
        return this.parentIndicesByChildIndex.clone();
    }

    public void setParentToChildIndices(Map<Integer, Integer> parentIndicesByChildIndex)
    {
        this.parentIndicesByChildIndex = parentIndicesByChildIndex;
    }

    public Integer getChildIndexFromParentIndex(Integer x)
    {
        return childIndicesByParentIndex.get(x);
    }

    public Map<Integer, Integer> getChildToParentIndices()
    {
        return this.childIndicesByParentIndex.clone();
    }

    public void setChildToParentIndices(Map<Integer, Integer> childIndicesByParentIndex)
    {
        this.childIndicesByParentIndex = childIndicesByParentIndex;
    }

    public void setChangedIndices(Set<Integer> changedIndices)
    {
        this.changedIndices = changedIndices;
    }

    public virtual sObjectList getSuperset()
    {
        return this.supersetsObjectList;
    }

    public void setSuperset(sObjectList superset)
    {
        this.supersetsObjectList = superset;
    }

    public sObjectList getParents()
    {
        return this.parentsObjectList;
    }

    public sObject getParentFromChildIndex(Integer x)
    {
        return parentsObjectList.get(parentIndicesByChildIndex.get(x));
    }

    public sObjectList getChildren()
    {
        return this.childsObjectList;
    }

    public sObject getChildFromParentIndex(Integer x)
    {
        return childsObjectList.get(childIndicesByParentIndex.get(x));
    }

    public void setParents(sObjectList parentsObjectList, Map<Integer, Integer> parentIndicesByChildIndex)
    {
        this.parentsObjectList = parentsObjectList;
        this.parentIndicesByChildIndex = parentIndicesByChildIndex;
    }

    public void setChildren(sObjectList childsObjectList, Map<Integer, Integer> childIndicesByParentIndex)
    {
        this.childsObjectList = childsObjectList;
        this.childIndicesByParentIndex = childIndicesByParentIndex;
    }

    public void setParents(sObjectList parentsObjects, String parentIdField)
    {
        //this.parentsObjectList = parentsObjects;
        if(parentsObjects.size() > 0 && this.size() > 0)
        {
            this.parentsObjectList = 
                parentsObjects
                .getSubset()
                .whereMyField('Id')
                .equalsSet(this.getFieldValues(parentIdField))
                .execute();

            for(Integer y : parentsObjectList.getAllIndices())
            {
                sObject parent = parentsObjectList.get(y);
                  
                for(Integer x : objMap.keySet())
                {
                    sObject child = objMap.get(x);
                    Id childsParentId = (Id) child.get(parentIdField);

                    if(parent.get('Id') == childsParentId)
                    {
                        this.parentIndicesByChildIndex.put(x, y);
                    }
                }
            }
        }
    }

    public void setChildren(sObjectList childsObjects, String childsParentIdField)
    {
        if(childsObjects.size() > 0 && this.size() > 0)
        {
            this.childsObjectList = 
               childsObjects 
                .getSubset()
                .whereMyField(childsParentIdField)
                .equalsSet(this.getFieldValues('Id'))
                .execute();

            for(Integer y : childsObjectList.getAllIndices())
            {
                sObject child = childsObjectList.get(y);
                  
                for(Integer x : objMap.keySet())
                {
                    sObject parent = objMap.get(x);
                    Id parentId = (Id) parent.get('Id');

                    if(child.get(childsParentIdField) == parentId)
                    {
                        this.childIndicesByParentIndex.put(x, y);
                    }
                }
            }
        }
    }

    public void insertChanged()
    {
        insert getChangedObjects();
    }

    public void updateChanged()
    {
        update getChangedObjects();
    }

    public void deleteAll()
    {
        delete getAllObjects();
    }

    public Set<Object> getFieldValues(String fieldName)
    {
        Set<Object> values = new Set<Object>();
        for(sObject obj : objMap.values())
        {
            values.add(obj.get(fieldName));
        }

        return values;
    }

    public Set<Integer> getInverseIndices(Set<Integer> indicesToInvert)
    {
        Set<Integer> indices = getAllIndices();
        indices.removeAll(indicesToInvert);
        return indices.clone();
    }

    public sObjectListSubsetFactory getSubset()
    {
        return new sObjectListSubsetFactory(this);
    }

    public sObjectList getSubset(Set<Integer> indicesToKeep)
    {
        sObjectList subset = this.clone();
        subset.setUUID(generateUUID());

        subset.setSuperset(this);

        Map<Integer, sObject> newObjMap = new Map<Integer, sObject>();
        for(Integer x : indicesToKeep)
        {
            newObjMap.put(x, subset.get(x));
        }
        subset.setObjMap(newObjMap);

        Set<Integer> changedIndices = subset.getChangedIndices();
        for(Integer x : changedIndices)
        {
            if(!indicesToKeep.contains(x))
            {
                objMap.remove(x);
                changedIndices.remove(x);
            }
        }
        subset.setChangedIndices(changedIndices);

        if(subset.getParents() != null)
        {
            Map<Integer, Integer> parentToChildIndices = subset.getParentToChildIndices();

            Set<Integer> parentIndicesToKeep = new Set<Integer>();
            for(Integer x : parentToChildIndices.keySet())
            {
                if(!indicesToKeep.contains(x))
                {
                    parentToChildIndices.remove(x);
                }
                else
                {
                    parentIndicesToKeep.add(parentToChildIndices.get(x)); 
                }
            }

            subset.setParents(subset.getParents().getSubset(parentIndicesToKeep), parentToChildIndices);
        }

        return subset;
    }

    //http://salesforce.stackexchange.com/questions/4073/how-to-generate-a-guid-uuid
    public String generateUUID()
    {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return guid;
    }

    public String getUUID()
    {
        return this.uuid;
    }

    public void setUUID(String uuid)
    {
        this.uuid = uuid;
    }

    public sObjectList getSupersetChildsObjects(sObjectList supersetChildsObjects, String childObjectIdField)
    {
        return supersetChildsObjects
            .getSubset()
            .compareToParents()
            .whereMyField(childObjectIdField)
            .equalsTheirField('Id')
            .execute();
    }
}