using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.ActivityRecording as Record;

class SailingToolsApp extends App.AppBase {

	var sailingToolsViews = [];
	var sailingToolsDelegates = [];
	var viewIndex = null;
	var timerIndex = null;
	var raceTimer = null;

    var posnInfo = null; // Position.Info object
    var lastPosnUpdate = null; // the time of the last position update
    
    var canRecord = false; // Whether we can record activity
    var recording = false; // Whether we're recording acitivity
    var session = null; // recording session
    var secTimer = null; // Main timer for updating UI, starting recording, etc.

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
        
		if( Toybox has :ActivityRecording ) {
			canRecord = true;
		}
		
		secTimer = new Timer.Timer();
		secTimer.start(method(:refresh), 1000, true);
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
		secTimer.stop();
		if( session != null && session.isRecording() ) {
			session.stop();
			session.save();
			session = null;
		}
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }

    function onPosition(info) {
		posnInfo = info;
        lastPosnUpdate = Time.now();
        sailingToolsViews[viewIndex].setPosition(info, lastPosnUpdate);
    }

    // Return the initial view of your application here
    function getInitialView() {
		// main view
    		sailingToolsViews.add( new SailingToolsMainView() );
    		sailingToolsDelegates.add( new SailingToolsDelegate() );
    		
    		// set up one target view
    		//sailingToolsViews.add( new SailingToolsTargetView() );
    		//sailingToolsDelegates.add( new SailingToolsDelegate() );
    		
    		// start with main view
    		viewIndex = 0;
        return [ sailingToolsViews[0], sailingToolsDelegates[0] ];
    }

// This is called every second, to update view, etc.
	function refresh() {
		Ui.requestUpdate();
		// check if we can record, and if we're not then try to
		if (canRecord && !recording) {
			// Only start recording if signal is good
			if (Position.getInfo().accuracy >= Position.QUALITY_POOR){
				// create target with initial position and name = "Start"
				addCurPosAsTarget("Start");
				recording = true;
				if( ( session == null ) || ( session.isRecording() == false ) ) {
					Sys.println("start ActivityRecording");
					session = Record.createSession({:name=>"Sailing", :sport=>Record.SPORT_GENERIC});
					session.start();
				}
			}
		}
		
		// Handle beeps for race timer
		// We do this in app, since we may not be in the race timer view when beep time is hit
		if (raceTimer != null) {
			raceTimer.update();
		}
	}
	
	function addCurPosAsTarget(targetName) {
    		// set up new target view as last view
    		sailingToolsViews.add( new SailingToolsTargetView() );
    		sailingToolsDelegates.add( new SailingToolsDelegate() );
    		
    		// Set target to current location
    		sailingToolsViews[sailingToolsViews.size() - 1].setTarget(Position.getInfo().position);
    		sailingToolsViews[sailingToolsViews.size() - 1].setTargetName(targetName);
	}
	
	// Called via Target context menu
	function unfollowTarget() {
		doPageUp();
		sailingToolsViews.remove(sailingToolsViews[viewIndex + 1]);
		sailingToolsDelegates.remove(sailingToolsDelegates[viewIndex + 1]);
	}
	
	// Need to update position for current view when returning from a menu
	function returnFromMenu() {
        sailingToolsViews[viewIndex].setPosition(posnInfo, lastPosnUpdate);
		Ui.requestUpdate();
	}
	
	// Add current position as target, then switch to that target
	function doubleSelect() {
		addCurPosAsTarget("New Waypoint");
    		viewIndex = sailingToolsViews.size() - 1;
        sailingToolsViews[viewIndex].setPosition(posnInfo, lastPosnUpdate);
		Ui.switchToView(sailingToolsViews[viewIndex], sailingToolsDelegates[viewIndex], Ui.SLIDE_UP);
	}
	
	// send select event to current view, for context sensitive menu
	function singleSelect() {
		sailingToolsViews[viewIndex].doSelect();
	}
	
	function startTimer5() {
		startTimer(5);
	}
	// Start Timer menu item selected
	function startTimer(minutes) {
		// if timer started, show that page and restart it
		// if timer not started, start one
		// timer class will need to be in App, and update timer view, since timer view can be 
		// hidden 
		
		// set up the timer object
		// this is used in the App object to set off beeps
		if (raceTimer == null) {
			Sys.println("Attempting to start timer");
			raceTimer = new RaceTimer();
		}
		raceTimer.setMinutes(minutes);
		
		// set up the timer view
		if (timerIndex == null) {
			sailingToolsViews.add( new SailingToolsTimerView() );
	    	sailingToolsDelegates.add( new SailingToolsDelegate() );
			
    		viewIndex = sailingToolsViews.size() - 1;
    		timerIndex = viewIndex;
		} else {
			viewIndex = timerIndex;
		}
		raceTimer.stopTimer(); // stop timer if it's already started
		raceTimer.resetTimer();
        sailingToolsViews[viewIndex].setPosition(posnInfo, lastPosnUpdate);
		Ui.popView(Ui.SLIDE_UP); // Need to pop the menu, then switch views
		Ui.switchToView(sailingToolsViews[viewIndex], sailingToolsDelegates[viewIndex], Ui.SLIDE_UP);
	}
	
	// Load a saved waypoint as a target, then switch to that target
	function loadSavedTarget( slotId ) {
		Sys.println("Attempting to load from " + slotId );
    		sailingToolsViews.add( new SailingToolsTargetView() );
    		sailingToolsDelegates.add( new SailingToolsDelegate() );
    		
    		// Set target to current location
    		sailingToolsViews[sailingToolsViews.size() - 1].loadFromSlot( slotId );
    		
    		viewIndex = sailingToolsViews.size() - 1;
        sailingToolsViews[viewIndex].setPosition(posnInfo, lastPosnUpdate);
		Ui.switchToView(sailingToolsViews[viewIndex], sailingToolsDelegates[viewIndex], Ui.SLIDE_UP);
	}
	
	// Save current target to slot given 
	function saveTarget( slotId ) {
		Sys.println("Attempting to save to " + slotId);
    		sailingToolsViews[viewIndex].saveToSlot( slotId );
		
	}
	
	function doPageUp() {
		if ( sailingToolsViews.size() > 1 ) {
			viewIndex -= 1;
			if (viewIndex < 0) {
				viewIndex = sailingToolsViews.size() - 1;
			}
			// make sure the new view knows our position
	        sailingToolsViews[viewIndex].setPosition(posnInfo, lastPosnUpdate);
			Ui.switchToView(sailingToolsViews[viewIndex], sailingToolsDelegates[viewIndex], Ui.SLIDE_DOWN);
		}
	}
	
	function doPageDown() {
		if ( sailingToolsViews.size() > 1 ) {
			viewIndex += 1;
			if (viewIndex >= sailingToolsViews.size()) {
				viewIndex = 0;
			}
			// make sure the new view knows our position
	        sailingToolsViews[viewIndex].setPosition(posnInfo, lastPosnUpdate);
			Ui.switchToView(sailingToolsViews[viewIndex], sailingToolsDelegates[viewIndex], Ui.SLIDE_UP);
		}
	}
	
	
	function saveAndExit() {
		secTimer.stop();
		if( session != null && session.isRecording() ) {
			session.stop();
			session.save();
			session = null;
		}
		Ui.popView(Ui.SLIDE_IMMEDIATE); // This exits the app
	}
	
	function discardAndExit() {
		secTimer.stop();
		if( session != null && session.isRecording() ) {
			session.stop();
			session.discard();
			session = null;
		}
		Ui.popView(Ui.SLIDE_IMMEDIATE); // This exits the app
	}
}
