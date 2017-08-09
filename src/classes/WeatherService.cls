/*
Copyright 2017 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
*/

public with sharing class WeatherService {
    private static final String ENDPOINT = 'https://api.weather.com';
    private static String severeSignificance;
    private static Boolean key = true;
    
    @AuraEnabled
    public static WeatherDetailsResponse getWeather(Id recordId, String units, String addressField) {
        if (units == 'Metric') units = 'm';
        else units = 'e';

        String objType = recordId.getSObjectType().getDescribe().getName();

        WeatherDetailsResponse resp = new WeatherDetailsResponse();
        try {
            resp.actions = new UserWeatherActions(recordId);

            GeoLocation gl = objType == 'Account' ? GeoLocation.getGeoLocationForAccount(recordId, addressField) : GeoLocation.getGeoLocationForContact(recordId, addressField);

            resp.condition = getCurrentWeather(gl, units);
            resp.forecast = get3DayForecast(gl, resp.condition.dayInd, units);
            resp.alerts = getAlerts(gl);
            resp.location = objType == 'Account' ? WeatherLocation.getWeatherLocationForAccount(recordId, addressField, gl) : WeatherLocation.getWeatherLocationForContact(recordId, addressField, gl);
            resp.location.city = gl.city;
            resp.location.state = gl.state;
            resp.location.postalCode = 'Postal Code ' + gl.postalCode;
            resp.location.countryCode = gl.countryCode;
            resp.location.adminDistrict = gl.adminDistrict;
            resp.weatherURL = 'https://weather.com/redir?page=tenday&id=' + String.valueOf(gl.latitude) + ',' + String.valueOf(gl.longitude) + 
                     '&par=salesforce_weatherfocus&locale=en-US';
            resp.success = true;
            resp.severeAlert = severeSignificance;
        } catch(Exception ex) {
            resp.hasPurchasedKey = key;
            resp.error = ex.getMessage();
            resp.success = false;
        }

        return resp;
    }

    @AuraEnabled
    public static WeatherAlertDetailsResponse getAlertDetails(String alertDetailKey) {
        WeatherAlertDetailsResponse ret = new WeatherAlertDetailsResponse();
        try {
            ret.success = true;

            Map<String, Object> resp = new Map<String, Object>();
            if (!Test.isRunningTest()) {
                resp = callUrl('/v1/alert/' + alertDetailKey + '/details.json');                
            } else {
                resp = new Map<String, Object> { 'alertDetail' => new Map<String, Object> {} };
            }

            resp = (Map<String, Object>)resp.get('alertDetail');
            if (resp == null) throw new WeatherServiceException(System.Label.err_invalid_api_response_received);

            ret.alertDetails = new AlertDetails();
            ret.alertDetails.areaName = (String)resp.get('area_name');
            ret.alertDetails.headline = (String)resp.get('headline_text');

            List<Object> respo = (List<Object>)resp.get('texts');
            if (respo != null && !respo.isEmpty()) {
                resp = (Map<String, Object>)respo[0];
                ret.alertDetails.description = (String)resp.get('description');
                ret.alertDetails.overview = (String)resp.get('overview');
                ret.alertDetails.instruction = (String)resp.get('instruction');
            }
        } catch(Exception ex) {
            ret.error = ex.getMessage();
            ret.success = false;
        }
        return ret;
    }

    public static Map<String, Object> callUrl(String url) {
        API__mdt apiInfo;
        try {
         apiInfo = APIHelper.getAPI_SUNWeather();
        }
        catch(Exception e){
            key = false;
            throw new WeatherServiceException(e.getMessage());            
        }

        if (url.indexOf('?') < 0) url += '?';
        url += '&language=en-US&apiKey=' + apiInfo.API_Key__c;

        HttpRequest request = new HttpRequest();
        request.setEndpoint(ENDPOINT + url);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        String body = null;
        if (Test.isRunningTest()) {
            body = '{"errors":[{"error":{"message":""}}]}';
        } else {
            HttpResponse response = http.send(request);
            body = response.getBody();
        }

        Map<String, Object> resp = (Map<String, Object>)JSON.deserializeUntyped(body);
        List<Object> errors = (List<Object>)resp.get('errors');
        if (errors != null && !errors.isEmpty()) {
            Map<String, Object> error = (Map<String, Object>)errors[0];
            error = (Map<String, Object>)error.get('error');
            if(!(((String)error.get('message')).equals('Invalid apiKey.')))
            	throw new WeatherAPIException((String)error.get('code'), (String)error.get('message'));
            else {
                key = false;
                throw new WeatherAPIException((String)error.get('code'), Label.err_noAPI_Key); 
            }
        }
        return resp;
    }

    public static WeatherForecast get3DayForecast(GeoLocation gl, String dayInd, String units) {
        Map<String, Object> resp = null;
        if (!Test.isRunningTest()) {
            resp = callUrl('/v1/geocode/' + gl.latitude + '/' + gl.longitude + '/forecast/daily/3day.json?units=' + units);
        } else {
            resp = new Map<String, Object> { 'forecasts' => new List<Object> { new Map<String, Object> {'night' => new Map<String, Object> {'wspd' => 0, 'qpf' => 0, 'pop' => 0}, 'day' => new Map<String, Object> {'wspd' => 0, 'qpf' => 0, 'pop' => 0}, 'min_temp' => 0, 'max_temp' => 0 } } };
        }
        List<Object> respo = (List<Object>)resp.get('forecasts');
        if (respo == null || respo.isEmpty()) throw new WeatherServiceException(System.Label.err_invalid_api_response_received);

        WeatherForecast ret = new WeatherForecast();
        resp = (Map<String, Object>)respo[0];

        ret.minTemp = (resp.get('min_temp')==null) ? 'N/A' : '' + resp.get('min_temp');      
        ret.maxTemp = (resp.get('max_temp')==null) ? 'N/A' : '' + resp.get('max_temp'); 
        
        if (dayInd == 'd') {
            if ((Map<String, Object>)resp.get('day') != null)
              resp = (Map<String, Object>)resp.get('day');
            else
              resp = (Map<String, Object>)resp.get('night');
        }
        else if (dayInd == 'n') {
            if ((Map<String, Object>)resp.get('night') != null)
              resp = (Map<String, Object>)resp.get('night');
            else
              resp = (Map<String, Object>)resp.get('day');
        }
        
        ret.windSpeed = (resp.get('wspd')==null) ? 'N/A' : '' + resp.get('wspd');
        ret.windDirectionCardinal = (resp.get('wdir_cardinal')==null) ? 'N/A' : '' + resp.get('wdir_cardinal');
        ret.chanceOfPrecip = (resp.get('pop')==null) ? 'N/A' : '' + resp.get('pop');
        ret.precipType = (resp.get('precip_type')==null) ?'N/A' : '' + resp.get('precip_type');
        ret.precipAmount = (resp.get('qpf')==null) ? 'N/A' : '' + resp.get('qpf');    

        return ret;
    }

    public static WeatherCondition getCurrentWeather(GeoLocation gl, String units) {
        Map<String, Object> resp = null;

        if (!Test.isRunningTest()) {
            resp = callUrl('/v1/geocode/' + gl.latitude + '/' + gl.longitude + '/observations.json?units=' + units);
        } else {
            resp = new Map<String, Object> { 'observation' => new Map<String, Object> { 'valid_time_gmt' => 1494946380, 'imperial' => new Map<String, Object> {}, 'metric' => new Map<String, object> {}}};
        }

        resp = (Map<String, Object>)resp.get('observation');
        if (resp == null) throw new WeatherServiceException(System.Label.err_invalid_api_response_received);

        WeatherCondition ret = new WeatherCondition();
        ret.iconCode = '' + (resp.get('wx_icon') == null ? 'na' : resp.get('wx_icon'));
        ret.phrase = (resp.get('wx_phrase')==null) ? 'N/A' : ''+ resp.get('wx_phrase');
        ret.dayInd = '' + resp.get('day_ind');
        
        Integer unixTime = (Integer)resp.get('valid_time_gmt');
        DateTime dateInstance = Datetime.newInstanceGmt(1970, 1, 1, 0, 0, 0);
        DateTime localTime = DateTime.parse(dateInstance.addSeconds(unixTime).format());
        ret.asOf = localTime;
        
        ret.temp = (resp.get('temp')==null) ? 'N/A' : '' + resp.get('temp');
        ret.feelsLikeTemp = (resp.get('feels_like')==null) ? 'N/A' : '' + resp.get('feels_like');
        
        return ret;
    }

    public static List<Alert> getAlerts(GeoLocation gl) {
        Map<String, Object> resp = null;
        List<Alert> ret = new List<Alert>();

        if (!test.isRunningtest()) {
            try {
                resp = callUrl('/v1/geocode/' + gl.latitude + '/' + gl.longitude + '/alerts.json');
            } catch(WeatherAPIException we) {
                if (we.code == 'NDF-0001') {
                    // no alerts
                    return ret;
                }
                throw we;
            }            
        } else {
            resp = new Map<String, Object> {'alerts' => new List<Object> { new Map<String, Object> { 'effective_dt_tm_local' => '2010-01-01T00:00:00Z', 'expire_dt_tm_local' => '2010-01-01T00:00:00Z', 'issue_dt_tm_local' => '2010-01-01T00:00:00Z', 'significance' => 'S' } } };
        }

        List<Object> respo = (List<Object>)resp.get('alerts');
        if (resp == null) throw new WeatherServiceException(System.Label.err_invalid_api_response_received);

        Map<String, List<Alert>> alertBySeverity = new Map<String, List<Alert>>();

        for (Object o : respo) {
            resp = (Map<String, Object>)o;
            Alert al = new Alert();
            al.key = (String)resp.get('key');
            al.headline = (String)resp.get('headline_text');
            al.effectiveFrom = Util.parseJSONDateTime((String)resp.get('effective_dt_tm_local'));
            al.effectiveTo = Util.parseJSONDateTime((String)resp.get('expire_dt_tm_local'));
            al.issueDate = Util.parseJSONDateTime((String)resp.get('issue_dt_tm_local'));
            al.detailKey = (String)resp.get('detail_key');
            al.severityCd = resp.get('severity_cd') == null ? null : Integer.valueOf(resp.get('severity_cd'));
            al.significance = (String)resp.get('significance');

            if (!alertBySeverity.containsKey(al.significance)) alertBySeverity.put(al.significance, new List<Alert>());
            alertBySeverity.get(al.significance).add(al);
        }

        for (String s : new List<String> {'W','A','Y','S'}) {
            List<Alert> ax = alertBySeverity.get(s);
            if (ax != null) {
                ax.sort();
                ret.addAll(ax);
                if (String.isEmpty(severeSignificance)) severeSignificance = s;
            }
        }
        return ret;
    }

    public class WeatherDetailsResponse {
        @AuraEnabled public WeatherCondition condition;
        @AuraEnabled public WeatherForecast forecast;
        @AuraEnabled public WeatherLocation location;
        @AuraEnabled public UserWeatherActions actions;
        @AuraEnabled public String weatherURL;
        @AuraEnabled public Boolean hasPurchasedKey;
        @AuraEnabled public String severeAlert;
        @AuraEnabled public List<Alert> alerts;
        @AuraEnabled public String error;
        @AuraEnabled public Boolean success;
    }

    public class WeatherAlertDetailsResponse {
        @AuraEnabled public AlertDetails alertDetails;
        @AuraEnabled public String error;
        @AuraEnabled public Boolean success;
    }

    public class WeatherServiceException extends Exception {}
    public class WeatherAPIException extends Exception {
        public String code;
        public WeatherAPIException(String code, String message) {
            this(message);
            this.code = code;
        }
    }
}
