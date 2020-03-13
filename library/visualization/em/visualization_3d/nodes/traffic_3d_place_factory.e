indexing
	description: "Factory for creating place representations"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_3D_PLACE_FACTORY inherit

		TE_3D_MEMBER_FACTORY_PRIMITIVE
			redefine
				make
			end

		TRAFFIC_CONSTANTS

create make

feature -- Initialization

	make is
			-- makes factory and sets the color to black
		local
		default_material: TE_MATERIAL_SIMPLE
		do
			create default_material.make_with_color(1.0,1.0,1.0)
			set_material(default_material)
		end

feature -- Basic operations

	new_place_member (a_place: TRAFFIC_PLACE): TRAFFIC_3D_RENDERABLE [TRAFFIC_PLACE] is
			-- Creates a representation for `a_place' using the available material.
		require
			a_place_not_void: a_place /= void
		local
			border: DOUBLE
		do
			border := 4.0
			create_simple_plane (a_place.width+border, a_place.breadth+border)
			create Result.make (a_place)
			Result.add_child (last_3d_member)
			Result.transform.set_position (a_place.position.x, 0.07, a_place.position.y)
		ensure
			Result_exists: Result /= Void
		end

end
