indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TE_3D_MEMBER inherit

		TE_3D_NODE
			rename
				make as make_node,
				make_as_child as make_node_as_child
			redefine
				draw,
				render_node,
				create_deep_instance,
				calculate_hierarchy_bounding_box
			end

		IDENTIFIED
		rename is_equal as has_equal_id, copy as copy_by_id
		select has_equal_id, copy_by_id
		end

		TE_3D_SHARED_GLOBALS

		EM_GL_CONSTANTS export {NONE} all end

	create
		make, make_as_child

feature -- Initialization

	make (a_ressource_list: ARRAYED_LIST [TE_3D_RESSOURCE])
			-- create 3D member from a list of 3d ressources, calculate bounding_sphere for item 1 and make it child of root
		require
			list_not_empty: a_ressource_list.count > 0
		do
			make_node
			ressource_list := a_ressource_list
			shadow_ressource := a_ressource_list.i_th (a_ressource_list.count)
			create shadow_volume.make
			create bounding_sphere
			create bounding_box.make (6)
			calculate_boundaries
			create level_of_detail.make (ressource_list.count)
			--enable_frustum_culling
			enable_hierarchy_renderable
			enable_renderable
			enable_use_shadow_ressource
		end

	make_as_child (a_ressource_list: ARRAYED_LIST [TE_3D_RESSOURCE]; a_parent: TE_3D_NODE)
			-- create 3D member from a list of 3d ressources, calculate bounding_sphere for item 1 and make it child of a_parent
		require
			list_not_empty: a_ressource_list.count > 0
		do
			make_node_as_child (a_parent)
			ressource_list := a_ressource_list
			shadow_ressource := a_ressource_list.i_th (a_ressource_list.count)
			create shadow_volume.make
			create bounding_sphere
			create bounding_box.make (6)
			calculate_boundaries
			create level_of_detail.make (ressource_list.count)
			--enable_frustum_culling
			enable_hierarchy_renderable
			enable_renderable
			enable_use_shadow_ressource
		end


feature -- Access

	bounding_sphere: TUPLE[EM_VECTOR3D, DOUBLE]
		-- bounding sphere with pivot and radius, containing all vertices of the first LOD level of the member

	bounding_box: ARRAYED_LIST[EM_VECTOR3D]
		-- arrayed list containing 8 vectors representing the corners of the bounding box with the following order:
		-- X(-Y)Z, (-X)(-Y)Z, (-X)(-Y)(-Z), X(-Y)(-Z), XYZ, XY(-Z), (-X)Y(-Z), (-X)YZ

