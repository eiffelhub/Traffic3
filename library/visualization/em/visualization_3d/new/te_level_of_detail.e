indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TE_LEVEL_OF_DETAIL inherit

		TE_3D_SHARED_GLOBALS

		DOUBLE_MATH

	create
		make

feature -- Initialization

	make(iteration_count:INTEGER) is
			-- creates LOD controller with 'iterations' as iteration steps
		require
			iterations_is_positive : iteration_count > 0
		do
			iterations := iteration_count
			if iteration_count = 1 then
				disable
			end
			index := 1
			automatic := true
			enabled := true
		end

feature -- Access

	index: INTEGER
		-- stores the last calculated LOD level

	iterations: INTEGER
		-- how many LOD levels exist? - must be greater than 0

feature -- Measurement

feature -- Status report

	automatic:BOOLEAN
		-- index gets calculated

	enabled:BOOLEAN
		-- if enabled is false, index is always 1

feature -- Status setting

	enable is
			-- enables the level of detail calculation
		do
			enabled := true
		end

	disable is
			-- disables the level of detail calculation
		do
			enabled := false
			index := 1
		end

feature -- Cursor movement

feature -- Element change

feature -- Removal

feature -- Resizing

feature -- Transformation

feature -- Conversion

feature -- Duplication

feature -- Miscellaneous

feature -- Basic operations

feature -- Obsolete

feature -- Inapplicable

feature -- Implementation

	update_by_bounding_sphere (a_3d_member:TE_3D_MEMBER; a_camera:TE_3D_CAMERA) is
		-- transforms the boundingsphere to screenspace to calculate the LOD index
		local
			bs_center: EM_VECTOR3D
			screenspace_percentage, distance_to_camera, screen_height, ang2rad: DOUBLE
			radius: DOUBLE
		do
			ang2rad := 3.14159265358979323846/180.0

			radius ?= a_3d_member.bounding_sphere.item(2)
			bs_center ?= a_3d_member.bounding_sphere.item(1)
			bs_center := a_3d_member.localspace_to_worldspace(bs_center) -- boundingsphere center in worldspace
			distance_to_camera := (bs_center-a_camera.world_transform.position).length
			screen_height := 2.0 * distance_to_camera * tangent(ang2rad * a_camera.fov/2.0)
			screenspace_percentage := 100.0 * (radius/screen_height)

			index := (screenspace_percentage/(100.0/(iterations+1))).floor + 1
		ensure
			index_is_within_range: index > 0 and index <= iterations
		end

invariant
	iterations_is_positive: iterations > 0 -- there must be at least one LOD level

end
