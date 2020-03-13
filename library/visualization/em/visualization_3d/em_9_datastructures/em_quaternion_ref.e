indexing
	description: " A Quaternion is a replacement for retation-matrices. Its very fast and easy to interpolate, ... and can be transformed into a rotation matrix and vice versa "
	date: "$Date: 2006/10/17 22:27:35 $"
	revision: "$Revision: 1.5 $"

class
	EM_QUATERNION_REF

inherit
	DOUBLE_MATH
		export
			{NONE} all
		redefine
			out,
			default_create
		end
	ANY
	redefine
		out,
		default_create
	end

create
	make,
	default_create,
	make_from_rotation,
	make_from_matrix44,
	make_from_arc

feature -- Access
	v: EM_VECTOR3D
	w: DOUBLE

	small_double: DOUBLE is 0.0000000001 -- 10 e-10

feature -- Initialization
	make_from_reference( quaternion: EM_QUATERNION_REF ) is
			-- Creates from a reference
		require
			quaternion /= void
		do
			v := quaternion.v
			w := quaternion.w
		end

	make( a_v: like v; a_w: like w) is
			-- Creates a Quaternion from its components
			-- ATTENTION a_v and a_w ARE NOT ANGLE AND DIRECTION!!
		require
			normalized: (a_v.norm+a_w*a_w-1)<small_double
		do
			v := a_v
			w := a_w
		end

	make_from_tuple(  t: TUPLE[ DOUBLE, DOUBLE, DOUBLE, DOUBLE ] ) is
			-- Creates a Quaternion given the four parameters
		do
			v.set ( t.double_item (1), t.double_item (2), t.double_item (3) )
			w := t.double_item (4)
			normalize
		end

	make_from_vector_tuple(  t: TUPLE[ EM_VECTOR3D, DOUBLE ] ) is
			-- Creates a Quaternion from a vector and a rotation, safed in a tuple
		local
			vector_ref: EM_VECTOR3D_REF
		do
			vector_ref ?= t.reference_item (1)
			check
				vector_ref/=void
			end
			make_from_rotation( vector_ref, t.double_item (2) )
		end

	make_from_vector_ref_tuple(  t: TUPLE[ EM_VECTOR3D_REF, DOUBLE ] ) is
			-- Creates a Quaternion from a vector and a rotation, safed in a tuple
		local
			vector_ref: EM_VECTOR3D_REF
		do
			vector_ref ?= t.reference_item (1)
			check
				vector_ref/=void
			end
			make_from_rotation( vector_ref, t.double_item (2) )
		end

	default_create is
			-- Creates an empty quaternion
		do
			w := 1
		end

	make_from_rotation( direction: EM_VECTOR3D; angle: DOUBLE ) is
			-- Creates a Quaternion from a rotation with a given direction and angle( radian )
		local
			s: DOUBLE
			nd: EM_VECTOR3D
		do
			nd := direction.normalized
			s := sine ( angle / 2 )
			check
				-1<=s and s<=1
			end
			v.set( nd.x*s, nd.y*s, nd.z*s )
			w := cosine ( angle / 2 )
			normalize
		end


	make_from_matrix44( matrix: EM_MATRIX44 ) is
			-- Creates the Quaterion from a 4x4 Matrix
			-- Translation is ignored
		local
			t: DOUBLE
			s: DOUBLE
		do
			t := matrix[1,1] + matrix[2,2] + matrix[3,3] + 1
			if t>0 then
				s := 0.5 / sqrt(t)
				w := 0.25 / s
				v.set ( s * (matrix[2,3] - matrix[3,2]),
						s * (matrix[3,1] - matrix[1,3]),
						s * (matrix[1,2] - matrix[2,1]) )

			elseif (matrix[1,1] > matrix[2,2]) and (matrix[1,1] > matrix[3,3]) then
				s := sqrt( 1.0 + matrix[1,1] - matrix[2,2] - matrix[3,3] ) * 2
				v.set ( s * 0.25,
						(matrix[1,2] + matrix[2,1]) / s,
						(matrix[1,3] + matrix[3,1]) / s )
				w := (matrix[3,2] - matrix[2,3] ) / s

			elseif matrix[2,2] > matrix[3,3] then
				s := sqrt( 1.0 + matrix[2,2] - matrix[1,1] - matrix[3,3] ) * 2
				v.set ( (matrix[2,1] + matrix[1,2]) / s,
						s * 0.25,
						(matrix[2,3] + matrix[3,2]) / s )
				w := (matrix[1,3] - matrix[3,1] ) / s

			else
				s := sqrt( 1.0 + matrix[3,3] - matrix[2,2] - matrix[1,1] ) * 2
				v.set ( (matrix[3,3] + matrix[3,3]) / s,
						(matrix[3,2] + matrix[2,3]) / s,
						s * 0.25 )
				w := (matrix[2,1] - matrix[2,1] ) / s
			end
			normalize
		end

	make_from_arc( v1: EM_VECTOR3D; v2: EM_VECTOR3D ) is
			-- Create a quaternion from the angle between v1 and v2,
			-- so that is transforms v1 to v2
		local
			n_v1: EM_VECTOR3D -- A normalized 3D vector
			n_v2: EM_VECTOR3D -- A normalized 3D vector
			c: EM_VECTOR3D -- Cross product
			d: DOUBLE -- Dot Product
			s: DOUBLE -- temp value
		do
			n_v1 := v1.normalized
			n_v2 := v2.normalized
			c := n_v1.cross_product ( n_v2 )
			d := n_v1.dot_product ( n_v2 )
			s := sqrt( (1+d)*2 )

			if s.abs < small_double then
				-- there is no unique solution
				if n_v1.x=0 then
					v.set ( 1, 0, 0 )
				else
					s := 1 / sqrt( ( (n_v1.y*n_v1.y)/(n_v1.x*n_v1.x) ) + 1 )
					v.set ( -n_v1.y/n_v1.x*s , s, 0 )
				end
				w := 0
			else
				v.set ( c.x/s , c.y/s , c.z/s )
				w := s / 2
			end
			normalize
		end

	make_from_euler( yaw, pitch, roll: DOUBLE ) is
			-- Create the Quaternion from an Euler rotation
		local
			sinY, cosY: DOUBLE
			sinP, cosP: DOUBLE
			sinR, cosR: DOUBLE
		do
			sinY := sine( yaw / 2 )
			cosY := cosine( yaw / 2 )
			sinP := sine( pitch / 2 )
			cosP := cosine( pitch / 2 )
			sinR := sine( roll / 2 )
			cosR := cosine( roll / 2 )
			v := [ cosR * sinP * cosY + sinR * cosP * sinY,
			       cosR * cosP * sinY - sinR * sinP * cosY,
			       sinR * cosP * cosY - cosR * sinP * sinY ]
			w := cosR * cosP * cosY + sinR * sinP *sinY
			normalize
		end



