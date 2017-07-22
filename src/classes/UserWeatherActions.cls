/*
Copyright 2017 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
*/

public class UserWeatherActions {
    @AuraEnabled public Id accountId;
    @AuraEnabled public Boolean hasAction = false;

    @AuraEnabled public Boolean allowNewCase = false;
    @AuraEnabled public Boolean allowNewOpportunity = false;
    @AuraEnabled public Boolean allowNewTask = false;
    @AuraEnabled public Boolean allowCallLog = false;
    @AuraEnabled public Boolean allowNewEvent = false;
    public UserWeatherActions(Id recordId) {
        String objType = recordId.getSObjectType().getDescribe().getName();
        if (objType == 'Account') accountId = recordId;
        else if (objType == 'Contact') accountId = [select AccountId from Contact where Id = :recordId].AccountId;

        if (Type.forName('Case') != null) {
            allowNewCase = schema.getglobaldescribe().get('Case').getdescribe().iscreateable();
            hasAction = true;
        }
        if (Type.forName('Opportunity') != null) {
            allowNewOpportunity = schema.getglobaldescribe().get('Opportunity').getdescribe().iscreateable();
            hasAction = true;
        }
        if (Type.forName('Task') != null) {
            allowNewTask = allowCallLog = schema.getglobaldescribe().get('Task').getdescribe().iscreateable();
            hasAction = true;
        }
        if (Type.forName('Event') != null) {
            allowNewEvent = allowCallLog = schema.getglobaldescribe().get('Event').getdescribe().iscreateable();
            hasAction = true;
        }
    }
}