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
using Toybox.Application as App;

class SailingToolsTargetView extends SailingToolsViewTemplate {
    
    var tgt = null; // Position.location object of current target
    var tgtName = ""; // name of target
    var slotId = ""; // name of slot target saved to

    function initialize() {
        SailingToolsViewTemplate.initialize();
        setTarget( new Position.Location(
			    {
			        :latitude => 43.044235,
			        :longitude => -87.880455,
			        :format => :degrees
			    }
			)
		);
		setTargetName( "MKE North Gap");
    }
    
    function setTarget( tgt ) {
    		self.tgt = tgt;
    }
	
	function setTargetName( tgtName ) {
		self.tgtName = tgtName;
	}
	
	function saveToSlot( slotId	) {
		var saveString = tgtName + ";" + tgt.toDegrees()[0] + ";" + tgt.toDegrees()[1];
		Sys.println("saveString: " + saveString);
		try {
			App.getApp().setProperty( slotId, saveString );
			self.slotId = slotId; 
		}
		catch ( ex ) {
			System.println("Error in saveToSlot: " + ex.getErrorMessage );
			// TODO: Figure out a way to let user know target wasn't saved
		}
	}
	
	function loadFromSlot( slotId ) {
		var saveString = App.getApp().getProperty( slotId );
		var newName, newLat, newLong;
		var delimIndex = saveString.find( ";" );
		if ( delimIndex != null ) {
			newName = saveString.substring(0,delimIndex);
			saveString = saveString.substring(delimIndex + 1, saveString.length());
			
			delimIndex = saveString.find( ";" );
			if ( delimIndex != null ) {
				newLat = saveString.substring(0,delimIndex).toFloat();
				newLong = saveString.substring(delimIndex + 1, saveString.length()).toFloat();
				
				Sys.println("newName:" + newName);
				Sys.println("newLat:" + newLat);
				Sys.println("newLong:" + newLong);
				
				self.slotId = slotId;
				
				setTargetName( newName );
		        setTarget( new Position.Location(
					    {
					        :latitude => newLat,
					        :longitude => newLong,
					        :format => :degrees
					    }
					)
				);
			}
		}
	}
	
	// Handle Select button press
	function doSelect() {
		// push context menu
        Ui.pushView(new Rez.Menus.TargetMenu(), new SailingToolsMenuDelagate_TargetContext(), Ui.SLIDE_LEFT);
        return true;
	}


    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
		self.bearingArrow = new BearingArrow();
		self.bearingArrow.setColors( Gfx.COLOR_LT_GRAY, Gfx.COLOR_RED );
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        var string;
        var myDrawText = new DrawText();

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
        
        
        // show target name at bottom
        dc.drawText( dc.getWidth()/2, 156, Gfx.FONT_MEDIUM, tgtName, Gfx.TEXT_JUSTIFY_CENTER );
	        
        // only display position data if it we have it 
        if( posnInfo != null ) {
			// if last position update was > 10 seconds old or signal is poor, draw data in dark grey 
			if (Time.now().subtract( lastPosnUpdate ).value() >= 10 || posnInfo.accuracy < Position.QUALITY_USABLE) {
		        dc.setColor( Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT );
			}
			
			// get distance and bearing to target
            var distance = GeoCalcs.getDistance(posnInfo.position, tgt);
            var bearing_deg = GeoCalcs.getBearing_deg(posnInfo.position, tgt);
            
            // get heading (for drawing bearing arrow relative to current heading)
			var heading_deg = posnInfo.heading * (180 / Math.PI);
            
			// draw dividers
			// between ETE and distance
			dc.drawLine( 107, 45, 107, 160 );
			// above lat/long
			dc.drawLine( 0, 160, dc.getWidth(), 160 );
			
			// ETE = Estimated Time Enroute
			// Time to target on left upper
			// get relative speed to target
			var speed_rel = Math.cos( (bearing_deg - heading_deg) * (Math.PI / 180) ) * (posnInfo.speed * 1.94384);
			// If our relative speed is less than 0.1kt we show NA
			// This handles negative and zero speeds, and those that would produce very high ETE
			if (speed_rel < 0 || speed_rel == 0) {
				string = "NA";
				dc.drawText( 102, 28, Gfx.FONT_NUMBER_HOT, string, Gfx.TEXT_JUSTIFY_RIGHT );
			} else {
				var ETE = distance / speed_rel;
				//Sys.println( "ETE: " + ETE );
				// if time is > 1 hour, then show as hours:minutes
				if ( ETE > 1 ) {
					string = ETE.toNumber().toString() + ":";
					string += ((ETE - ETE.toNumber()) * 60).format("%02d");
					dc.drawText( 102, 28, Gfx.FONT_NUMBER_HOT, string, Gfx.TEXT_JUSTIFY_RIGHT );
				} else { // otherwise show as minutes:seconds
					// draw seconds in smaller font
					var string1 = (ETE * 60).toNumber().toString() + ":";
					var txtDim1 = dc.getTextDimensions( string1, Gfx.FONT_NUMBER_HOT );
					string = (((ETE * 60) - (ETE * 60).toNumber()) * 60).format("%02d");
					var txtDim = dc.getTextDimensions( string, Gfx.FONT_NUMBER_MEDIUM );
					// Need to start minutes the width of the seconds to the left
					dc.drawText( 102 - txtDim[0],
								 28, Gfx.FONT_NUMBER_HOT, string1, Gfx.TEXT_JUSTIFY_RIGHT );
					// Need to start seconds down the difference between minutes height and seconds height
					dc.drawText( 102,
								28 + txtDim1[1] - txtDim[1], 
								Gfx.FONT_NUMBER_MEDIUM, string, Gfx.TEXT_JUSTIFY_RIGHT );
				}
			}
			//dc.drawText( 82, 30, Gfx.FONT_NUMBER_HOT, string, Gfx.TEXT_JUSTIFY_RIGHT );
			dc.drawText( 99, 79, Gfx.FONT_SMALL, "ETE", Gfx.TEXT_JUSTIFY_RIGHT );
			
			// Bearing to target on left lower
			if (bearing_deg < 0) { bearing_deg += 360; } // make sure degrees are positive
			string = bearing_deg.format("%1.0f");
			dc.drawText( 102, 88, Gfx.FONT_NUMBER_HOT, string, Gfx.TEXT_JUSTIFY_RIGHT );
			dc.drawText( 99, 139, Gfx.FONT_SMALL, "Brg", Gfx.TEXT_JUSTIFY_RIGHT );
			
			// speed in kt large on right upper
            string = (posnInfo.speed * 1.94384).format("%1.1f"); // Convert from m/s to knots
			dc.drawText( 110, 28, Gfx.FONT_NUMBER_HOT, string, Gfx.TEXT_JUSTIFY_LEFT );
			dc.drawText( 113, 79, Gfx.FONT_SMALL, "knt", Gfx.TEXT_JUSTIFY_LEFT );
			
        		// distance in nm large on right lower
            string = distance.format("%1.1f"); 
			dc.drawText( 110, 88, Gfx.FONT_NUMBER_HOT, string, Gfx.TEXT_JUSTIFY_LEFT );
			dc.drawText( 113, 139, Gfx.FONT_SMALL, "nm", Gfx.TEXT_JUSTIFY_LEFT );
            
            // draw arrow for bearing
            self.bearingArrow.draw( dc, bearing_deg - heading_deg );
            
            // Warn if position is stale or not usable
			if (Time.now().subtract( lastPosnUpdate ).value() >= 10) {
				dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_DK_GRAY );
				
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
				dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_DK_GRAY );
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

}
