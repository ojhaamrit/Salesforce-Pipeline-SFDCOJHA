/**
 * OpportunityDomain.cls
 *
 * @description 
 * The Domain represents Opportunity-specific business rules.
 * For example: An Opportunity cannot have a negative Amount.
 * 
 * The important idea is that validation belongs to the Domain, not the trigger.
 *
 * @author      Amrit Ojha
 * @created     2026-08-10
 * @updated     2026-08-10
 */
public with sharing class OpportunityDomain {

    private List<Opportunity> records;

    private Map<Id, Opportunity> oldMap;


    public OpportunityDomain(
        List<Opportunity> records
    ) {
        this.records = records;
        this.oldMap = new Map<Id, Opportunity>();
    }


    public OpportunityDomain(
        List<Opportunity> records,
        Map<Id, Opportunity> oldMap
    ) {
        this.records = records;
        this.oldMap = oldMap != null
            ? oldMap
            : new Map<Id, Opportunity>();
    }


    public void validateBeforeInsert() {

        for (Opportunity opp : records) {

            validateAmount(opp);
        }
    }


    public void validateBeforeUpdate() {

        for (Opportunity opp : records) {

            Opportunity oldOpp = oldMap.get(opp.Id);

            if (oldOpp == null) {
                continue;
            }

            validateAmount(opp);
        }
    }


    private void validateAmount(
        Opportunity opp
    ) {

        if (
            opp.Amount != null &&
            opp.Amount < 0
        ) {
            opp.addError(
                'Opportunity Amount cannot be negative.'
            );
        }
    }
}