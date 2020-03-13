indexing
	description: "[
			A plane describes by a plane equation
		]"
	date: "$Date: Oct 15, 2006 4:36:44 PM$"
	revision: "$Revision: 1.0$"

class EM_PLANE_REF

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
	default_create, make, make_from_normal, make_from_points

feature {NONE} -- Implementation
	small_double: DOUBLE is 0.000001 -- Used for double comparison

feature -- Initialization
	default_create is
			-- By default EM_PLANE is a yz-plane
		do
			a := 1
		end
	make_from_reference ( a_ref: EM_PLANE_REF ) is
			-- Create a new EM_PLANE from a referece
		require
			a_valid_ref: a_ref/=void
		do
			make( a_ref.a, a_ref.b, a_ref.c, a_ref.d )
		end
	make ( an_a, a_b, a_c, a_d: DOUBLE) is
			-- Create a new EM_PLANE object, given the parameters of the plane equation
		require
			valid_plane: not (an_a=0 and a_b=0 and a_c=0)
		do
			a := an_a
			b := a_b
			c := a_c
			d := a_d
		ensure
			values_set: a = an_a and b = a_b and c = a_c and d = a_d
		end
	make_from_normal( a_point, a_normal: EM_VECTOR3D) is
			-- Create a new EM_PLANE object, given
		require
			valid_point: a_point /= void
			valid_normal: a_normal /= void
		do
			a := a_normal.x
			b := a_normal.y
			c := a_normal.z
			d := -( a*a_point.x + b*a_point.y + c*a_point.z )
		end
	make_from_points( a_p1, a_p2, a_p3: EM_VECTOR3D) is
			-- Create a new EM_PLANE object, given
		require
			valid_p1: a_p1 /= void
			valid_p2: a_p2 /= void
			valid_p3: a_p3 /= void
		do
			make_from_normal( a_p1, (a_p2-a_p1).cross_product (a_p3-a_p1) )
		end
	make_from_tuple( a_tuple: TUPLE[ DOUBLE, DOUBLE, DOUBLE, DOUBLE ] ) is
			-- Create a new EM_PLANE object from a TUPLE
		require
			a_valid_tuple: a_tuple /= void
		do
			a := a_tuple.double_item( 1 )
			b := a_tuple.double_item( 2 )
			c := a_tuple.double_item( 3 )
			d := a_tuple.double_item( 4 )
		end
	make_from_tuplef( a_tuple: TUPLE[REAL, REAL, REAL, REAL] ) is
			-- Create a new EM_PLANE object from a TUPLE
		require
			a_valid_tuple: a_tuple /= void
		do
			a := a_tuple.real_item( 1 )
			b := a_tuple.real_item( 2 )
			c := a_tuple.real_item( 3 )
			d := a_tuple.real_item( 4 )
		end
	make_from_tuplei( a_tuple: TUPLE[ INTEGER, INTEGER, INTEGER, INTEGER ] ) is
			-- Create a new EM_PLANE object from a TUPLE
		require
			a_valid_tuple: a_tuple /= void
		do
			a := a_tuple.integer_item( 1 )
			b := a_tuple.integer_item( 2 )
			c := a_tuple.integer_item( 3 )
			d := a_tuple.integer_item( 4 )
		end
	make_from_normal_tuple( a_tuple: TUPLE[ EM_VECTOR3D, EM_VECTOR3D ] ) is
			-- Create a new EM_PLANE object from a TUPLE
		require
			a_valid_tuple: a_tuple /= void
		local
			p, n: EM_VECTOR3D_REF
		do
			p ?= a_tuple.reference_item (1)
			n ?= a_tuple.reference_item (2)
			if p /= void and n /= void then
				make_from_normal ( p.to_vector3d, n.to_vector3d )
			end
		end
	make_from_normal_tuplei( a_tuple: TUPLE[ EM_VECTOR3I, EM_VECTOR3I ] ) is
			-- Create a new EM_PLANE object from a TUPLE
		require
			a_valid_tuple: a_tuple /= void
		local
			p, n: EM_VECTOR3I_REF
		do
			p ?= a_tuple.reference_item (1)
			n ?= a_tuple.reference_item (2)
			if p /= void and n /= void then
				make_from_normal ( p.to_vector3d, n.to_vector3d )
			end
		end
	make_from_normal_tuplef( a_tuple: TUPLE[ EM_VECTOR3F, EM_VECTOR3F ] ) is
			-- Create a new EM_PLANE object from a TUPLE
		require
			a_valid_tuple: a_tuple /= void
		local
			p, n: EM_VECTOR3F_REF
		do
			p ?= a_tuple.reference_item (1)
			n ?= a_tuple.reference_item (2)
			if p /= void and n /= void then
				make_from_normal ( p.to_vector3d, n.to_vector3d )
			end
		end
	make_from_point_tuple( a_tuple: TUPLE[ EM_VECTOR3D, EM_VECTOR3D, EM_VECTOR3D ] ) is
			-- Create a new EM_PLANE object from a TUPLE
		require
			a_valid_tuple: a_tuple /= void
		local
			p1, p2, p3: EM_VECTOR3D_REF
		do
			p1 ?= a_tuple.reference_item (1)
			p2 ?= a_tuple.reference_item (2)
			p3 ?= a_tuple.reference_item (3)
			if p1 /= void and p2 /= void and p3 /= void then
				make_from_points ( p1.to_vector3d, p2.to_vector3d, p3.to_vector3d )
			end
		end
	make_from_point_tuplei( a_tuple: TUPLE[ EM_VECTOR3I, EM_VECTOR3I, EM_VECTOR3I ] ) is
			-- Create a new EM_PLANE object from a TUPLE
		require
			a_valid_tuple: a_tuple /= void
		local
			p1, p2, p3: EM_VECTOR3I_REF
		do
			p1 ?= a_tuple.reference_item (1)
			p2 ?= a_tuple.reference_item (2)
			p3 ?= a_tuple.reference_item (3)
			if p1 /= void and p2 /= void and p3 /= void then
				make_from_points ( p1.to_vector3d, p2.to_vector3d, p3.to_vector3d )
			end
		end
	make_from_point_tuplef( a_tuple: TUPLE[ EM_VECTOR3F, EM_VECTOR3F, EM_VECTOR3F ] ) is
			-- Create a new EM_PLANE object from a TUPLE
		require
			a_valid_tuple: a_tuple /= void
		local
			p1, p2, p3: EM_VECTOR3F_REF
		do
			p1 ?= a_tuple.reference_item (1)
			p2 ?= a_tuple.reference_item (2)
			p3 ?= a_tuple.reference_item (3)
			if p1 /= void and p2 /= void and p3 /= void then
				make_from_points ( p1.to_vector3d, p2.to_vector3d, p3.to_vector3d )
			end
		end
