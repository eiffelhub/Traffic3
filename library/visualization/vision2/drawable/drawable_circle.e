indexing

	description: "Circles that will scale when zooming in EV_CANVAS"
	status:	"See notice at end of class"
	author: "Till G. Bay"
	date: "$Date: 2004/10/20 10:03:03 $"
	revision: "$Revision: 1.3 $"

class DRAWABLE_CIRCLE inherit

	DRAWABLE_OBJECT

create

	make

feature -- Initialization

	make (a_center: like center) is
			-- Create a circle that scales at `a_center' with default diameter and edge width.
		require
			a_center_not_void: a_center /= Void
		do
			set_width (default_width)
			set_color (create {EV_COLOR}.make_with_rgb (0.0,0.0,0.0))
			set_diameter (default_diameter)
			set_center (a_center)
			is_shown := True
		ensure
			width_set: width = default_width
			diameter_set: diameter = default_diameter
			center_set: center = a_center
			shown: is_shown
		end

feature -- Access

	width: INTEGER
			-- The width of the cirle's line

	diameter: INTEGER
			-- The circle's diameter

	center: REAL_COORDINATE
			-- The circle's center

	bounding_box: REAL_RECTANGLE is
			-- The bounding box of the circle
		do
			create Result.make (
									create {REAL_COORDINATE}.make (center.x - (diameter/2), center.y - (diameter/2)),
									create {REAL_COORDINATE}.make (center.x + (diameter/2), center.y + (diameter/2)))
		end

feature -- Element change

	set_diameter (a_diameter: INTEGER) is
			-- Change the circle's diameter to `a_diameter'.
		do
			diameter:= a_diameter
			invalidate
		ensure
			new_diameter: diameter = a_diameter
		end

	set_center (a_center: REAL_COORDINATE) is
			-- Change the circle's center to `a_center'.
		require
			a_center_not_void: a_center /= Void
		do
			center:= a_center
			invalidate
		ensure
			new_center: center = a_center
		end

	set_width (a_width: INTEGER)  is
			-- Change the circle's edge width to `a_width'.
		do
			width:= a_width
			invalidate
		ensure
			new_width: width= a_width
		end

feature -- Status report

	is_filled: BOOLEAN
			-- Is the circle drawn filled

feature -- Status setting

	enable_filled is
			-- Fill the circle.
		do
			is_filled:= True
			invalidate
		ensure
			is_filled: is_filled
		end

	disable_filled is
			-- Unfill the circle.
		do
			is_filled:= False
			invalidate
		ensure
			not_filled: not is_filled
		end

feature {CANVAS} -- Basic operations

	draw_object is
			-- Draw the circle.
		local
			scaled_p1, scaled_p2 : EV_COORDINATE
		do
			scaled_p1 := real_to_integer_coordinate (bounding_box.upper_left)
			scaled_p2 := real_to_integer_coordinate (bounding_box.lower_right)
			canvas.set_line_width (width)
			if color /= Void then
				canvas.set_foreground_color (color)
			end
			if
				is_filled
			then
				canvas.fill_ellipse (scaled_p1.x, scaled_p1.y, scaled_p2.x - scaled_p1.x, scaled_p2.y - scaled_p1.y)
			else
				canvas.draw_ellipse (scaled_p1.x, scaled_p1.y, scaled_p2.x - scaled_p1.x, scaled_p2.y - scaled_p1.y)
			end
		end

feature {NONE} -- Constants for implementation

	Default_width: INTEGER is 1
			-- The default width for the circles edge

	Default_diameter: INTEGER is 5
			-- The default diameter of the circle

invariant

	center_not_void: center /= Void

end

--|--------------------------------------------------------
--| This file is Copyright (C) 2003 by ETH Zurich.
--|
--| For questions, comments, additions or suggestions on
--| how to improve this package, please write to:
--|
--|     Till G. Bay <tillbay@student.ethz.ch>
--|
--|--------------------------------------------------------
