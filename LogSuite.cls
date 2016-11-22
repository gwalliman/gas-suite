public class LogSuite 
{
    private static Set<String> activeLogTypes = new Set<String>();
    private static Boolean loadedCustomSettings = false;
    private static String testflowName = '';

    public static Set<String> getActiveLogTypes()
    {
        if(!loadedCustomSettings)
        {
            populateActiveLogtypesCustomSetting();
        }
        
        return activeLogTypes;
    }

    public static void populateActiveLogtypesCustomSetting()
    {
        List<LogSuite__c> logsuite = [
            SELECT Active__c, Name
            FROM LogSuite__c
        ];

        for(LogSuite__c l : logsuite)
        {
            if(l.Active__c)
            {
                activateLogType(l.Name);
            }
        }

        loadedCustomSettings = true;
    }

    public static void activateLogType(String logType)
    {
        activeLogTypes.add(logType.toLowerCase());
    }

    public static void deactivateLogType(String logType)
    {
        activeLogTypes.remove(logType.toLowerCase());
    }

    public static void deactivateAllLogTypes()
    {
        activeLogTypes = new Set<String>();
    }

    public static void activateLogSuite(String logSuite)
    {
        if(logSuite == 'testflow')
        {
            activateLogType('DML');
            activateLogType('codeflow');
            activateLogType('query');
            activateLogType('testname');
            activateLogType('runstats');
        }        
    }

    public static void activateTestFlowSuite(String testname)
    {
        testflowName = testname;
        activateLogSuite('testflow');
        log('testname', 'Starting test ' + testflowName);
    }

    public static void deactivateTestFlowSuite()
    {
        log('testname', 'Finishing test ' + testflowName);
        testflowName = '';
        deactivateAllLogTypes();
    }

    public static Boolean logTypeIsActive(String logType)
    {
        if(!loadedCustomSettings)
        {
            populateActiveLogtypesCustomSetting();
        }

        if(activeLogTypes.contains(logType.toLowerCase()))
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    public static void log(String logType, String message)
    {
        if(logTypeIsActive(logType))
        {
            System.debug(LoggingLevel.WARN, 'LOGSUITE: ' + logType.toUppercase() + ' - ' + message);
        }
    }

    public static void log(String logType, Object message)
    {
        if(logTypeIsActive(logType))
        {
            System.debug(LoggingLevel.WARN, 'LOGSUITE: ' + logType.toUppercase() + ' - ' + message);
        }
    }
}