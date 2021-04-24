public with sharing class BL_GDriveImageController {

    @AuraEnabled
    public static String uploadImage(Blob imageData, String fileType, String recordId) {

        BL_Team__c teamRecord = [SELECT Id, Logo_Id__c FROM BL_Team__c WHERE Id = :recordId LIMIT 1];

        if (String.isBlank(teamRecord.Logo_Id__c)) {
            return createLogoFile(imageData, fileType, teamRecord);
        } else {
            return updateLogoFile(imageData, fileType, teamRecord);

        }
    }

    private static String createLogoFile(Blob imageData, String fileType, BL_Team__c teamRecord) {
        Http http = new Http();

        HttpRequest imageBodyRequest = new HttpRequest();
        imageBodyRequest.setMethod('POST');
        imageBodyRequest.setEndpoint('callout:Google_Drive_Upload?uploadType=media');
        imageBodyRequest.setHeader('Content-Type', fileType);
        imageBodyRequest.setBodyAsBlob(EncodingUtil.base64Decode(imageData.toString()));

        HTTPResponse imageBodyResponse = http.send(imageBodyRequest);
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(imageBodyResponse.getBody());
        String imageId = (String)results.get('id');

        HttpRequest metadataRequest = new HttpRequest();
        metadataRequest.setMethod('POST');
        metadataRequest.setHeader('X-HTTP-Method-Override','PATCH');
        metadataRequest.setEndpoint('callout:Google_Drive/' + imageId);
        metadataRequest.setHeader('Content-Type','application/json');
        metadataRequest.setBody('{"name": "' + teamRecord.Id + '"}');
        HTTPResponse metadataResponse = http.send(metadataRequest);

        HttpRequest permissionRequest = new HttpRequest();
        permissionRequest.setMethod('POST');
        permissionRequest.setEndpoint('callout:Google_Drive/' + imageId + '/permissions');
        permissionRequest.setHeader('Content-Type','application/json');
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('role', 'reader');
        requestBody.put('type', 'anyone');
        requestBody.put('allowFileDiscovery', false);
        permissionRequest.setBody(JSON.serialize(requestBody));
        HTTPResponse permissionRseponse = http.send(permissionRequest);

        String logoURL = (String)results.get('webContentLink');

        teamRecord.Logo_Id__c = imageId;
        update teamRecord;

        return 'https://drive.google.com/uc?id=' + imageId + '&export=download';
    }

    private static String updateLogoFile(Blob imageData, String fileType, BL_Team__c teamRecord) {
        Http http = new Http();

        HttpRequest imageBodyRequest = new HttpRequest();
        imageBodyRequest.setMethod('POST');
        imageBodyRequest.setHeader('X-HTTP-Method-Override','PATCH');
        imageBodyRequest.setEndpoint('callout:Google_Drive_Upload/' + teamRecord.Logo_Id__c + '/?uploadType=media');
        imageBodyRequest.setHeader('Content-Type', fileType);
        imageBodyRequest.setBodyAsBlob(EncodingUtil.base64Decode(imageData.toString()));

        HTTPResponse imageBodyResponse = http.send(imageBodyRequest);
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(imageBodyResponse.getBody());
        String imageId = (String)results.get('id');

        return 'https://drive.google.com/uc?id=' + imageId + '&export=download';
    }
}