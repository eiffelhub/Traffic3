indexing
	description: " A 4x4 Matrix with basic operations"
	date: "$Date: 2006/08/18 09:47:33 $"
	revision: "$Revision: 1.3 $"

expanded class
	EM_MATRIX44

inherit
	EM_MATRIX44_REF
	rename
		make_empty as set_empty,
		make_from_tuple as set_from_tuple,
		make_from_translation as set_from_translation,
		make as set,
		make_from_scalar as set_from_scalar,
		make_from_rotation as set_from_rotation,
		make_unit  as set_unit
	end

create
	default_create,
	make_from_reference,
	make_from_quaternion
convert
	make_from_reference({EM_MATRIX44_REF}),
	make_from_quaternion ({EM_QUATERNION}),
	to_pointer: {POINTER}

end
