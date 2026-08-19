/**
 * OpportunityTriggerHandler.cls
 * 
 * The handler translates Salesforce trigger context into application operations.
 *
 * This class is responsible for handling the trigger events for the Opportunity object.
 * It delegates the business logic to the OpportunityDomain and OpportunityService classes.
 * 
 * Then handler responsibility is simply:
 *  1. What happened?
 *  2. What application operation should be performed?
 * 
 * It shouldn't know how the business logic is implemented.

 * @author      Amrit Ojha
 * @created     2026-08-10
 * @updated     2026-08-10
 */

public with sharing class OpportunityTriggerHandler {

    public void beforeInsert(
        List<Opportunity> newRecords
    ) {
        OpportunityDomain domain =
            new OpportunityDomain(newRecords);

        domain.validateBeforeInsert();
    }


    public void beforeUpdate(
        List<Opportunity> newRecords,
        Map<Id, Opportunity> oldMap
    ) {
        OpportunityDomain domain =
            new OpportunityDomain(newRecords, oldMap);

        domain.validateBeforeUpdate();
    }


    public void beforeDelete(
        List<Opportunity> oldRecords
    ) {
        // No business logic required for this example.
    }


    public void afterInsert(
        List<Opportunity> newRecords
    ) {
        OpportunityService service =
            new OpportunityService();

        service.recalculateAccountPipeline(
            newRecords,
            null
        );
    }


    public void afterUpdate(
        List<Opportunity> newRecords,
        Map<Id, Opportunity> oldMap
    ) {
        OpportunityService service =
            new OpportunityService();

        service.recalculateAccountPipeline(
            newRecords,
            oldMap
        );
    }


    public void afterDelete(
        List<Opportunity> oldRecords
    ) {
        OpportunityService service =
            new OpportunityService();

        service.recalculateAccountPipeline(
            null,
            oldRecords
        );
    }


    public void afterUndelete(
        List<Opportunity> newRecords
    ) {
        OpportunityService service =
            new OpportunityService();

        service.recalculateAccountPipeline(
            newRecords,
            null
        );
    }
}