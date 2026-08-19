@IsTest
private class OpportunityTriggerTest {

    @IsTest
    static void shouldCalculatePipelineAfterInsert() {

        Account account =
            TestDataFactory.createAccount(
                'Acme Corporation',
                true
            );


        Opportunity opp =
            TestDataFactory.createOpportunity(
                account.Id,
                100000,
                'Prospecting',
                false
            );


        Test.startTest();

        insert opp;

        Test.stopTest();


        Account result = [
            SELECT Id, Open_Pipeline__c
            FROM Account
            WHERE Id = :account.Id
        ];


        System.assertEquals(
            100000,
            result.Open_Pipeline__c,
            'Pipeline should equal open Opportunity amount.'
        );
    }


    @IsTest
    static void shouldRecalculateAfterAmountUpdate() {

        Account account =
            TestDataFactory.createAccount(
                'Acme Corporation',
                true
            );


        Opportunity opp =
            TestDataFactory.createOpportunity(
                account.Id,
                100000,
                'Prospecting',
                true
            );


        Test.startTest();

        opp.Amount = 250000;

        update opp;

        Test.stopTest();


        Account result = [
            SELECT Open_Pipeline__c
            FROM Account
            WHERE Id = :account.Id
        ];


        System.assertEquals(
            250000,
            result.Open_Pipeline__c
        );
    }


    @IsTest
    static void shouldRemoveClosedOpportunityFromPipeline() {

        Account account =
            TestDataFactory.createAccount(
                'Acme Corporation',
                true
            );


        Opportunity opp =
            TestDataFactory.createOpportunity(
                account.Id,
                100000,
                'Prospecting',
                true
            );


        Test.startTest();

        opp.StageName = 'Closed Won';

        update opp;

        Test.stopTest();


        Account result = [
            SELECT Open_Pipeline__c
            FROM Account
            WHERE Id = :account.Id
        ];


        System.assertEquals(
            0,
            result.Open_Pipeline__c
        );
    }


    @IsTest
    static void shouldAddOpportunityWhenClosedBecomesOpen() {

        Account account =
            TestDataFactory.createAccount(
                'Acme Corporation',
                true
            );


        Opportunity opp =
            TestDataFactory.createOpportunity(
                account.Id,
                100000,
                'Closed Won',
                true
            );


        Account initialAccount = [
            SELECT Open_Pipeline__c
            FROM Account
            WHERE Id = :account.Id
        ];


        System.assertEquals(
            0,
            initialAccount.Open_Pipeline__c
        );


        Test.startTest();

        opp.StageName = 'Prospecting';

        update opp;

        Test.stopTest();


        Account result = [
            SELECT Open_Pipeline__c
            FROM Account
            WHERE Id = :account.Id
        ];


        System.assertEquals(
            100000,
            result.Open_Pipeline__c
        );
    }


    @IsTest
    static void shouldHandleAccountChange() {

        Account accountA =
            TestDataFactory.createAccount(
                'Account A',
                true
            );


        Account accountB =
            TestDataFactory.createAccount(
                'Account B',
                true
            );


        Opportunity opp =
            TestDataFactory.createOpportunity(
                accountA.Id,
                100000,
                'Prospecting',
                true
            );


        Test.startTest();

        opp.AccountId = accountB.Id;

        update opp;

        Test.stopTest();


        Map<Id, Account> accounts =
            new Map<Id, Account>([
                SELECT Id, Open_Pipeline__c
                FROM Account
                WHERE Id IN :new Set<Id>{
                    accountA.Id,
                    accountB.Id
                }
            ]);


        System.assertEquals(
            0,
            accounts.get(accountA.Id).Open_Pipeline__c,
            'Old Account should lose pipeline.'
        );


        System.assertEquals(
            100000,
            accounts.get(accountB.Id).Open_Pipeline__c,
            'New Account should gain pipeline.'
        );
    }


    @IsTest
    static void shouldRecalculateAfterDelete() {

        Account account =
            TestDataFactory.createAccount(
                'Acme Corporation',
                true
            );


        Opportunity opp =
            TestDataFactory.createOpportunity(
                account.Id,
                100000,
                'Prospecting',
                true
            );


        Test.startTest();

        delete opp;

        Test.stopTest();


        Account result = [
            SELECT Open_Pipeline__c
            FROM Account
            WHERE Id = :account.Id
        ];


        System.assertEquals(
            0,
            result.Open_Pipeline__c
        );
    }


    @IsTest
    static void shouldRecalculateAfterUndelete() {

        Account account =
            TestDataFactory.createAccount(
                'Acme Corporation',
                true
            );


        Opportunity opp =
            TestDataFactory.createOpportunity(
                account.Id,
                100000,
                'Prospecting',
                true
            );


        delete opp;


        Test.startTest();

        undelete opp;

        Test.stopTest();


        Account result = [
            SELECT Open_Pipeline__c
            FROM Account
            WHERE Id = :account.Id
        ];


        System.assertEquals(
            100000,
            result.Open_Pipeline__c
        );
    }


    @IsTest
    static void shouldHandleBulkInsert() {

        Account account =
            TestDataFactory.createAccount(
                'Bulk Account',
                true
            );


        List<Opportunity> opportunities =
            new List<Opportunity>();


        for (Integer i = 0; i < 200; i++) {

            opportunities.add(
                new Opportunity(
                    Name = 'Bulk Opportunity ' + i,
                    AccountId = account.Id,
                    Amount = 1000,
                    StageName = 'Prospecting',
                    CloseDate = Date.today().addDays(30)
                )
            );
        }


        Test.startTest();

        insert opportunities;

        Test.stopTest();


        Account result = [
            SELECT Open_Pipeline__c
            FROM Account
            WHERE Id = :account.Id
        ];


        System.assertEquals(
            200000,
            result.Open_Pipeline__c
        );
    }


    @IsTest
    static void shouldRejectNegativeAmount() {

        Account account =
            TestDataFactory.createAccount(
                'Validation Account',
                true
            );


        Opportunity opp =
            TestDataFactory.createOpportunity(
                account.Id,
                -100,
                'Prospecting',
                false
            );


        Test.startTest();

        Database.SaveResult result =
            Database.insert(
                opp,
                false
            );

        Test.stopTest();


        System.assertEquals(
            false,
            result.isSuccess()
        );


        System.assert(
            result.getErrors()[0]
                .getMessage()
                .contains(
                    'Amount cannot be negative'
                )
        );
    }
}