/**
 * OpportunityTrigger.trigger
 *
 * The trigger should contain almost no business logic.
 * Notice that there is no SOQL, no DML and no business logic here.
 * That's intentional.
 *
 *  @author      Amrit Ojha
 * @created     2026-08-10
 * @updated     2026-08-10
 */
trigger OpportunityTrigger on Opportunity (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    
    OpportunityTriggerHandler handler =
        new OpportunityTriggerHandler();

    if (Trigger.isBefore) {

        if (Trigger.isInsert) {
            handler.beforeInsert(Trigger.new);
        }

        if (Trigger.isUpdate) {
            handler.beforeUpdate(
                Trigger.new,
                Trigger.oldMap
            );
        }

        if (Trigger.isDelete) {
            handler.beforeDelete(Trigger.old);
        }
    }

    if (Trigger.isAfter) {

        if (Trigger.isInsert) {
            handler.afterInsert(Trigger.new);
        }

        if (Trigger.isUpdate) {
            handler.afterUpdate(
                Trigger.new,
                Trigger.oldMap
            );
        }

        if (Trigger.isDelete) {
            handler.afterDelete(Trigger.old);
        }

        if (Trigger.isUndelete) {
            handler.afterUndelete(Trigger.new);
        }
    }
}