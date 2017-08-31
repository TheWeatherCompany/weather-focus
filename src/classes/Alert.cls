/*
Copyright 2017 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
*/

global with sharing class Alert implements Comparable {
	@AuraEnabled public String key;
	@AuraEnabled public String detailKey;
	@AuraEnabled public String significance;
	@AuraEnabled public Integer severityCd;
    @AuraEnabled public String headline;
    @AuraEnabled public DateTime effectiveFrom;
    @AuraEnabled public DateTime effectiveTo;
    @AuraEnabled public DateTime issueDate;
    @AuraEnabled public String description;
    @AuraEnabled public Integer certaintyCode;
    @AuraEnabled public List<Integer> responseTypeCode;
    @AuraEnabled public Long effectiveFromLong;
    
    global Integer compareTo(Object compareTo) {
		Alert compareToAlert = (Alert)compareTo;
		if (issueDate == compareToAlert.issueDate) return 0;
		if (issueDate < compareToAlert.issueDate) return 1;
		return -1;       
    }
}