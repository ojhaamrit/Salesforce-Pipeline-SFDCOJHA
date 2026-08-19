/**
 * TestDataFactory.cls
 *
 * This class is a utility for creating test data in Salesforce.
 * It provides methods to create Account and Opportunity records for testing purposes.
 * 
 * This prevents every test class from duplicating setup code and ensures consistency in test data creation.
 *
 * @author      Amrit Ojha
 * @created     2026-08-10
 * @updated     2026-08-10
 */

@IsTest
public class TestDataFactory {

    public static Account createAccount(
        String name,
        Boolean doInsert
    ) {

        Account account = new Account(
            Name = name
        );

        if (doInsert) {
            insert account;
        }

        return account;
    }


    public static Opportunity createOpportunity(
        Id accountId,
        Decimal amount,
        String stageName,
        Boolean doInsert
    ) {

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = accountId,
            Amount = amount,
            StageName = stageName,
            CloseDate = Date.today().addDays(30)
        );

        if (doInsert) {
            insert opp;
        }

        return opp;
    }
}