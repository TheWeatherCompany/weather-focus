/*
Copyright 2017 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
*/

({
    init: function(component) {
        var isMockup = component.get('v.useMockup')
        if (isMockup){
            this.loadMockup(component);
        }
        else {
	        this.loadWeather(component);
        }
    },

    initMap: function(component) {
      var latitude = component.get('v.weatherLocation.latitude');
      var longitude = component.get('v.weatherLocation.longitude');
      var map_container = component.find("map").getElement();

      /**
       * This code hides map div if you are using map - remove it
       */
      var map_controls = component.find("map_controls").getElement();
      map_container.style.display = 'none';
      map_controls.style.display = 'none';

      /**
       * Add your code that initializes the map and put the map to map_container(div)
       */

      /**
       * You may save the pointer to the map to access it in other functions
       * component.set('v.mapReference', your map id);
       * window[mapp.id] = map;
       */

      /**
       * Add callback if there is timeout in loading map
       * map.absoluteTimeout.addListener(() => {this.mapTimeout(component);});
       */

      /**
       * Change the attribute mapLoaded to true to display the map
       * component.set('v.mapLoaded', true);
       */

    },
    loadAlertDetails: function(component, key) {
        var action = component.get('c.getAlertDetails');
        action.setParams({
            alertDetailKey: key
        });

        action.setCallback(this, function(a) {
            var ret = a.getReturnValue();
            var errorMessage = '';

            if (ret) {
                if (ret.success) {
                    component.set('v.currentAlert.details', ret.alertDetails);
                } else {
                    errorMessage = ret.error;
                }
            } else {
                errorMessage = a.getError()[0].message;
            }

            component.set('v.errorMessage', errorMessage);
        })
        $A.enqueueAction(action);
    },

   loadMockup : function(component) {
        if (!component.get('v.scriptsLoaded') || !component.get('v.domLoaded') || component.get('v.weatherLoading')) return;
		//component.set('v.weatherLoading', true);
        component.set('v.weatherLocation',{city: $A.get("$Label.c.mock_city"),state: $A.get("$Label.c.mock_state"), countryCode:'US'});
        component.set('v.currentConditions', {feelsLikeTemp:"40",iconCode:"28",phrase: $A.get("$Label.c.mock_phrase"),temp:"45", asOf: new Date().toLocaleString()});
        component.set('v.alerts', [{headline: $A.get("$Label.c.mock_alert1_title"),severityCd:2,significance:"W"},{headline: $A.get("$Label.c.mock_alert2_title"),severityCd:4,significance:"Y"},{headline: $A.get("$Label.c.mock_alert3_title"),severityCd:5,significance:"S"}]);
        component.set('v.severeAlertImage','/alert-warning.svg');
        component.set('v.forecast', {chanceOfPrecip:"0",maxTemp:"100",minTemp:"10",precipAmount:"10.0",precipType: $A.get("$Label.c.mock_precip_type"),windDirectionCardinal: $A.get("$Label.c.mock_wind_dir"),windSpeed:"8"});
        component.set('v.weatherURL', 'https://weather.com/redir?page=tenday&id=38.902,-77.040&par=salesforce_weatherfocus&locale=en-US');
        component.set('v.selTabId', 'current');
        component.set('v.weatherLoading', false);
        component.set('v.weatherLoaded', true);
        component.set('v.actions',{'allowCallLog':true, 'allowNewCase':true, 'allowNewEvent':true, 'allowNewOpportunity':true, 'allowNewTask':true, 'hasAction':true});
        this.refreshTabs(component);
	},

	loadWeather : function(component) {
        if (!component.get('v.scriptsLoaded') || !component.get('v.domLoaded') || component.get('v.weatherLoading')) return;

        var action = component.get("c.getWeather");
        component.set('v.weatherLoading', true);

        action.setParams({
            recordId: component.get('v.recordId'),
            units: component.get('v.units'),
            addressField: component.get('v.addressType')
        });
        action.setCallback(this, function(a) {
            var ret = a.getReturnValue();
            var weatherLoaded = false;
            var errorMessage = '';
            if (ret) {
                if (ret.success) {
                    component.set('v.currentConditions', ret.condition);
                    component.set('v.alerts', ret.alerts);
                    component.set('v.forecast', ret.forecast);
                    component.set('v.weatherLocation',ret.location);
                    component.set('v.weatherURL', ret.weatherURL);
                    component.set('v.selTabId', 'current');
                    component.set('v.actions', ret.actions);
                    if(ret.severeAlert=='W') {
                        component.set('v.severeAlertImage','/alert-warning.svg');
                    }
                    else if(ret.severeAlert=='A') {
                        component.set('v.severeAlertImage','/alert-watch.svg');
                    }
                    else if(ret.severeAlert=='Y') {
                        component.set('v.severeAlertImage','/alert-advisory.svg');
                    }
                    else if(ret.severeAlert=='S') {
                        component.set('v.severeAlertImage','/alert-statement.svg');
                    }
                    weatherLoaded = true;
                } else {
		    component.set('v.hasPurchasedKey', ret.hasPurchasedKey);
                    errorMessage = ret.error;
                }
            } else {
                errorMessage = a.getError()[0].message;
            }

            component.set('v.errorMessage', errorMessage);
			component.set('v.weatherLoading', false);
            component.set('v.weatherLoaded', weatherLoaded);

            this.refreshTabs(component);
        })
        $A.enqueueAction(action);
	},
    refreshTabs: function(component) {

        component.find('map_container').getElement().style.display = 'none';
        component.find('tab_current').getElement().style.display = 'none';
        component.find('tab_alerts').getElement().style.display = 'none';
        component.find('alerts_list').getElement().style.display = 'none';
        component.find('alert_detail').getElement().style.display = 'none';
        if (!component.get('v.weatherLoaded')) return;

        var isMockup = component.get('v.useMockup');
      	if (isMockup) {
            component.find('mockup_map').getElement().style.display = '';
          	component.find('map_container').getElement().style.display = 'none';
      	}
        if (!isMockup){
	        if (!component.get('v.mapLoaded')) {
                component.find('map_container').getElement().style.display = '';
                this.initMap(component);
	        }
			else {
				/** Get you map pointer.
				 * If you used the method described above use the following command to retrieve your map pointer
				 * var mapId = component.get('v.mapReference');
				 * var map = window[mapId];
				 */

                var latitude = component.get('v.weatherLocation.latitude');
                var longitude = component.get('v.weatherLocation.longitude');

				/**
				 * Move the map to latitude and longitude from above
				 * You may also add a marker
				 */
        	}
        }

       	var idd = component.get('v.selTabId');
        var currentAlert = component.get('v.currentAlert');
        if ((idd == 'current' || !currentAlert) && !isMockup) component.find('map_container').getElement().style.display = '';
        if (idd == 'current') {
            component.find('tab_current').getElement().style.display = '';
        }
        if (idd == 'alert') {
            component.find('tab_alerts').getElement().style.display = '';
        }
        if (!currentAlert) component.find('alerts_list').getElement().style.display = '';
        else {
            component.find('alert_detail').getElement().style.display = '';
            if (isMockup && !(idd == 'current')) component.find('mockup_map').getElement().style.display = 'none';
        }
	},

	addMapMarker: function(component) {
     /**
      * You may implement here your custom marker for the map
      * and call this using this.addMapMarker(component)
      */
    },

	mapTimeout: function(component) {
	  var container = component.find('map_timeout_container').getElement();
	  container.style.display = 'block';

	  /**
	   * Display your custom timeout message
	   */
	}
})
