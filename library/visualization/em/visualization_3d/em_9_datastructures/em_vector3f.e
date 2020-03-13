indexing
	description: " A simple 3D-Vector. "

	date: "$Date: 2006/08/24 11:20:29 $"
	revision: "$Revision: 1.6 $"

expanded class
	EM_VECTOR3F

inherit
	EM_VECTOR3F_REF
	rename
		make as set
	end

create
	make_from_reference,
	default_create,
	make_from_tuplei,
	make_from_tuple,
	make_from_tupled

convert
	make_from_reference ({EM_VECTOR3F_REF}),
	make_from_tuplei ({TUPLE[INTEGER, INTEGER, INTEGER]}),
	make_from_tuple ({TUPLE[REAL, REAL, REAL]}),
	make_from_tupled ({TUPLE[DOUBLE, DOUBLE, DOUBLE]}),

	to_vector1i: {EM_VECTOR1I},
	to_vector2i: {EM_VECTOR2I},
	to_vector3i: {EM_VECTOR3I},
	to_vector4i: {EM_VECTOR4I},

	to_vector1f: {EM_VECTOR1F},
	to_vector2f: {EM_VECTOR2F},
	to_vector4f: {EM_VECTOR4F},

	to_vector1d: {EM_VECTOR1D},
	to_vector2d: {EM_VECTOR2D},
	to_vector3d: {EM_VECTOR3D},
	to_vector4d: {EM_VECTOR4D},

	to_tuple: {TUPLE[REAL, REAL, REAL]},
	to_pointer: {POINTER}

end
