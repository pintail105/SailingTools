//!
//! Copyright 2017-2018 by Dan Perik
//!

using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Position as Position;
using Toybox.Math as Math;

class GeoCalcs {
	
    // see: http://www.movable-type.co.uk/scripts/latlong.html
    
	// Need to pass Postion.Location objects
	static function getDistance(loc1, loc2) {
		var lat1 = loc1.toRadians()[0];
		var lon1 = loc1.toRadians()[1];
		var lat2 = loc2.toRadians()[0];
		var lon2 = loc2.toRadians()[1];
		var φ1 = lat1, φ2 = lat2, Δλ = (lon2-lon1);
		//var R = 6371e3; // gives d in metres
		//var R = 6371; // gives d in kilometres
		var R = 3440.0695; // gives d in nautical miles : 3440.06954644
		var d = Math.acos( Math.sin(φ1)*Math.sin(φ2) + Math.cos(φ1)*Math.cos(φ2) * Math.cos(Δλ) ) * R;
		
		return d;
	}
	
	static function getDistance_m(loc1, loc2) {
		var lat1 = loc1.toRadians()[0];
		var lon1 = loc1.toRadians()[1];
		var lat2 = loc2.toRadians()[0];
		var lon2 = loc2.toRadians()[1];
		var φ1 = lat1, φ2 = lat2, Δλ = (lon2-lon1);
		//var R = 6371e3; // gives d in metres
		//var R = 6371; // gives d in kilometres
		var R = 6371e3; // gives d in nautical miles : 3440.06954644
		var d = Math.acos( Math.sin(φ1)*Math.sin(φ2) + Math.cos(φ1)*Math.cos(φ2) * Math.cos(Δλ) ) * R;
		
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
}

