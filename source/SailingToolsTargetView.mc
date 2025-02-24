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
    var ETEorBRG = 1; // 0 = ETE; 1 = BRG
    var speedOrVMG = 0; // 0 = SOG; 1 = VMC

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
		
		ETEorBRG = App.getApp().getProperty( "preferredTargetETEorBRG" );
		speedOrVMG = App.getApp().getProperty( "preferredTargetSpeedOrVMG" );
		
		Sys.println("ETEorBRG = " + ETEorBRG);
		Sys.println("speedOrVMG = " + speedOrVMG);
		
    }
    
    function setTarget( tgt ) {
    		self.tgt = tgt;
    }
	
	function setTargetName( tgtName ) {
		self.tgtName = tgtName;
	}
	
	function saveToSlot( slotId	) {
		var lat_str = Calcs.formatLatLongDegrees(tgt.toDegrees()[0]);
		var long_str = Calcs.formatLatLongDegrees(tgt.toDegrees()[1]);
		
		lat_str = cleanLatLong(lat_str);
		long_str = cleanLatLong(long_str);
		
		var saveString = tgtName + ";" + lat_str + ";" + long_str;
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
	
	// Remove degree, minutes, and seconds symbols
	function cleanLatLong( string ) {
		//Sys.println("entering clean: " + string);
		var index = string.find("°");
		if (index != null) {
			string = string.substring(0,index) + string.substring(index+1,string.length());
		}
		
		index = string.find("'");
		if (index != null) {
			string = string.substring(0,index) + string.substring(index+1,string.length());
		}
		index = string.find("\"");
		if (index != null) {
			string = string.substring(0,index) + string.substring(index+1,string.length());
		}
		
		//Sys.println("leaving clean: " + string);
		return string;
	}
	
	// to get float from one of:
	// d.decimal
	// d m.decimal
	// d m s
	function parseLatLong( string ) {
		string = cleanLatLong(string);
		var isNegative = false;
		var value;
		var str1 = "0";
		var str2 = "0";
		var spaceIndex = string.find( " " );
		if ( spaceIndex != null ) {
			str1 = string.substring(0,spaceIndex);
			string = string.substring(spaceIndex + 1, string.length());
			
			spaceIndex = string.find( " " );
			if ( spaceIndex != null ) {
				// 2 spaces => d m s
				str2 = string.substring(0,spaceIndex);
				string = string.substring(spaceIndex + 1, string.length());
			} else {
				// 1 space => d m.decimal
				str2 = string;
				string = "0";
			}
		} else {
			// no spaces => interpret as d.decimal
			str1 = string;
			string = "0";
		}
		

		value = str1.toFloat(); // degrees
		var minutes = str2.toFloat();
		var seconds = string.toFloat();
		if (minutes == null) { minutes = 0; }
		if (seconds == null) { seconds = 0; }
		
		Sys.println("degress: '" + value + "'; minutes: '" + minutes + "'; seconds: '" + seconds + "'");
		// We have to save off sign of degrees
		// Add all the portions as absolute numbers
		// Then negate if sign was negative
		isNegative = (value < 0);
		value = value.abs();
		value = value + minutes/60 + seconds/3600;
		if (isNegative) { value = -value; }
		return value;
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
				newLat = parseLatLong(saveString.substring(0,delimIndex));
				newLong = parseLatLong(saveString.substring(delimIndex + 1, saveString.length()));
				
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
	
	
	function toggleETEorBRG() {
		if (ETEorBRG == 0) {
			ETEorBRG = 1;
		} else {
			ETEorBRG = 0;
		}
	}
	function toggleSpeedOrVMG() {
		if (speedOrVMG == 0) {
			speedOrVMG = 1;
		} else {
			speedOrVMG = 0;
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
        var string;
        
		setTextColor( Gfx.COLOR_WHITE );
				
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
			
			// get distance and bearing to target
            var distance = Calcs.getDistance_m(posnInfo.position, tgt);
            var bearing_deg = Calcs.getBearing_deg(posnInfo.position, tgt);
            
            // get heading (for drawing bearing arrow relative to current heading)
			var heading_deg = posnInfo.heading * (180 / Math.PI);
            
			
			// Relative bearing (= bearing - heading)
			var relBearing_deg = bearing_deg - heading_deg;
			// Keep in range of -180 to +180
			if (relBearing_deg < -180) { relBearing_deg += 360; }
			if (relBearing_deg > 180) { relBearing_deg -= 360; }
			
			if (relBearing_deg < 0) {
				// If to port, draw in red
				View.findDrawableById("targetRelBRG").setColor( Gfx.COLOR_RED );
			} 
			else {
				// If to starboard, draw in green
				View.findDrawableById("targetRelBRG").setColor( Gfx.COLOR_GREEN );
			}
			//string = relBearing_deg.format("%+1.0f");
			string = relBearing_deg.format("%1.0f"); // some watch number fonts don't include '+'
			View.findDrawableById("targetRelBRG").setText( string );
			
			
			var speed_rel = Math.cos( (bearing_deg - heading_deg) * (Math.PI / 180) ) * (posnInfo.speed);
			
			var targetBRGorETE = View.findDrawableById("targetBRGorETE");
			var lblTargetBRGorETE = View.findDrawableById("lblTargetBRGorETE");
			if ( ETEorBRG == 0) {
				// ETE = Estimated Time Enroute
				// Time to target on left upper
				// get relative speed to target
				
				// If our relative speed is less than 0.05m/s (~0.1kt) we show NA
				// This handles negative and zero speeds, and those that would produce very high ETE
				if (speed_rel < 0.05 ) { //|| speed_rel == 0) {
					targetBRGorETE.setText("");
						lblTargetBRGorETE.setText( "ETE (n/a)" );
				} else {
					var ETE = distance / speed_rel; // meters / meters per seconds = seconds
					Sys.println( "ETE: " + ETE );
					// if time is > 1 hour, then show as hours:minutes
					if ( ETE > 3600 ) { // 60 * 60 = 3600
						ETE = ETE / 3600; // ETE now in hours
						string = ETE.toNumber().toString() + ":";
						string += ((ETE - ETE.toNumber()) * 60).format("%02d");
						lblTargetBRGorETE.setText( "ETE (h:m)" );
						targetBRGorETE.setText(string);	
					} else { // otherwise show as minutes:seconds
						ETE = ETE / 60; // ETE now in minutes
						string = ETE.toNumber().toString() + ":";
						string += ((ETE - ETE.toNumber()) * 60).format("%02d");
						lblTargetBRGorETE.setText( "ETE (m:s)" );
						targetBRGorETE.setText( string );
					}
				}
				/*
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
				*/
				
				
			} else {
				lblTargetBRGorETE.setText( "BTW" );
				// Bearing to target on left lower
				if (bearing_deg < 0) { 
					bearing_deg += 360; // make sure degrees are positive
				} 
				string = bearing_deg.format("%1.0f");
				targetBRGorETE.setText( string );
			}
			

			
			
			if (speedOrVMG == 0) { // speed
				// speed in kt large on right upper
	            //string = (posnInfo.speed * 1.94384).format("%1.1f"); // Convert from m/s to knots
				//View.findDrawableById("targetKnt").setText( string );
				var speed = Calcs.metersPerSecond_to_preferred(posnInfo.speed);
				View.findDrawableById("targetSpeedOrVMG").setText(speed["value"].format("%1.1f"));
				View.findDrawableById("lblTargetSpeedOrVMG").setText("SOG (" + speed["label"] + ")");
            } else { // VMG
            	var vmg = Calcs.metersPerSecond_to_preferred(speed_rel);
				View.findDrawableById("targetSpeedOrVMG").setText(vmg["value"].format("%1.1f"));
				View.findDrawableById("lblTargetSpeedOrVMG").setText("VMC (" + vmg["label"] + ")");
            }
			
    		// distance in nm large on right lower
            //string = distance.format("%1.2f"); 
			//View.findDrawableById("targetNM").setText( string );
			
	        if ( distance != null ) {
	        	distance = Calcs.meters_to_preferred(distance);
	        	if (distance["value"] >= 100) {
			        string = distance["value"].format("%1.0f");
	        	} else if (distance["value"] >= 10) {
			        string = distance["value"].format("%1.1f");
	        	} else {
			        string = distance["value"].format("%1.2f");
	        	}
	        } else {
	        	string = "N/A";
	        }
			View.findDrawableById("targetDistance").setText( string );
			View.findDrawableById("lblTargetDistance").setText( "DTW (" + distance["label"] + ")");
            
            
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
			//} else {	
			//	setTextColor( Gfx.COLOR_WHITE );			
			}
			
            
	        // Call the parent onUpdate function to redraw the layout
	        // We do this _after_ we've updated the layout elements
	        View.onUpdate(dc);
	        
            // _Then_ we draw the arrow for relative bearing
            if ( self.bearingArrow != null ) { // If we're just being called from onLayout, we can't draw the bearing arrow
				self.bearingArrow.draw( dc, bearing_deg - heading_deg );
            }
	        
        }
        else {
			View.findDrawableById("targetBadPos").setText( "No position info" );
			setTextColor( Gfx.COLOR_DK_GRAY );
			
	        // Call the parent onUpdate function to redraw the layout
	        // We do this _after_ we've updated the layout elements
	        View.onUpdate(dc);
        }
    }
    
    function setTextColor( color ) {
				
		View.findDrawableById("lblTargetRelBRG").setColor( color );
		View.findDrawableById("lblTargetBRGorETE").setColor( color );
		View.findDrawableById("lblTargetSpeedOrVMG").setColor( color );
		View.findDrawableById("lblTargetDistance").setColor( color );
		
		View.findDrawableById("targetTime").setColor( color );
		View.findDrawableById("targetName").setColor( color );
		View.findDrawableById("targetRelBRG").setColor( color );
		View.findDrawableById("targetBRGorETE").setColor( color );
		View.findDrawableById("targetSpeedOrVMG").setColor( color );
		View.findDrawableById("targetDistance").setColor( color );
    }

}
