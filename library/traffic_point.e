note
	description: "Point (coordinate) objects for visualization independent traffic representations"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_POINT

inherit

	ANY
		redefine
			out
		end

	DOUBLE_MATH
		undefine
			out
		end

create

	make, make_from_other, make_moved, make_distance

feature -- Access

	x: REAL_64
			-- Horizontal position

	y: REAL_64
			-- Vertical position

feature -- Constants

	one: REAL_64
			-- Neutral element for "*" and "/"
		do
			Result := 1.0
		end

	zero: like Current
			-- Neutral element for "+" and "-"
		do
			create Result.make (0.0, 0.0)
		end

feature -- Creation

	make (a_x, a_y: REAL_64)
			-- Make with values `a_x' and `a_y'.
		do
			x := a_x
			y := a_y
		ensure
			x_set: x = a_x
			y_set: y = a_y
		end

	make_from_other (other: like Current)
			-- Make with values of `other'.
		require
			other_not_void: other /= Void
		do
			x := other.x
			y := other.y
		ensure
			equal_to_other: is_equal (other)
		end

	make_moved (other, a_distance: like Current)
			-- Make `Current' like `other' moved by `direction'.
		require
			other_not_void: other /= Void
			a_distance_not_void: a_distance /= Void
		do
			x := other.x + a_distance.x
			y := other.y + a_distance.y
		ensure
			equal_to_moved_other: is_equal (other + a_distance)
		end

	make_distance (from_vector, to_vector: like Current)
			-- Make distance from `from_vector' to `to_vector'.
		require
			from_vector_not_void: from_vector /= Void
			to_vector_not_void: to_vector /= Void
		do
			x := to_vector.x - from_vector.x
			y := to_vector.y - from_vector.y
		ensure
			equal_to_distance: is_equal (to_vector - from_vector)
		end

