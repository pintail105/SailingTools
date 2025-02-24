//!
//! Copyright 2017-2018 by Dan Perik
//!

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Activity as Activity;
using Toybox.Position as Position;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.Timer as Timer;
using Toybox.ActivityRecording as Record;
using Toybox.Application as App;

/*
function type_name(obj) {
	if (obj instanceof Toybox.Lang.Number) {
	    return "Number";
	} else if (obj instanceof Toybox.Lang.Long) {
	    return "Long";
	} else if (obj instanceof Toybox.Lang.Float) {
	    return "Float";
	} else if (obj instanceof Toybox.Lang.Double) {
	    return "Double";
	} else if (obj instanceof Toybox.Lang.Boolean) {
	    return "Boolean";
	} else if (obj instanceof Toybox.Lang.String) {
	    return "String";
	}
}	 
*/       

class SailingToolsStatsView extends SailingToolsViewTemplate {

    function initialize() {
        SailingToolsViewTemplate.initialize();
    }
    
    function onLayout( dc ) {
        setLayout( Rez.Layouts.StatsLayout( dc ) );
        onUpdate( dc ); // Need to do the initial update of dynamic content
    }
	
    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
		//self.bearingArrow = new BearingArrow();
		//self.bearingArrow.setColors( Gfx.COLOR_LT_GRAY, Gfx.COLOR_RED );
    }

    // Update the view
    function onUpdate(dc) {
        var string;

		//var foreColor = Gfx.COLOR_WHITE;
        
    		// Forerunner 235 width: 215, height: 180
    		//  center: 107, 90
    		// time at top
		var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		string = today.hour.format("%2d") + ":" + today.min.format("%02d") + ":" + today.sec.format("%02d");
		View.findDrawableById("statsTime").setText( string );
        
        var activityInfo = Activity.getActivityInfo();
        // only display position data if it we have it 
        if( (activityInfo != null) && (posnInfo != null) ) {
        	
			View.findDrawableById("statsBadPos").setText( "" );
			
			var sysStats = System.getSystemStats();
			//System.println(sysStats.battery);
			View.findDrawableById("statsBatteryPercent").setText( sysStats.battery.format("%1.0f") + "%");
					
			//Sys.println("activityInfo.elapsedTime: " + activityInfo.elapsedTime);
			//Sys.println("activityInfo.elapsedTime type: " + type_name(activityInfo.elapsedTime));
			
			// in milliseconds
			var elapsedTime = activityInfo.elapsedTime;
			if (elapsedTime != null) {
				string =  (elapsedTime / 3600000).format("%02d") + ":"
					+ ((elapsedTime % 3600000) / 60000).format("%02d") + ":"
					+ ((elapsedTime % 60000) / 1000).format("%02d");
			} else {
				string = "N/A";
			}
			View.findDrawableById("statsElapsedTime").setText( string );
			
	        // in meters
	        var elapsedDistance = activityInfo.elapsedDistance;
	        if ( elapsedDistance != null ) {
	        	elapsedDistance = Calcs.meters_to_preferred(elapsedDistance);
	        	if (elapsedDistance["value"] >= 100) {
			        string = elapsedDistance["value"].format("%1.0f") + " " + elapsedDistance["label"];
	        	} else if (elapsedDistance["value"] >= 10) {
			        string = elapsedDistance["value"].format("%1.1f") + " " + elapsedDistance["label"];
	        	} else {
			        string = elapsedDistance["value"].format("%1.2f") + " " + elapsedDistance["label"];
	        	}
	        } else {
	        	string = "N/A";
	        }
			View.findDrawableById("statsElapsedDistance").setText( string );
	        
	        // in meters per second
	        var averageSpeed = activityInfo.averageSpeed;
	        if (averageSpeed != null) {
	        	averageSpeed = Calcs.metersPerSecond_to_preferred(averageSpeed);
	        	string = averageSpeed["value"].format("%1.1f") + " " + averageSpeed["label"]; 
			} else {
				string = "N/A";
			}
			View.findDrawableById("statsAverageSpeed").setText( string );
			
			var maxSpeed = activityInfo.maxSpeed;
			if (maxSpeed != null) {
				maxSpeed = Calcs.metersPerSecond_to_preferred(maxSpeed);
		        string = maxSpeed["value"].format("%1.1f") + " " + maxSpeed["label"];
		    } else {
		    	string = "N/A";
		    }
			View.findDrawableById("statsMaxSpeed").setText( string );
			
            // Warn if position is stale or not usable
			if (Time.now().subtract( lastPosnUpdate ).value() >= 10) {
//				dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_DK_GRAY );
				
				var posnTime = Gregorian.info(lastPosnUpdate, Time.FORMAT_SHORT);
				string = "Position stale\nLast update:\n";
				string += posnTime.hour.format("%2d") + ":" + posnTime.min.format("%02d") + ":" + posnTime.sec.format("%02d");
				
				View.findDrawableById("statsBadPos").setText( string );
				
				setTextColor( Gfx.COLOR_DK_GRAY);				 
				 
			} else if (posnInfo.accuracy < Position.QUALITY_USABLE) { 
//				dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_DK_GRAY );
				View.findDrawableById("statsBadPos").setText( "Position accuracy\nis poor" );	
				
				setTextColor( Gfx.COLOR_LT_GRAY);
			} else {				
				setTextColor( Gfx.COLOR_WHITE );
			}
			
            
	        // Call the parent onUpdate function to redraw the layout
	        // We do this _after_ we've updated the layout elements
	        View.onUpdate(dc);
	        
	        
        }
        else {
			View.findDrawableById("statsBadPos").setText( "No position info" );
			setTextColor( Gfx.COLOR_DK_GRAY );
			
	        // Call the parent onUpdate function to redraw the layout
	        // We do this _after_ we've updated the layout elements
	        View.onUpdate(dc);
        }
    }
    
    function setTextColor( color ) {
				
		View.findDrawableById("lblStatsElapsedTime").setColor( color );
		View.findDrawableById("lblStatsElapsedDistance").setColor( color );
		View.findDrawableById("lblStatsAverageSpeed").setColor( color );
		View.findDrawableById("lblStatsMaxSpeed").setColor( color );
		View.findDrawableById("lblStatsMaxSpeed").setColor( color );
		View.findDrawableById("lblStatsBatteryPercent").setColor( color );
		
		View.findDrawableById("statsTime").setColor( color );
		View.findDrawableById("statsElapsedTime").setColor( color );
		View.findDrawableById("statsElapsedDistance").setColor( color );
		View.findDrawableById("statsAverageSpeed").setColor( color );
		View.findDrawableById("statsMaxSpeed").setColor( color );
    }

}
