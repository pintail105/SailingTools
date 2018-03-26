using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application as App;

class SailingToolsDelegate extends Ui.BehaviorDelegate {
	//var lastSelectTime = null; // save last time of select button for determining double-click select
	var selTimer = null; // timer for distinguishing single select

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
        Ui.pushView(new Rez.Menus.MainMenu(), new SailingToolsMenuDelegate_Main(), Ui.SLIDE_LEFT);
        return true;
    }
    
	function onKey(evt) {
		Sys.println("key evt : " +evt);
		if (evt.getKey() == Ui.KEY_ESC) {
			Sys.println("back button pressed (from event)");
			Ui.pushView(new Rez.Menus.StopMenu(), new SailingToolsMenuDelegate_Exit(), Ui.SLIDE_LEFT);
			return true;
		}
		return false;
	}

	function onBack() {
		Sys.println("back button pressed");
		Ui.pushView(new Rez.Menus.StopMenu(), new SailingToolsMenuDelegate_Exit(), Ui.SLIDE_LEFT);
		return true;
	}

	function onPreviousPage() {
		// Go to next page
		Sys.println("up pressed");
		App.getApp().doPageUp();
		return true;
	}

	function onNextPage() {
		// Go to next page
		Sys.println("down pressed");
		App.getApp().doPageDown();
		return true;
	}
	
	// set a timer for selection in 1 second
	// if they hit the button again before then, stop the timer and it should be a double click
	function onSelect() {
		Sys.println("select pressed");
		// If timer is running and we're here, that means a double-select
		if (selTimer != null) {
			// we have to clear the timer and set to null
			selTimer.stop();
			selTimer = null;
			App.getApp().doubleSelect();
		/*}
		
		// check for "double-click" of select button
		var fireEvent = false;
		if (lastSelectTime != null && lastSelectTime.subtract( Time.now() ).value() == 0) {
			Sys.println( "time since last select: " + lastSelectTime.subtract( Time.now() ).value() );
			fireEvent = true;
		}
		lastSelectTime = Time.now();
		if (fireEvent) {
			App.getApp().doubleSelect();
			*/
		} else {
			// Start timer for single select 
			selTimer = new Timer.Timer();
			selTimer.start(method(:doSingleSelect), 500, false);
		}
		return true;
	}
	
	// Timer fired for single select
	function doSingleSelect() {
		// clear timer, otherwise next select will trigger double-select code
		if (selTimer != null) {
			selTimer.stop();
			selTimer = null;
		}
		App.getApp().singleSelect();
	}
}