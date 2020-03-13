indexing
	description: " A simple 4D-Vector. "

	date: "$Date: 2006/08/28 16:50:04 $"
	revision: "$Revision: 1.8 $"

class
	EM_VECTOR4F_REF

inherit
	EM_ABSTRACT_VECTOR4[REAL]
	rename
		make_from_tuplef as make_from_tuple
	end

create
	make,
	default_create

feature -- Initialization

	make_from_tuplei( t: TUPLE[INTEGER, INTEGER, INTEGER, INTEGER] ) is
			-- Create a vector from a tuple eg. [1,2,3,4]
		do
			x := t.integer_item(1)
			y := t.integer_item(2)
			z := t.integer_item(3)
			w := t.integer_item(4)
		end

	make_from_tuple( t: TUPLE[REAL, REAL, REAL, REAL] ) is
			-- Create a vector from a tuple eg. [1,2,3,4]
		do
			x := t.real_item(1)
			y := t.real_item(2)
			z := t.real_item(3)
			w := t.real_item(4)
		end

	make_from_tupled( t: TUPLE[DOUBLE, DOUBLE, DOUBLE, DOUBLE] ) is
			-- Create a vector from a tuple eg. [1,2,3,4]
		do
			x := t.double_item(1)
			y := t.double_item(2)
			z := t.double_item(3)
			w := t.double_item(4)
		end

	make_from_reference ( vec: EM_VECTOR4F_REF ) is
			-- create the vector from a ref
		do
			make( vec.x, vec.y, vec.z, vec.w )
		end

	make_filled_d, fill_d (a_value: DOUBLE) is
			-- Fills the vector with 'a_value'
		do
			x := a_value
			y := a_value
			z := a_value
			w := a_value
		end

	default_create is
			-- creates a vector set to 0
		do
			x := 0
			y := 0
			z := 0
			w := 0
		end

feature -- Access
	zero: like Current is
		do
			create Result.make(0, 0, 0, 0)
		end

	one: like Current is
		do
			create Result.make(1, 1, 1, 1)
		end



feature -- Commands

	length alias "||": REAL is
			-- Returns the length of the vector
		do
			Result := sqrt(norm.to_double).rounded
		end

	scale_d ( factor: DOUBLE ) is
			-- Scales the 'Current' vector by 'factor'.
		do
			x := x * factor
			y := y * factor
			z := z * factor
			w := w * factor
		end

	scaled alias "*" ( factor: REAL ) : like Current is
			-- Returns a new by 'factor' scaled vector
		do
			create result.make( factor*x, factor*y, factor*z, factor*w )
		end

	scaled_d ( factor: DOUBLE ) : like Current is
			-- Returns a new by 'factor' scaled vector
		do
			create result.make( factor*x, factor*y, factor*z, factor*w )
		end

	ew_multiplied  ( other: like Current ): like Current is
			-- Multiplies two vectors element wise.
		do
			create result.make( x*other.x, y*other.y, z*other.z, w*other.w )
		end

	ew_divided  ( other: like Current ): like Current is
			-- Divides two vectors element wise.
		do
			create result.make( x/other.x, y/other.y, z/other.z, w/other.w )
		end


	infix "+", ew_added ( other: like Current ): like Current is
			-- Adds two vectors and returns a new instance
		do
			create result.make( x+other.x, y+other.y, z+other.z, w+other.w )
		end

	infix "-", ew_subtracted ( other: like Current ): like Current is
			-- Substracts two vectors and returns a new instance
		do
			create result.make( x-other.x, y-other.y, z-other.z, w-other.w )
		end

	prefix "-": like Current is
			-- Negates the vector
		do
			create result.make( -x, -y, -z, -w )
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
			result.set(x.rounded,y.rounded,z.rounded,w.rounded)
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
			result.set(x,y,z,w)
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
			result.set(x,y,z,w)
		end

	to_reference: EM_VECTOR4F_REF is
			-- Associated reference of Current
		do
			create Result.make(x,y,z,w)
		end

end