feature -- Access
	a,b,c,d: DOUBLE
	feature normal: EM_VECTOR3D is
			-- The plane normal
		do
			result.set( a, b, c )
		end
	feature point: EM_VECTOR3D is
			-- A point lying on the plane
		do
			if a/=0 then
				result.set( -d/a, 0, 0 )
			elseif b/=0 then
				result.set( 0, -d/b, 0 )
			else -- Due to the invariant c/=0
				result.set( 0, 0, -d/c )
			end
		end
feature -- Status
	set_a (an_a: DOUBLE) is
				-- Set `a' to `an_a'.
		require
			an_a_valid: not (an_a=0 and b=0 and c=0) /= Void
		do
			a := an_a
		ensure
			definition_of_set_a: a = an_a
		end
	set_b (a_b: DOUBLE) is
				-- Set `b' to `a_b'.
		require
			a_b_valid: not (a_b=0 and a=0 and c=0) /= Void
		do
			b := a_b
		ensure
			definition_of_set_b: b = a_b
		end
	set_c (a_c: DOUBLE) is
				-- Set `c' to `a_c'.
		require
			a_c_valid: not (a_c=0 and b=0 and a=0) /= Void
		do
			c := a_c
		ensure
			definition_of_set_c: c = a_c
		end
	set_d (a_d: DOUBLE) is
				-- Set `d' to `a_d'.
		do
			d := a_d
		ensure
			definition_of_set_d: d = a_d
		end

	distance_to_point( a_point: EM_VECTOR3D ):DOUBLE is
			-- Calculates the minimal distance between 'a_point' and the plane
			-- Important note: The distance might be negative!!!
		require
			valid_point: a_point /= void
		do
			result := unnormalized_distance_to_point( a_point ) / sqrt( a*a + b*b + c*c )
		end
	unnormalized_distance_to_point( a_point: EM_VECTOR3D ): DOUBLE is
			-- The unnormalized distance is a fast way of determining,
			-- if a point lies above or under a plane
		require
			valid_point: a_point /= void
		do
			result := a_point.x*a + a_point.y*b + a_point.z*c + d
		end
	is_point_inside( a_point: EM_VECTOR3D ): BOOLEAN is
			-- Does the point lie on the plane?
		require
			valid_point: a_point /= void
		do
			result := unnormalized_distance_to_point( a_point ).abs < small_double
		end
	is_point_above( a_point: EM_VECTOR3D ): BOOLEAN is
			-- Does the point lie above the plane?
		require
			valid_point: a_point /= void
		do
			result := unnormalized_distance_to_point( a_point ) >= small_double
		end
	is_point_below( a_point: EM_VECTOR3D ): BOOLEAN is
			-- Does the point lie below the plane?
		require
			valid_point: a_point /= void
		do
			result := unnormalized_distance_to_point( a_point ) <= -small_double
		end

feature -- Output
	out: STRING is
			-- Output the plane
		do
			result := "[ "+a.out+" , "+b.out+" , "+c.out+" , "+d.out+" ]"
		end


invariant
	valid_plane: not (a=0 and b=0 and c=0)
end -- class EM_PLANE_REF
