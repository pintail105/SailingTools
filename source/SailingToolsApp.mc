using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.ActivityRecording as Record;
using Toybox.Time.Gregorian;

class SailingToolsApp extends App.AppBase {

	var sailingToolsViews = [];
	var sailingToolsDelegates = [];
	var viewIndex = null;
	var timerIndex = null;
	var raceTimer = null;
	
	var newWaypointNum = 0; // For counting multiple new waypoints

    var posnInfo = null; // Position.Info object
    var lastPosnUpdate = null; // the time of the last position update
    
    // for smoothing speed / bearing
    var useSmoothedPosn = false; // This will be set by preferences
    var posnInfo_arr_length = 0; // This will be set by preferences
    var posnInfo_arr = null; //new [15]; // array will be created in onStart, based on preferences
    var posnInfo_arr_pntr = 0; 
    
    var canRecord = false; // Whether we can record activity
    var recording = false; // Whether we're recording acitivity
    var session = null; // recording session
    var secTimer = null; // Main timer for updating UI, starting recording, etc.
    
    var battLowIndicator = 10; // Level at which to show "BATTERY LOW" on screen
    var battLowShutdown = 3; // Level at which to shutdown and save track

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    	// load smoothing preferences
		posnInfo_arr_length = App.getApp().getProperty( "smoothingNum" );
		useSmoothedPosn = posnInfo_arr_length != 0 ? true : false;
		if (useSmoothedPosn) {
			posnInfo_arr = new [posnInfo_arr_length];
			//Sys.println("Using smoothing, with smoothingNum = " + posnInfo_arr_length);
		} else {
			//Sys.println("Not using smoothing, with smoothingNum = " + posnInfo_arr_length);
		}
		
		Calcs.preferredDistance = App.getApp().getProperty( "preferredDistance" );
		Calcs.preferredLatLong = App.getApp().getProperty( "preferredLatLong" );
    
    	Calcs.loadPreferences();
    
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
        
		if( Toybox has :ActivityRecording ) {
			canRecord = true;
		}
		
		secTimer = new Timer.Timer();
		secTimer.start(method(:refresh), 1000, true);
		
		battLowIndicator = App.getApp().getProperty( "battLowIndicator" );
		battLowShutdown = App.getApp().getProperty( "battLowShutdown" );
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
        
        /*
		var today = Gregorian.info(lastPosnUpdate, Time.FORMAT_MEDIUM);
        var now_str = Lang.format(
			    "$1$:$2$:$3$",
			    [
			        today.hour,
			        today.min,
			        today.sec
			    ]
			);
			
		var infoWhen = Gregorian.info(info.when, Time.FORMAT_MEDIUM);
        var infoWhen_str = Lang.format(
			    "$1$:$2$:$3$",
			    [
			        infoWhen.hour,
			        infoWhen.min,
			        infoWhen.sec
			    ]
			);
		
        Sys.println("position updated at: " + now_str + "; info.when: " + infoWhen_str);
        
        */
        if( useSmoothedPosn ) {
        	var posnInfo_15ago = null;
        	var distance, heading, elapsed, speed;
        	posnInfo_arr_pntr++;
        	if ( posnInfo_arr_pntr > (posnInfo_arr_length - 1)) { // arrays are 0-based
        		posnInfo_arr_pntr = 0;
        	}
        	posnInfo_arr[posnInfo_arr_pntr] = info;
        	
        	// get position we received 15 calls ago
        	if (posnInfo_arr_pntr == (posnInfo_arr_length - 1)) {
	        	posnInfo_15ago = posnInfo_arr[0];
        	} else {
	        	posnInfo_15ago = posnInfo_arr[posnInfo_arr_pntr + 1];
        	}
        	
        	if (posnInfo_15ago != null) {
	        	distance = Calcs.getDistance_m(posnInfo_15ago.position, info.position); // in meters
	        	heading = Calcs.getBearing_rad(posnInfo_15ago.position, info.position); // in radians
	        	elapsed = info.when.subtract(posnInfo_15ago.when).value(); // stored in seconds
	        	speed = distance / elapsed; // meters per second
	        	
	        	posnInfo.heading = heading;
	        	posnInfo.speed = speed;
        	}
        }
        
        sailingToolsViews[viewIndex].setPosition(posnInfo, lastPosnUpdate);
    }

    // Return the initial view of your application here
    function getInitialView() {
    	
		// stats view is at top, then main view
		sailingToolsViews = [ new SailingToolsStatsView(), new SailingToolsMainView() ];
		sailingToolsDelegates = [ new SailingToolsDelegate(), new SailingToolsDelegate() ];
		
		// set up one target view
		//sailingToolsViews.add( new SailingToolsTargetView() );
		//sailingToolsDelegates.add( new SailingToolsDelegate() );
		
		// start with main view
		viewIndex = 1;
        return [ sailingToolsViews[viewIndex], sailingToolsDelegates[viewIndex] ];
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
//					session = Record.createSession({:name=>"Sailing", :sport=>Record.SPORT_GENERIC});
					session = Record.createSession({:name=>"Sailing", :sport=>Record.SPORT_SAILING});
					session.start();
				}
			}
		}
		
		// Handle beeps for race timer
		// We do this in app, since we may not be in the race timer view when beep time is hit
		if (raceTimer != null) {
			raceTimer.update();
		}
		
		
		var sysStats = System.getSystemStats();
		//System.println(sysStats.battery);
		if ( sysStats.battery < battLowShutdown ) {
			saveAndExit();
			// App.getApp().saveAndExit();
		} else if ( sysStats.battery < battLowIndicator) {
			sailingToolsViews[viewIndex].overlayMessage( "BATTERY LOW" );
		} else {
			sailingToolsViews[viewIndex].overlayMessage( "" );
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
		newWaypointNum++;
		addCurPosAsTarget("New Waypoint " + newWaypointNum);
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
	
	function toggleETEorBRG() {
		sailingToolsViews[viewIndex].toggleETEorBRG( );
	}
	
	function toggleSpeedOrVMG() {
		sailingToolsViews[viewIndex].toggleSpeedOrVMG( );
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
