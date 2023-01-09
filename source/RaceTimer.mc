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
	var started = false;
	var raceOver = false;
	var raceOverTime = null;
	
	function isStarted() {
		return started;
	}
	
	function isRacing() {
		// If we've started and race is not over
		// If seconds to start is negative, then we're racing
		if (started & !raceOver) {
			return (getSecsToStart()<0);
		} 
		return false;
	}
	
	function stopRace() {
		raceOver = true;
		raceOverTime = Time.now();
	}
	
	function stopTimer() {
		started = false;
	}
	
	function startTimer() {
		started = true;
		raceOver = false;
		raceOverTime = null;
		resetTimer();
	}
	
	function setMinutes(minutes) {
		timerMinutes = minutes;
	}
	
	function resetTimer() {
		// Get time that is timerMinutes from now, as Moment object
		endTime = Time.now().add(new Time.Duration( timerMinutes * Gregorian.SECONDS_PER_MINUTE ));
	}
	
	function getEndTime() {
		return endTime;
	}
	
	function getSecsToStart() {
		var secsToStart = timerMinutes * 60;
		if (started) {
			if (raceOver) {
				secsToStart = endTime.compare(raceOverTime);
			} else {
				secsToStart = endTime.compare(Time.now());
			}
		}
		return secsToStart;
	}
	
	function roundMinutes() {
	// round to nearest minutes
        //var minutesRemaining = (endTime.compare( Time.now() ) + (Gregorian.SECONDS_PER_MINUTE/2)) % Gregorian.SECONDS_PER_MINUTE;
        var minutesRemaining = Math.round((endTime.compare( Time.now() ) + (Gregorian.SECONDS_PER_MINUTE/2))  / Gregorian.SECONDS_PER_MINUTE);
        
		Sys.println("minutesRemaining: " + minutesRemaining);
        endTime = Time.now().add(new Time.Duration( minutesRemaining * Gregorian.SECONDS_PER_MINUTE ));
        
	}
	
	function update() {
		if ( started ) {
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