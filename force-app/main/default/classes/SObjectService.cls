/**
 * @description SObjectService class is used to manage the SObjects
 */
public with sharing class SObjectService {
    /**
     * @description Get the name of the SObject by its Id
     * 
     * @param recordId Id of the record
     * @return String Name of the SObject
     */
    @AuraEnabled(cacheable=true)
    public static String getSObjectNameById(Id recordId){
        return recordId.getSobjectType().getDescribe().getName();
    }
}