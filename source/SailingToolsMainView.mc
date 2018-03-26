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
        setLayout(Rez.Layouts.MainLayout(dc));
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
	
}

class SailingToolsMainView extends SailingToolsViewTemplate {

    function initialize() {
        SailingToolsViewTemplate.initialize();
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
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        var string;

        // Set background color
        dc.setColor( Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK );
        dc.clear();
        dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
        
        
    		// Forerunner 235 width: 215, height: 180
    		//  center: 107, 90
    		// time at top
		var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		string = today.hour.format("%2d") + ":" + today.min.format("%02d") + ":" + today.sec.format("%02d");
		dc.drawText( dc.getWidth()/2, 10, Gfx.FONT_LARGE, string, Gfx.TEXT_JUSTIFY_CENTER );
        
        // only display position data if it we have it 
        if( posnInfo != null ) {
			// if last position update was > 10 seconds old or signal is poor, draw data in dark grey 
			if (Time.now().subtract( lastPosnUpdate ).value() >= 10 || posnInfo.accuracy < Position.QUALITY_USABLE) {
		        dc.setColor( Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT );
			}
			// draw dividers
			// between COG and knt
			dc.drawLine( 77, 45, 77, 142 );
			// above lat/long
			dc.drawLine( 0, 144, dc.getWidth(), 144 );
        
			// Heading (Course Over Ground) on left
			var heading_deg = posnInfo.heading * (180 / Math.PI);
			if (heading_deg < 0) { heading_deg += 360; } // make sure degrees are positive
			string = heading_deg.format("%1.0f");
			dc.drawText( 72, 70, Gfx.FONT_NUMBER_HOT, string, Gfx.TEXT_JUSTIFY_RIGHT );
			dc.drawText( 69, 123, Gfx.FONT_SMALL, "COG", Gfx.TEXT_JUSTIFY_RIGHT );
        
        		// speed in knots big on right
            string = (posnInfo.speed * 1.94384).format("%1.1f"); // Convert from m/s to knots
			dc.drawText( 80, 31, Gfx.FONT_NUMBER_THAI_HOT, string, Gfx.TEXT_JUSTIFY_LEFT );
			dc.drawText( 83, 123, Gfx.FONT_SMALL, "knt", Gfx.TEXT_JUSTIFY_LEFT );
            
            // show lat/long at bottom
            // lat
            string = posnInfo.position.toDegrees()[0].format("%1.6f");
	        dc.drawText( 137, 142, Gfx.FONT_MEDIUM, string, Gfx.TEXT_JUSTIFY_RIGHT );
            if (posnInfo.position.toDegrees()[0] > 0) {
                string = "N";
            } else {
                string = "S";
            }
	        dc.drawText( 142, 142, Gfx.FONT_MEDIUM, string, Gfx.TEXT_JUSTIFY_LEFT );
         	// long
            string = posnInfo.position.toDegrees()[1].format("%1.6f");
	        dc.drawText( 137, 160, Gfx.FONT_MEDIUM, string, Gfx.TEXT_JUSTIFY_RIGHT );
            if (posnInfo.position.toDegrees()[1] > 0) {
                string = "E";
            } else {
                string = "W";
            }
	        dc.drawText( 142, 160, Gfx.FONT_MEDIUM, string, Gfx.TEXT_JUSTIFY_LEFT );
            
            // draw arrow for COG
            self.bearingArrow.draw( dc, heading_deg );
            
            // Warn if position is stale or not usable
			if (Time.now().subtract( lastPosnUpdate ).value() >= 10) {
				dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
				
				var posnTime = Gregorian.info(lastPosnUpdate, Time.FORMAT_SHORT);
				string = "Position stale\nLast update:\n";
				string += posnTime.hour.format("%2d") + ":" + posnTime.min.format("%02d") + ":" + posnTime.sec.format("%02d");
				//string += "\n" + posnTime.year.format("%4d") + "-" + posnTime.month.format("%02d") + "-" + posnTime.day.format("%02d");
				dc.drawText( 
					dc.getWidth()/2, 
					31, 
					Gfx.FONT_LARGE,
					string,
 					Gfx.TEXT_JUSTIFY_CENTER
				 );
			} else if (posnInfo.accuracy < Position.QUALITY_USABLE) { 
				dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
				dc.drawText( 
					dc.getWidth()/2, 
					31, 
					Gfx.FONT_LARGE,
					"Position accuracy\nis poor",
 					Gfx.TEXT_JUSTIFY_CENTER
				 );
			}
			
            
        }
        else {
			dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
			dc.drawText( 
				dc.getWidth()/2, 
				31, 
				Gfx.FONT_LARGE,
				"No position info",
				Gfx.TEXT_JUSTIFY_CENTER
			);
        }
    }
    
	// Handle Select button press
	function doSelect() {
	}

}
