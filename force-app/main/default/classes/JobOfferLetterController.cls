/**
 * @description JobOfferInfo class is a controller for the VisualForce page called JobOfferLetter 
 *              used as a template for generating Job Offer PDF file
 */
public class JobOfferLetterController {
    public String candidateName { get; set; } // canidate's fullname
    public String jobTitle { get; set; } // title of the job
    public String companyName { get; set; } // name of the company
    public Date startDate { get; set; } // date the job starts
    public String location { get; set; } // location of the job
    public Decimal salaryAmount { get; set; } // amount of the salary
    public String bonusDetails { get; set; } // details of the bonus
    public Integer probationPeriod { get; set; } // details of the probation period in months
    public String hiringManagerEmail { get; set; } // recruiter's email
    public String hiringManager { get; set; } // recruiter's fullname

    /**
     * @description JobOfferLetterController constructor that is used to populate the class properties
     *              with the data from the URL parameters 
     */
    public JobOfferLetterController() {
        // Get URl parameters of the current page
        Map<String, String> pageParameters = ApexPages.currentPage().getParameters();

        if (pageParameters.containsKey('candidateName')) {
            candidateName = pageParameters.get('candidateName');
        }
        if (pageParameters.containsKey('jobTitle')) {
            jobTitle = pageParameters.get('jobTitle');
        }
        if (pageParameters.containsKey('companyName')) {
            companyName = pageParameters.get('companyName');
        }
        if (pageParameters.containsKey('startDate')) {
            startDate = Date.valueOf(pageParameters.get('startDate'));
        }
        if (pageParameters.containsKey('location')) {
            location = pageParameters.get('location');
        }
        if (pageParameters.containsKey('salaryAmount')) {
            salaryAmount = Decimal.valueOf(pageParameters.get('salaryAmount'));
        }
        if (pageParameters.containsKey('bonusDetails')) {
            bonusDetails = pageParameters.get('bonusDetails');
        }
        if (pageParameters.containsKey('probationPeriod')) {
            probationPeriod = Integer.valueOf(pageParameters.get('probationPeriod'));
        }
        if (pageParameters.containsKey('hiringManagerEmail')) {
            hiringManagerEmail = pageParameters.get('hiringManagerEmail');
        }
        if (pageParameters.containsKey('hiringManager')) {
            hiringManager = pageParameters.get('hiringManager');
        }
    }
}
