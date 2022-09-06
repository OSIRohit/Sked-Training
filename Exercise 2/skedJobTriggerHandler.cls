public class skedJobTriggerHandler {
    
    public static void onAfterInsert(List<sked__job__c> newJobs) {
        statusCompletionMessage(newJobs, null);
    }
    
    public static void onAfterUpdate(List<sked__job__c> newJobs, Map<id, sked__job__c> map_id_old) {
        statusCompletionMessage(newJobs,map_id_old);
    } 
    
    public static void statusCompletionMessage(List<sked__job__c> newJobs, Map<id, sked__job__c> map_id_old) {
        Set<Id> conIds = new Set<Id>();
        for (sked__Job__c job : newJobs) {
            if (map_id_old != null) {
                if (job.sked__Job_Status__c != map_id_old.get(job.Id).sked__Job_Status__c && job.sked__Job_Status__c == 'Complete' && !String.isBlank(job.sked__Contact__c)) {
                    conIds.add(job.sked__Contact__c);
                }
            } else if (job.sked__Job_Status__c == 'Complete' && !String.isBlank(job.sked__Contact__c)) {
                conIds.add(job.sked__Contact__c);
            }
        }
        onCalloutResponse(conIds);
    }
    
    @future (callout=true) 
    public static void onCalloutResponse(Set<Id> conIds) {
        String countryCode = 'US';
        String message = 'Trial Message for SalesHood Hands on Exercise 2';
        try {
            List<Contact> conDetailList = [SELECT Id, Phone,LastName 
                                           FROM Contact 
                                           WHERE Id IN : conIds LIMIT 1];
            if (conDetailList.size() > 0) {
                String phone = conDetailList[0].Phone;
                sked.ApiResult.Sms response = sked.SkeduloAPI.sms(phone, countryCode, message); 
            }
        } catch(Exception e) {
            //Exception can be logged as well
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
    }
}
