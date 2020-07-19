using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application as App;

class SailingToolsMenuWaypointDelegate extends Ui.MenuInputDelegate {

	function initialize() {
		MenuInputDelegate.initialize();
	}
	
    // create menu for waypoints
	function createWaypointMenu() {
		var menu = new Ui.Menu();
		menu.setTitle("Waypoints");
		menu.addItem("Back", :back);
		
		var slotName = "";
		var slotId = "";
		
		// load all slots 1-19
		for ( var i = 1; i <= 19; i++ ) {
			slotId = "slot" + i.format("%02d");
			slotName = getSlotName(slotId);
			if ( slotName != "") {
				menu.addItem(i.format("%2d") + ": " + slotName, i);
			}
		}
		// load special start_pin and cmte_boat slots
		menu.addItem( "Start Pin", :start_pin); //@Strings.title_start_pin
		menu.addItem( "Committee Boat", :cmte_boat); //@Strings.title_cmte_boat
		
		return menu;
	}
	
	function getSlotName( slotId ) {
		var string = "";
		try {
			string = App.getApp().getProperty(slotId);
			if ( string != null ) {
				string = string.toString();
				var delimIndex = string.find( ";" );
				if ( delimIndex != null ) {
					string = string.substring(0,delimIndex);
				} else {
					string = "<blank>";
				}
			} else { 
				string = ""; 
			}
		}
		catch ( ex ) {
			System.println("Error in getSlotName: " + ex.getErrorMessage );
		}
		//Sys.println("slotId name: " + string);
		return string;
	}
}

class SailingToolsMenuDelegate_Main extends SailingToolsMenuWaypointDelegate {

    function initialize() {
        SailingToolsMenuWaypointDelegate.initialize();
    }

    function onMenuItem(item) {
		switch (item) {
			case :load_waypoint:
		        Sys.println("load_waypoint");
				Ui.pushView(createWaypointMenu(), new SailingToolsMenuDelegate_FollowTarget(), Ui.SLIDE_LEFT);	
				break;
			case :start_timer_5:
		        Sys.println("start_timer_5");
				App.getApp().startTimer5();
				break;
			case :start_timer_custom:
		        Sys.println("start_timer_custom");
				App.getApp().startTimer(App.getApp().getProperty("customTimer"));
				break;
			case :back:
				// Do nothing -> return	
				App.getApp().returnFromMenu();
				break;
			default:
				break;
		}
    }    
}

class SailingToolsMenuDelegate_Exit extends Ui.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        if (item == :save) {
            Sys.println("save and exit");
			App.getApp().saveAndExit();
		}
        if (item == :discard) {
            Sys.println("discard and exit");
			App.getApp().discardAndExit();
        } else if (item == :back) {
            Sys.println("back");
			// Do nothing -> return	
			App.getApp().returnFromMenu();
        }
    }
}

class SailingToolsMenuDelegate_FollowTarget extends Ui.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
		var slotId = null;
        if (item == :back) {
			// Do nothing -> return	
			//Ui.popView(Ui.SLIDE_RIGHT);
			App.getApp().returnFromMenu();
        } else if (item >= 1 && item <= 19) {
			slotId = "slot" + item.format("%02d");
        } else if (item == :start_pin) {
			slotId = "start_pin";
        } else if ( item == :cmte_boat) {
			slotId = "cmte_boat";
        } else {
			Sys.println("no action on item: " + item);
        }
        if ( slotId != null ) {
			Sys.println("load waypoint from slot: " + slotId);
			Ui.popView(Ui.SLIDE_RIGHT); // We need to pop our menus off since we provided the last one ourselves
			Ui.popView(Ui.SLIDE_RIGHT); 
			App.getApp().loadSavedTarget(slotId);
        }
    }
}

class SailingToolsMenuDelagate_TargetContext extends SailingToolsMenuWaypointDelegate {

    function initialize() {
        SailingToolsMenuWaypointDelegate.initialize();
    }
    
    function onMenuItem(item) {
		switch (item) {
			case :unfollow:
		        Sys.println("unfollow");
				App.getApp().unfollowTarget();
				break;
			case :save:
		        Sys.println("save");
				Ui.pushView(createWaypointMenu(), new SailingToolsMenuDelegate_SaveTarget(), Ui.SLIDE_LEFT);	
				break;
				break;
			case :back:
				// Do nothing -> return	
				App.getApp().returnFromMenu();
				break;
			default:
				break;
		}
	}
}

class SailingToolsMenuDelegate_SaveTarget extends Ui.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
		var slotId = "";
        if (item == :back) {
			// Do nothing -> return	
			//Ui.popView(Ui.SLIDE_RIGHT);
			App.getApp().returnFromMenu();
        } else if (item > 1 && item <= 19) {
			slotId = "slot" + item.format("%02d");
        } else if (item == :start_pin) {
			slotId = "start_pin";
        } else if ( item == :cmte_boat) {
			slotId = "cmte_boat";
        } else {
			Sys.println("no action on item: " + item);
        }
        if ( slotId != "" ) {
			Sys.println("save waypoint to slot: " + slotId);
			Ui.popView(Ui.SLIDE_RIGHT); // We need to pop our menus off since we provided the last one ourselves
			//Ui.popView(Ui.SLIDE_RIGHT); 
			App.getApp().saveTarget(slotId);
        }
    }
}
