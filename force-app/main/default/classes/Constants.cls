/**
 *   @date: 03/26/2020
 *   @author: Altimetrik
 *   The class must contain public constant values
 *   The constants must be grouped by objects through inner classes
 *   Named convention: FIELD_VALUE
 *   Example: CASE_STATUS_OPEN
 */
public with sharing class Constants {
    public static final AWSConstants AWS = new AWSConstants();
    public static final LegalAdvisorConstants LEGAL_ADVISORS = new LegalAdvisorConstants();

    public class AWSConstants {
        public final String UCL_BUCKET_ENDPOINT { get { return 'callout:uclawyers/uclawyers.json'; } }
    }

    public class LegalAdvisorConstants {
        public final String STATUS_DISABLED { get { return 'Disabled'; } }
        public final String STATUS_ENABLED { get { return 'Enabled'; } }
    }
}
