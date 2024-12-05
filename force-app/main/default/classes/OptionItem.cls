/**
 * @description OptionItem class is a data transfer object for exchanging data between LWC and Apex
 *              This class is used for storing data for diplaying pills in LWC
 */
public class OptionItem {
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public Object value { get; set; }

    public OptionItem(String label, Object value) {
        this.label = label;
        this.value = value;
    }
}