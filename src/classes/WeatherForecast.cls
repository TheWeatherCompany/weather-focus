/*
Copyright 2017 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
*/

public with sharing class WeatherForecast {
	@AuraEnabled public String minTemp;
	@AuraEnabled public String maxTemp;
    @AuraEnabled public String chanceOfPrecip;
    @AuraEnabled public String windSpeed;
    @AuraEnabled public String windDirectionCardinal;
    @AuraEnabled public String precipType;
    @AuraEnabled public String precipAmount;
}