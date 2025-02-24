//!
//! Copyright 2017-2018 by Dan Perik
//!

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Position as Position;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.Timer as Timer;
using Toybox.ActivityRecording as Record;

class SailingToolsViewTemplate extends Ui.View {

    var posnInfo = null; // Position.Info object
    // posnInfo.when doesn't seem to provide valid values (they're 20 years off)
    // so we capture Time.now(), and use that for checking for stale posnInfo
    var lastPosnUpdate = null; // last time the posnInfo was updated
    
    var bearingArrow = null; // BearingArrow object

    function initialize() {
        View.initialize();
    }
	
    // Load resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.DefaultLayout(dc));
	}

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
		self.bearingArrow = null;
	    self.posnInfo = null; 
	    self.lastPosnUpdate = null; 
    }
    
	// Handle Select button press
	function doSelect() {
	}
    
    function setPosition(info, lastUpdate) {
        posnInfo = info;
        lastPosnUpdate = lastUpdate;
    }
    
    function overlayMessage( message ) {
		View.findDrawableById("overlayMessage").setColor( Gfx.COLOR_PINK );
		View.findDrawableById("overlayMessage").setText( message );
    }
	
}

class SailingToolsMainView extends SailingToolsViewTemplate {

    function initialize() {
        SailingToolsViewTemplate.initialize();
    }
	
    // Load resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
        onUpdate( dc ); // Need to do the initial update of dynamic content
	}

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
		self.bearingArrow = new BearingArrow();
		self.bearingArrow.setColors( Gfx.COLOR_LT_GRAY, Gfx.COLOR_DK_GREEN );
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
		View.findDrawableById("mainTime").setText( string );
        
        // only display position data if it we have it 
        if( posnInfo != null ) {
			View.findDrawableById("mainBadPos").setText( "" );
			/*
			// if last position update was > 10 seconds old or signal is poor, draw data in dark grey 
			if (Time.now().subtract( lastPosnUpdate ).value() >= 10 || posnInfo.accuracy < Position.QUALITY_USABLE) {
				foreColor = Gfx.COLOR_DK_GRAY;
			}
			*/
        
			// Heading (Course Over Ground) on left
			var heading_deg = posnInfo.heading * (180 / Math.PI);
			if (heading_deg < 0) { heading_deg += 360; } // make sure degrees are positive
			string = heading_deg.format("%1.0f");
			//string = Calcs.formatDegrees(heading_deg);
			View.findDrawableById("mainCOG").setText(string);
        
    		// speed in knots big on right
			//string = (posnInfo.speed * 1.94384).format("%1.1f"); // Convert from m/s to knots
			var speed = Calcs.metersPerSecond_to_preferred(posnInfo.speed);
			View.findDrawableById("mainSpeed").setText(speed["value"].format("%1.1f"));
			View.findDrawableById("lblMainSpeed").setText("SOG (" + speed["label"] + ")");
            
            // show lat/long at bottom
            // lat
            //string = posnInfo.position.toDegrees()[0].format("%1.6f");
            string = Calcs.formatLatLongDegrees(posnInfo.position.toDegrees()[0]);
			View.findDrawableById("mainLat").setText(string);
            if (posnInfo.position.toDegrees()[0] > 0) {
                string = "N";
            } else {
                string = "S";
            }
			View.findDrawableById("mainLatNS").setText(string);
         	// long
            //string = posnInfo.position.toDegrees()[1].format("%1.6f");
            string = Calcs.formatLatLongDegrees(posnInfo.position.toDegrees()[1]);
			View.findDrawableById("mainLon").setText(string);
            if (posnInfo.position.toDegrees()[1] > 0) {
                string = "E";
            } else {
                string = "W";
            }
			View.findDrawableById("mainLonEW").setText(string);
            
            
            
            // Warn if position is stale or not usable
			if (Time.now().subtract( lastPosnUpdate ).value() >= 10) {
//				dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_DK_GRAY );
				
				var posnTime = Gregorian.info(lastPosnUpdate, Time.FORMAT_SHORT);
				string = "Position stale\nLast update:\n";
				string += posnTime.hour.format("%2d") + ":" + posnTime.min.format("%02d") + ":" + posnTime.sec.format("%02d");
				
				View.findDrawableById("mainBadPos").setText( string );
				 
				setTextColor( Gfx.COLOR_DK_GRAY );
				 
			} else if (posnInfo.accuracy < Position.QUALITY_USABLE) { 
//				dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_DK_GRAY );
				View.findDrawableById("mainBadPos").setText( "Position accuracy\nis poor" );
				 
				setTextColor( Gfx.COLOR_LT_GRAY );
			} else {
				setTextColor( Gfx.COLOR_WHITE );
			}
			
			
	        // Call the parent onUpdate function to redraw the layout
	        // We do this _after_ we've updated the layout elements
	        View.onUpdate(dc);
	        
            // _Then_ we draw the arrow for COG
            if ( self.bearingArrow != null ) {// If we're just being called from onLayout, we can't draw the bearing arrow
	            self.bearingArrow.draw( dc, heading_deg );
            }
            
        }
        else {
			View.findDrawableById("mainBadPos").setText( "No position info" );
				 
			setTextColor( Gfx.COLOR_DK_GRAY );
			
	        // Call the parent onUpdate function to redraw the layout
	        // We do this _after_ we've updated the layout elements
	        View.onUpdate(dc);
        }
    }
    
	// Handle Select button press
	function doSelect() {
	}
	
    function setTextColor( color ) {
				 
		View.findDrawableById("lblMainETE").setColor( color );
		View.findDrawableById("lblMainSpeed").setColor( color );

		View.findDrawableById("mainTime").setColor( color );
		View.findDrawableById("mainCOG").setColor( color );
		View.findDrawableById("mainSpeed").setColor( color );
		View.findDrawableById("mainLat").setColor( color );
		View.findDrawableById("mainLatNS").setColor( color );
		View.findDrawableById("mainLon").setColor( color );
		View.findDrawableById("mainLonEW").setColor( color );
	}
}
