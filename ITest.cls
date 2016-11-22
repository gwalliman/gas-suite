public interface ITest 
{
	String getTestHumanName();
	String getTestDescription();
	void setupTest();
	void runTest();
	void postTest();
}