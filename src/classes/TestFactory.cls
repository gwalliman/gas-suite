public class TestFactory 
{
    public static void createAndExecuteTest(Type type)
    {
        LogSuite.activateLogType('TestFactory');
        LogSuite.activateLogType('GASTriggerFactory');
        LogSuite.activateLogType('GASAccountHandler');
        LogSuite.activateLogType('AccountTests');
        // Get a handler appropriate to the object being processed
        ITest test = getHandler(type);
         
        // Make sure we have a handler registered, new handlers must be registered in the getHandler method.
        if (test == null)
        {
            throw new TestException('No Test class found named: ' + type.getName());
        }
         
        // Execute the handler to fulfil the trigger
        LogSuite.log('TestFactory', '==========================================');
        LogSuite.log('TestFactory', 'STARTING TEST: ' + type);
        execute(type, test);
        LogSuite.log('TestFactory', 'COMPLETING TEST: ' + type);
        LogSuite.log('TestFactory', '==========================================');
        LogSuite.deactivateLogType('TestFactory');
        LogSuite.deactivateLogType('GASTriggerFactory');
        LogSuite.deactivateLogType('GASAccountHandler');
        LogSuite.deactivateLogType('AccountTests');
    }
    
    private static void execute(Type type, ITest t)
    {
        List<List<Integer>> testStatistics = new List<List<Integer>>();

        Integer preSetupTestCPUTime = Limits.getCPUTime();
        Integer preSetupTestDMLStmts = Limits.getDMLStatements();
        Integer preSetupTestFutureCalls = Limits.getFutureCalls();
        Integer preSetupTestSoqlQueries = Limits.getQueries();
        Integer preSetupTestSoslQueries = Limits.getSoslQueries();
        testStatistics.add(new List<Integer>{
            preSetupTestCPUTime, 
            preSetupTestDMLStmts, 
            preSetupTestFutureCalls,
            preSetupTestSoqlQueries,
            preSetupTestSoslQueries
        });

        LogSuite.log('TestFactory', '----------------------------------------------------');
        LogSuite.log('TestFactory', 'RUNNING SETUP TEST FOR: ' + type);
        LogSuite.log('TestFactory', '----------------------------------------------------');
        t.setupTest();
        LogSuite.log('TestFactory', '----------------------------------------------------');
        LogSuite.log('TestFactory', 'CONCLUDING SETUP TEST FOR: ' + type);
        LogSuite.log('TestFactory', '----------------------------------------------------');

        Integer postSetupTestCPUTime = Limits.getCPUTime();
        Integer postSetupTestDMLStmts = Limits.getDMLStatements();
        Integer postSetupTestFutureCalls = Limits.getFutureCalls();
        Integer postSetupTestSoqlQueries = Limits.getQueries();
        Integer postSetupTestSoslQueries = Limits.getSoslQueries();
        testStatistics.add(new List<Integer>{
            postSetupTestCPUTime, 
            postSetupTestDMLStmts, 
            postSetupTestFutureCalls,
            postSetupTestSoqlQueries,
            postSetupTestSoslQueries
        });
        
        Test.startTest();

        Integer preTestCPUTime = Limits.getCPUTime();
        Integer preTestDMLStmts = Limits.getDMLStatements();
        Integer preTestFutureCalls = Limits.getFutureCalls();
        Integer preTestSoqlQueries = Limits.getQueries();
        Integer preTestSoslQueries = Limits.getSoslQueries();
        testStatistics.add(new List<Integer>{
            preTestCPUTime, 
            preTestDMLStmts, 
            preTestFutureCalls,
            preTestSoqlQueries,
            preTestSoslQueries
        });

        LogSuite.log('TestFactory', '----------------------------------------------------');
        LogSuite.log('TestFactory', 'RUNNING TEST FOR: ' + type);
        LogSuite.log('TestFactory', '----------------------------------------------------');
        t.runTest();
        LogSuite.log('TestFactory', '----------------------------------------------------');
        LogSuite.log('TestFactory', 'CONCLUDING TEST FOR: ' + type);
        LogSuite.log('TestFactory', '----------------------------------------------------');

        Integer postTestCPUTime = Limits.getCPUTime();
        Integer postTestDMLStmts = Limits.getDMLStatements();
        Integer postTestFutureCalls = Limits.getFutureCalls();
        Integer postTestSoqlQueries = Limits.getQueries();
        Integer postTestSoslQueries = Limits.getSoslQueries();
        testStatistics.add(new List<Integer>{
            postTestCPUTime, 
            postTestDMLStmts, 
            postTestFutureCalls,
            postTestSoqlQueries,
            postTestSoslQueries
        });

        Test.stopTest();

        Integer prePostTestCPUTime = Limits.getCPUTime();
        Integer prePostTestDMLStmts = Limits.getDMLStatements();
        Integer prePostTestFutureCalls = Limits.getFutureCalls();
        Integer prePostTestSoqlQueries = Limits.getQueries();
        Integer prePostTestSoslQueries = Limits.getSoslQueries();
        testStatistics.add(new List<Integer>{
            prePostTestCPUTime, 
            prePostTestDMLStmts, 
            prePostTestFutureCalls,
            prePostTestSoqlQueries,
            prePostTestSoslQueries
        });

        LogSuite.log('TestFactory', '----------------------------------------------------');
        LogSuite.log('TestFactory', 'RUNNING POST TEST FOR: ' + type);
        LogSuite.log('TestFactory', '----------------------------------------------------');
        t.postTest();
        LogSuite.log('TestFactory', '----------------------------------------------------');
        LogSuite.log('TestFactory', 'CONCLUDING POST TEST FOR: ' + type);
        LogSuite.log('TestFactory', '----------------------------------------------------');

        Integer postPostTestCPUTime = Limits.getCPUTime();
        Integer postPostTestDMLStmts = Limits.getDMLStatements();
        Integer postPostTestFutureCalls = Limits.getFutureCalls();
        Integer postPostTestSoqlQueries = Limits.getQueries();
        Integer postPostTestSoslQueries = Limits.getSoslQueries();
        testStatistics.add(new List<Integer>{
            postPostTestCPUTime, 
            postPostTestDMLStmts, 
            postPostTestFutureCalls,
            postPostTestSoqlQueries,
            postPostTestSoslQueries
        });

        calculateAndSaveTestStatistics(type, t, testStatistics);
    }

    private static void calculateAndSaveTestStatistics(Type type, ITest t, List<List<Integer>> stats)
    {
        SF_Test_Statistics__c statsObj = new SF_Test_Statistics__c();

        statsObj.Name = String.valueOf(Datetime.now().getTime());
        statsObj.Test_Name__c = type.getName();
        statsObj.Test_Human_Name__c = t.getTestHumanName();
        statsObj.Test_Description__c = t.getTestDescription();
        
        statsObj.Setup_CPU_Time_Elapsed__c = stats[1][0] - stats[0][0];
        statsObj.Setup_DML_Statements_Made__c = stats[1][1] - stats[0][1];
        statsObj.Setup_Future_Calls_Made__c = stats[1][2] - stats[0][2];
        statsObj.Setup_SOQL_Queries_Made__c = stats[1][3] - stats[0][3];
        statsObj.Setup_SOSL_Queries_Made__c = stats[1][4] - stats[0][4];

        statsObj.Test_CPU_Time_Elapsed__c = stats[3][0] - stats[2][0];
        statsObj.Test_DML_Statements_Made__c = stats[3][1] - stats[2][1];
        statsObj.Test_Future_Calls_Made__c = stats[3][2] - stats[2][2];
        statsObj.Test_SOQL_Queries_Made__c = stats[3][3] - stats[2][3];
        statsObj.Test_SOSL_Queries_Made__c = stats[3][4] - stats[2][4];

        statsObj.Post_Test_CPU_Time_Elapsed__c = stats[5][0] - stats[4][0];
        statsObj.Post_Test_DML_Statements_Made__c = stats[5][1] - stats[4][1];
        statsObj.Post_Test_Future_Calls_Made__c = stats[5][2] - stats[4][2];
        statsObj.Post_Test_SOQL_Queries_Made__c = stats[5][3] - stats[4][3];
        statsObj.Post_Test_SOSL_Queries_Made__c = stats[5][4] - stats[4][4];

        statsObj.Outside_Test_CPU_Time_Elapsed__c = statsObj.Setup_CPU_Time_Elapsed__c + statsObj.Post_Test_CPU_Time_Elapsed__c;
        statsObj.Outside_Test_DML_Statements_Made__c = statsObj.Setup_DML_Statements_Made__c + statsObj.Post_Test_DML_Statements_Made__c;
        statsObj.Outside_Test_Future_Calls_Made__c = statsObj.Setup_Future_Calls_Made__c + statsObj.Post_Test_Future_Calls_Made__c;
        statsObj.Outside_Test_SOQL_Queries_Made__c = statsObj.Setup_SOQL_Queries_Made__c + statsObj.Post_Test_SOQL_Queries_Made__c;
        statsObj.Outside_Test_SOSL_Queries_Made__c = statsObj.Setup_SOSL_Queries_Made__c + statsObj.Post_Test_SOSL_Queries_Made__c;

        statsObj.Total_CPU_Time_Elapsed__c = statsObj.Setup_CPU_Time_Elapsed__c + statsObj.Test_CPU_Time_Elapsed__c + statsObj.Post_Test_CPU_Time_Elapsed__c;

        //TEMPOARY DEBUGS (HOPEFULLY TEMPORARY)
        LogSuite.log('TestFactory', 'Unique Name: ' + String.valueOf(Datetime.now().getTime()));
        LogSuite.log('TestFactory', 'Test_Name__c: ' + type.getName());
        LogSuite.log('TestFactory', 'Test_Human_Name__c: ' + t.getTestHumanName());
        LogSuite.log('TestFactory', 'Test_Description__c: ' + t.getTestDescription());
        LogSuite.log('TestFactory', 'Setup_CPU_Time_Elapsed__c: ' + (stats[1][0] - stats[0][0]));
        LogSuite.log('TestFactory', 'Setup_DML_Statements_Made__c: ' + (stats[1][1] - stats[0][1]));
        LogSuite.log('TestFactory', 'Setup_Future_Calls_Made__c: ' + (stats[1][2] - stats[0][2]));
        LogSuite.log('TestFactory', 'Setup_SOQL_Queries_Made__c: ' + (stats[1][3] - stats[0][3]));
        LogSuite.log('TestFactory', 'Setup_SOSL_Queries_Made__c: ' + (stats[1][4] - stats[0][4]));
        LogSuite.log('TestFactory', 'Test_CPU_Time_Elapsed__c: ' + (stats[3][0] - stats[2][0]));
        LogSuite.log('TestFactory', 'Test_DML_Statements_Made__c: ' + (stats[3][1] - stats[2][1]));
        LogSuite.log('TestFactory', 'Test_Future_Calls_Made__c: ' + (stats[3][2] - stats[2][2]));
        LogSuite.log('TestFactory', 'Test_SOQL_Queries_Made__c: ' + (stats[3][3] - stats[2][3]));
        LogSuite.log('TestFactory', 'Test_SOSL_Queries_Made__c: ' + (stats[3][4] - stats[2][4]));
        LogSuite.log('TestFactory', 'Post_Test_CPU_Time_Elapsed__c: ' + (stats[5][0] - stats[4][0]));
        LogSuite.log('TestFactory', 'Post_Test_DML_Statements_Made__c: ' + (stats[5][1] - stats[4][1]));
        LogSuite.log('TestFactory', 'Post_Test_Future_Calls_Made__c: ' + (stats[5][2] - stats[4][2]));
        LogSuite.log('TestFactory', 'Post_Test_SOQL_Queries_Made__c: ' + (stats[5][3] - stats[4][3]));
        LogSuite.log('TestFactory', 'Post_Test_SOSL_Queries_Made__c: ' + (stats[5][4] - stats[4][4]));
        LogSuite.log('TestFactory', 'Outside_Test_CPU_Time_Elapsed__c: ' + (statsObj.Setup_CPU_Time_Elapsed__c + statsObj.Post_Test_CPU_Time_Elapsed__c));
        LogSuite.log('TestFactory', 'Outside_Test_DML_Statements_Made__c: ' + (statsObj.Setup_DML_Statements_Made__c + statsObj.Post_Test_DML_Statements_Made__c));
        LogSuite.log('TestFactory', 'Outside_Test_Future_Calls_Made__c: ' + (statsObj.Setup_Future_Calls_Made__c + statsObj.Post_Test_Future_Calls_Made__c));
        LogSuite.log('TestFactory', 'Outside_Test_SOQL_Queries_Made__c: ' + (statsObj.Setup_SOQL_Queries_Made__c + statsObj.Post_Test_SOQL_Queries_Made__c));
        LogSuite.log('TestFactory', 'Outside_Test_SOSL_Queries_Made__c: ' + (statsObj.Setup_SOSL_Queries_Made__c + statsObj.Post_Test_SOSL_Queries_Made__c));
        LogSuite.log('TestFactory', 'Total_CPU_Time_Elapsed__c: ' + (statsObj.Setup_CPU_Time_Elapsed__c + statsObj.Test_CPU_Time_Elapsed__c + statsObj.Post_Test_CPU_Time_Elapsed__c));

        //TRANSFER EVERYTHING BELOW INTO A WEB SERVICE
        /*List<SF_Test_Statistics__c> test = [
            SELECT Id, Average_Total_CPU_Time__c, Average_Outside_CPU_Time__c, Average_Post_CPU_Time__c, Average_Setup_CPU_Time__c, Average_Test_CPU_Time__c, Times_Successfully_Run__c
            FROM SF_Test_Statistics__c
            WHERE Name = :statsObj.Name
        ];

        if(test.size() > 0)
        {
            statsObj.Id = test[0].Id;
            Decimal previousTimesSuccessfullyRun = statsObj.Times_Successfully_Run__c;

            statsObj.Times_Successfully_Run__c = test[0].Times_Successfully_Run__c + 1;
            statsObj.Average_Setup_CPU_Time__c = (statsObj.Average_Setup_CPU_Time__c * previousTimesSuccessfullyRun + statsObj.Setup_CPU_Time_Elapsed__c) / statsObj.Times_Successfully_Run__c;
            statsObj.Average_Test_CPU_Time__c = (statsObj.Average_Test_CPU_Time__c * previousTimesSuccessfullyRun + statsObj.Test_CPU_Time_Elapsed__c) / statsObj.Times_Successfully_Run__c;
            statsObj.Average_Post_CPU_Time__c = (statsObj.Average_Post_CPU_Time__c * previousTimesSuccessfullyRun + statsObj.Post_Test_CPU_Time_Elapsed__c) / statsObj.Times_Successfully_Run__c;
            statsObj.Average_Outside_CPU_Time__c = (statsObj.Average_Outside_CPU_Time__c * previousTimesSuccessfullyRun + statsObj.Outside_Test_CPU_Time_Elapsed__c) / statsObj.Times_Successfully_Run__c;
            statsObj.Average_Total_CPU_Time__c = (statsObj.Average_Total_CPU_Time__c * previousTimesSuccessfullyRun + statsObj.Total_CPU_Time_Elapsed__c) / statsObj.Times_Successfully_Run__c;

            update statsObj;
        }
        else
        {
            statsObj.Times_Successfully_Run__c = 1;
            statsObj.Average_Setup_CPU_Time__c = statsObj.Setup_CPU_Time_Elapsed__c;
            statsObj.Average_Test_CPU_Time__c = statsObj.Test_CPU_Time_Elapsed__c;
            statsObj.Average_Post_CPU_Time__c = statsObj.Post_Test_CPU_Time_Elapsed__c;
            statsObj.Average_Outside_CPU_Time__c = statsObj.Outside_Test_CPU_Time_Elapsed__c;
            statsObj.Average_Total_CPU_Time__c = statsObj.Total_CPU_Time_Elapsed__c;

            insert statsObj;
        }*/
    }
    
    private static ITest getHandler(Type t)
    {
        // Instantiate the type
        Object o = t.newInstance();
 
        // if its not an instance of ITrigger return null
        if (!(o instanceOf ITest))
        {
            return null;
        }
 
        return (ITest)o;
    }
    
    public class TestException extends Exception {}
}