/*
Copyright 2017 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
*/

public with sharing class GeoLocation {
    @AuraEnabled public Decimal latitude;
    @AuraEnabled public Decimal longitude;
	@AuraEnabled public String city;
    @AuraEnabled public String state;
    @AuraEnabled public String country;
   	@AuraEnabled public String address;
   	@AuraEnabled public String postalCode;
    @AuraEnabled public String countryCode; 
    @AuraEnabled public String adminDistrict;
   	
    public Boolean isValid() {
        return latitude != null && longitude != null;
    }

	public static GeoLocation getGeoLocationForAccount(Id accountId, String addressField) {
        Account acct = [select Id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude,
            ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingLatitude, ShippingLongitude from Account where Id = :accountId];

        return getGeoLocationFromSObject(acct, addressField);
    }
    public static GeoLocation getGeoLocationForContact(Id contactId, String addressField) {
        Contact cont = [select Id, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude,
            OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry, OtherLatitude, OtherLongitude from Contact where Id = :contactId];

        return getGeoLocationFromSObject(cont, addressField);
    }
    private static GeoLocation getGeoLocationFromSObject(SObject obj, String addressField) {
        GeoLocation gl = new GeoLocation();
        gl.latitude = (Decimal)obj.get(addressField + 'Latitude');
        gl.longitude = (Decimal)obj.get(addressField + 'Longitude');
		String postalCode = (String)obj.get(addressField + 'PostalCode');
        String country = (String)obj.get(addressField + 'Country');
        
        if ((gl == null || !gl.isValid()) && (String.isNotEmpty(postalCode) && String.isNotEmpty(country))) {
            
            if (country.startsWithIgnoreCase('ca') || (postalCode.length() >= 2 && postalCode.substring(0, 1).isNumeric() != postalCode.substring(1, 2).isNumeric())) {
                postalCode = postalCode.toUpperCase();
            	country = 'CA';
            } else {
				country = 'US';
            }
                
            if (country == 'US' && postalCode.length() > 5)
            	postalCode = postalCode.substring(0, 5);

            if (country == 'CA' && postalCode.length() > 3)
                postalCode = postalCode.substring(0, 3);
		    
            try {
            	gl = LocationService.getLocationForPostalCode(postalCode, country);
            } catch(Exception ex) {
                System.debug(ex);
            }
        }
        String address = '';
        address += (obj.get(addressField + 'Street')==null) ? '' : (String)obj.get(addressField + 'Street') + ' ';
        address += (obj.get(addressField + 'City')==null) ? '' : (String)obj.get(addressField + 'City') + ' ';
        address += (obj.get(addressField + 'State')==null) ? '' : (String)obj.get(addressField + 'State') + ' ';
        address += (obj.get(addressField + 'PostalCode')==null) ? '' : (String)obj.get(addressField + 'PostalCode') + ' ';
        address += (obj.get(addressField + 'Country')==null) ? '' : (String)obj.get(addressField + 'Country');
        
		if ((gl == null || !gl.isValid()) && (String.isNotEmpty(postalCode) && String.isNotEmpty(country))) {              
            if(!String.isEmpty((String)obj.get(addressField + 'City')) || !String.isEmpty((String)obj.get(addressField + 'State')))
	            gl = LocationService.getLocationForLocationType(address,'city');
        }
        if(gl == null || !gl.isValid()) {          
            if(!String.isEmpty((String)obj.get(addressField + 'City')) || !String.isEmpty((String)obj.get(addressField + 'State')))
	            gl = LocationService.getLocationForLocationType(address,'address');
        }
        if (gl == null || !gl.isValid()) {
            throw new GeoLocationException(System.Label.err_unable_to_determine_location);
        }
	gl.postalCode = postalCode;
        return gl;
	}
	class GeoLocationException extends Exception{}
}
