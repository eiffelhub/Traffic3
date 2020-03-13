indexing
	description: " A simple 3D-Vector. "

	date: "$Date: 2006/08/28 15:20:27 $"
	revision: "$Revision: 1.8 $"

class
	EM_VECTOR3F_REF

inherit
	EM_ABSTRACT_VECTOR3[REAL]
	rename
		make_from_tuplef as make_from_tuple
	end

create
	make,
	default_create

feature -- Initialization

	make_from_tuplei( t: TUPLE[INTEGER, INTEGER, INTEGER] ) is
			-- Create a vector from a tuple eg. [1,2,3]
		do
			x := t.integer_item(1)
			y := t.integer_item(2)
			z := t.integer_item(3)
		end

	make_from_tuple( t: TUPLE[REAL, REAL, REAL] ) is
			-- Create a vector from a tuple eg. [1,2,3]
		do
			x := t.real_item(1)
			y := t.real_item(2)
			z := t.real_item(3)
		end

	make_from_tupled( t: TUPLE[DOUBLE, DOUBLE, DOUBLE] ) is
			-- Create a vector from a tuple eg. [1,2,3]
		do
			x := t.double_item(1)
			y := t.double_item(2)
			z := t.double_item(3)
		end

	make_from_reference ( vec: EM_VECTOR3F_REF ) is
			-- create the vector from a ref
		do
			make( vec.x, vec.y, vec.z )
		end

	make_filled_d, fill_d (a_value: DOUBLE) is
			-- Fills the vector with 'a_value'
		do
			x := a_value
			y := a_value
			z := a_value
		end

	default_create is
			-- creates a vector set to 0
		do
			x := 0
			y := 0
			z := 0
		end

feature -- Access
	zero: like Current is
		do
			create Result.make(0, 0, 0)
		end

	one: like Current is
		do
			create Result.make(1, 1, 0)
		end



feature -- Commands

	length alias "||": REAL is
			-- returns the length of the vector
		do
			Result := sqrt(norm)
		end

	scale_d ( factor: DOUBLE ) is
			-- returns the length of the vector
		do
			x := x * factor
			y := y * factor
			z := z * factor
		end

	scaled alias "*" ( factor: REAL ) : like Current is
			-- returns the length of the vector
		do
			create result.make( factor*x, factor*y, factor*z )
		end

	scaled_d ( factor: DOUBLE ) : like Current is
			-- returns the length of the vector
		do
			create result.make( factor*x, factor*y, factor*z )
		end


	cross_product ( other: like Current): like Current is
			-- Dot product
		do
			create result.make( y*other.z - z*other.y ,
					z*other.x - x*other.z ,
					x*other.y - y*other.x )
		end

	ew_multiplied  ( other: like Current ): like Current is
			-- Multiplies two vectors element wise
		do
			create result.make( x*other.x, y*other.y, z*other.z )
		end

	ew_divided  ( other: like Current ): like Current is
			-- Divides two vectors element wise
		do
			create result.make( x/other.x, y/other.y, z/other.z )
		end

	infix "+", ew_added ( other: like Current ): like Current is
			-- Adds two vectors.
		do
			create result.make( x+other.x, y+other.y, z+other.z )
		end

	infix "-", ew_subtracted ( other: like Current ): like Current is
			-- Subtracts two vectors.
		do
			create result.make( x-other.x, y-other.y, z-other.z )
		end

	prefix "-" : like Current is
			-- Negates the vector
		do
			create result.make( -x, -y, -z )
		end

feature -- Conversion
	to_vector1i: EM_VECTOR1I is
			-- convert to a 1d vector
		do
			Result.set(x.rounded)
		end

	to_vector2i: EM_VECTOR2I is
			-- convert to a 2d vector
		do
			Result.set(x.rounded, y.rounded)
		end

	to_vector3i: EM_VECTOR3I is
			-- convert to a 3d vector
		do
			result.set(x.rounded,y.rounded,z.rounded)
		end

	to_vector4i: EM_VECTOR4I is
			-- convert to a 4d vector
		do
			result.set(x.rounded,y.rounded,z.rounded,0)
		end

	to_vector1d: EM_VECTOR1D is
			-- convert to a 1d vector
		do
			Result.set(x)
		end

	to_vector2d: EM_VECTOR2D is
			-- convert to a 2d vector
		do
			Result.set(x, y)
		end

	to_vector3d: EM_VECTOR3D is
			-- convert to a 3d vector
		do
			result.set(x,y,z)
		end

	to_vector4d: EM_VECTOR4D is
			-- convert to a 4d vector
		do
			result.set(x,y,z,0)
		end


	to_vector1f: EM_VECTOR1F is
			-- convert to a 1d vector
			-- There might be a data loss
		do
			result.set(x)
		end

	to_vector2f: EM_VECTOR2F is
			-- convert to a 2d vector
			-- There might be a data loss
		do
			result.set(x,y)
		end

	to_vector3f: EM_VECTOR3F is
			-- convert to a 3d vector
			-- There might be a data loss
		do
			result.set(x,y,z)
		end

	to_vector4f: EM_VECTOR4F is
			-- convert to a 4d vector
			-- There might be a data loss
		do
			result.set(x,y,z,0)
		end

	to_reference: EM_VECTOR3F_REF is
			-- Associated reference of Current
		do
			create Result.make(x,y,z)
		end

end
