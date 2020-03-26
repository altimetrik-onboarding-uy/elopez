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

    public class AWSConstants {
        public final String UCL_BUCKET_ENDPOINT = 'callout:uclawyers/uclawyers.json';
    }
}
