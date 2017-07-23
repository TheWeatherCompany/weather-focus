# Weather Company Weather Focus <br/> Unmanaged Component Guide

This component allows you to visualize the weather affecting your customers and use it as a conversation-starter and/or sales tool. For example, if inclement weather is causing active alerts that might impact travel, you can better plan a time to call your contact at a logistics company who might be distracted by the current storms.

This Lightning component can be added to account and contact pages to provide the following data:
- Current weather conditions (e.g., cloud cover, temperature, precipitation, wind, etc.)
- Short-term forecasts
- Active National Weather Service watches and warnings 

For a more detailed forecast, links are provided to view a full 10-day forecast on Weather.com.

You can download the unmanaged component from [GitHub](https://github.com/TheWeatherCompany/weather-focus/). To set it up, add the API key from your paid data package subscription from The Weather Company, integrate with a map API of your choice, and customize per your needs. Alternatively, you can use the code as a sample to understand how the API works and then build your own standalone app.

*Tip:* The component is shipped with mock data so you can try it out before you obtain an API key.

### Obtaining an API Key
By purchasing a data package and access key from The Weather Company, you can include any of the following data streams into the component:
- Weather Company Data for Salesforce – Core: Daily forecasts for the next 10 days, hourly forecasts for the next 48 hours, and historical weather conditions for the past 24 hours
- Weather Company Data for Salesforce – Enhanced: More precise and frequent weather observations, precipitation forecast, 15-minute forecast, and Nowcast
- Weather Company Data for Salesforce – Severe Weather: Information on conditions including hail, lightning, and storms, and a power disruption index

To purchase a Weather Company data package, visit [Weather Company Data for Salesforce](https://business.weather.com/products/weather-data-packages-salesforce).

## Installing and Configuring the Component
### System Requirements
The component is supported for all Salesforce editions; Lightning Experience must be enabled. The component is not supported in Salesforce Classic. The component is supported on all browsers that are supported for Lightning Experience (see [Supported Browsers for Lightning Experience](https://help.salesforce.com/articleView?id=getstart_browsers_sfx.htm) in the Salesforce documentation).

### Setting Up the Component
*Prerequisite*: Prior to installation, ensure Lightning Experience is enabled (see [Enable Lightning Experience](https://help.salesforce.com/articleView?id=lex_enable_intro.htm)). 

To set up the component:
1. Get the component from [GitHub](https://github.com/TheWeatherCompany/weather-focus/) and deploy it to Salesforce.
2. Optional: Change the default values of the component properties in **Setup > Custom Settings**.

	| Property   | Description   |
	| --- |---|
	| Units | Default type of units to display; possible values: English, metric |
	| Account Address Field | Address type for which to display weather information when the component is on an account page. By default, the component uses the shipping address for accounts. Possible values: shipping, billing.|
	| Contact Address Field | Address type for which to display weather information when the component is on a contact page. By default, the component uses the mailing address for contacts. Possible values: mailing, other. |

3. Add the component to the contact and account pages by editing the pages in the Lightning App Builder (see [Configure Lightning Experience Record Pages](https://help.salesforce.com/articleView?id=lightning_app_builder_customize_lex_pages.htm)). 
	1. In the **Lightning Components** list, scroll down to the **Custom** section.
	2. Click **Weather Company Weather Focus** and drag the component to any place on the page. *Tip*: You can add multiple instances of this component to a page and associate each with a different address type (e.g., one instance of the component is associated with the billing address and another instance is associated with the shipping address).
	3. In the properties pane, configure the component’s properties:
		- Select the address type for which to display weather information. By default, the component uses the mailing address for contacts and the shipping address for accounts.
		- Select the default type of units to display.	
	4. Save and activate the updated pages.

The component is now running with mock data.

### Enabling the component to display real data
After you obtain an API key (see [Weather Company Data for Salesforce](https://business.weather.com/products/weather-data-packages-salesforce)), enable the component to display real weather data.

To enable the component to display real data:
1. Integrate the component with a map API.
	1. In Salesforce, add the URL of your map API to **Setup > CSP Trusted Sites** and **Setup > Remote Site Settings**.
	2. Define the associated JS files as local resources in **Setup > Static Resources**. *Tip:* Ensure that you create static resources for all JS files. Salesforce doesn't allow you to access JS files on the web.
	3. In the src/aura/weatherfocus/weatherfocus.cmp file, add a statement to load the JS files. For example: 
		```
		<ltng:require scripts="{!join(',', $Resource.<js1_name>, $Resource..<js2_name>, ..., 
		$Resource..<jsn_name>,afterScriptsLoaded="{!c.afterScriptsLoaded}" />
		```
	4. In the weatherfocusHelper.js file, add code to initialize and display the map and calls to send the location information to your map API. The component determines the latitude and longitude for the customer's address and sets these values as attributes of the weatherLocation object. The following code gets the values you can send to your map API:
		```
		component.get('v.weatherLocation.latitude')
		component.get('v.weatherLocation.longitude
		```
	5. If you want to provide custom zoom controls for the map, implement the mapZoom function. For more information about integrating with your map API, see the comments in the weatherfocus.cmp, weatherfocusController.js, and weatherfocusHelper.js files. *Tip*: To improve performance, configure Salesforce to automatically add geocodes to all account, contact, and lead records (see [Set Up Geocode Data Integration Rules](https://help.salesforce.com/articleView?id=data_dot_com_clean_add_geocode_information_to_all_records.htm)). The component then uses the geocode values instead of making API calls to determine the latitude and longitude for each address.   

2. In Salesforce, create a CSP Trusted Site for https://<i></i>api.weather.com to access The Weather Company APIs (see [Create CSP Trusted Sites to Access Third-Party APIs](https://help.salesforce.com/articleView?id=csp_trusted_sites.htm)).       
3. Enter the API key. In Custom Metadata Types, edit the SUN Weather API record (see [Add or Edit Custom Metadata Records Declaratively](https://help.salesforce.com/articleView?id=custommetadatatypes_ui_populate.htm)). For the API Key field, specify the API key you received when you purchased the data package. For the API User field, don’t specify a value. *Tip*: If the API key field is not displayed for the API record, edit its page layout.
4. Disable the sample data response and activate the API calls to Weather.com. In the weatherfocus.cmp file, change the useMockup attribute to “false.”      
        
### Extending the Component
You can extend the component by purchasing a data subscription and customizing the code:
- Add the component to other Salesforce pages, such as leads or opportunities.
- Add more detailed weather data to support operational planning and other activities:
  - 10-day forecast with 2 days hourly (included in Core data package)
  - 15-day hourly forecast with 7 hours of 15-minute increments (included in Enhanced data package)
  - More precise location for current conditions (included in Enhanced data package)
  - Current conditions enhanced with severe weather like hail and ice (included in Severe  Weather data package) 
For more details about how to extend the component, see the comments in the code.

### Restrictions
The component shows data for locations in the U.S. and Canada only. The user interface is available in English only.
