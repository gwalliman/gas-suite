public class GASTriggerFactory
{
    public static void createAndExecuteHandler(Type t)
    {
        // Get a handler appropriate to the object being processed
        IGASTrigger handlerClass = getHandler(t);

        // Make sure we have a handler registered, new handlers must be registered in the getHandler method.
        if(handlerClass == null)
        {
            throw new GASTriggerException('No Trigger Handler found named: ' + t.getName());
        }

        execute(t, handlerClass);
    }

    private static void execute(Type t, IGasTrigger handler)
    {
        LogSuite.log('GASTriggerFactory', '-----------------------------');
        LogSuite.log('GASTriggerFactory', 'STARTING PLAN ACTION FOR ' + t);
        LogSuite.log('GASTriggerFactory', '-----------------------------');
        handler.planAction();
        LogSuite.log('GASTriggerFactory', '-----------------------------');
        LogSuite.log('GASTriggerFactory', 'CONCLUDING PLAN ACTION FOR ' + t);
        LogSuite.log('GASTriggerFactory', '-----------------------------');
        LogSuite.log('GASTriggerFactory', 'STARTING RUN SERVICE FOR ' + t);
        LogSuite.log('GASTriggerFactory', '-----------------------------');
        handler.runServices();
        LogSuite.log('GASTriggerFactory', '-----------------------------');
        LogSuite.log('GASTriggerFactory', 'CONCLUDING RUN SERVICE FOR ' + t);
        LogSuite.log('GASTriggerFactory', '-----------------------------');
        LogSuite.log('GASTriggerFactory', 'STARTING COMMIT CHANGES FOR ' + t);
        LogSuite.log('GASTriggerFactory', '-----------------------------');
        handler.commitChanges();
        LogSuite.log('GASTriggerFactory', '-----------------------------');
        LogSuite.log('GASTriggerFactory', 'CONCLUDING COMMIT CHANGES FOR ' + t);
        LogSuite.log('GASTriggerFactory', '-----------------------------');
    }

    private static IGASTrigger getHandler(Type t)
    {
        Object o = t.newInstance();

        if(!(o instanceOf IGASTrigger))
        {
            return null;
        }

        return (IGASTrigger) o;
    }

    public class GASTriggerException extends Exception {}
}