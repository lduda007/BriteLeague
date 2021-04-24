/**
 * @author Mateusz Przywara
 * @date   2016-10-12
 * @description BTN_ChatterUtils
*/
public class BTN_ChatterUtils {
    public static String CHATTER_FEED_GROUP_RECORD = 'AllNetworks';
    public static String CHATTER_FEED_VISIBILITY = 'AllUsers';

    private static String hrGroupName = BTN_ConstantRepo.HUMAN_RESOURCES_GROUP_NAME;

    // cache Collaboration Group - This data cannot be changed during transaction.
    public static CollaborationGroup HUMAN_RESOURCES_GROUP {
        set;
        get {
            String hrGroupName = (Test.isRunningTest()) ? BTN_TestDataFactory.TEST_HR_COLLABORATION_GROUP_NAME : BTN_ConstantRepo.HUMAN_RESOURCES_GROUP_NAME;
            if (HUMAN_RESOURCES_GROUP == null) {
                HUMAN_RESOURCES_GROUP =
                        new BTN_DAO_CollaborationGroup().findGroupByName(hrGroupName);
            }
            return HUMAN_RESOURCES_GROUP;
    }}

    /**
     * @author Mateusz Przywara
     * @date   2016-10-12
     * @description postEvents Post Feed Items on the Contact and optionally on Candidates related to Contact
     * @return void
    */
    public static List<Database.SaveResult> postEvents(List<BTN_Event__c> events) {
        List<FeedItem> posts = new List<FeedItem>();
        Set<Id> contactIds = new Set<Id>();
        Set<Id> candidateIds = new Set<Id>();
        Id parentIdForFeedItem;
        for (BTN_Event__c eventItem : events) {
            if (BTN_RecordTypeUtils.isGeneral(eventItem)) {
                parentIdForFeedItem = eventItem.Interviewed__c;
            } else {
                parentIdForFeedItem = eventItem.Candidate__c;
                if(BTN_RecordTypeUtils.isInterview(eventItem) && eventItem.Candidate__c!=null){
                    candidateIds.add(eventItem.Candidate__c);
                }
            }
            if (!BTN_ValidationHandler.isNull(parentIdForFeedItem)) {
                posts.add(new FeedItem(
                        Body = eventItem.Type__c + ' ' + System.Label.HasBeenCreated,
                        ParentId = parentIdForFeedItem,
                        Visibility = CHATTER_FEED_VISIBILITY,
                        NetworkScope = CHATTER_FEED_GROUP_RECORD)
                );
            }
            contactIds.add(eventItem.Interviewed__c);
        }
        // Retrieve Candidates for Events
        List<BTN_CV__c> candidates = new List<BTN_CV__c>(new BTN_DAO_Candidate().findCandidatesInContactSet(contactIds));
        //iterate again to build FeedItems for related Candidates
        for (BTN_Event__c eventItem : events) {
            if (eventItem.PostOnRelatedCandidates__c) {
                for (BTN_CV__c candidate : candidates) {
                    if (candidate.Contact__c.equals(eventItem.Interviewed__c)) {
                        posts.add(new FeedItem(
                                Body = eventItem.Description__c,
                                ParentId = candidate.Id,
                                Visibility = CHATTER_FEED_VISIBILITY,
                                NetworkScope = CHATTER_FEED_GROUP_RECORD)
                        );
                    }
                }
            }
        }
        if(!candidateIds.isEmpty()){
            changeStatusOfCandidates(candidates,candidateIds);
        }
        return Database.insert(posts);
    }
    public static void changeStatusOfCandidates(List<BTN_CV__c> dbCondidates,Set<Id> candidateIds){
        List<BTN_CV__c> candidatesToBeUpdated = new  List<BTN_CV__c>();
        for (BTN_CV__c candidate : dbCondidates) {
            if (candidateIds.contains(candidate.Id)&&candidate.Status__c.equals('Open')) {
                candidate.Status__c = 'Interview-in-progress';
                candidatesToBeUpdated.add(candidate);
            }
        }
        update candidatesToBeUpdated;
    }
    /**
     * @author Mateusz Przywara
     * @date   2016-10-20
     * @description postChangesOnGroup Post Feed Items on Collaboration Group
     * @param oldObjectList List of sObjects before changes
     * @param newObjectMap Map of Fields after changes
     * @param trackingFieldNameSet API names of fields to track
     * @param recordsNameField API of field with Full Name of Contact / Candidate etc.
     * @param groupId Parent for FeedItems
     * @return List<Database.SaveResult> FeedItem List DML result
    */
    public static List<Database.SaveResult> postChangesOnGroup(
            List<sObject> oldObjectList,
            Map<Id, sObject> newObjectMap,
            Set<String> trackingFieldNameSet,
            String recordsNameField,
            Id groupId,
            String scopeName
    ) {
        List<FeedItem> posts = new List<FeedItem>();
        String tmpChanges = '';
        Set<String> objectsWithLink  = BTN_Utils.getSetValuesByName('ObjectsWithChatterLink');
        String domain = getDomain();
        for (sObject oldObjectItem : oldObjectList) {
            for (String fieldName : trackingFieldNameSet) {
                if (!oldObjectItem.get(fieldName).equals(newObjectMap.get(oldObjectItem.Id).get(fieldName))) {
                    tmpChanges +=
                            String.format(
                                    //{0} of {1} {2} has been changed from {3} to {4}
                                    System.Label.ChangeOnCandidate,
                                    new List<String>{
                                            Schema.getGlobalDescribe().get(oldObjectItem.getSobjectType().getDescribe().getName()).getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel(),
                                            oldObjectItem.getSobjectType().getDescribe().getLabel(),
                                            String.valueOf(oldObjectItem.get(recordsNameField)),
                                            String.valueOf(oldObjectItem.get(fieldName)),
                                            String.valueOf(newObjectMap.get(oldObjectItem.Id).get(fieldName))
                                    }
                            );
                }
            }
            if (String.isBlank(tmpChanges)) {
                tmpChanges =
                        oldObjectItem.getSObjectType().getDescribe().getLabel()
                                + ' ' + oldObjectItem.get(recordsNameField)
                                + ' ' + System.Label.hasBeenUpdated;
            }
            if(!domain.equals('not exist')&& objectsWithLink.contains(oldObjectItem.getSobjectType().getDescribe().getName())){
                tmpChanges = checkIfLinkNeeded(oldObjectItem,tmpChanges,domain);
            }

            posts.add(new FeedItem(
                    Body = tmpChanges,
                    ParentId = groupId,
                    Visibility = CHATTER_FEED_VISIBILITY,
                    NetworkScope = scopeName)
            );
        }
        return Database.insert(posts);
    }
    private static String checkIfLinkNeeded(SObject record,String oldMessage,String domain ){
        return oldMessage + ' https://'+domain+'/'+ record.Id +' ';

    }
    private static String getDomain(){
        List<Domain> domainList = [SELECT Domain,DomainType FROM Domain];
        if(domainList.isEmpty()){
            return 'not exist';
        }else{
            return domainList[0].Domain;
        }


    }
    /**
     * @author Mateusz Przywara
     * @date   2016-10-20
     * @description postChangesOnGroup Post Feed Items on Collaboration Group
     * @param oldObjectList List of sObjects before changes
     * @param newObjectMap Map of Fields after changes
     * @param trackingFieldNameSet API names of fields to track
     * @return List<Database.SaveResult> FeedItem List DML result
    */
    public static List<Database.SaveResult> postChangesOnHumanResourcesGroup(
            List<sObject> oldObjectList,
            Map<Id, sObject> newObjectMap,
            Set<String> trackingFieldNameSet,
            String recordsNameField
    ) {
        return postChangesOnGroup(
                oldObjectList,
                newObjectMap,
                trackingFieldNameSet,
                recordsNameField,
                BTN_ChatterUtils.HUMAN_RESOURCES_GROUP.Id,
                BTN_ChatterUtils.HUMAN_RESOURCES_GROUP.NetworkId
        );
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-13
     * @description postChangesOnGroup Post Feed Items on Collaboration Group
     * @param oldObjectList List of sObjects before changes
     * @param newObjectMap Map of Fields after changes
     * @param recordsNameField API of field with Full Name of Contact / Candidate etc.
     * @param groupId Parent for FeedItems
     * @param String Scope Id of Network(Community) or CHATTER_FEED_GROUP_RECORD to post on record feed
     * @return void
    */
    public static List<Database.SaveResult> postInsertsOnGroup(
            Map<Id, sObject> newObjectMap,
            String recordsNameField,
            Id groupId,
            String scopeName
    ) {
        List<FeedItem> posts = new List<FeedItem>();
        Set<String> objectsWithLink  = BTN_Utils.getSetValuesByName('ObjectsWithChatterLink');
        String domain = getDomain();
        for (sObject objectItem : newObjectMap.values()) {
            String feedBody = objectItem.getSObjectType().getDescribe().getLabel()
                    + ' ' + objectItem.get(recordsNameField)
                    + ' ' + System.Label.hasBeenCreated;
            if(!domain.equals('not exist')&& objectsWithLink.contains(objectItem.getSobjectType().getDescribe().getName())){
                feedBody = checkIfLinkNeeded(objectItem,feedBody,domain);
            }
            posts.add(new FeedItem(
                    Body = feedBody,
                    ParentId = groupId,
                    Visibility = CHATTER_FEED_VISIBILITY,
                    NetworkScope = scopeName)
            );
        }
        return Database.insert(posts);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-13
     * @description postChangesOnGroup Post Feed Items on Collaboration Group
     * @param oldObjectList List of sObjects before changes
     * @param newObjectMap Map of Fields after changes
     * @param recordsNameField API of field with Full Name of Contact / Candidate etc.
     * @return void
    */
    public static List<Database.SaveResult> postInsertsOnHumanResourcesGroup(
            Map<Id, sObject> newObjectMap,
            String recordsNameField
    ) {
        return postInsertsOnGroup(
                newObjectMap,
                recordsNameField,
                BTN_ChatterUtils.HUMAN_RESOURCES_GROUP.Id,
                BTN_ChatterUtils.HUMAN_RESOURCES_GROUP.NetworkId
        );
    }
}