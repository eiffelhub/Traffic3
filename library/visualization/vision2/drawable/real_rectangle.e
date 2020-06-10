note
	description: "Rectangular areas."
	status:	"See notice at end of class"
	author: "Till G. Bay"
	date: "$Date: 2004/10/20 10:03:03 $"
	revision: "$Revision: 1.3 $"

class REAL_RECTANGLE inherit

	ANY
		redefine
			out
		end

create

	make,
	make_from_reals

feature -- Creation

	make (a_point_a, a_point_b: REAL_COORDINATE)
			-- Create a new rectangle from `a_point_a' and `a_point_b'.
		require
			a_point_a_not_void: a_point_a /= Void
			a_point_b_not_void: a_point_b /= Void
		do
			point_a := a_point_a
			point_b := a_point_b
		ensure
			point_a_set: point_a = a_point_a
			point_b_set: point_b = a_point_b
		end

	make_from_reals (x1, y1, x2, y2: REAL_64)
			-- Create a rectangle from real coordinates.
		do
			make (create {REAL_COORDINATE}.make (x1,y1), create {REAL_COORDINATE}.make (x2,y2))
		end

feature -- Access

	point_a: REAL_COORDINATE
			-- One corner point of the rectangle

	point_b: REAL_COORDINATE
			-- The other corner point of the rectangle

	width: REAL_64
			-- Width of `Current'
		do
			Result := (point_a.x - point_b.x).abs
		end

	height: REAL_64
			-- Height of `Current'
		do
			Result := (point_a.y - point_b.y).abs
		end


feature -- Status report

	upper_left: REAL_COORDINATE
			-- Upper-left corner of `Current'
		do
			create Result.make (point_a.x.min (point_b.x),point_a.y.max (point_b.y))
		ensure
			result_not_void: Result /= Void
		end

	upper_right: REAL_COORDINATE
			-- Upper-right corner of `Current'
		do
			create Result.make (point_a.x.max (point_b.x),point_a.y.max (point_b.y))
		ensure
			result_not_void: Result /= Void
		end

	lower_left: REAL_COORDINATE
			-- Lower-left corner of `Current'
		do
			create Result.make (point_a.x.min (point_b.x),point_a.y.min (point_b.y))
		ensure
			result_not_void: Result /= Void
		end

	lower_right: REAL_COORDINATE
			-- Lower-right corner of `Current'
		do
			create Result.make (point_a.x.max (point_b.x),point_a.y.min (point_b.y))
		ensure
			result_not_void: Result /= Void
		end

	center: REAL_COORDINATE
		-- Center of `Current'
		do
			create Result.make ((point_a.x+point_b.x) / 2, (point_a.y+point_b.y) / 2)
		ensure
			result_not_void: Result /= Void
		end

	upper_bound: REAL_64
			-- Upper bound of `Current'
		do
			Result := point_a.y.max (point_b.y)
		end

	lower_bound: REAL_64
			-- Upper bound of `Current'
		do
			Result := point_a.y.min (point_b.y)
		end

	left_bound: REAL_64
			-- Upper bound of `Current'
		do
			Result := point_a.x.min (point_b.x)
		end

	right_bound: REAL_64
			-- Upper bound of `Current'
		do
			Result := point_a.x.max (point_b.x)
		end

feature -- Calculations

	right_by (a_distance: REAL_64)
			-- Return a new point `a_distance' right of the current point.
		do
			point_a := point_a.right_by (a_distance)
			point_b := point_b.right_by (a_distance)
		end

	up_by (a_distance: REAL_64)
			-- Return a new point `a_distance' above of the current point.
		do
			point_a := point_a.up_by (a_distance)
			point_b := point_b.up_by (a_distance)
		end

	down_by (a_distance: REAL_64)
			-- Return a new point `a_distance' right of the current point.
		do
			point_a := point_a.down_by (a_distance)
			point_b := point_b.down_by (a_distance)
		end

	left_by (a_distance: REAL_64)
			-- Return a new point `a_distance' above of the current point.
		do
			point_a := point_a.left_by (a_distance)
			point_b := point_b.left_by (a_distance)
		end

	translate (a_distance: REAL_COORDINATE)
			-- Move the rectangle by the vector `a_distance'.
		require
			a_distance_not_void: a_distance /= Void
		do
			point_a := point_a + a_distance
			point_b := point_b + a_distance
		end

	scale (a_factor: REAL_64)
			-- Scalar multiplication by `a_factor'
		do
			point_a := point_a * a_factor
			point_b := point_b * a_factor
		end

feature -- Status report

	has (a_coordinate: REAL_COORDINATE): BOOLEAN
			-- Is `a_coordinate' inside `Current'?
		require
			a_coordinate_not_void: a_coordinate /= Void
		local
			lower_left_coordinate : REAL_COORDINATE
			upper_right_coordinate : REAL_COORDINATE
		do
			lower_left_coordinate := lower_left
			upper_right_coordinate := upper_right
			Result := (a_coordinate.x >= lower_left_coordinate.x) and
					  (a_coordinate.y >= lower_left_coordinate.y) and
					  (a_coordinate.x <= upper_right_coordinate.x) and
					  (a_coordinate.y <= upper_right_coordinate.y)
		end

	intersects (other: like Current): BOOLEAN
			-- Does `Current' and `other' overlap
		require
			other_not_void: other /= Void
		do
			Result := not ( (right_bound < other.left_bound) or
						    (left_bound > other.right_bound) or
						    (upper_bound < other.lower_bound) or
						    (lower_bound > other.upper_bound) )
		end

feature -- Output

	out: STRING
			-- Return readable string.
		do
			Result := "(X1: " + point_a.x.out + ", Y1: " + point_a.y.out +
				", X2: " + point_b.x.out +", Y2: " + point_b.y.out + ")"
		end

invariant

	width_positive: width >= 0
	height_positive: height >= 0
	point_a_not_void: point_a /= Void
	point_b_not_void: point_b /= Void

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
