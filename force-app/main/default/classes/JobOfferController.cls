/**
 * @description JobOfferController is controller class for createOffer LWC component
 */
public with sharing class JobOfferController {
    // Developer name of the email template used for sending job offers
    private static final String EMAIL_TEMPLATE_NAME = 'Job_Offer_Template';

    /**
     * @description Get the initial data for the Job Offer creation
     * 
     * @param jobApplicationId Id of the Job_Application__c record
     * @return JobOfferInfo object containing the information for creation of the Job Offer
     */
    @AuraEnabled(cacheable=true)
    public static JobOfferInfo getInitialData(Id jobApplicationId){
        // Get company information
        Organization currentOrganization = [SELECT Id, Name FROM Organization LIMIT 1];
        // Get current user information
        String userFullname = UserInfo.getName();
        String userEmail = UserInfo.getUserEmail();
        // Get candidate & job position information
        Job_Application__c applicationInfo = [
            SELECT 
                Id, Candidate__c, Candidate__r.Name, Candidate__r.Email, Job_Position__r.Name 
            FROM Job_Application__c 
            WHERE Id = :jobApplicationId
        ];

        JobOfferInfo offerInfo = new JobOfferInfo();
        offerInfo.jobApplicationId = jobApplicationId;
        offerInfo.candidateId = applicationInfo.Candidate__c;
        offerInfo.candidateName = applicationInfo.Candidate__r.Name;
        offerInfo.jobTitle = applicationInfo.Job_Position__r.Name;
        offerInfo.companyName = currentOrganization.Name;
        offerInfo.startDate = Date.today().addDays(1);
        offerInfo.location = '';
        offerInfo.salaryAmount = 0.00;
        offerInfo.bonusDetails = '';
        offerInfo.probationPeriod = null;
        offerInfo.hiringManagerEmail = userEmail; // email of the recruiter who created the Job Offer
        offerInfo.hiringManager = userFullname; // fullname of the recruiter who created the Job Offer
        offerInfo.candidateEmail = applicationInfo.Candidate__r.Email;

        return offerInfo;
    }

    /**
     * @description Generate, save and send the offer as an email
     * 
     * @param offerInfo JobOfferInfo object containing the information for creation of the Job Offer
     * @param offerUrl Url of the Job Offer
     * @param sendEmail Boolean value to indicate if the offer should be sent as an email
     */
    @AuraEnabled
    public static void generateOffer(JobOfferInfo offerInfo, Boolean sendEmail) {
        // Generate the PDF file using VisualForce page with customized data that passes as URL parameters
        PageReference offerPageRef = new PageReference(generateOfferUrl(offerInfo));

        String documentTitle = 'Job offer for ' + offerInfo.candidateName;

        // Create a ContentVersion record with the PDF file
        ContentVersion contVersion = new ContentVersion();
        
        contVersion.Title = documentTitle;
        contVersion.PathOnClient = documentTitle.replace(' ', '_') + '.pdf';
        if (!Test.isRunningTest()) {
            contVersion.VersionData = offerPageRef.getContentAsPdf();
        } else {
            contVersion.VersionData = Blob.valueOf('Test');
        }
        contVersion.Origin = 'C'; // A content document from the user’s personal library
        
        insert contVersion;

        contVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contVersion.Id];

        // Create a ContentDocumentLink record to link the document to the Job Application record
        ContentDocumentLink contDocLink = new ContentDocumentLink();
        contDocLink.ContentDocumentId = contVersion.ContentDocumentId;
        contDocLink.LinkedEntityId = offerInfo.jobApplicationId;
        contDocLink.Visibility = 'AllUsers';
        contDocLink.ShareType = 'V'; // Viewer permission

        insert contDocLink;

        if (sendEmail) {
            // Sending an email with the generated offer PDF as an attachment
            sendEmailWithAttachment(offerInfo, contVersion.Id);
        }
    }

    /**
     * @description Render the email template for the Job Offer
     * 
     * @param offerInfo JobOfferInfo object containing the information for email rendering
     * @return String with the rendered email template
     */
    @AuraEnabled
    public static String getRenderedEmail(JobOfferInfo offerInfo){
        String templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :EMAIL_TEMPLATE_NAME]?.Id;

        // Render stored email template 
        // offerInfo.candidateId (contact id of the applicant) is used for rendering the email template merge fields
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(templateId, offerInfo.candidateId, null);

        return mail.getPlainTextBody();
    }

    /**
     * @description Send an email with the generated offer PDF as an attachment
     * 
     * @param offerInfo JobOfferInfo object containing the information for email rendering
     * @param attachmentId Id of the ContentVersion record with the generated PDF file
     */
    private static void sendEmailWithAttachment(JobOfferInfo offerInfo, Id attachmentId) {
        Id jobOfferEmailTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :EMAIL_TEMPLATE_NAME]?.Id;

        // Create an email message
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { offerInfo.candidateEmail });

        mail.setTemplateId(jobOfferEmailTemplateId);
        mail.setEntityAttachments(new String[] { attachmentId });
        mail.setTargetObjectId(offerInfo.candidateId); // for merge fields

        // Sending an email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    /**
     * @description Generate the URL for the PDF file to be downloaded
     * 
     * @param offerInfo JobOfferInfo object containing the information for creation of the Job Offer
     * @return String containing the URL for the PDF file to be downloaded
     */
    private static String generateOfferUrl(JobOfferInfo offerInfo) {
        String offerUrl = '/apex/JobOfferLetter?';
        List<String> ulrParams = new List<String> ();

        // Convert custom apex class to the Map<String, Object> structure
        Map<String, Object> offerInfoMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(offerInfo));

        // Iterate over the class properties
        for (String key : offerInfoMap.keySet()) {
            String value = String.valueOf(offerInfoMap.get(key));
            if (String.isNotBlank(value)) {
                ulrParams.add(EncodingUtil.urlEncode(key, 'UTF-8') + '=' + EncodingUtil.urlEncode(value, 'UTF-8'));
            }
        }

        return offerUrl + String.join(ulrParams, '&');
    }
 }