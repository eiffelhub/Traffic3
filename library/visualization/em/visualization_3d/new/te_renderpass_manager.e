indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TE_RENDERPASS_MANAGER inherit

		GL_FUNCTIONS export {NONE} all end

		--EM_GL_CONSTANTS export {NONE} all end

		EMGL_SETTINGS export {NONE} all end

		EMGL_SELECT export {NONE} all end

		EMGL_VIEW export {NONE} all end

		EMGLU_VIEW export {NONE} all end

		GLEXT_FUNCTIONS export {NONE} all end

		EM_GLEXT_CONSTANTS export {NONE} all end

		--DEBUG
		MEMORY

		SDL_VIDEO_FUNCTIONS_EXTERNAL
		--/DEBUG

	create
		make

feature {TE_3D_SHARED_GLOBALS} -- Initialization

	make is
			-- creates the renderpass manager, sets default global render settings and creates the first render pass
		local
			beauty_renderpass: TE_RENDERPASS_BEAUTY
			s:STRING
			i:INTEGER
		do

			--SETTING SELECTIONBUFFER CAPACITY
				create selectbuf.make_new_unshared (256)
				create member_finder
			--/SETTING SELECTIONBUFFER CAPACITY

			enable_culling

			create renderpasses.make(1)
			create beauty_renderpass.make
			current_renderpass := beauty_renderpass
			set_camera(beauty_renderpass.camera)
			current_renderpass_index := 1
			renderpasses.extend(beauty_renderpass)

			--DEBUG
				io.put_string("OpenGL Info: %N")
				create s.make_from_c (gl_get_string(em_GL_VENDOR))
				io.put_string("GL_VENDOR: " + s +"%N")
				create s.make_from_c (gl_get_string(em_GL_RENDERER))
				io.put_string("GL_RENDERER: " + s +"%N")
--				create s.make_from_c (gl_get_string(em_GL_EXTENSIONS))
--				io.put_string("GL_EXTENSIONS: " + s + "%N")
				emgl_get_integerv(em_GL_MAX_TEXTURE_UNITS_ARB, $i)
				io.put_string ("supported number of Textures for Multitexturing: " + i.out + "%N")

				io.put_string("garbage collection: " + collecting.out + "%N")

				io.put_string("%N %N")
			--/DEBUG
		end


feature -- Access

	camera: TE_3D_CAMERA

	current_renderpass: TE_RENDERPASS

	current_renderpass_index: INTEGER

	renderpasses: ARRAYED_LIST[TE_RENDERPASS]

feature -- Global Render Settings

	enable_culling is
			-- enables gobal culling
		do
			emgl_enable(em_gl_cull_face)
		end

	disable_culling is
			-- disables global culling
		do
			emgl_disable(em_gl_cull_face)
		end

	enable_anti_aliasing is
			-- enables global antialiasing
		do

		end

	disable_anti_aliasing is
			-- disables global anti_aliasing
		do

		end

	set_camera(a_camera:TE_3D_CAMERA) is
			-- sets the camera
		do
			camera := a_camera
		ensure
			camera_set: camera = a_camera
		end


feature -- Renderpass handling

	add_renderpass(new_render_pass: TE_RENDERPASS) is
			-- adds a renderpass to the queue
		do
			renderpasses.extend (new_render_pass)
		end

feature -- Implementation

	render is
			-- renders all renderpasses
		local
			i:INTEGER
		do
			--camera.specify

			emgl_hint(em_gl_perspective_correction_hint, em_gl_dont_care)

			from
				renderpasses.start
				i := 1
			until
				renderpasses.after
			loop
				if renderpasses[i].enabled then
					current_renderpass := renderpasses[i]
					current_renderpass_index := i
					renderpasses.item.render
				end
				renderpasses.forth
				i := i+1
			end
		end


	selectbuf: EWG_MANAGED_POINTER
	member_finder: IDENTIFIED

	select_objects (mouse_x, mouse_y, delta_x, delta_y: INTEGER; viewport: EM_VECTOR4I): LINKED_LIST[TUPLE[TE_3D_MEMBER, NATURAL_32]] is
			-- returns a list of 3d_members under the selection point
		local
			proj_mat: EM_MATRIX44
			hits,i,j, pos, stack_depth, id, temp: INTEGER
			z_near, z_far, n: NATURAL_32
			member: TE_3D_MEMBER
			memberlist: LINKED_LIST[TUPLE[TE_3D_MEMBER, NATURAL_32]]
		do
			create memberlist.make

			gl_viewport_external (viewport.x, viewport.y, viewport.z, viewport.w)


			camera.specify
			proj_mat := emgl_get_projection_matrix

			emgl_push_matrix
			emgl_load_identity

			emgl_select_buffer(selectbuf.capacity, selectbuf.item)
			temp := emgl_render_mode(em_gl_select)
			emgl_init_names
			emgl_push_name(-666)
			emgl_matrix_mode(em_gl_projection)
			emgl_push_matrix
			emgl_load_identity
			emglu_pick_matrix(mouse_x, 30+viewport.w-mouse_y,delta_x,delta_y,viewport)
			emgl_mult_matrixd (proj_mat)

			emgl_matrix_mode (em_gl_modelview)

			render

			emgl_pop_matrix
			emgl_matrix_mode (em_gl_projection)
			emgl_pop_matrix
			emgl_matrix_mode(em_gl_modelview)

			hits := emgl_render_mode(em_gl_render)
			pos := 0
			from i := 1 until i> hits loop
				stack_depth := selectbuf.read_integer(pos);	pos := pos+4
				z_near := selectbuf.read_integer( pos ).as_natural_32 ; pos := pos + 4
				z_far := selectbuf.read_integer( pos ).as_natural_32 ; pos := pos + 4
				from j:=1 until j>stack_depth loop
					id := selectbuf.read_integer( pos ) ; pos := pos + 4
					member ?= member_finder.id_object (id)
					if member /= void then
						from
							memberlist.start
						until
							memberlist.after
						loop
							n ?= memberlist.item.item (2)
							if z_near < n then
								memberlist.put_left ([member, z_near])
							elseif memberlist.after then
								memberlist.put_right ([member, z_near])
							end
							memberlist.forth
						end
						if memberlist.empty then
							memberlist.force ([member, z_near])
						end

						io.put_string("object with id " + id.out + " selected %N")
					end
					j := j + 1
				end
				i := i + 1
			end

			result := memberlist

			--DEBUG
			--sdl_gl_swap_buffers_external
			--gl_flush
			--/DEBUG

		end





invariant
	invariant_clause: True -- Your invariant here

end
