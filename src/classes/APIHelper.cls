/*
Copyright 2017 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
*/

public class APIHelper {
    static Map<String, API__mdt> apis = null;

    public static API__mdt getAPI(String key) {
        if (apis == null) {
            apis = new Map<String, API__mdt>();
            for (API__mdt api : [select MasterLabel, QualifiedApiName, API_User__c, API_Key__c from API__mdt]) {
                apis.put(api.MasterLabel.toLowerCase(), api);
            }
        }
        API__mdt api = apis.get(key.toLowerCase());
        if (api == null) {
            throw new APIException(System.Label.err_unable_to_load_api_metadata);
        }
        return api;
    }

    public static API__mdt getAPI_SUNWeather() {
        return getAPI('SUN Weather');
    }
    
    class APIException extends Exception {}
}