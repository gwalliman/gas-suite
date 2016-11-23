GAS SUITE
Garret's Apex Suite - Salesforce Apex Trigger Design Pattern and Utilities

This repository contains the core code for the GAS Suite, which consists of:

* GASTriggerFactory.cls
* IGASTrigger.cls
* GASTriggerServices.cls
* sObjectList.cls
* sObjectListSubsetFactory.cls
* TestFactory.cls
* ITest.cls
* LogSuite.cls

It also contains some common sObjectList extensions, currently consisting of:

 * AccountList.cls
 * OpportunityList.cls
 * EventList.cls
 * CaseList.cls

 Finally, there is a sample AccountTrigger and related classes (AccountTriggerHandler, AccountTriggerService) that can serve as a guide to making your own trigger handlers.

 You can also find sample Apex tests using TestFactory (Test_AccountTriggerHandler.cls, AccountTriggerTests.cls)

 These sample classes have comments explaining how they work.