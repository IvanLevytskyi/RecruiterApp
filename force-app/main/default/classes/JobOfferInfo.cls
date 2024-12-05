/**
 * @description JobOfferInfo class is a data transfer object for exchanging data between LWC and Apex
 */
public with sharing class JobOfferInfo {
    @AuraEnabled
    public Id jobApplicationId { get; set; }
    @AuraEnabled
    public Id candidateId { get; set; }
    @AuraEnabled
    public String candidateName { get; set; }
    @AuraEnabled
    public String jobTitle { get; set; }
    @AuraEnabled
    public String companyName { get; set; }
    @AuraEnabled
    public Date startDate { get; set; }
    @AuraEnabled
    public String location { get; set; }
    @AuraEnabled
    public Decimal salaryAmount { get; set; }
    @AuraEnabled
    public String bonusDetails { get; set; }
    @AuraEnabled
    public Integer probationPeriod { get; set; } // In months
    @AuraEnabled
    public String hiringManagerEmail { get; set; } // recruiter email
    @AuraEnabled
    public String hiringManager { get; set; } // recruiter fullname
    @AuraEnabled
    public String candidateEmail { get; set; }
}