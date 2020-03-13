indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TE_RENDERPASS_BEAUTY inherit

		TE_RENDERPASS redefine make end

		TE_3D_SHARED_GLOBALS

		GL_FUNCTIONS export {NONE} all end

		GLU_FUNCTIONS

		EM_GL_CONSTANTS export {NONE} all end

	create
		make

feature {TE_RENDERPASS_MANAGER} -- Initialization

	make is
			-- create renderpass with
	do
		Precursor
		create camera.make_as_child(root)
		create light_sources.make
		background_color.set(0.1, 0.4, 0.5, 0.0)
		create global_ambient_color.make_xyzt(0.0,0.0,0.0,0.0)
	end

feature -- Access

	camera: TE_3D_CAMERA

	light_sources: LINKED_LIST[TE_3D_LIGHT_SOURCE]

	background_color: EM_VECTOR4D

	global_ambient_color: GL_VECTOR_4D[REAL]

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

	add_light_source(new_light_source: TE_3D_LIGHT_SOURCE) is
			-- adds a light source to the light sources which will influence to the lighting equation of this renderpass
		require
			is_in_hierarchy: new_light_source.parent /= Void
		do
			light_sources.extend (new_light_source)
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

	set_background_color (r,g,b: DOUBLE) is
			-- sets the background color of the current renderpass
		do
			background_color.set (r,g,b,0.0)
		end

feature {TE_RENDERPASS_MANAGER} -- Implementation

	render is
			-- renders the current pass
		local
		i:INTEGER
		test, pos, tar, up: EM_VECTOR3D
		testmat, wt: EM_MATRIX44
		do
			gl_push_attrib(em_GL_ENABLE_BIT | em_GL_DEPTH_BUFFER_BIT | em_GL_LIGHTING_BIT | em_GL_CURRENT_BIT)

			-- Lighting specific
			gl_enable(em_gl_lighting)
			gl_enable(em_GL_NORMALIZE)
			gl_light_modelfv(em_GL_LIGHT_MODEL_AMBIENT, global_ambient_color.pointer)
			gl_Color4d(1.0,1.0,1.0,1.0)

			-- Depth buffer specific
			gl_clear_external (Em_gl_depth_buffer_bit)
			gl_enable_external (Em_gl_depth_test)
			gl_depth_func (em_GL_LEQUAL)
			gl_depth_mask(1)

			-- Clearing background color to background_color
			gl_clear_color_external (background_color.x, background_color.y, background_color.z, background_color.w)
			gl_clear_external (em_gl_color_buffer_bit)

			--enable and specify lightsources of the current pass
			gl_matrix_mode(em_GL_MODELVIEW)
			gl_load_identity

			from
				light_sources.start
				i:=0
			until
				light_sources.after
			loop
				if light_sources.item.enabled then
					gl_enable(em_GL_LIGHT0 + i)
					light_sources.item.specify(i)
				else
					gl_disable(em_GL_LIGHT0 + i)
				end
				light_sources.forth
				i := i+1
			end
			--disable unused lightsources
			from
			until
				i > 7
			loop
				gl_disable(em_GL_LIGHT0 + i)
				i := i+1
			end

			--camera.specify

			--gl_hint(em_gl_perspective_correction_hint, em_gl_nicest)
			root.draw

			gl_pop_attrib
		end




	output_gl_states is
			-- outputs some gl states for debugging
		do
			--create output_string.make_empty

			io.put_string("%N %N %N %N %N %N %N %N %N %N %N %N %N %N %N %N %N %N %N %N %N %N %N %N %N %N %N %N %N %N %N")
			--gl_get_booleanv(em_GL_BLEND, output_string)
			--io.put_string ("blending: " + output_string +"%N")
			--gl_get_booleanv(em_GL_CULL_FACE,output_string)
			--io.put_string ("polygon culling: " +output_string +"%N")
			--gl_get_integerv(em_GL_CULL_FACE_MODE,output_int.to_pointer)
			--io.put_string ("culling mode: " +output_int.x.out + "%N")

			io.put_string("lightsources: " + light_sources.count.out +"%N")
			io.put_string("lightsource1 position: " + light_sources.first.transform.position.x.floor.out + " "+ light_sources.first.transform.position.y.floor.out + " " + light_sources.first.transform.position.z.floor.out)
		end



invariant
	invariant_clause: True -- Your invariant here
	valid_number_of_lightsources: light_sources.count <= 8

end
