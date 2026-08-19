/**
 * OpportunitySelector.cls
 * 
 * The Selector owns database queries and data aggregation for the Opportunity object.
 * 
 * This class is responsible for selecting and aggregating Opportunity data.
 * It provides methods to retrieve the open pipeline amount by Account Ids.
 * 
 * This is important because it separates the data access logic from the business logic, allowing for better maintainability and testability.
 * 
 * @author      Amrit Ojha
 * @created     2026-08-10
 * @updated     2026-08-10
 */
public with sharing class OpportunitySelector {

    public Map<Id, Decimal> getOpenPipelineByAccount(
        Set<Id> accountIds
    ) {
        Map<Id, Decimal> pipelineByAccount =
            new Map<Id, Decimal>();


        if (accountIds == null || accountIds.isEmpty()) {
            return pipelineByAccount;
        }


        for (AggregateResult result : [
            SELECT
                AccountId accountId,
                SUM(Amount) totalAmount
            FROM Opportunity
            WHERE AccountId IN :accountIds
            AND IsClosed = false
            GROUP BY AccountId
        ]) {

            Id accountId =
                (Id) result.get('accountId');

            Decimal amount =
                (Decimal) result.get('totalAmount');

            pipelineByAccount.put(
                accountId,
                amount
            );
        }


        return pipelineByAccount;
    }
}