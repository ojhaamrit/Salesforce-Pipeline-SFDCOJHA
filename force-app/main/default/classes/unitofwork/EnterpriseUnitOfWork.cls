/** 
 * * EnterpriseUnitOfWork.cls
 * 
 * This class is responsible for managing the unit of work pattern for Salesforce SObjects.
 * It allows for registering dirty records and committing them in a single transaction.
 * 
 * For this example, we're primarily using it to manage the update of Account records when Opportunities are inserted or updated.
 * The purpose is to avoid DML being scattered throughout business logic.
 * 
 * @author      Amrit Ojha
 * @created     2026-08-10
 * @updated     2026-08-10
 */

public with sharing class EnterpriseUnitOfWork {

    private Map<Id, SObject> dirtyRecords =
        new Map<Id, SObject>();


    public void registerDirty(
        SObject record
    ) {

        if (record == null || record.Id == null) {
            throw new UnitOfWorkException(
                'Cannot register a record without an Id.'
            );
        }

        dirtyRecords.put(
            record.Id,
            record
        );
    }


    public Boolean hasWork() {
        return !dirtyRecords.isEmpty();
    }


    public void commitWork() {

        if (dirtyRecords.isEmpty()) {
            return;
        }


        List<SObject> recordsToUpdate =
            new List<SObject>();

        recordsToUpdate.addAll(
            dirtyRecords.values()
        );


        Database.update(
            recordsToUpdate,
            true
        );


        dirtyRecords.clear();
    }


    public class UnitOfWorkException
        extends Exception {
    }
}