feature -- Element change

	set_x (an_x: REAL_64)
			-- Set `x' to `an_x'.
		do
			x := an_x
		ensure
			x_set: x = an_x
		end

	set_y (an_y: REAL_64)
			-- Set `y' to `an_y'.
		do
			y := an_y
		ensure
			y_set: y = an_y
		end

	left_by (a_value: REAL_64)
			-- Subtract `a_value' from `x'.
		do
			x := x - a_value
		ensure
			moved_left: x = old x - a_value
		end

	right_by (a_value: REAL_64)
			-- Add `a_value' to `x'.
		do
			x := x + a_value
		ensure
			moved_right: x = old x + a_value
		end

	up_by (a_value: REAL_64)
			-- Subtract `a_value' from `y'.
		do
			y := y - a_value
		ensure
			moved_up: y = old y - a_value
		end

	down_by (a_value: REAL_64)
			-- Add `a_value' to `y'.
		do
			y := y + a_value
		ensure
			moved_down: y = old y + a_value
		end

	move_by, add (other: like Current)
			-- Move `Current' by `other'.
		require
			other_not_void: other /= Void
			other_not_current: other /= Current
		do
			y := y + other.y
			x := x + other.x
		ensure
			moved: y = old y + other.y and x = old x + other.x
		end

	subtract (other: like Current)
			-- Subtract `other' from `Curent'.
		require
			other_not_void: other /= Void
			other_not_current: other /= Current
		do
			y := y - other.y
			x := x - other.x
		ensure
			moved: y = old y - other.y and x = old x - other.x
		end

	rotate (angle: REAL_64)
			-- Rotate `Current' by `angle' (radian).
		local
			x_new: REAL_64
			a_sin, a_cos: REAL_64
		do
			a_sin := sin (angle)
			a_cos := cos (angle)
			x_new := x * a_cos - y * a_sin
			y := x * a_sin + y * a_cos
			x := x_new
		end

	rotate_rectangularly
			-- Rotate `Current' by rectangular angle.
		local
			x_new: REAL_64
		do
			x_new := - y
			y := x
			x := x_new
		end

	scale (a_value: REAL_64)
			-- Scale `Current' by `a_value'.
		do
			x := x * a_value
			y := y * a_value
		ensure
			scaled: x = old x * a_value and y = old y * a_value
		end

	stretch (x_factor, y_factor: REAL_64)
			-- Scale `x' by `x_factor' and `y' by `y_factor'.
		do
			x := x * x_factor
			y := y * y_factor
		ensure
			stretched: x = old x * x_factor and y = old y * y_factor
		end

	scale_to (a_length: REAL_64)
			-- Scale 'Current' to `a_length'.
		require
			current_not_zero: length > 0
		local
			fact: REAL_64
		do
			fact := a_length / length
			x := x * fact
			y := y * fact
		end

	normalize
			-- Normalize `Current'.
		require
			current_not_zero: length > 0
		do
			scale (1 / length)
		end

feature -- Calculations

	length: REAL_64
			-- Length of `Current'.
		do
			Result := sqrt (x^2 + y^2)
		ensure
			result_calculated: Result = sqrt (x^2 + y^2)
		end

	length_squared: REAL_64
			-- squared Length of `Current'.
		do
			Result := x^2 + y^2
		ensure
			result_calculated: Result = (x^2 + y^2)
		end

	plus alias "+" (other: like Current): like Current
			-- Sum with `other' (commutative).
		do
			create Result.make (x + other.x, y + other.y)
		end

	minus alias "-" (other: like Current): like Current
			-- Result of subtracting `other'
		do
			create Result.make (x - other.x, y - other.y)
		end

	product alias "*" (a_factor: REAL_64): like Current
			-- Scalar multiplication by `a_factor'
		do
			create Result.make (x * a_factor, y * a_factor)
		end

	quotient alias "/" (a_divisor: REAL_64): like Current
			-- Scalar division by `a_divisor'.
		do
			create Result.make (x / a_divisor, y / a_divisor)
		end

	identity alias"+": like Current
			-- Unary plus
		do
			create Result.make (x, y)
		ensure then
			result_is_same: Result.x = x and Result.y = y
		end

	opposite alias "-": like Current
			-- Unary minus
		do
			create Result.make (-x, -y)
		ensure then
			result_is_negation: Result.x = -x and Result.y = -y
		end

	scalar_product (other: like Current): REAL_64
			-- Scalar product of `Current' with `other'.
		require
			other_exists: other /= Void
		do
			Result := x * other.x + y * other.y
		ensure
			result_calculated: Result = x * other.x + y * other.y
		end

	rotation_around_zero (angle: REAL_64): like Current
			-- Rotation of `Current' around `zero' by `angle' (radian).
		local
			cos_angle, sin_angle: REAL_64
		do
			cos_angle := cos (angle)
			sin_angle := sin (angle)
			create Result.make (x * cos_angle - y * sin_angle, x * sin_angle + y * cos_angle)
		end

	is_parallel_to (other: like Current): BOOLEAN
			-- Is `Current' parallel to `other'?
		do
			Result := x * other.y - other.x * y = 0.0
		end

	straight_line_intersection_point (direction, other_point, other_direction: like Current): like Current
			-- Intersection point of two straight_lines
			-- starting at `Current' and `other_point'
			-- with directions `direction' and `other_direction'.
		require
			directions_not_parallel: not direction.is_parallel_to (other_direction)
		local
			x_dist, y_dist, param, denom: REAL_64
		do
			-- Algorithm as explained under http://astronomy.swin.edu.au/~pbourke/geometry/lineline2d/
			x_dist := x - other_point.x
			y_dist := y - other_point.y
			denom := other_direction.y * direction.x - other_direction.x * direction.y
			param := (other_direction.x * y_dist - other_direction.y * x_dist) / denom
			create Result.make (x + direction.x * param, y + direction.y * param)
		ensure
			result_created: Result /= Void
		end

	rotation (center: like Current; angle: REAL_64): like Current
			-- Rotation of `Current' around `center' by `angle' (radian).
		require
			center_not_void: center /= Void
			center_not_equal_current: center.x /= x or center.y /= y
		local
			x_new, y_new, cos_angle, sin_angle, x_rot, y_rot: REAL_64
		do
			x_new := x - center.x
			y_new := y - center.y
			cos_angle := cos (angle)
			sin_angle := sin (angle)
			x_rot := x_new * cos_angle - y_new * sin_angle
			y_rot := x_new * sin_angle + y_new * cos_angle
			create Result.make (x_rot + center.x, y_rot + center.y)
		ensure
			result_set: Result /= Void
		end

	reflection (axis: like Current): like Current
			-- Mirrors the `current' along the `axis'
		require
			axis_not_void: axis /= Void
		do
			Result := axis * (Current.scalar_product(axis) / axis.length_squared) * 2 - Current
		end

	distance (other: like Current): REAL_64
			-- Distance between `Current' and `other'.
		do
			Result := sqrt ((other.x - x) ^ 2 + (other.y - y) ^ 2)
		end

feature -- Output

	out: STRING
			-- Textual representation
		do
			Result := "(x = " + x.out + ", y = " + y.out + ")"
		end

feature {NONE} -- Implementation

	cos (angle: REAL_64): REAL_64
			-- Cosine function that handles all input (radian)
		do
			Result := sin (Pi/2 - angle)
		end

	sin (angle: REAL_64): REAL_64
			-- Sine function that handles all input (in radian)
		local
			rad: REAL_64
		do
			from
				rad := angle
			until
				rad >= 0 and rad <= 2*Pi
			loop
				if rad < 0 then
					rad := rad + 2 * Pi
				else
					rad := rad - 2 * Pi
				end
			end
			if rad <= Pi / 4 then
				Result := sine (rad)
			elseif rad <= Pi / 2 then
				Result := cosine (Pi/2 - rad)
			elseif rad <= Pi then
				Result := sin (Pi-rad)
			elseif rad <= 3/2*Pi then
				Result := - sin (rad - Pi)
			else
				Result := - sin (2*Pi - rad)
			end
		end

end
