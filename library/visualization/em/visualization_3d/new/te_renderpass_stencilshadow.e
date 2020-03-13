indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TE_RENDERPASS_STENCILSHADOW inherit

		TE_RENDERPASS redefine make, enable end

		TE_3D_SHARED_GLOBALS export {NONE} all end

		GL_FUNCTIONS export {NONE} all end

		EM_GL_CONSTANTS export {NONE} all end

	create
		make

feature {TE_RENDERPASS_MANAGER} -- Initialization

	make is
			-- create renderpass with
	do
		Precursor
		create camera.make_as_child(root)
		create {TE_3D_INFINITE_LIGHT} shadow_light.make_as_child(root)
		create color.make_xyzt(0.0,0.0,0.05,0.4)
		light_position_changed := true
	end

feature -- Access

	camera: TE_3D_CAMERA

	shadow_light: TE_3D_LIGHT_SOURCE

	color: GL_VECTOR_4D[DOUBLE]

feature -- Measurement

feature -- Status report

feature -- Status setting

feature -- Cursor movement

feature -- Element change

feature -- Removal

feature -- Resizing

feature -- Transformation

feature -- Conversion

feature -- Duplication

feature -- Miscellaneous

feature -- Basic operations

	set_shadow_light(new_shadow_light:TE_3D_LIGHT_SOURCE) is
			-- sets the shadow_light
		do
			shadow_light := new_shadow_light
			shadow_light.transform.event_channel.subscribe (agent set_light_position_changed_flag)
			light_position_changed := true
		end

	enable is
			-- enables and sets light_position_changed_flag
		do
			Precursor
			light_position_changed := true
		end


feature -- Obsolete

feature -- Inapplicable

	set_camera (a_camera:TE_3D_CAMERA) is
			-- sets the camera of the current renderpass
		require
			is_in_hierarchy: camera.parent /= Void
		do
			camera := a_camera
		end

