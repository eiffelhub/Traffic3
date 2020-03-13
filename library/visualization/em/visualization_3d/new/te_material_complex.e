indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TE_MATERIAL_COMPLEX

inherit
	TE_MATERIAL
		redefine
			make
		end

	EM_GL_CONSTANTS

	GL_FUNCTIONS
		export
			{NONE} all
		end

create
	make

feature

	make
		local
			single_material_pass: EM_EVENT_CHANNEL[TUPLE[]]
		do
			Precursor
			create ambient_color.make_xyzt (0.2, 0.2, 0.2, 1.0)
			create diffuse_color.make_xyzt (1.0, 1.0, 1.0, 1.0)
			create specular_color.make_xyzt (1.0, 1.0, 1.0, 1.0)
			create emissive_color.make_xyzt (0.0, 0.0, 0.0, 1.0)
			shininess := 0.0
			blend_source_func := em_gl_src_alpha
			blend_target_func := em_gl_one_minus_src_alpha
			opacity := 1.0
			frontside_visible := True
			render_type := em_gl_fill
			shaded := True
			min_filter := True
			mag_filter := True

			-- create material_pass event and subscribe specify to it
			create single_material_pass
			single_material_pass.subscribe (agent default_pass)
			specify_material_pass.extend(single_material_pass)
		end

feature -- Access

	ambient_color: GL_VECTOR_4D [REAL_32]

	diffuse_color: GL_VECTOR_4D [REAL_32]

	specular_color: GL_VECTOR_4D [REAL_32]
			-- CULLING MUST BE ENABLED OR false WILL TAKE NO EFFECT!

	emissive_color: GL_VECTOR_4D [REAL_32]

	shininess: REAL_32

	diffuse_texture: GL_TEXTURE

	emissive_texture: GL_TEXTURE

	--reflection_texture: GL_TEXTURE

	blending: BOOLEAN

	blend_source_func: INTEGER_32

	blend_target_func: INTEGER_32

	alpha_testing: BOOLEAN

	opacity: REAL_32
			-- CULLING MUST BE ENABLED OR false WILL TAKE NO EFFECT!

	frontside_visible: BOOLEAN
			-- Name of current object's generating type
			-- (type of which it is a direct instance)
			-- (from ANY)

	backside_visible: BOOLEAN

	render_type: INTEGER_32

	shaded: BOOLEAN

	faceted: BOOLEAN

	min_filter: BOOLEAN
			-- Name of current object's generating class
			-- (base class of the type of which it is a direct instance)
			-- (from ANY)

	mag_filter: BOOLEAN

feature -- Status setting

	set_ambient_color (r, g, b: REAL_64)
		do
			ambient_color.set_xyzt (r, g, b, 1.0)
		end

	set_diffuse_color (r, g, b: REAL_64)
			-- range from 0.0 to 128.0
		do
			diffuse_color.set_xyzt (r, g, b, 1.0)
		end

	set_specular_color (r, g, b: REAL_64)
			-- Are `some' and `other' either both void
			-- or attached to isomorphic object structures?
			-- (from ANY)
		do
			specular_color.set_xyzt (r, g, b, 1.0)
		end

	set_emissive_color (r, g, b: REAL_64)
		do
			emissive_color.set_xyzt (r, g, b, 1.0)
		end

	set_shininess (a_value: REAL_32)
			-- from ANY
		require
			value_is_in_range: a_value >= 0.0 and a_value <= 128.0
		do
			shininess := a_value
		end

	set_diffuse_texture (a_texture: GL_TEXTURE)
		require
			texture_not_void: a_texture /= Void
		do
			diffuse_texture := a_texture
		end

	enable_blending
		do
			blending := True
		end

	disable_blending
		do
			blending := False
		end

	set_blend_func (sf, tf: INTEGER_32)
		require
			valid_parameters: (sf = em_gl_zero or sf = em_gl_one or sf = em_gl_dst_color or sf = em_gl_one_minus_dst_color or sf = em_gl_src_alpha or sf = em_gl_one_minus_src_alpha or sf = em_gl_src_color or sf = em_gl_one_minus_src_color or sf = em_gl_dst_alpha or sf = em_gl_one_minus_dst_alpha or sf = em_gl_src_alpha_saturate) and (tf = em_gl_zero or tf = em_gl_one or tf = em_gl_dst_color or tf = em_gl_one_minus_dst_color or tf = em_gl_src_alpha or tf = em_gl_one_minus_src_alpha or tf = em_gl_src_color or tf = em_gl_one_minus_src_color or tf = em_gl_dst_alpha or tf = em_gl_one_minus_dst_alpha or tf = em_gl_src_alpha_saturate)
		do
			blend_source_func := sf
			blend_target_func := tf
		end

	enable_alpha_testing
		do
			alpha_testing := True
		end

	disable_alpha_testing
		do
			alpha_testing := False
		end

	set_opacity (new_opacity: REAL_64)
		require
			opacity_in_range: new_opacity >= 0.0 and new_opacity <= 1.0
		do
		end

	set_visibility (front, back: BOOLEAN)
			-- Are `some' and `other' either both void or attached to
			-- field-by-field identical objects of the same type?
			-- Always uses default object comparison criterion.
			-- (from ANY)
		require
			one_face_visible: front = True or back = True
		do
			frontside_visible := front
			backside_visible := back
		end

	set_render_type (a_render_type: INTEGER_32)
			-- from ANY
		require
			valid_render_type: a_render_type = em_gl_point or a_render_type = em_gl_line or a_render_type = em_gl_fill
		do
			render_type := a_render_type
		end

	enable_shading
		do
			shaded := True
		end

	disable_shading
		do
			shaded := False
		end

	enable_faceted
		do
			faceted := True
		end

	disable_faceted
		do
			faceted := False
		end

	set_texture_filtering (min, mag: BOOLEAN)
		do
			min_filter := min
			mag_filter := mag
		end

	set_name (a_name: STRING_8)
		do
			name := a_name
		end

