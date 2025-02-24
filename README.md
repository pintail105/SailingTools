# SailingTools
A Garmin watch IQ app designed for sailing

Four views:  
Stats - Shows elapsed distance, elapsed time, average speed, max speed, and battery percentage.
Main - Shows time, current heading (both as number and as arrow on edge of screen), speed, position.  
Target(s) - Shows time, speed, and target (i.e., waypoint) information, including relative bearing (both as number and as arrow on edge of screen), bearing, and distance.  Can show Estimated Time Enroute (ETE) in place of bearing (BTW), and Velocity Made Course (VMC) instead of speed (SOG). Relative bearing is shown in red when to port and in green when to starboard.
Timer - Race timer  

Multiple targets can be loaded. Screens are rotated by pressing the up/down arrow keys.  
Double-pressing (within 1 second) the run button on any screen sets a new target using your current position.  
Single-pressing the run button on the target view opens menu. Choices are to stop following that target, save the target, toggle ETE/BTW, and toggle SOG/VMC.  
Holding the up button opens the main menu. Choices are to load a saved target, load the default 5 minute timer, or load the custom timer.  
Pressing the back button opens the exit menu. Choices are to Save and Exit or Discard and Exit.  
All menus are designed with Back being the default option. This helps avoid choosing something you don't want to do when accidentally bumping the buttons, like during an active race.  
Targets are saved to slots. Garmin limits the menu items, so only 15 slots are available at this time.  
Activity recording starts automatically when the unit gets a (marginal) location fix.  

Speed and heading can be smoothed. The number of recent position updates to use for smoothing can be set in the app settings. The default is 0, which means do not smooth. I believe the watch updates the position every second (Garmin's docs are not very clear on this), so a smoothing value of 10 would use the current position now versus the position from 10 seconds ago to determine speed and heading. Larger numbers will mean values such as ETE and VMC are more stable, but it also will mean speed and heading values will lag your true speed and heading. I recommend experimenting with different smoothing values and using this feature with care.

When viewing the timer, pressing the run button will start the timer. Pressing the run button while the timer is counting down will round the timer to closest minute. 
After the start (when finishing the race), pressing the run button will stop the timer and display an additional smaller timer counting from 0 in blue below the finish time. This is so you can see how much time your competitors finish after you did. If you press the run button again, it will set that as the finish time, and again begin the smaller time counting up from 0. 
If the timer is already running, reloading it from the main menu will reset it. The default timer is hard coded to 5 minutes. You can set a custom timer in the app settings through your phone.

If the location stops being updated or becomes poor quality, the display will grey slightly and will include a warning text in red.  
If the battery gets below 10% (configurable in settings), "LOW BATTERY" will be overlaid on every screen.
If the battery gets below 3% (configurable in settings), the app will save and exit.

Editing or manually inputting targets (waypoints) is done by editing the SailingTools app settings through the Garmin Connect IQ app on your phone. The format is "name;latitude;longitude" (without the quotes). Here is an example: "MKE North Gap;43.044235;-87.880455".  Only 15 slots are actually available due to Garmin's limit on menu items. You can use any of the formats: d.decmial, d m.decimal, d m s. Do not use double spaces, since this will cause parsing the values to either fail or (worse!) be wrong.

Other configurable settings include:
Speed units: Knots (kt), miles per hour (mph), kilometers per hour (kph). Knots is the default.
Distance units: Nautical miles (nm), miles (mi), kilometers (km). Nautical miles is the default.
Preferred Lat/Long Format: d.decimal (degrees only with decimal), d m.decimal (degrees and minutes with decimal), d m s (degrees minutes seconds). d m.decimal is the default.
Preferred target ETE or BTW: Whether bearing to waypoint (BTW) or estimated time enroute (ETE) should be displayed by default in the target view. The default is BTW.
Preferred target SOG or VMC: Whether speed (SOG) or velocity made course (VMC) should be displayed by default in the target view. The default is SOG.
Smoothing Num: How many recent positions to use to smooth speed and bearing. Set to 0 to disable smoothing.
Battery Low Indicator: Batter percentage below which a warning should be displayed.
Battery Low Shutdown: Battery percentage below which the app should save and close.
Custom Timer Minutes: The default is 3.

The layout was originally designed for the Garmin Forerunner 235, and now for the Forefunner 245.  Layouts for other round-faced watches are now included, though there could be minor issues due to different font sizes on different devices.  Please feel free to let me know if there are issues with the layout on a particular watch, or for requests to support a specific watch.  

Disclaimer: Do not use this app for primary navigational purposes.  

I wrote this app because I love sailing, and I needed a quick and easy app to use while racing or just cruising around the lake. I don't accept any payment. But, if you find this app useful, the best payment I could imagine is an invitation to come sailing with you. 

Main View:  
![Main View](https://github.com/pintail105/SailingTools/raw/master/img/mainView.png?raw=true "Main View")

Target (waypoint) View:  
![Target View](https://github.com/pintail105/SailingTools/raw/master/img/targetView.png?raw=true "Target (waypoint) View")

Timer View:  
![Timer View](https://github.com/pintail105/SailingTools/raw/master/img/timerView.png?raw=true "Timer View")

Stats View: 
![Timer View](https://github.com/pintail105/SailingTools/raw/master/img/statsView.png?raw=true "Stats View")
