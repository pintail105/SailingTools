# SailingTools
A Garmin watch IQ app designed for sailing

Three views:  
Main - Shows time, current heading (both as number and as arrow on edge of screen), speed, position.  
Target - Shows time, speed, and target (i.e., waypoint) information, including relative bearing (both as number and as arrow on edge of screen), bearing, and distance.  
Timer - Race timer  

Multiple targets can be loaded. Screens are rotated by pressing the up/down arrow keys.  
Double-pressing (within 1 second) the run button sets a new target.  
Single-pressing the run button on the target view opens menu. Choices are to stop following that target or save the target.  
Holding the up button opens the main menu. Choices are to load a saved target or start the timer.  
Pressing the back button opens the exit menu. Choices are to Save and Exit or Discard and Exit.  
All menus are designed with Back being the default option. This helps avoid choosing something you don't want to do when bumping the buttons, like during an active race.  
Targets are saved to slots. Garmin limits the menu items, so only 15 slots are available at this time.  
Activity recording starts automatically when the unit gets a (marginal) location fix.  
If the timer is already running, starting it from the main menu will reset it. The time is currently hard coded to 5 minutes.  
When viewing the timer, pressing the run button will round the timer to closest minute.  
If the location stops being updated or becomes poor quality, the display will grey slightly and will include a warning text in red.  

Editing or manually inputting targets (waypoints) is done by editing the SailingTools app settings through the Garmin app on your phone. The format is "name;latitude;longitude" (without the quotes). Here is an example: "MKE North Gap;43.044235;-87.880455".  Only 15 slots are actually available due to Garmin's limit on menu items. The last couple slots are specially named for possible future features.

The original layout was designed for the Garmin Forerunner 235.  Layouts for other round-faced watches are now included, though there could be minor issues to different font sizes on different devices.  Please feel free to let me know if there are issues with the layout on a particular watch, or for requests to support a specific watch.  

Disclaimer: Do not use this app for primary navigational purposes.  

Main View:  
![Main View](https://github.com/pintail105/SailingTools/raw/master/img/mainView.png?raw=true "Main View")

Target (waypoint) View:  
![Target View](https://github.com/pintail105/SailingTools/raw/master/img/targetView.png?raw=true "Target (waypoint) View")

Timer View:  
![Timer View](https://github.com/pintail105/SailingTools/raw/master/img/timerView.png?raw=true "Timer View")