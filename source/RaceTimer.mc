//!
//! Copyright 2017-2020 by Dan Perik
//!

using Toybox.System as Sys;
//using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
//using Toybox.Timer as Timer;
using Toybox.Attention;

class RaceTimer {
	
	var timerMinutes = 5;
	var endTime = null;
	
	function setMinutes(minutes) {
		timerMinutes = minutes;
	}
	
	function resetTimer() {
		// Get time 5 minutes from now, as Moment object
		endTime = Time.now().add(new Time.Duration( timerMinutes * Gregorian.SECONDS_PER_MINUTE ));
//		endTime = Time.now().add(new Time.Duration( 300 )); //TESTING
	}
	
	function getEndTime() {
		return endTime;
	}
	
	function getSecsToStart() {
		return endTime.compare(Time.now());
	}
	
	function roundMinutes() {
	// round to nearest minutes
        //var minutesRemaining = (endTime.compare( Time.now() ) + (Gregorian.SECONDS_PER_MINUTE/2)) % Gregorian.SECONDS_PER_MINUTE;
        var minutesRemaining = Math.round((endTime.compare( Time.now() ) + (Gregorian.SECONDS_PER_MINUTE/2))  / Gregorian.SECONDS_PER_MINUTE);
        
		Sys.println("minutesRemaining: " + minutesRemaining);
        endTime = Time.now().add(new Time.Duration( minutesRemaining * Gregorian.SECONDS_PER_MINUTE ));
        
	}
	
	function update() {
		var secToStart = getSecsToStart();
		if ( secToStart >= 0 ) {
			if ( (secToStart % 60) == 0 ) {
				notify();
			}
			if ( secToStart == 30 || secToStart == 15 || secToStart == 10 ) {
				notify();
			}
			if ( secToStart <= 5 ) {
				notify();
			}
		}
	}
	
	function notify() {
		if (Attention has :backlight) {
		    Attention.backlight(true);
		}
		if (Attention has :playTone) {	
//			Attention.playTone(Attention.TONE_TIME_ALERT);
			Attention.playTone(Attention.TONE_ALARM);
		}
		if (Attention has :vibrate) {
			Attention.vibrate([new Attention.VibeProfile(100, 500)]); // On for one second)
		}
	}
}