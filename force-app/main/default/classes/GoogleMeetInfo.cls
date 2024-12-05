/**
 * @description GoogleMeetInfo class is a data transfer object for exchanging data between LWC and Apex
 */
public with sharing class GoogleMeetInfo {
    // Meeting participant class
    public class Participant {
        @AuraEnabled
        public String email { get; set; }
        @AuraEnabled
        public String displayName { get; set; }
    }

    @AuraEnabled
    public Id jobApplicationId { get; set; }
    @AuraEnabled
    public Id candidateId { get; set; }
    @AuraEnabled
    public String title { get; set; }
    @AuraEnabled
    public String description { get; set; }
    @AuraEnabled
    public Datetime startDatetime { get; set; }
    @AuraEnabled
    public Datetime endDatetime { get; set; }
    @AuraEnabled
    public List<Participant> participants { get; set; }
}