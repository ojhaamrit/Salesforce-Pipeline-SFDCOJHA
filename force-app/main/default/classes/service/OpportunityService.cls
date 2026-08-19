/**
 * @description This class is responsible for handling the business logic related to Opportunity records.
 * 
 * It shouldn't know how the business logic is implemented.
 *
 * @author      Amrit Ojha
 * @created     2026-08-10
 * @updated     2026-08-10
 */

public with sharing class OpportunityService {

    private OpportunitySelector selector;
    private EnterpriseUnitOfWork unitOfWork;


    public OpportunityService() {

        this.selector =
            new OpportunitySelector();

        this.unitOfWork =
            new EnterpriseUnitOfWork();
    }


    public OpportunityService(
        OpportunitySelector selector,
        EnterpriseUnitOfWork unitOfWork
    ) {

        this.selector = selector;
        this.unitOfWork = unitOfWork;
    }


    public void recalculateAccountPipeline(
        List<Opportunity> newRecords,
        Map<Id, Opportunity> oldMap
    ) {

        Set<Id> accountIds =
            collectAffectedAccountIds(
                newRecords,
                oldMap
            );


        if (accountIds.isEmpty()) {
            return;
        }


        Map<Id, Decimal> pipelineByAccount =
            selector.getOpenPipelineByAccount(
                accountIds
            );


        for (Id accountId : accountIds) {

            Decimal pipelineAmount =
                pipelineByAccount.containsKey(accountId)
                    ? pipelineByAccount.get(accountId)
                    : 0;


            Account accountToUpdate =
                new Account(
                    Id = accountId,
                    Open_Pipeline__c = pipelineAmount
                );


            unitOfWork.registerDirty(
                accountToUpdate
            );
        }


        unitOfWork.commitWork();
    }


    private Set<Id> collectAffectedAccountIds(
        List<Opportunity> newRecords,
        Map<Id, Opportunity> oldMap
    ) {

        Set<Id> accountIds =
            new Set<Id>();


        /*
         * New Account relationships.
         */
        if (newRecords != null) {

            for (Opportunity opp : newRecords) {

                if (opp.AccountId != null) {
                    accountIds.add(
                        opp.AccountId
                    );
                }
            }
        }


        /*
         * Old Account relationships.
         *
         * This is critical when an Opportunity
         * moves from Account A to Account B.
         */
        if (oldMap != null) {

            for (Opportunity oldOpp : oldMap.values()) {

                if (oldOpp.AccountId != null) {
                    accountIds.add(
                        oldOpp.AccountId
                    );
                }
            }
        }


        return accountIds;
    }
}