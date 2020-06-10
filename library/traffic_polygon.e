note
	description: "Objects that ..."
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_POLYGON

create
	make

feature
	make (a_point_array: like points; a_color: like color) 
			-- Create a polygon from `a_point_array' and `a_color'
		require
			a_point_array_not_void: a_point_array /= Void
		local

		do
			set_color (a_color)
			set_points (a_point_array)
			create points_with_y_inverted.make (a_point_array.lower, a_point_array.upper)
			points_with_y_inverted.copy (a_point_array)
			invert_y_coordinates
		ensure
			points_set: points = a_point_array
			color_set: color = a_color
		end

feature -- Access

	color: TRAFFIC_COLOR

	points: ARRAY [REAL_COORDINATE]
			-- The points of the polygon

	points_with_y_inverted: ARRAY [REAL_COORDINATE]
			-- The points of the polygon with y set to -y

feature -- Commands

	set_points (new_points: like points)
			-- Replace the polygon's points with `new_points'
		require
			new_points_not_void: new_points /= Void
		do
			points:= new_points
		ensure
			new_points: points = new_points
		end

	set_color (new_color: like color)
			-- Replace the polygon's color with `new_color'
		require
			new_color_not_void: new_color /= Void
		do
			color:= new_color
		ensure
			new_color: color = new_color
		end

feature {NONE} -- Implementation

	invert_y_coordinates
			-- sets the y coordinate of all `points_with_y_inverted' to -y.
		local
			i: INTEGER
			new: REAL_COORDINATE
		do
			from
				i:= 1
			until
				i > points_with_y_inverted.count
			loop
				create new.make (points_with_y_inverted[i].x, -points_with_y_inverted[i].y )
				points_with_y_inverted.put (new, i)
				i := i+1
			end
		end



invariant

	points_not_void: points /= Void

	inverted_points_not_void: points_with_y_inverted /= void

end