feature -- Commands
	conjugate is
			-- returns the inverse of the Quaternion
		do
			v := -v
		end

	conjugated: like Current is
			-- returns the inverse of the Quaternion
		do
			create result.make(-v, w)
		end

	inverse is
			-- returns the inverse of the Quaternion
		do
			conjugate
			scale(1/norm)
		end

	inversed: like Current is
			-- returns the inverse of the Quaternion
		do
			result := conjugated.scaled(1/norm)
		end

	interpolate_linear( b: like Current; t: DOUBLE): like Current is
			-- Interpolates current and b, t is in [0, 1] 0 is current and 1 is b
		require
			0<=t and t<=1
		do
			result := scaled(1-t) + b.scaled(t)
			-- linear interpolation does NOT preserve magnitude so we have to normalize
			result := result.normalized
		ensure
			(result.norm -1).abs < small_double
		end

	interpolate_spherical_linear( b: like Current; t: DOUBLE): like Current is
			-- Interpolates current and b, t is in [0, 1] 0 is current and 1 is b
			-- If you can precompute the angle between the two vectors safe it and use
			-- 'interpolate_spherical_linear_a' instead. This function is a big overhead
			-- Since b and -b are the same rotation, its best to  choose -b if |cutting_angle| > pi/2
		require
			0<=t and t<=1
		local
			a: DOUBLE
		do
			a := cutting_angle( b )
			if a > pi/2 then
				result := interpolate_spherical_linear_a( -b, t, pi-a )
			else
				result := interpolate_spherical_linear_a( b, t, a )
			end
		ensure
			(result.norm -1).abs < small_double
		end

	interpolate_spherical_linear_a( b: like Current; t: DOUBLE; a: DOUBLE): like Current is
			-- Interpolates current and b, t is in [0, 1] 0 is current and 1 is b
			-- a: is the angle between current and b, so it dont has to be recomputed every time
			-- Since b and -b are the same rotation, its best to  choose -b if |cutting_angle| > pi/2
		require
			0<=t and t<=1
			(a - cutting_angle(b) ).abs > small_double
		do
			result := scaled( sine ( (1-t) * a ) ) + b.scaled( sine ( t * a ) )
			-- linear interpolation does NOT preserve magnitude so we have to normalize
			result := result.scaled( sine( a ) )
		ensure
			(result.norm -1).abs < small_double
		end

	cutting_angle ( other: like current ): DOUBLE is
			-- returns the cutting angle
		do
			result := arc_cosine ( dot_product ( other ) )
		end

	acute_cutting_angle ( other: like current ): DOUBLE is
			-- returns the acute cutting angle
		do
			result := arc_cosine ( dot_product ( other ).abs )
		end


	dot_product ( other:  like Current ): DOUBLE is
			-- Multiplies two Quaternion
		do
			result := (w*other.w) + v.dot_product(other.v);
		end

	infix "*" ( other:  like Current ): like Current is
			-- Multiplies two Quaternion
		do
			create result.make( v.cross_product(other.v) + (v*other.w) + (other.v*w) , (w*other.w) - (v.dot_product(other.v)) )
		end

	infix "+" ( other:  like Current ): like Current is
			-- Adds two Quaternion
		do
			create result.make( v + other.v , w + other.w )
		end

	infix "-" ( other:  like Current ): like Current is
			-- Adds two Quaternion
		do
			create result.make( v - other.v , w - other.w )
		end

	prefix "-" : like Current is
			-- Adds two Quaternion
		do
			create result.make( - v , - w )
		end

	norm : DOUBLE is
			-- gets length*length of a quaternion
		do
			result := v.x*v.x + v.y*v.y + v.z*v.z + w*w
		end

	length alias "||" : DOUBLE is
			-- gets the "length" of a quaternion
		do
			result := sqrt(norm)
		end

	normalized: like Current is
			-- returns a the unit quaternion belonging to the current quaternion
		do
			if length>small_double then
				result := scaled(1/length)
			else
				create result.make( v , w )
			end
		end

	normalize is
			-- returns a the unit quaternion belonging to the current quaternion
		local
			a: DOUBLE
		do
			if length>small_double then
				a := 1/length
				v := v * a
				w := w * a
			end
		end


	scaled( factor: DOUBLE ): like Current is
			-- returns a scalar of the current Quaternion
		do
			create result.make( v*factor, w*factor )
		end

	scale( factor: DOUBLE ) is
			-- returns a scalar of the current Quaternion
		do
			v := v*factor
			w := w*factor
		end

	power alias "^" ( t: DOUBLE ): like Current is
			-- returns the t'th power of current
		do
			create result.make_from_rotation ( axis_of_rotation, angle_of_rotation*t )
		end

	angle_of_rotation_sign: INTEGER is
			-- The sign of the angle of rot
		local
			a: DOUBLE
		do
			a := w/length + 3/2 * pi
			-- Modulo
			a := a - 2*pi*( a / (2*pi) ).floor
			result := (a-pi).sign
		end


	axis_of_rotation: EM_VECTOR3D is
			-- returns the rotation vector
		do
			if v.is_equal(v.zero) then
				Result := v.zero
			else
				result := v.normalized * angle_of_rotation_sign
			end
		end

	angle_of_rotation: DOUBLE is
			-- returns the rotation angle in radians
		do
			result := 2 * arc_cosine ( w/length )
		end

	angle_of_rotation_degree: DOUBLE is
			-- returns the rotation angle in radians
		do
			result := angle_of_rotation*180.0/pi
		end

	rotate_vector3( a_vector: EM_VECTOR3D ): EM_VECTOR3D is
			-- rotate a vector around a quaternion
		local
			vv: EM_VECTOR3D
			ww: DOUBLE
		do
			vv := (-v).cross_product( a_vector ) + (a_vector*w)
			ww := (v.dot_product(a_vector))
			result := vv.cross_product ( v ) + v*ww + vv*w
		ensure
			length_perserved: (a_vector.length - result.length).abs < small_double
		end

feature -- Output

	out: STRING is
			-- Output the matrix to a string
		do
			Result := "[ "  + v.x.out +
					  " , " + v.y.out +
					  " , " + v.z.out +
					  " , " + w.out + " ]"
		end


feature -- Conversion
	to_reference: EM_QUATERNION_REF is
			-- Associated reference of Current
		do
			create Result.make(v,w)
		ensure
			to_reference_not_void: Result /= Void
		end

invariant
	normalized: (length-1).abs < small_double

end
