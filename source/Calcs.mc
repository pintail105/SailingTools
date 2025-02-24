//!
//! Copyright 2017-2018 by Dan Perik
//!

using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Position as Position;
using Toybox.Math as Math;
using Toybox.Application as App;

class Calcs {
	
	static var preferredSpeed = 0; //"kt";
	static var preferredDistance = 0; // "nm";
	static var preferredLatLong = 0; //"d.decimal"; // "d.decimal", "d m.decimal", "d m' s\""
	
	static function loadPreferences() {
		Calcs.preferredSpeed = App.getApp().getProperty( "preferredSpeed" );
		Calcs.preferredDistance = App.getApp().getProperty( "preferredDistance" );
		Calcs.preferredLatLong = App.getApp().getProperty( "preferredLatLong" );
	}
	
    // see: http://www.movable-type.co.uk/scripts/latlong.html
    
	// Need to pass Postion.Location objects
	/*
	static function getDistance(loc1, loc2) {
		var lat1 = loc1.toRadians()[0];
		var lon1 = loc1.toRadians()[1];
		var lat2 = loc2.toRadians()[0];
		var lon2 = loc2.toRadians()[1];
		var phi1 = lat1, phi2 = lat2, deltaLambda = (lon2-lon1);
		//var R = 6371e3; // gives d in metres
		//var R = 6371; // gives d in kilometres
		var R = 3440.0695; // gives d in nautical miles : 3440.06954644
		var d = Math.acos( Math.sin(phi1)*Math.sin(phi2) + Math.cos(phi1)*Math.cos(phi2) * Math.cos(deltaLambda) ) * R;
		
		return d;
	}
	*/
	
	static function getDistance_m(loc1, loc2) {
		var lat1 = loc1.toRadians()[0];
		var lon1 = loc1.toRadians()[1];
		var lat2 = loc2.toRadians()[0];
		var lon2 = loc2.toRadians()[1];
		var phi1 = lat1, phi2 = lat2, deltaLambda = (lon2-lon1);
		//var R = 6371e3; // gives d in metres
		//var R = 6371; // gives d in kilometres
		// gives d in nautical miles : 3440.06954644
		var R = 6371e3; 
		var d = Math.acos( Math.sin(phi1)*Math.sin(phi2) + Math.cos(phi1)*Math.cos(phi2) * Math.cos(deltaLambda) ) * R;
		
		return d;
	}
	
	
	static function getBearing_rad(loc1, loc2) {
		var lat1 = loc1.toRadians()[0];
		var lon1 = loc1.toRadians()[1];
		var lat2 = loc2.toRadians()[0];
		var lon2 = loc2.toRadians()[1];
		var y = Math.sin(lon2-lon1) * Math.cos(lat2);
		var x = Math.cos(lat1)*Math.sin(lat2) -
		        Math.sin(lat1)*Math.cos(lat2)*Math.cos(lon2-lon1);
		var brng = Math.atan2(y, x);
		
		return brng;
	}
	
	static function getBearing_deg(loc1, loc2) {
		return Math.toDegrees(getBearing_rad(loc1, loc2));		
	}
	
	static function formatLatLongDegrees(deg) {
		//preferredDegrees = "d.decimal"; // "d m.decimal"", "d m' s\""
		
		//Sys.println("deg: " + deg);
		//Sys.println("Calcs.preferredDegrees: " + Calcs.preferredDegrees);
		var string;
		if (deg != null) {
			deg = deg.abs();
			if (Calcs.preferredLatLong == 0) { // 0 = d.decimal
				string = deg.format("%1.6f");
			} else if (Calcs.preferredLatLong == 1) { // 1 = d m.decimal
				var whole_deg = deg.toLong();
				//var minutes = ((deg % 1) * 60);
				var minutes = ((deg - whole_deg) * 60);
				//string =  deg.toNumber().format("%2d") + "° " 
				string =  whole_deg.format("%2d") + "° " 
					+ minutes.format("%02.3f") + "'";
			} else if (Calcs.preferredLatLong == 2) { // 2 = d m s
				var whole_deg = deg.toLong();
				//var minutes = ((deg % 1) * 60);
				var minutes = ((deg - whole_deg) * 60).toLong();
				var seconds = ((deg - whole_deg) - (minutes.toFloat()/60)) * 3600;
				string = whole_deg.format("%3d") + "° " 
					+ minutes.format("%02d") + "' "
					+ (seconds < 10 ? "0" : "") + seconds.format("%2.1f") + "\"";
			} else {
				string = "unknown format";
			}
		} else {
			string = "N/A";
		}
		//Sys.println("formatDegrees: " + string);
		return string;
	}
	
	static function metersPerSecond_to_preferred(ms) {
		var v = { "multiplier" => 1.94384, "label" => "kt", "value" => 0};
		
		if (Calcs.preferredSpeed == 0) { v["multiplier"] = 1.94384; v["label"] = "kt";} // 0 = kt
		if (Calcs.preferredSpeed == 1) { v["multiplier"] = 2.23694; v["label"] = "mph";} // 1 = mph
		if (Calcs.preferredSpeed == 2) { v["multiplier"] = 3.6; v["label"] = "kph";} // 2 = kph
		
		v["value"] = v["multiplier"] * ms;
		
		return v;
	}
	
	static function meters_to_preferred(m) {
		var d = { "multiplier" => 0.000539957, "label" => "nm", "value" => 0};
		
		if (Calcs.preferredDistance == 0) { d["multiplier"] = 0.000539957; d["label"] = "nm"; }  // 0 = nm
		if (Calcs.preferredDistance == 1) { d["multiplier"] = 0.000621371; d["label"] = "mi"; }  // 1 = mi
		if (Calcs.preferredDistance == 2) { d["multiplier"] = 0.001; d["label"] = "km"; }  // 2 = km
		d["value"] = d["multiplier"] * m;
		
		return d;
	}
}