feature {TE_RENDERPASS_MANAGER} -- Implementation

	render is
			-- renders the current pass
		require else
			shadow_light_exists: shadow_light /= Void
		do
			gl_Push_Attrib( em_GL_COLOR_BUFFER_BIT | em_GL_DEPTH_BUFFER_BIT | em_GL_ENABLE_BIT | em_GL_POLYGON_BIT | em_GL_STENCIL_BUFFER_BIT | em_GL_LIGHTING_BIT | em_GL_CURRENT_BIT)
			gl_push_client_attrib(em_GL_CLIENT_VERTEX_ARRAY_BIT)

			camera.specify

			gl_matrix_mode(em_GL_MODELVIEW)
			gl_load_identity

			--Stencil settings
			gl_clear(em_GL_STENCIL_BUFFER_BIT)
			gl_Disable( em_GL_LIGHTING )
			gl_enable (em_GL_CULL_FACE)
			gl_depth_mask(0)
			gl_enable (Em_gl_depth_test)
			gl_depth_func( em_GL_LEQUAL )
			gl_Enable( em_GL_STENCIL_TEST )
			gl_Color_Mask( 0, 0, 0, 0 )
			gl_Stencil_Func( em_GL_ALWAYS, 1, 0xFFFFFFFF )

			--Shadow Volume settings
			gl_enable_client_state(em_GL_VERTEX_ARRAY)

			--add frontfaces of shadowvolumes to the stencil buffer
			gl_cull_face(em_GL_BACK)
			gl_Stencil_Op(em_GL_KEEP, em_GL_KEEP, em_GL_INCR)

			if light_position_changed then
				update_and_draw_shadows_of_children(root, shadow_light)
			else
				draw_shadows_of_children(root)
			end

			--subtract frontfaces of shadowvolumes from the stencilbuffer
			gl_cull_face(em_GL_FRONT)
			gl_Stencil_Op( em_GL_KEEP, em_GL_KEEP, em_GL_DECR )
			draw_shadows_of_children(root)

			light_position_changed := false

			--draw a big black polygon

			gl_cull_face(em_GL_BACK)
			gl_Color_Mask( 1, 1, 1, 1 )

			gl_Color4dv(color.pointer)
			gl_Enable( em_GL_BLEND );
			gl_Blend_Func( em_GL_SRC_ALPHA, em_GL_ONE_MINUS_SRC_ALPHA )
			gl_Stencil_Func( em_GL_NOTEQUAL, 0, 0xFFFFFFFF )
			gl_Stencil_Op( em_GL_KEEP, em_GL_KEEP, em_GL_KEEP )

			gl_matrix_mode(em_GL_PROJECTION)
			gl_Push_Matrix
			gl_Load_Identity
			gl_Begin( em_GL_QUADS )
				gl_Vertex3d(-1.0, 1.0,0.0)
				gl_Vertex3d(-1.0,-1.0,0.0)
				gl_Vertex3d( 1.0, -1.0,0.0)
				gl_Vertex3d( 1.0, 1.0,0.0)
			gl_End
			gl_Pop_Matrix
			gl_Pop_Attrib
			gl_pop_client_attrib
		end

	update_and_draw_shadows_of_children(a_node:TE_3D_NODE; a_light_source: TE_3D_LIGHT_SOURCE) is
			-- updates the shadows and directly draws them and recursively goes through all the children and does the same
		local
			current_member: TE_3D_MEMBER
		do
			if a_node.is_hierarchy_renderable then
				from
					a_node.children.start
				until
					a_node.children.after
				loop
					gl_push_matrix
					gl_mult_matrixd(a_node.children.item_for_iteration.transform.to_opengl)

					current_member ?= a_node.children.item_for_iteration
					if current_member /= Void and then current_member.casts_shadows then -- if the current node is a 3d_member
						current_member.update_shadow_volume (a_light_source)
						current_member.render_shadow_volume
					end
					update_and_draw_shadows_of_children(a_node.children.item_for_iteration, a_light_source) -- do the same recursively with the children of the current node
					a_node.children.forth

					gl_pop_matrix
				end
			end
		end

	draw_shadows_of_children(a_node: TE_3D_NODE) is
			-- draws the shadows of the children of a_node of the scene without updating them
		local
			current_member: TE_3D_MEMBER
		do
			if a_node.is_hierarchy_renderable then
				from
					a_node.children.start
				until
					a_node.children.after
				loop
					gl_push_matrix
					gl_mult_matrixd(a_node.children.item_for_iteration.transform.to_opengl)

					current_member ?= a_node.children.item_for_iteration
					if current_member /= Void and then current_member.casts_shadows then -- if the current node is a 3d_member
						current_member.render_shadow_volume
					end
					draw_shadows_and_unlit_faces_of_children(a_node.children.item_for_iteration) -- do the same recursively with the children of the current node
					a_node.children.forth

					gl_pop_matrix
				end
			end
		end

	draw_shadows_and_unlit_faces_of_children(a_node: TE_3D_NODE) is
			-- draws the shadows of the children of a_node of the scene without updating them
		local
			current_member: TE_3D_MEMBER
		do
			if a_node.is_hierarchy_renderable then
				from
					a_node.children.start
				until
					a_node.children.after
				loop
					gl_push_matrix
					gl_mult_matrixd(a_node.children.item_for_iteration.transform.to_opengl)

					current_member ?= a_node.children.item_for_iteration
					if current_member /= Void and then current_member.casts_shadows then -- if the current node is a 3d_member
						current_member.render_shadow_volume
						gl_push_attrib(em_GL_POLYGON_BIT | em_GL_STENCIL_BUFFER_BIT)
							gl_cull_face(em_GL_BACK)
							gl_Stencil_Func( em_GL_ALWAYS, 0, 0xFFFFFFFF )
							gl_Stencil_Op( em_GL_KEEP, em_GL_KEEP, em_GL_REPLACE )
							current_member.render_unlit_faces
						gl_pop_attrib
					end
					draw_shadows_and_unlit_faces_of_children(a_node.children.item_for_iteration) -- do the same recursively with the children of the current node
					a_node.children.forth

					gl_pop_matrix
				end
			end
		end


	light_position_changed: BOOLEAN

	set_light_position_changed_flag is
			-- sets light_position_changed flag
		do
			light_position_changed := true
		end


invariant
	invariant_clause: True -- Your invariant here

end
