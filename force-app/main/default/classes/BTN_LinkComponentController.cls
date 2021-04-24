public with sharing class BTN_LinkComponentController {

    public Id mysObject{set; get;}

    public String mysObjectName{set; get;}

    public BTN_LinkComponentController() {}

    public String getLink() {
        return (System.URL.getSalesforceBaseUrl().getHost().remove('-api' ) + '/' + mysObject);
    }
}