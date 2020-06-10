note
	description: "[
					Circle that wont scale when zooming in
					EV_CANVAS, threfore a spot
					]"
	status:	"See notice at end of class"
	author: "Till G. Bay"
	date: "$Date: 2004/10/20 10:03:03 $"
	revision: "$Revision: 1.3 $"

class DRAWABLE_SPOT inherit

	DRAWABLE_OBJECT

create

	make

feature -- Creation

	make (a_center: like center)
			-- Create a circle that does not scale at `a_center'.
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

feature -- Element change

	set_width (a_width: like width)
			-- Set the circle's edge width to `a_width'.
		do
			width:= a_width
			invalidate
		ensure
			new_width: width = a_width
			not_valid: not is_valid
		end

	set_diameter (a_diameter: like diameter)
			-- Set the circle's diameter to `a_diameter'.
		do
			diameter := a_diameter
			invalidate
		ensure
			new_diameter: diameter = a_diameter
			not_valid: not is_valid
		end

	set_center (a_center: like center)
			-- Set the center of the spot to `a_center'.
		require
			a_center_not_void: a_center /= Void
		do
			center := a_center
			invalidate
		ensure
			new_center: center = a_center
			not_valid: not is_valid
		end

feature -- Access

	diameter : INTEGER
			-- The diameter of the spot

	width: INTEGER
			-- The width of the spot's edge

	center: REAL_COORDINATE
			-- Center attribute

	bounding_box: REAL_RECTANGLE
			-- The bounding-box of the spot
		do
			create Result.make (center, center)
		end

feature {CANVAS} -- Implementation

	draw_object
			-- Draw the spot
		local
			scaled_center: EV_COORDINATE
		do
			scaled_center := real_to_integer_coordinate (center)
			canvas.set_line_width (width)
			if
				is_filled
			then
				canvas.fill_ellipse (scaled_center.x - (diameter / 2).rounded,
									 scaled_center.y - (diameter / 2).rounded,
									 diameter, diameter)
			else
				canvas.draw_ellipse (scaled_center.x - (diameter / 2).rounded,
									 scaled_center.y - (diameter / 2).rounded,
									 diameter, diameter)
			end
		end

feature -- Status report

	is_filled: BOOLEAN
			-- Is the circle drawn filled

feature -- Status setting

	enable_filled
			-- Fill the circle.
		do
			is_filled:= True
			invalidate
		ensure
			is_filled: is_filled
			not_valid: not is_valid
		end

	disable_filled
			-- Unfill the circle.
		do
			is_filled:= False
			invalidate
		ensure
			not_filled: not is_filled
			not_valid: not is_valid
		end

feature {NONE} -- Implementation

	Default_diameter: INTEGER = 20
			-- The default diameter of the spot

	Default_width: INTEGER = 1
			-- The default width of the spot's edge

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
