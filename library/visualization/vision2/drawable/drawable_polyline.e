indexing

	description: "Polyline that will scale when zooming in EV_CANVAS"
	status:	"See notice at end of class"
	author: "Till G. Bay"
	date: "$Date: 2004/10/20 10:03:03 $"
	revision: "$Revision: 1.4 $"

class DRAWABLE_POLYLINE inherit

	DRAWABLE_OBJECT

create

	make

feature -- Creation

	make (a_point_array: like points; a_scaling_reference: like scaling_reference) is
			-- Create a line from the `a_point_array'
			-- `A_scaling_reference' is used to calulate the width of the polyline
		require
			a_point_array_not_void: a_point_array /= Void
			no_void_element: not a_point_array.has(Void)
		do
			set_points (a_point_array)
			set_width (default_width)
			current_width:= width
			scaling_reference:= a_scaling_reference
			dashed:= False
			set_color (create {EV_COLOR}.make_with_rgb (0.0, 0.0, 0.0))
			is_shown := True
		ensure
			not_dashed: not dashed
			points_set: points = a_point_array
			width_set: width = default_width
			current_width_set: current_width = width
			reference_set: scaling_reference = a_scaling_reference
			shown: is_shown
		end

feature -- Commands

	set_points (new_points: like points) is
			-- Set the polyline's points with `new_points'
		require
			new_points_not_void: new_points /= Void
		do
			points:= new_points
			invalidate
		ensure
			new_points: points = new_points
		end

	set_width (a_width: like width) is
			-- Set the polyline's width to `a_width'
		do
			width:= a_width
			invalidate
		ensure
			new_width: width = a_width
		end

	enable_dashed_line is
			-- Draw the line dashed.
		do
			dashed := True
			invalidate
		ensure
			dashed_true: dashed
		end

feature -- Queries

	width: INTEGER
			-- The polylines width (initial)

	current_width: INTEGER
			-- The width of the polyline at the very moment (after it has been scaled)

	dashed: BOOLEAN
			-- Is the line drawn dashed?

feature{EV_CANVAS} -- Display

	bounding_box : REAL_RECTANGLE is
			-- The bounding box of the polyline
		local
			index: INTEGER
			upper, lower: REAL_COORDINATE
		do
			create upper.make (points.entry (1).x,points.entry (1).y)
			create lower.make (points.entry (1).x,points.entry (1).y)
			from
				index:= 1
			until
				index > points.count
			loop
				if	points.entry (index).x > upper.x then
					upper:= create {REAL_COORDINATE}.make (points.entry (index).x, upper.y)
				end
				if	points.entry (index).y > upper.y then
					upper:= create {REAL_COORDINATE}.make (upper.x, points.entry (index).y)
				end
				if	points.entry (index).x <= lower.x then
					lower:= create {REAL_COORDINATE}.make (points.entry (index).x, lower.y)
				end
				if	points.entry (index).y <= lower.y then
					lower:= create {REAL_COORDINATE}.make (lower.x, points.entry (index).y)
				end
				index := index + 1
			end
			create Result.make (upper, lower)
		end


	draw_object is
			-- Draw the polyline
		local
			index, line_width: INTEGER
			ratio: REAL_64
			point : EV_COORDINATE
			points_to_draw: ARRAY [EV_COORDINATE]
		do
			create points_to_draw.make (1, 1)
			from
				index:= 1
			until
				index > points.count
			loop
				point := real_to_integer_coordinate (points.entry (index))
				points_to_draw.force (point, index)
				index:= index + 1
			end
			ratio := scaling_reference / canvas.visible_area.height
			if ratio > 1.0 then
				ratio:= 1.0
			end
			line_width:= (width * ratio).rounded
			if line_width = 0 then
				line_width:= 1
			end
			current_width:= line_width
			canvas.set_line_width (line_width)
			if color /= Void then
				canvas.set_foreground_color (color)
			end
			if
				dashed
			then
				canvas.enable_dashed_line_style
			end
			canvas.draw_polyline (points_to_draw, False)
			if
				dashed
			then
				canvas.disable_dashed_line_style
			end
		end


feature {NONE} -- Implementation

	points: ARRAY [REAL_COORDINATE]
			-- The points of the polyline

	scaling_reference: REAL_64
			-- The scaling reference

	Default_width: INTEGER is 4
			-- The default width for polylines

invariant

	points_not_void: points /= Void

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
