/*
Copyright 2017 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
*/

public with sharing class WeatherLocation {
   @AuraEnabled public String city;
   @AuraEnabled public String state;
   @AuraEnabled public Decimal latitude;
   @AuraEnabled public Decimal longitude;
   @AuraEnabled public String country;
   @AuraEnabled public String address;
   @AuraEnabled public String postalCode;
   @AuraEnabled public String countryCode; 
   @AuraEnabled public String adminDistrict;
   
   public WeatherLocation(String city, String state, Decimal latitude, Decimal longitude, String country, String address, String postalCode) {
       this.city = city;
       this.state = state;
       this.latitude = latitude;
       this.longitude = longitude;
       this.country = country;
       this.address = address;
       this.postalCode = postalCode;
   }

    public static WeatherLocation getWeatherLocationForAccount(Id accountId, String addressField, GeoLocation gl) {
        Account acct = [select Id, BillingCity, BillingState, BillingStreet, ShippingCity, ShippingState, ShippingStreet from Account where Id = :accountId];
        if (!Schema.sObjectType.Account.fields.getMap().get(addressField + 'City').getDescribe().isAccessible()) {
        	return null;
        }
        return new WeatherLocation((String)acct.get(addressField + 'City'), (String)acct.get(addressField + 'State'), gl.latitude, gl.longitude, gl.country, (String)acct.get(addressField + 'Street'), gl.postalCode);
    }

    public static WeatherLocation getWeatherLocationForContact(Id contactId, String addressField, GeoLocation gl) {
        Contact c = [select Id, MailingCity, MailingState, MailingStreet, OtherCity, OtherState, OtherStreet from Contact where Id = :contactId];
        if (!Schema.sObjectType.Contact.fields.getMap().get(addressField + 'City').getDescribe().isAccessible()) {
        	return null;
        }
        return new WeatherLocation((String)c.get(addressField + 'City'), (String)c.get(addressField + 'State'), gl.latitude, gl.longitude, gl.country, (String)c.get(addressField + 'Street'), gl.postalCode);
    }
}