feature -- Pass setting

	set_emissive_pass (new_emissive_texture: GL_TEXTURE) is
			-- sets and activates the emissive material pass
		local
			emissive_material_pass: EM_EVENT_CHANNEL[TUPLE[]]
		do
			if emissive_texture = Void then
				create emissive_material_pass
				emissive_material_pass.subscribe (agent emissive_pass)
				specify_material_pass.extend(emissive_material_pass)
			end
			emissive_texture := new_emissive_texture
		end


feature {NONE} -- Implementation

	material_in_gl_use: BOOLEAN

	default_pass
		do
			material_in_gl_use := True
			gl_push_attrib (em_gl_enable_bit | em_gl_polygon_bit | em_GL_COLOR_BUFFER_BIT | em_GL_DEPTH_BUFFER_BIT | em_GL_LIGHTING_BIT)
			--enable alpha testing
			if alpha_testing then
				gl_enable(em_GL_ALPHA_TEST)
			end

			if faceted then
				gl_shade_model (em_gl_flat)
			else
				gl_shade_model (em_gl_smooth)
			end
			if not shaded then
				gl_disable (em_gl_lighting)
			end
			if alpha_testing then
				gl_enable (em_gl_alpha_test)
				gl_alpha_func (em_gl_greater, 0.5)
			end
			if blending then
				gl_enable (em_gl_blend)
				gl_blend_func (blend_source_func, blend_target_func)
			end
			if frontside_visible and backside_visible then
				gl_disable (em_gl_cull_face)
				gl_polygon_mode (em_gl_front_and_back, render_type)
			elseif backside_visible then
				gl_cull_face (em_gl_front)
				gl_polygon_mode (em_gl_back, render_type)
			else
				gl_cull_face (em_gl_back)
				gl_polygon_mode (em_gl_front, render_type)
			end
			gl_materialfv (em_gl_front_and_back, em_gl_ambient, ambient_color.pointer)
			gl_materialfv (em_gl_front_and_back, em_gl_diffuse, diffuse_color.pointer)
			gl_materialfv (em_gl_front_and_back, em_gl_specular, specular_color.pointer)
			gl_materialfv (em_gl_front_and_back, em_gl_emission, emissive_color.pointer)
			gl_materialf (em_gl_front_and_back, em_gl_shininess, shininess)
			if diffuse_texture /= Void then
				gl_enable (em_gl_texture_2d)
				gl_bind_texture (em_gl_texture_2d, diffuse_texture.id)
			end
		end

	emissive_pass is
			-- emissive pass for emissive textures
		require
			emissive_texture_exists: emissive_texture /= Void
		do
			gl_disable(em_GL_LIGHTING)
			gl_depth_mask(0)
			gl_enable(em_GL_BLEND)
			gl_depth_func(em_GL_LEQUAL)
			gl_blend_func(em_GL_ONE, em_GL_ONE)
			gl_bind_texture(em_gl_texture_2d, emissive_texture.id)
		end


	remove
			-- sets the blend function
		require else
			material_currently_used: material_in_gl_use
		do
			gl_pop_attrib
			material_in_gl_use := False
		end

invariant
	opacity_in_range: opacity >= 0.0 and opacity <= 1.0

end -- class TE_MATERIAL_COMPLEX

