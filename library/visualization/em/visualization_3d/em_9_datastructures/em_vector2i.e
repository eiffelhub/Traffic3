indexing
	description: " A simple 2D-Vector. "

	date: "$Date: 2006/08/28 16:26:43 $"
	revision: "$Revision: 1.2 $"

expanded class
	EM_VECTOR2I

inherit
	EM_VECTOR2I_REF
	rename
		make as set
	end

create
	make_from_reference,
	default_create,
	make_from_tuple,
	make_from_tuplef,
	make_from_tupled,
	make_filled,
	make_filled_d

convert
	make_from_reference ({EM_VECTOR2I_REF}),
	make_from_tuple ({TUPLE[INTEGER, INTEGER]}),
	make_from_tuplef ({TUPLE[REAL, REAL]}),
	make_from_tupled ({TUPLE[DOUBLE, DOUBLE]}),

	to_vector1i: {EM_VECTOR1I},
	to_vector3i: {EM_VECTOR3I},
	to_vector4i: {EM_VECTOR4I},

	to_vector1d: {EM_VECTOR1D},
	to_vector2d: {EM_VECTOR2D},
	to_vector3d: {EM_VECTOR3D},
	to_vector4d: {EM_VECTOR4D},

	to_vector1f: {EM_VECTOR1F},
	to_vector2f: {EM_VECTOR2F},
	to_vector3f: {EM_VECTOR3F},
	to_vector4f: {EM_VECTOR4F},

	to_tuple: {TUPLE[INTEGER, INTEGER]},
	to_pointer: {POINTER}

end
