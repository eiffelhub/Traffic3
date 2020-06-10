note
	description: "[
					Objects that can be drawn on EV_CANVAS and
					that will scale when zooming
					]"
	status:	"See notice at end of class"
	author: "Till G. Bay"
	date: "$Date: 2004/08/25 12:03:42 $"
	revision: "$Revision: 1.2 $"

deferred class DRAWABLE_OBJECT

feature -- Commands

	set_color (a_color: like color) 
			-- Set the color of the object to `a_color'
		require
			a_color_not_void: a_color /= Void
		do
			color := a_color
			invalidate
		ensure
			color_set: color = a_color
		end

	hide
			-- Highlight the view.
		do
			is_shown := False
			invalidate
		ensure
			hidden: not is_shown
		end

	show
			-- Unhighlight the view.
		do
			is_shown := True
			invalidate
		ensure
			shown: is_shown
		end

feature -- Status report

	is_shown: BOOLEAN
			-- Is the view shown?

	is_valid: BOOLEAN
			-- Is there no change to `Current'?

feature -- Access

	canvas : CANVAS
			-- Reference to the canvas

	color: EV_COLOR
			-- The color of the drawable object

	bounding_box: REAL_RECTANGLE
			-- The bounding box of `Current'
		deferred
		ensure
			bounding_box_not_void: Result /= Void
		end

	real_to_integer_coordinate (a_real_coordinate: REAL_COORDINATE): EV_COORDINATE
			-- Convert `a_real_coordinate' to an integer coordinate.
		require
			a_real_coordinate_not_void: a_real_coordinate /= Void
			canvas_visible_area_width_not_zero: canvas.visible_area.width /= 0.0
			canvas_visible_area_height_not_zero: canvas.visible_area.height /= 0.0
		local
			x_int : INTEGER
			y_int : INTEGER
		do
			x_int := (((a_real_coordinate.x-canvas.visible_area.left_bound) * canvas.width) /
					   canvas.visible_area.width).rounded
			y_int := canvas.height +
					(((canvas.visible_area.lower_bound-a_real_coordinate.y) * canvas.height) /
					   canvas.visible_area.height).rounded
			create Result.set (x_int,y_int)
		ensure
			result_not_void: Result /= Void
		end

	integer_to_real_coordinate (an_integer_coordinate: EV_COORDINATE): REAL_COORDINATE
			-- Convert `an_integer_coordinate' to a real coordinate.
		require
			an_integer_coordinate_not_void: an_integer_coordinate /= Void
			canvas_width_not_zero: canvas.width /= 0
			canvas_height_not_zero: canvas.height /= 0
		local
			x_real : REAL_64
			y_real : REAL_64
		do

			x_real:= ((an_integer_coordinate.x * canvas.visible_area.width) / canvas.width) + canvas.visible_area.left_bound
			y_real:= ((an_integer_coordinate.y * canvas.visible_area.height) / canvas.height) + canvas.visible_area.lower_bound
			create Result.make (x_real,y_real)
		ensure
			result_not_void: Result /= Void
		end

feature {CANVAS, DRAWABLE_OBJECT} -- Display

	draw (a_target: CANVAS)
			-- Draw `Current' onto `a_target'
		require
			a_target_not_void: a_target /= Void
		do
			check
				color_not_void: color /= Void
			end
			canvas := a_target
			if is_shown then
				canvas.set_foreground_color (color)
				draw_object
				validate
			end
		ensure
			canvas_set: canvas = a_target
		end

	draw_object
			-- Draw the object.
		deferred
		end

feature {NONE} -- Implementation

	invalidate
			-- Some property of `Current' has changed.
		do
			is_valid := False
			if canvas /= Void then
				canvas.redraw
			end
		end

	validate
			-- `Current' has been updated by a projector.
		do
			if not is_valid then
				is_valid := True
			end
		end

invariant

	color_not_void: color /= Void

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
