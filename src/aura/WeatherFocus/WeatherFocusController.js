/*
Copyright 2017 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
*/

({
	doInit : function(component, event, helper) {
        if (component.get('v.domLoaded')) return;
        component.set('v.domLoaded', true);
        helper.init(component);
    },
    afterScriptsLoaded: function(component, event, helper) {
    	/**
    	 * Use this function to execute the code you would like to run after the map code is loaded
    	 */
    	if (component.get('v.scriptsLoaded')) return;
        component.set('v.scriptsLoaded', true);
        helper.init(component);
	},
	handleTabChange: function(component, event, helper) {
        helper.refreshTabs(component);
	},
    reloadWeather: function(component, event, helper) {
        helper.loadWeather(component);
    },
    gotoCurrentTab: function(component, event, helper) {
        component.set('v.selTabId', 'current');
    },
    gotoAlertTab: function(component, event, helper) {
        component.set('v.selTabId', 'alert');
    },
    loadAlertDetail: function(component, event, helper) {
        var isMockup = component.get('v.useMockup');
        if (isMockup){
        	var mockAlerts = {};
        	mockAlerts[$A.get("$Label.c.mock_alert1_title")]=$A.get("$Label.c.mock_alert1_description");
        	mockAlerts[$A.get("$Label.c.mock_alert2_title")]=$A.get("$Label.c.mock_alert2_description");
        	mockAlerts[$A.get("$Label.c.mock_alert3_title")]=$A.get("$Label.c.mock_alert3_description");
            var tg = event.currentTarget;
	        var text = tg.text;
            component.set('v.currentAlert', {});
            component.set('v.currentAlert.details.headline', $A.get("$Label.c.alert") +' '+ text);
            component.set('v.currentAlert.details.overview',  mockAlerts[text]);
        	helper.refreshTabs(component);
            return;
        }
        	var tg = event.currentTarget;
        var key = tg.getAttribute('data-key');
        component.set('v.currentAlert', {});
        helper.refreshTabs(component);
        helper.loadAlertDetails(component, key);
    },
    closeAlertDetail: function(component, event, helper) {
        component.set('v.currentAlert', null);
        helper.refreshTabs(component);
    },
    mapZoom: function(component, event, helper) {
        var tg = event.currentTarget;
        var action = tg.getAttribute('data-action');
        /**
    	 * Add your call to zoom in/out the map
    	 * if (action == 'in')
    	 *
    	 * else if (action == 'out')
    	 */
    },

    handleAction: function(component, event, helper) {
        var sel = event.getParam("value");
        var obj = component.get('v.sObjectName');
        var accountId = component.get('v.actions.accountId');

        if (sel == 'task' || sel == 'call') {
            var evt = $A.get("e.force:createRecord");
            var defValues = {
                'ActivityDate': new Date(),
                'WhatId': accountId
            };
            if (sel == 'call') {
                defValues['Subject'] = 'Call';
                defValues['Status'] = 'Completed';
            }
            if (obj == 'Contact') {
                defValues['WhoId'] = component.get('v.recordId');
            }

            evt.setParams({
               'entityApiName':'Task',
               'defaultFieldValues': defValues
            });
            evt.fire();
        } else if (sel == 'event') {
            var evt = $A.get("e.force:createRecord");
            var defValues = {
                'WhatId': accountId
            };
            if (obj == 'Contact') {
                defValues['WhoId'] = component.get('v.recordId');
            }

            evt.setParams({
               'entityApiName':'Event',
               'defaultFieldValues': defValues
            });
            evt.fire();
        } else if (sel == 'case') {
			var evt = $A.get("e.force:createRecord");
            var defValues = {
                'AccountId': accountId
            };
            if (obj == 'Contact') {
                defValues['ContactId'] = component.get('v.recordId');
            }

            evt.setParams({
               'entityApiName':'Case',
               'defaultFieldValues': defValues
            });
            evt.fire();
        } else if (sel == 'opportunity') {
			var evt = $A.get("e.force:createRecord");
            var defValues = {
                'AccountId': accountId
            };

            evt.setParams({
               'entityApiName':'Opportunity',
               'defaultFieldValues': defValues
            });
            evt.fire();
        } else if(sel == 'Metric') {
            component.set('v.units','Metric');
            helper.loadWeather(component);
        } else if(sel == 'English') {
            component.set('v.units','English');
            helper.loadWeather(component);
        }
    }
})
