/**
 * @description This class is responsible for handling triggers in Salesforce. 
 *              It provides a framework for implementing custom logic before or after insert, update, delete, and undelete operations on sObjects.
 */
public abstract class TriggerHandler {
    /**
     * @description Executes the trigger handler logic based on the trigger context.
     */
    public void execute() {
        switch on Trigger.operationType {
            when BEFORE_INSERT{
                beforeInsert(Trigger.new);
            }
            when AFTER_INSERT{
                afterInsert(Trigger.new, Trigger.newMap);
            }
            when BEFORE_UPDATE{
                beforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
            }
            when AFTER_UPDATE{
                afterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
            }
            when BEFORE_DELETE{
                beforeDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_DELETE{
                afterDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_UNDELETE{
                afterUndelete(Trigger.new, Trigger.newMap);
            }
        }
    }

    /**
     * @description This method is called before insert operations.
     * 
     * @param List<sObject> newList - List of sObject records that are being inserted.
     */
    public virtual void beforeInsert(List<sObject> newList) {}

    /**
     * @description This method is called after insert operations.
     * 
     * @param List<sObject> newList - List of sObject records that were inserted.
     * @param Map<Id, sObject> newMap - Map of sObject records that were inserted.
     */
    public virtual void afterInsert(List<sObject> newList, Map<Id, sObject> newMap) {}

    /**
     * @description This method is called before update operations.
     * 
     * @param List<sObject> newList - List of sObject records that are being updated.
     * @param Map<Id, sObject> newMap - Map of sObject records that are being updated.
     * @param List<sObject> oldList - List of sObject records before they were updated.
     * @param Map<Id, sObject> oldMap - Map of sObject records before they were updated.
     */
    public virtual void beforeUpdate(
        List<sObject> newList, 
        Map<Id, sObject> newMap, 
        List<sObject> oldList, 
        Map<Id, sObject> oldMap
    ) {}

    /**
     * @description This method is called after update operations.
     * 
     * @param List<sObject> newList - List of sObject records that were updated.
     * @param Map<Id, sObject> newMap - Map of sObject records that were updated.
     * @param List<sObject> oldList - List of sObject records before they were updated.
     * @param Map<Id, sObject> oldMap - Map of sObject records before they were updated.
     */
    public virtual void afterUpdate(
        List<sObject> newList, 
        Map<Id, sObject> newMap, 
        List<sObject> oldList, 
        Map<Id, sObject> oldMap
    ) {}

    /**
     * @description This method is called before delete operations.
     * 
     * @param List<sObject> oldList - List of sObject records that are being deleted.
     * @param Map<Id, sObject> oldMap - Map of sObject records that are being deleted.
     */
    public virtual void beforeDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {}

    /**
     * @description This method is called after delete operations.
     * 
     * @param List<sObject> oldList - List of sObject records that were deleted.
     * @param Map<Id, sObject> oldMap - Map of sObject records that were deleted.
     */
    public virtual void afterDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {}

    /**
     * @description This method is called after undelete operations.
     * 
     * @param List<sObject> newList - List of sObject records that were undeleted.
     * @param Map<Id, sObject> newMap - Map of sObject records that were undeleted.
     */
    public virtual void afterUndelete(List<sObject> newList, Map<Id, sObject> newMap) {}
}