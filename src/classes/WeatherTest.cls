/*
Copyright 2017 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
*/

@istest
private class WeatherTest {
    private static testmethod void test() {
        Util.parseJSONDateTime('2010-01-01T00:00:00Z');
        LocationService.getLocationForPostalCode('12345','US');
        try {
            LocationService.getLocationForPostalCode('','US');
            System.assert(false);
        } catch(Exception ex) {
        }

        try {
            LocationService.getLocationForLocationType('Andover MA','city');
        }
        catch(Exception ex) {
        }
        
        try {
            LocationService.getLocationForLocationType('12345','');
        }
        catch(Exception ex) {
        }
        
        try {
            LocationService.getLocationForLocationType('','');
            System.assert(false);
        } catch(Exception ex) {
        }

        WeatherLocation wl = new weatherLocation('a','b', 0, 0, '','','');

        Account a = new Account(Name = 'a', BillingCity = 'Somewhere', BillingPostalCode = '12345', BillingCountry = 'US');
        insert a;

        Contact c = new Contact(LastName = 'a', FirstName = 'a', AccountId = a.Id, MailingCity = 'Somewhere', MailingPostalCode = '12345', MailingCountry = 'US');
        insert c;

        WeatherLocation.getWeatherLocationForAccount(a.Id, 'Billing', new GeoLocation());
        WeatherLocation.getWeatherLocationForContact(c.Id, 'Mailing', new GeoLocation());

        GeoLocation gl = GeoLocation.getGeoLocationForAccount(a.Id, 'Billing');
        GeoLocation.getGeoLocationForContact(c.Id, 'Mailing');

        WeatherService.getWeather(a.Id, 'e', 'English');
        WeatherService.getCurrentWeather(new GeoLocation(), 'e');
        try {
            WeatherService.get3DayForecast(gl, 'd', 'e');
        } catch(Exception ex) {
        }
        try {
            WeatherService.get3DayForecast(gl, 'n', 'e');
        } catch(Exception ex) {
        }
        try {
            WeatherService.getAlerts(gl);
        } catch(Exception ex) {
        }
        try {
            WeatherService.callUrl('a');
        } catch(Exception ex) {
        }
        WeatherService.getAlertDetails('a');
        
        Alert all = new Alert();
        all.issueDate = System.today() - 1;
        Alert all2 = new Alert();
        all2.issueDate = System.today() - 1;
        all.compareTo(all2);
        all2.issueDate = System.today();
        all.compareTo(all2);
        all2.compareTo(all);
    }
}