feature -- Status report

	frustum_culling_enabled: BOOLEAN
		-- is frustum culling enabled?

	level_of_detail_enabled: BOOLEAN
		-- is level of detail enabled?

	is_in_view_frustum: BOOLEAN
			-- calculates, wetherthe member is within the viewfrustum or not
		local
			modelview_matrix, projection_matrix: EM_MATRIX44
			pivot3d: EM_VECTOR3D
			pivot4d: EM_VECTOR4D
		do
			gl_get_doublev (em_gl_modelview_matrix, modelview_matrix.to_pointer)
			gl_get_doublev (em_gl_projection_matrix, projection_matrix.to_pointer)
			pivot3d := transform.position
			pivot4d.set (pivot3d.x, pivot3d.y, pivot3d.z, 1.0)
			pivot4d := modelview_matrix.mult (pivot4d)
			pivot4d := projection_matrix.mult (pivot4d)
			Result := pivot4d.x.abs < pivot4d.w.abs and pivot4d.y.abs < pivot4d.w.abs and pivot4d.z.abs < pivot4d.w.abs
		end

	renderable: BOOLEAN
			-- is this node renderable (doesn't affect the hierarchy)


	use_shadow_ressource: BOOLEAN
			-- if this is true, the shadow ressource gets used to cast shadows. if false, the current LOD level will cast shadows

	casts_shadows: BOOLEAN
			-- does the member cast stencil shadows?

feature -- Status setting

	enable_renderable is
			-- enables renderable
		do
			renderable := true
		end

	disable_renderable is
			-- disables renderable
		do
			renderable := false
		end

feature -- Engines

	level_of_detail: TE_LEVEL_OF_DETAIL
		-- object to calculate the current LOD state		

feature -- Status setting

	enable_frustum_culling  is
			-- enables frustum culling
		do
			frustum_culling_enabled := true
		end

	disable_frustum_culling is
			-- disables frustum culling
		do
			frustum_culling_enabled := false
		end

	enable_level_of_detail is
			-- enables level of detail
		do
			level_of_detail.enable
			level_of_detail_enabled := true
		end

	disable_level_of_detail
			-- enables level of detail
		do
			level_of_detail.disable
			level_of_detail_enabled := False
		end

	disable_shadow_casting
			-- disables stencil shadow casting
		do
			casts_shadows := False
		end

	disable_use_shadow_ressource
			-- disables use_shadow_ressource
		do
			use_shadow_ressource := False
		end

	enable_shadow_casting
			-- enables stencil shadow casting
		do
			casts_shadows := True
		end

	enable_use_shadow_ressource
			-- enables use_shadow_ressource
		do
			use_shadow_ressource := True
		end

feature -- Element setting

	set_shadow_ressource (new_shadow_ressource: TE_3D_RESSOURCE)
			-- sets the shadow-ressource
		do
			shadow_ressource := new_shadow_ressource
		end

feature -- Ressources

	ressource_list : ARRAYED_LIST[TE_3D_RESSOURCE]
		-- list of 3D_ressources, each one representing one LOD level

	shadow_ressource: TE_3D_RESSOURCE
			-- separate ressource for casting shadows. by default this is the most simple LOD level

	shadow_volume: TE_3D_SHADOW_VOLUME

feature -- Removal

feature -- Cloning

	create_deep_instance: TE_3D_MEMBER
			-- returns an instance of the 3D member and instances of all childs and subchilds of the 3d member as hirarchy
		do
			Result := create_instance
			Result.set_hierarchy_bounding_box (hierarchy_bounding_box.twin)
			Result.set_shadow_ressource (shadow_ressource)
			from
				children.start
			until
				children.after
			loop
				Result.add_child (children.item_for_iteration.create_deep_instance)
				children.forth
			end
		end

	create_instance: TE_3D_MEMBER
			-- returns an instance of the 3D member. it references the same 3D ressources like current
		do
			create Result.make_as_child (ressource_list, parent)
			Result.set_shadow_ressource (shadow_ressource)
		end

feature -- Transformation

feature -- Measurement

	calculate_hierarchy_bounding_box is
			-- updates the hierarchy_boundingbox. DON'T USE THIS EVERY FRAME SINCE IT IS NOT PERFORMANT!
		local
			max_x, min_x, max_y, min_y, max_z, min_z: DOUBLE
			vec1,vec2,vec3,vec4,vec5,vec6,vec7,vec8: EM_VECTOR3D
			current_vertex: EM_VECTOR3D
		do
			Precursor --create the hierarchy bounding box for all children

			--compare with local bounding box and expand if needed
			from
				hierarchy_bounding_box.start
				bounding_box.start
			until
				hierarchy_bounding_box.after and bounding_box.after
			loop
				current_vertex := hierarchy_bounding_box.item
				if current_vertex.x > max_x then max_x := current_vertex.x
				elseif current_vertex.x < min_x then min_x := current_vertex.x end
				if current_vertex.y > max_y then max_y := current_vertex.y
				elseif current_vertex.y < min_y then min_y := current_vertex.y end
				if current_vertex.z > max_z then max_z := current_vertex.z
				elseif current_vertex.z < min_z then min_z := current_vertex.z end

				current_vertex := bounding_box.item
				if current_vertex.x > max_x then max_x := current_vertex.x
				elseif current_vertex.x < min_x then min_x := current_vertex.x end
				if current_vertex.y > max_y then max_y := current_vertex.y
				elseif current_vertex.y < min_y then min_y := current_vertex.y end
				if current_vertex.z > max_z then max_z := current_vertex.z
				elseif current_vertex.z < min_z then min_z := current_vertex.z end

				hierarchy_bounding_box.forth
				bounding_box.forth
			end
			--define hierarchy_bounding_box
			vec1.set(max_x,min_y,max_z) --bottom quad
			vec2.set(max_x,min_y,min_z) --bottom quad
			vec3.set(min_x,min_y,min_z) --bottom quad
			vec4.set(min_x,min_y,max_z) --bottom quad
			vec5.set(max_x,max_y,max_z) --top quad
			vec6.set(min_x,max_y,max_z) --top quad
			vec7.set(min_x,max_y,min_z) --top quad
			vec8.set(max_x,max_y,min_z) --top quad

			hierarchy_bounding_box.wipe_out --remove all items
			hierarchy_bounding_box.extend(vec1)
			hierarchy_bounding_box.extend(vec2)
			hierarchy_bounding_box.extend(vec3)
			hierarchy_bounding_box.extend(vec4)
			hierarchy_bounding_box.extend(vec5)
			hierarchy_bounding_box.extend(vec6)
			hierarchy_bounding_box.extend(vec7)
			hierarchy_bounding_box.extend(vec8)
		end


feature -- Duplication

feature -- Miscellaneous

feature -- Basic operations

	render_shadow_volume
			-- renders the shadow volume of the active LOD level
		do
			shadow_volume.draw_shadow_volume
		end

	render_unlit_faces
			-- renders the faces which are currently not lit by the shadow casting lightsource
		do
			shadow_volume.draw_unlit_faces
		end

	update_shadow_volume (a_light_source: TE_3D_LIGHT_SOURCE)
			-- updates the shadow_volume of the active LOD level
		local
			local_shadow_light_position: EM_VECTOR3D
			world_shadow_light_position: EM_VECTOR3D
			is_directional_light: BOOLEAN
			active_3d_ressource: TE_3D_RESSOURCE
			lod_level: INTEGER
		do
			world_shadow_light_position := a_light_source.world_transform.position
			if a_light_source.light_position.t = 0.0 then
				local_shadow_light_position := worldspace_to_localspace (world_shadow_light_position + world_transform.position)
				is_directional_light := True
			else
				local_shadow_light_position := worldspace_to_localspace (world_shadow_light_position)
				is_directional_light := False
			end
			lod_level := 1
			if not use_shadow_ressource then
				active_3d_ressource := ressource_list [lod_level]
			else
				active_3d_ressource := shadow_ressource
			end
			shadow_volume.update_shadow_volume (local_shadow_light_position, is_directional_light, active_3d_ressource)
		end

feature -- Obsolete

feature -- Inapplicable

feature {NONE} -- Implementation

	calculate_boundaries is
			-- calculatesa sphere countaining all vertices of the first LOD level
			-- TODO: this is not the minimal enclosing sphere!! try to implement Bernd Gaertner's algorithm to improve this!
		local
			center, current_vertex: EM_VECTOR3D
			radius, distance_to_center: DOUBLE
			vertex_count : INTEGER

			max_x, min_x, max_y, min_y, max_z, min_z: DOUBLE
			vec1,vec2,vec3,vec4,vec5,vec6,vec7,vec8: EM_VECTOR3D
		do
			create center

			-- loop through all vertices of LOD level 1 to find the weighted center and the bounding_box
			from
				ressource_list[1].vertex_list.start
			until
				ressource_list[1].vertex_list.after
			loop
				-- find bounding sphere center
				current_vertex := ressource_list[1].vertex_list.item
				center := center + current_vertex
				vertex_count := vertex_count + 1

				--find bounding box boundaries
				if current_vertex.x > max_x then max_x := current_vertex.x
				elseif current_vertex.x < min_x then min_x := current_vertex.x end
				if current_vertex.y > max_y then max_y := current_vertex.y
				elseif current_vertex.y < min_y then min_y := current_vertex.y end
				if current_vertex.z > max_z then max_z := current_vertex.z
				elseif current_vertex.z < min_z then min_z := current_vertex.z end

				ressource_list[1].vertex_list.forth
			end
			center := center * (1.0/vertex_count)

			-- loop through all vertices to find the radius
			from
				ressource_list[1].vertex_list.start
			until
				ressource_list[1].vertex_list.after
			loop
				current_vertex := ressource_list[1].vertex_list.item
				distance_to_center := (current_vertex-center).length
				if distance_to_center > radius then
					radius:= distance_to_center
				end

				ressource_list[1].vertex_list.forth
			end

			--define bounding sphere
			bounding_sphere.put(center,1)
			bounding_sphere.put(radius,2)

			--define bounding_box
			vec1.set(max_x,min_y,max_z) --bottom quad
			vec2.set(max_x,min_y,min_z) --bottom quad
			vec3.set(min_x,min_y,min_z) --bottom quad
			vec4.set(min_x,min_y,max_z) --bottom quad
			vec5.set(max_x,max_y,max_z) --top quad
			vec6.set(min_x,max_y,max_z) --top quad
			vec7.set(min_x,max_y,min_z) --top quad
			vec8.set(max_x,max_y,min_z) --top quad

			bounding_box.wipe_out --remove all items
			bounding_box.extend(vec1)
			bounding_box.extend(vec2)
			bounding_box.extend(vec3)
			bounding_box.extend(vec4)
			bounding_box.extend(vec5)
			bounding_box.extend(vec6)
			bounding_box.extend(vec7)
			bounding_box.extend(vec8)
		end

	render_node
			-- renders the 3D_member to display
		local
			lod_level: INTEGER
		do
			if renderable then
				if not frustum_culling_enabled or else is_in_view_frustum then
					lod_level := 1;
					ressource_list [lod_level].draw_geometry
				end
			end
		end

	draw is
			-- Draw the hierarchy if `is_hierarchy_renderable'.
		do
			if is_hierarchy_renderable then
				gl_push_matrix
				gl_push_name(0)
				gl_load_name(object_id)

				gl_mult_matrixd(transform.to_opengl)

				--render the node
				render_node

				--draw the children
				from
					children.start
				until
					children.after
				loop
					children.item_for_iteration.draw
					children.forth
				end
				gl_pop_matrix
				gl_pop_name
			end
		end

invariant
	invariant_clause: True -- Your invariant here

end
