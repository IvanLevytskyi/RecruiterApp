/**
 * @description TestDataFactory class is used to create test data
 */
public with sharing class TestDataFactory {
    private final static String COMMUNITY_USER_PROFILE = 'Job Seeker Profile'; // Community User profile name
    private final static String STANDARD_USER_PROFILE = 'Standard User'; // Standard User profile name

    /**
     * @description Create a list of Skill__c records
     * 
     * @param numberOfRecords Number of records to create
     * @return List<Skill__c> List of Skill__c records
     */
    public static List<Skill__c> createSkills(Integer numberOfRecords) {
        List<Skill__c> skills = new List<Skill__c>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            Skill__c skill = new Skill__c(Name = 'Skill ' + i);
            skills.add(skill);
        }
        return skills;
    }

    /**
     * @description Create a list of Candidate_Skill__c records
     * 
     * @param numberOfRecords Number of records to create
     * @param candidateId Id of the Candidate (Contact) record
     * @return List<Candidate_Skill__c> List of Candidate_Skill__c records
     */
    public static List<Candidate_Skill__c> createCandidateSkills(Integer numberOfRecords, Id candidateId) {
        List<Skill__c> skills = createSkills(numberOfRecords);
        insert skills;

        List<Candidate_Skill__c> candidateSkills = new List<Candidate_Skill__c>();
        for (Skill__c skill : skills) {
            Candidate_Skill__c candidateSkill = new Candidate_Skill__c(
                Candidate__c = candidateId,
                Skill__c = skill.Id
            );
            candidateSkills.add(candidateSkill);
        }

        return candidateSkills;
    }

    /**
     * @description Create a list of Job_Skill__c records
     * 
     * @param numberOfRecords Number of records to create
     * @param jobPositionId Id of the Job_Position__c record
     * @return List<Job_Skill__c> List of Job_Skill__c records
     */
    public static List<Job_Skill__c> createJobSkills(Integer numberOfRecords, Id jobPositionId) {
        List<Skill__c> skills = createSkills(numberOfRecords);
        insert skills;

        List<Job_Skill__c> jobSkills = new List<Job_Skill__c>();
        for (Skill__c skill : skills) {
            Job_Skill__c jobSkill = new Job_Skill__c(
                Job_Position__c = jobPositionId,
                Skill__c = skill.Id
            );
            jobSkills.add(jobSkill);
        }

        return jobSkills;
    }

    /**
     * @description Create a list of Contact records
     * 
     * @param numberOfRecords Number of records to create
     * @return List<Contact> List of Contact records
     */
    public static List<Contact> createContacts(Integer numberOfRecords) {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            Contact tempContact = new Contact(
                FirstName = 'Test', 
                LastName = 'Contact ' + i,
                Email = 'test.contact' + i + '@nomail.com',
                Phone = '123456543' + i,
                MailingCity = 'Boston',
                MailingCountry = 'United States'
            );
            contacts.add(tempContact);
        }
        return contacts;
    }

    /**
     * @description Create a list of Account records
     * 
     * @param numberOfRecords Number of records to create
     * @return List<Account> List of Account records
     */
    public static List<Account> createAccounts(Integer numberOfRecords) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            Account tempAccount = new Account(
                Name = 'Test Account ' + i
            );
            accounts.add(tempAccount);
        }
        return accounts;
    }

    /**
     * @description Create a list of User records with Standard User profile
     * 
     * @param numberOfRecords Number of records to create
     * @return List<User> List of User records
     */
    public static List<User> createUsers(Integer numberOfRecords) {
        Id profileId = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER_PROFILE LIMIT 1]?.Id;
        List<User> users = new List<User>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            User tempUser = new User(
                FirstName = 'Test', 
                LastName = 'User' + i,
                Alias = 'tuser' + i,
                Email = 'testuser' + i + '@nomail.com',
                Username = 'testuser' + i + '@nomail.com',
                CommunityNickname = 'testuser' + i,
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'GMT',
                ProfileId = profileId,
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8'
            );
            users.add(tempUser);
        }
        return users;
    }

    /**
     * @description Create a list of User records with Community User profile
     * 
     * @param numberOfRecords Number of records to create
     * @return List<User> List of User records
     */
    public static List<User> createCommunityUsers(Integer numberOfRecords) {
        List<Account> commAccounts = createAccounts(numberOfRecords);
        insert commAccounts;

        List<Contact> commContacts = createContacts(numberOfRecords);

        for (Integer i = 0; i < numberOfRecords; i++) {
            commContacts[i].AccountId = commAccounts[i].Id;
        }
        insert commContacts;

        Id profileId = [SELECT Id FROM Profile WHERE Name = :COMMUNITY_USER_PROFILE LIMIT 1]?.Id;
        List<User> commUsers = createUsers(numberOfRecords);

        for (Integer i = 0; i < numberOfRecords; i++) {
            commUsers[i].ContactId = commContacts[i].Id;
            commUsers[i].ProfileId = profileId;
        }

        return commUsers;
    }

    /**
     * @description Create a list of Job_Position__c records
     * 
     * @param numberOfRecords Number of records to create
     * @return List<Job_Position__c> List of Job_Position__c records
     */
    public static List<Job_Position__c> createJobPositions(Integer numberOfRecords) {
        List<Job_Position__c> positions = new List<Job_Position__c>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            Job_Position__c tempPosition = new Job_Position__c(
                Name = 'Test Position ' + i,
                Status__c = 'Open',
                Description__c = 'Test Description',
                Is_remote_allowed__c = true,
                Salary_from__c = 1000 + i * 100,
                Salary_to__c = 1500 + i * 100
            );
            positions.add(tempPosition);
        }
        return positions;
    }

    /**
     * @description Create a Job_Application__c record
     * 
     * @param jobPositionId Id of the Job_Position__c record
     * @param candidateId Id of the Candidate (Contact) record
     * @return Job_Application__c Job_Application__c record
     */
    public static Job_Application__c createJobApplication(Id jobPositionId, Id candidateId) {
        Job_Application__c application = new Job_Application__c(
            Job_Position__c = jobPositionId,
            Candidate__c = candidateId
        );
        return application;
    }

    /**
     * @description Create a ContentVersion record with the text file
     * 
     * @return ContentVersion ContentVersion record
     */
    public static ContentVersion createContentVersion() {
        ContentVersion contVersion = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.txt',
            VersionData = Blob.valueOf('Test Content'),
            Origin = 'C'// A content document from the user’s personal library
        );
        return contVersion;
    }

    /**
     * @description Create a ContentDocumentLink record to link the document and the specified record
     * 
     * @param contentDocumentId Id of the ContentDocument record
     * @param linkedEntityId Id of the record to link to
     * @return ContentDocumentLink ContentDocumentLink record
     */
    public static ContentDocumentLink createContentDocumentLink(Id contentDocumentId, Id linkedEntityId) {
        ContentDocumentLink contDocLink = new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = linkedEntityId,
            Visibility = 'AllUsers',
            ShareType = 'V'
        );
        return contDocLink;
    }    
}