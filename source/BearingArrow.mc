//!
//! Copyright 2017-2018 by Dan Perik
//!

using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Position as Position;
using Toybox.Math as Math;

class BearingArrow {
	
	// center_x, center_y
	// h = arrow height
	// r = radius
	var h, sideLen; //, r, center_x, center_y, sideLen;
	
	var color_border, color_interior;
	
	function initialize() {
		setHeight( 10 ); // Set default arrow height (in pixels)
		setColors( Gfx.COLOR_LT_GRAY, Gfx.COLOR_DK_RED );
	}
	
	function setHeight( h_new ) {
		self.h = h_new;
		self.sideLen = Math.sqrt(2 * Math.pow(self.h, 2));
	}
	
	function setColors( color_border, color_interior ) {
		self.color_border = color_border;
		self.color_interior = color_interior;
	}
	
	/*function setSizes( dc ) {
	}
	*/

	function draw(dc, bearing) {
		var maxWidth = dc.getWidth();
		var maxHeight = dc.getHeight();
		var center_x = maxWidth / 2;
		var center_y = maxHeight / 2;
		var r = 0;
		// set r to maximum of center_x, center_y
		if (center_x < center_y ) {
			r = center_y;
		} else {
			r = center_x;
		}
		
		var brg = Math.toRadians(bearing);
		
		var pts =  [[0,0],[0,0],[0,0]]; // array of coordinates
		
		// arrow tip
		pts[0][0] = center_x + (Math.sin(brg) * r);
		pts[0][1] = center_y - (Math.cos(brg) * r);
		
		// If this is a semi-circle watch (like the Forerunner 235), then be sure tip is within view
		if (pts[0][1] < 0 ) {
			pts[0][1] = 0;
			pts[0][0] = Math.tan(brg) * center_y + center_x;
		} else if (pts[0][1] > maxHeight) {
			pts[0][1] = maxHeight;
			pts[0][0] = center_x - Math.tan(brg) * center_y;
		}

		// Get inner arrow points
		// calculate position of line in reverse direction of bearing +/- 45 degrees (3 * pi/4)
		pts[1][0] = pts[0][0] + Math.sin(brg-(Math.PI/4.0 * 3.0)) * self.sideLen;
		pts[1][1] = pts[0][1] - Math.cos(brg-(Math.PI/4.0 * 3.0)) * self.sideLen;
		pts[2][0] = pts[0][0] + Math.sin(brg+(Math.PI/4.0 * 3.0)) * self.sideLen;
		pts[2][1] = pts[0][1] - Math.cos(brg+(Math.PI/4.0 * 3.0)) * self.sideLen;

		//dc.drawLine(self.center_x, self.center_y, pts[0][0], pts[0][1]); // draw line from center to tip of arrow
	
        dc.setColor( self.color_interior, Gfx.COLOR_TRANSPARENT );
		dc.fillPolygon( pts ); // fill polygon		
		
        dc.setColor( self.color_border, Gfx.COLOR_TRANSPARENT );
		dc.drawLine(pts[0][0], pts[0][1], pts[1][0], pts[1][1]); // draw side 1
		dc.drawLine(pts[0][0], pts[0][1], pts[2][0], pts[2][1]); // draw side 2
		dc.drawLine(pts[1][0], pts[1][1], pts[2][0], pts[2][1]); // draw bottom
	} 
}