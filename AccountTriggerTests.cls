public class AccountTriggerTests
{
    public class AccountTriggerTestCreateNoteHistoryDontCreateNotesWhenEmpty implements ITest
	{
		private Account a;

		public String getTestHumanName()
		{
			return 'AccountTests - Don\'t create notes when no notes in field';
		}

		public String getTestDescription()
		{
			return 'Need to make sure that we don\'t create notes unnecessarily';
		}

		public void setupTest()
		{
			a = TestUtils.createAccount('test', 'test', 'test@test.com', true);
		}

		public void runTest()
		{
            //On initial insert, we always populate a note with Marketo Sync Complete (which is stupid)
            //This resets the notes fields
            a.Customer_Notes__c = null;
            a.Latest_Customer_Note__c = null;
            update a;
		}

		public void postTest()
		{
			a = [
			    SELECT Id, Latest_Customer_Note__c, Customer_Notes__c
			    FROM Account
			    WHERE Id = :a.Id
			];

			System.assert(String.isEmpty(a.Customer_Notes__c));
		}
	}

	public class AccountTriggerTestCreateNoteHistoryNoPreviousNotes implements ITest
	{
		private Account a;

		public String getTestHumanName()
		{
			return 'AccountTests - Create Note History with No Previous Notes';
		}

		public String getTestDescription()
		{
			return 'Set a note on an Account with no previous notes. Should append to Customer_Notes__c';
		}

		public void setupTest()
		{
			a = TestUtils.createAccount('test', 'test', 'test@test.com', true);
		}

		public void runTest()
		{
			a.Latest_Customer_Note__c = '456test';
			update a;
		}
		
		public void postTest()
		{
			a = [
			    SELECT Id, Latest_Customer_Note__c, Customer_Notes__c
			    FROM Account
			    WHERE Id = :a.Id
			];

			System.assert(!String.isEmpty(a.Customer_Notes__c));
			System.assert(a.Customer_Notes__c.contains('456test'));
		}
	}

	public class AccountTriggerTestCreateNoteHistoryHasPreviousNotes implements ITest
	{
		private Account a;

		public String getTestHumanName()
		{
			return 'AccountTests - Create Note History with Account Having Previous Notes';
		}

		public String getTestDescription()
		{
			return 'Set a note on an Account that has previous notes. Should prepend to Customer_Notes__c with new note first';
		}

		public void setupTest()
		{
			a = TestUtils.createAccount('test', 'test', 'test@test.com', true);
			a.Latest_Customer_Note__c = '456test';
			update a;
		}

		public void runTest()
		{
			a.Latest_Customer_Note__c = '789_-_';
			update a;
		}

		public void postTest()
		{
			a = [
			    SELECT Id, Latest_Customer_Note__c, Customer_Notes__c
			    FROM Account
			    WHERE Id = :a.Id
			];

			System.assert(!String.isEmpty(a.Customer_Notes__c));
			System.assert(a.Customer_Notes__c.contains('456test'));
			System.assert(a.Customer_Notes__c.contains('\n\n'));
			System.assert(a.Customer_Notes__c.contains('789_-_'));
		}
	}

	public class AccountTriggerTestLastContentChangeInsert implements ITest
	{
		private Account a;
		public String getTestHumanName()
		{
			return 'AccountTests - Set Content Last Modified Date upon Insert';
		}

		public String getTestDescription()
		{
			return 'The Content Last Modified Date value should be set on insert, if we\'re not running as Bulk User';
		}

		public void setupTest() {}

		public void runTest()
		{
			a = testUtils.createAccount('test', 'test', 'test@test.com', true);
		}

		public void postTest()
		{
			a = [
				SELECT Id, ContentLastModifiedDate__c 
				FROM Account 
				WHERE Id = :a.Id 
			];

			System.assert(a.ContentLastModifiedDate__c != null);
		}
	}


	public class AccountTriggerTestLastContentChangeUpdate implements ITest
	{
		private Account a;
		private Datetime lcc1;

		public String getTestHumanName()
		{
			return 'AccountTests - Update Content Last Modified Date upon Update';
		}

		public String getTestDescription()
		{
			return 'The Content Last Modified Date value should be updated on update, if we\'re not running as Bulk User';
		}

		public void setupTest()
		{
			a = testUtils.createAccount('test', 'test', 'test@test.com', true);

			a = [
				SELECT Id, ContentLastModifiedDate__c 
				FROM Account 
				WHERE Id = :a.Id 
			];

			//Updating the ContentLastModifiedDate to test whether the trigger resets it back to "real"
			//Can't just check whether it's greater than lcc1 without modification since these tests run so fast, it's not guaranteed to increment
			lcc1 = a.ContentLastModifiedDate__c.addSeconds(-1);
		}

		public void runTest()
		{
			a.Latest_Customer_Note__c = '12345';
			a.ContentLastModifiedDate__c = lcc1;
			update a;
		}

		public void postTest()
		{
			a = [
				SELECT Id, ContentLastModifiedDate__c 
				FROM Account 
				WHERE Id = :a.Id 
			];

			System.assert(a.ContentLastModifiedDate__c != null);
			System.assert(a.ContentLastModifiedDate__c > lcc1);
		}
	}

	public class AccountTriggerTestSyncHubEmailInsert implements ITest
	{
		private Account acct;
		private Opportunity oppt;

		public String getTestHumanName()
		{
			return 'AccountTests - Set Correct Hub Email on Opportunity Insert';
		}

		public String getTestDescription()
		{
			return 'When inserting an opportunity, the Oppt hub email should be set based on the Account Primary Location';
		}

		public void setupTest()
		{
			acct = testUtils.createAccount('firstName', 'lastName', 'email@email.com', false);
			acct.Delivery_Location__c = 'Charlotte';
			insert acct;
		}

		public void runTest()
		{
			oppt = testUtils.createOpportunity(acct.Id, 'Vehicle Locked', date.today().addDays(1), true);
		}

		public void postTest()
		{
			oppt = [
				SELECT Id, HUB_Email__c
				FROM Opportunity
				WHERE Id = :oppt.Id
			];

			System.assert(oppt.HUB_Email__c == 'DL-CarvanaCharlotteAll@carvana.com');
		}
	}

	public class AccountTriggerTestSyncHubEmailUpdate implements ITest
	{
		private Account acct;
		private Opportunity oppt;

		public String getTestHumanName()
		{
			return 'AccountTests - Set Correct Hub Email on Opportunity Update';
		}

		public String getTestDescription()
		{
			return 'When updating an opportunity, the Oppt hub email should be set based on the Account Primary Location';
		}

		public void setupTest()
		{
			acct = testUtils.createAccount('firstName', 'lastName', 'email@email.com', false);
			acct.Delivery_Location__c = 'Charlotte';
			insert acct;
			oppt = testUtils.createOpportunity(acct.Id, 'Vehicle Locked', date.today().addDays(1), true);
		}

		public void runTest()
		{
			acct.Delivery_Location__c = 'Austin';
			update acct;
		}

		public void postTest()
		{
			oppt = [
				SELECT Id, HUB_Email__c
				FROM Opportunity
				WHERE Id = :oppt.Id
			];

			System.assert(oppt.HUB_Email__c == 'DL-CarvanaAustinAll@carvana.com');
		}
	}

    public class AccountTriggerTestDoNotEmailSyncInsert implements ITest
	{
		private Account acct;
		private Opportunity oppt;

		public String getTestHumanName()
		{
			return 'AccountTests - Set Do Not Email on Opportunity Insert';
		}

		public String getTestDescription()
		{
			return 'When inserting an account, the account\'s Do Not Email value should be synced to the Opportunity';
		}

		public void setupTest()
		{
            acct = testUtils.createAccount('firstName', 'lastName', 'email@email.com', false);
            acct.Is_Do_Not_Email__c = true;
            insert acct;
		}

		public void runTest()
		{
            oppt = testUtils.createOpportunity(acct.Id, 'Vehicle Locked', date.today().addDays(1), true);
		}

		public void postTest()
		{
			oppt = [
				SELECT Id, Email_Opt_Out__c
				FROM Opportunity
				WHERE Id = :oppt.Id
			];

			System.assert(oppt.Email_Opt_Out__c == true);
		}
	}

	public class AccountTriggerTestDoNotEmailSyncUpdate implements ITest
	{
		private Account acct;
		private Opportunity oppt;

		public String getTestHumanName()
		{
			return 'AccountTests - Set Do Not Email on Account Update';
		}

		public String getTestDescription()
		{
			return 'When updating an account, the acount Do Not Email value should be synced to the Opportunity';
		}

		public void setupTest()
		{
			acct = testUtils.createAccount('firstName', 'lastName', 'email@email.com', true);
			oppt = testUtils.createOpportunity(acct.Id, 'Vehicle Locked', date.today().addDays(1), true);
		}

		public void runTest()
		{
			acct.Is_Do_Not_Email__c = true;
			update acct;
		}

		public void postTest()
		{
			oppt = [
				SELECT Id, Email_Opt_Out__c
				FROM Opportunity
				WHERE Id = :oppt.Id
			];

			System.assert(oppt.Email_Opt_Out__c == true);
		}
	}

	public class AccountTriggerTestAssignPersonContactIdOnAccountInsert implements ITest
	{
		private Account acct;

		public String getTestHumanName()
		{
			return 'AccountTests - Assign Person Contact Id on Account Insert';
		}

		public String getTestDescription()
		{
			return 'Ensure Person Contact ID is properly inserted on Account insert';
		}

		public void setupTest() {}

		public void runTest()
		{
			acct = testUtils.createAccount('firstName', 'lastName', 'email@email.com', false);
			acct.Is_Do_Not_Email__c = true;
			insert acct;
		}

		public void postTest()
		{
			acct = [
				SELECT Id, PersonContactId
				FROM Account
				WHERE Id = :acct.Id
			];

			System.assert(acct.PersonContactId != null);
		}
	}

	public class AccountTriggerTestCustomerWDYHAUAdvocate implements ITest
	{
		private Account acct;

		public String getTestHumanName()
		{
			return 'AccountTests - WDYHAU Advocate';
		}

		public String getTestDescription()
		{
			return 'On setting Lead Source Details, mark WDYHAU Advocate'; 
		}

		public void setupTest() 
		{
			acct = testUtils.createAccount('firstName', 'lastName', 'email@email.com', true);
		}

		public void runTest()
		{
			acct.Lead_Source_Details__pc = 'ASDF1234';
			update acct;
		}

		public void postTest()
		{
			acct = [
				SELECT Id, WDYHAU_Advocate__c
				FROM Account
				WHERE Id = :acct.Id
			];

			User currentUser = [
				SELECT FirstName, LastName
				FROM User
				WHERE Id = :UserInfo.getUserId()
			];
			
			System.assert(acct.WDYHAU_Advocate__c == currentUser.FirstName + ' ' + currentUser.LastName);
		}
	}

	public class AccountTriggerTestContactTransferCarvanaID implements ITest
	{
		private Account acct;

		public String getTestHumanName()
		{
			return 'AccountTests - Contact Transfer Carvana ID';
		}

		public String getTestDescription()
		{
			return 'On creating account, transfer Carvana ID to Carvana Contact ID';
		}

		public void setupTest() {}

		public void runTest()
		{
			acct = testUtils.createAccount('firstName', 'lastName', 'email@email.com', false);
			acct.Carvana_Id__c = '12345';
			insert acct;
		}

		public void postTest()
		{
			acct = [
				SELECT Id, Carvana_Id__pc 
				FROM Account
				WHERE Id = :acct.Id
			];

			System.assert(acct.Carvana_Id__pc == '12345');
		}
	}

	public class AccountTriggerTestPFDetectionDateCapture implements ITest
	{
		private Account acct;

		public String getTestHumanName()
		{
			return 'AccountTests - Capture PF Detection Date';
		}

		public String getTestDescription()
		{
			return 'Capture Potential Fraud Detection Date when that field is marked';
		}

		public void setupTest() 
		{
			acct = testUtils.createAccount('firstName', 'lastName', 'email@email.com', true);
		}

		public void runTest()
		{
			acct.Is_Potential_Fraud__c = true;
			update acct;
		}

		public void postTest()
		{
			acct = [
				SELECT Id, Potential_Fraud_Detected_Date__c 
				FROM Account
				WHERE Id = :acct.Id
			];

			System.assert(acct.Potential_Fraud_Detected_Date__c > Datetime.now().addSeconds(-5));
		}
	}
}