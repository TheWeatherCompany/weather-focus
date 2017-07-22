/*
Copyright 2017 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
*/

({
	    afterRender  : function(cmp, helper){    
        	this.superAfterRender();
	        cmp.set('v.domLoaded', true);
    	    cmp.set('v.scriptsLoaded', true); // remove this line if you implemented afterScriptsLoaded
            helper.init(cmp);
        }

})
