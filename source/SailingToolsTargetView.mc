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
    
    function onLayout( dc ) {
        setLayout( Rez.Layouts.TargetLayout( dc ) );
        onUpdate( dc ); // Need to do the initial update of dynamic content
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

		var foreColor = Gfx.COLOR_WHITE;
        
    		// Forerunner 235 width: 215, height: 180
    		//  center: 107, 90
    		// time at top
		var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		string = today.hour.format("%2d") + ":" + today.min.format("%02d") + ":" + today.sec.format("%02d");
		View.findDrawableById("targetTime").setText( string );
        
        
        // show target name at bottom
		View.findDrawableById("targetName").setText( tgtName );
        
	        
        // only display position data if it we have it 
        if( posnInfo != null ) {
			View.findDrawableById("targetBadPos").setText( "" );
			
			// if last position update was > 10 seconds old or signal is poor, draw data in dark grey 
			if (Time.now().subtract( lastPosnUpdate ).value() >= 10 || posnInfo.accuracy < Position.QUALITY_USABLE) {
				foreColor = Gfx.COLOR_DK_GRAY;
			}
			
			// get distance and bearing to target
            var distance = GeoCalcs.getDistance(posnInfo.position, tgt);
            var bearing_deg = GeoCalcs.getBearing_deg(posnInfo.position, tgt);
            
            // get heading (for drawing bearing arrow relative to current heading)
			var heading_deg = posnInfo.heading * (180 / Math.PI);
            
			
			// ETE = Estimated Time Enroute
			// Time to target on left upper
			// get relative speed to target
			/*
			var speed_rel = Math.cos( (bearing_deg - heading_deg) * (Math.PI / 180) ) * (posnInfo.speed * 1.94384);
			var targetETE = View.findDrawableById("targetETE");
			// If our relative speed is less than 0.1kt we show NA
			// This handles negative and zero speeds, and those that would produce very high ETE
			if (speed_rel < 0 || speed_rel == 0) {
				targetETE.setText("NA");
			} else {
				var ETE = distance / speed_rel;
				//Sys.println( "ETE: " + ETE );
				// if time is > 1 hour, then show as hours:minutes
				if ( ETE > 1 ) {
					string = ETE.toNumber().toString() + ":";
					string += ((ETE - ETE.toNumber()) * 60).format("%02d");
					targetETE.setText(string);	
				} else { // otherwise show as minutes:seconds
					// draw seconds in smaller font
					var string1 = (ETE * 60).toNumber().toString() + ":";
					string = (((ETE * 60) - (ETE * 60).toNumber()) * 60).format("%02d");
					// Need to start minutes the width of the seconds to the left
					targetETE.setText(string1 + "  ");
					// Need to start seconds down the difference between minutes height and seconds height
					View.findDrawableById("targetETE").setText( string );
				}
			}
			*/
			// Relative bearing (= bearing - heading)
			var relBearing_deg = bearing_deg - heading_deg;
			// Keep in range of -180 to +180
			if (relBearing_deg < -180) { relBearing_deg += 360; }
			if (relBearing_deg > 180) { relBearing_deg -= 360; }
			string = relBearing_deg.format("%+1.0f");
			View.findDrawableById("targetRelBRG").setText( string );
			
			// Bearing to target on left lower
			if (bearing_deg < 0) { bearing_deg += 360; } // make sure degrees are positive
			string = bearing_deg.format("%1.0f");
			View.findDrawableById("targetBrg").setText( string );
			
			// speed in kt large on right upper
            string = (posnInfo.speed * 1.94384).format("%1.1f"); // Convert from m/s to knots
			View.findDrawableById("targetKnt").setText( string );
			
        		// distance in nm large on right lower
            string = distance.format("%1.1f"); 
			View.findDrawableById("targetNM").setText( string );
            
            // draw arrow for relative bearing
            if ( self.bearingArrow != null ) { // If we're just being called from onLayout, we can't draw the bearing arrow
				self.bearingArrow.draw( dc, bearing_deg - heading_deg );
            }
            
            // Warn if position is stale or not usable
			if (Time.now().subtract( lastPosnUpdate ).value() >= 10) {
//				dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_DK_GRAY );
				
				var posnTime = Gregorian.info(lastPosnUpdate, Time.FORMAT_SHORT);
				string = "Position stale\nLast update:\n";
				string += posnTime.hour.format("%2d") + ":" + posnTime.min.format("%02d") + ":" + posnTime.sec.format("%02d");
				
				View.findDrawableById("targetBadPos").setText( string );
				
				setTextColor( Gfx.COLOR_DK_GRAY);				 
				 
			} else if (posnInfo.accuracy < Position.QUALITY_USABLE) { 
//				dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_DK_GRAY );
				View.findDrawableById("targetBadPos").setText( "Position accuracy\nis poor" );	
				
				setTextColor( Gfx.COLOR_LT_GRAY);
			} else {				
				setTextColor( Gfx.COLOR_WHITE );
			}
			
            
        }
        else {
			View.findDrawableById("targetBadPos").setText( "No position info" );
			setTextColor( Gfx.COLOR_DK_GRAY );
        }
    }
    
    function setTextColor( color ) {
				
		View.findDrawableById("lblTargetRelBRG").setColor( color );
		View.findDrawableById("lblTargetBRG").setColor( color );
		View.findDrawableById("lblTargetKNT").setColor( color );
		View.findDrawableById("lblTargetNM").setColor( color );
		
		View.findDrawableById("targetTime").setColor( color );
		View.findDrawableById("targetName").setColor( color );
		View.findDrawableById("targetRelBRG").setColor( color );
		View.findDrawableById("targetBrg").setColor( color );
		View.findDrawableById("targetKnt").setColor( color );
		View.findDrawableById("targetNM").setColor( color );
    }

}
