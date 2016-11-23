trigger AccountTrigger on Account (after delete, after insert, after update, before delete, before insert, before update) 
{
    if(Trigger.isBefore)
    {
        GASTriggerFactory.createAndExecuteHandler(AccountTriggerHandler.Before.class);
    }
    else if(Trigger.isAfter)
    {
        GASTriggerFactory.createAndExecuteHandler(AccountTriggerHandler.After.class);
    }
}