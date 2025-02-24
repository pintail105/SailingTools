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
//using Toybox.Timer as Timer;
//using Toybox.ActivityRecording as Record;
using Toybox.Application as App;

class SailingToolsTimerView extends SailingToolsViewTemplate {

//	var timeString = "";
	//var endTime = null;
	
    function initialize() {
        SailingToolsViewTemplate.initialize();
    }
    
    function onLayout( dc ) {
        setLayout( Rez.Layouts.TimerLayout( dc ) );
    }
	
	// Handle Select button press
	function doSelect() {
		// push context menu
		
        //Ui.pushView(new Rez.Menus.TargetMenu(), new SailingToolsMenuDelagate_TargetContext(), Ui.SLIDE_LEFT);
        
        
		Sys.println("SailingToolsTimerView.doSelect");
		var raceTimer = App.getApp().raceTimer;
		
		//  Start the timer if it's not started
		// Otherwise round to nearest minute
    	if (raceTimer != null ) {
    		Sys.println("isStarted()" + raceTimer.isStarted());
    		Sys.println("isRacing()" + raceTimer.isRacing());
    		
    		if (raceTimer.isStarted()) {
    			if (raceTimer.isRacing() || raceTimer.isRaceOver()) { 
    				// If race is over and we hit the button, it will set the current time as the race end time
    				raceTimer.stopRace();
    			} else {
	    			raceTimer.roundMinutes();
	    		}
	    	} else {
	    		raceTimer.startTimer();
	    	}
		}
        
        return true;
	}
	

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
	function onUpdate(dc) {
		// Update time at top
		var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		var timeString = today.hour.format("%2d") + ":" + today.min.format("%02d") + ":" + today.sec.format("%02d");
		var clockTimeDrawable = View.findDrawableById("clockTime");
		clockTimeDrawable.setText(timeString);
	
	
		var timerString = "";
		var secToStart = 0;
		var absSec = 0;
		
		var raceTimer = App.getApp().raceTimer;
		
		if (raceTimer != null ) {
			secToStart = raceTimer.getSecsToStart();//endTime.compare(Time.now());
			absSec = secToStart.abs();
			if ( (absSec > Gregorian.SECONDS_PER_HOUR) ) {
				timerString = (absSec / Gregorian.SECONDS_PER_HOUR).format("%1d") + ":" + 
							 ((absSec % Gregorian.SECONDS_PER_HOUR) / 60).format("%02d") + ":" +
							 (absSec % 60).format("%02d");
			} else {
				timerString = (absSec / 60).format("%1d") + ":" + (absSec % 60).format("%02d");
			}
		}
		var timerDrawable = View.findDrawableById("timerTime");
		timerDrawable.setText(timerString);
		
		var headDrawable = View.findDrawableById("timerHead");
		
		if ( secToStart > 10 ) { // more than 10 seconds to the start
			headDrawable.setColor(Gfx.COLOR_RED);
			headDrawable.setText("Time To Start");
			timerDrawable.setColor(Gfx.COLOR_WHITE);
		} else if ( secToStart >= 0 ) { // less than 10 seconds to the start
			headDrawable.setColor(Gfx.COLOR_RED);
			headDrawable.setText("Time To Start");
			timerDrawable.setColor(Gfx.COLOR_RED);
		} else if ( secToStart < 0 ) { // started, show elapsed time
			headDrawable.setColor(Gfx.COLOR_GREEN);
			if (raceTimer.isRacing()) {
				headDrawable.setText("Racing Time");
				timerDrawable.setColor(Gfx.COLOR_WHITE);
			} else { // Race is over
				headDrawable.setColor(Gfx.COLOR_DK_GREEN);
				headDrawable.setText("Finished Time");
				timerDrawable.setColor(Gfx.COLOR_WHITE);
				var secsSinceFinish = raceTimer.getSecsSinceFinish() ;
				secsSinceFinish = (secsSinceFinish / 60).format("%1d") + ":" + (secsSinceFinish % 60).format("%02d");
				View.findDrawableById("timer2Time").setColor(Gfx.COLOR_DK_BLUE);
				View.findDrawableById("timer2Time").setText( secsSinceFinish );
				
			}
			//timerDrawable.setFont(Gfx.FONT_NUMBER_HOT);
		}
		
		if (absSec > Gregorian.SECONDS_PER_HOUR)  {
			timerDrawable.setFont(Gfx.FONT_NUMBER_HOT);
		} else {
			timerDrawable.setFont(Gfx.FONT_NUMBER_THAI_HOT);
		}
		
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

}
