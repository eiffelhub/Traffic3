note
	description: "Polygon that will scale when zooming in EV_CANVAS"
	status:	"See notice at end of class"
	author: "Till G. Bay"
	date: "$Date: 2004/10/20 10:03:03 $"
	revision: "$Revision: 1.3 $"

class DRAWABLE_POLYGON inherit

	DRAWABLE_OBJECT

create

	make

feature -- Creation

	make (a_point_array: like points)
			-- Create a polygon from `a_point_array'
		require
			a_point_array_not_void: a_point_array /= Void
		do
			set_color (create {EV_COLOR}.make_with_rgb (0.0,0.0,0.0))
			set_points (a_point_array)
			is_shown := True
		ensure
			points_set: points = a_point_array
			shown: is_shown
		end

feature -- Commands

	set_points (new_points: like points)
			-- Replace the polygon's points with `new_points'
		require
			new_points_not_void: new_points /= Void
		do
			points:= new_points
			invalidate
		ensure
			new_points: points = new_points
			not_valid: not is_valid
		end

feature{EV_CANVAS} -- Display

	bounding_box: REAL_RECTANGLE
			-- The bounding box of the polygon
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


	draw_object
			-- Draw the polygon.
		local
			index: INTEGER
			point : EV_COORDINATE
			points_to_draw: ARRAY [EV_COORDINATE]
			polygon: EV_FIGURE_POLYGON
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
			create polygon.make_with_coordinates (points_to_draw)
			polygon.set_foreground_color (color)
			polygon.set_background_color (color)
			canvas.projector.draw_figure_polygon (polygon)
		end

feature {NONE} -- Implementation

	points: ARRAY [REAL_COORDINATE]
			-- The points of the polygon

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
