indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TE_MATERIAL_FACTORY inherit

		EM_GL_CONSTANTS

feature -- Initialization

	make is
			-- creates the factory and sets initial values
		do
			create ambient_color.make_xyzt (0.2,0.2,0.2,1.0)
			create diffuse_color.make_xyzt (1.0,1.0,1.0,1.0)
			create specular_color.make_xyzt (1.0,1.0,1.0,1.0)
			create emissive_color.make_xyzt (0.0,0.0,0.0,1.0)
			create name.make_empty
			create shininess.make(0.0)
			create last_nametable.make (1)
			blend_source_func := em_gl_src_alpha
			blend_target_func := em_gl_one_minus_src_alpha
			opacity := 1.0
			frontside_visible := true
			render_type := em_gl_fill
			shading := em_gl_smooth
			min_filter := true
			mag_filter := true
		end


feature {NONE} -- Internal

	ambient_color: GL_VECTOR_4D[DOUBLE]

	diffuse_color: GL_VECTOR_4D[DOUBLE]

	specular_color: GL_VECTOR_4D[DOUBLE]

	emissive_color: GL_VECTOR_4D[DOUBLE]

	shininess: TE_GL_VALUE[DOUBLE] -- range from 0.0 to 128.0

	diffuse_texture: GL_TEXTURE

	emissive_texture: GL_TEXTURE

	blending: BOOLEAN

	blend_source_func: INTEGER

	blend_target_func: INTEGER

	alpha_testing: BOOLEAN

	opacity: DOUBLE

	frontside_visible: BOOLEAN -- CULLING MUST BE ENABLED OR false WILL TAKE NO EFFECT!

	backside_visible: BOOLEAN -- CULLING MUST BE ENABLED OR false WILL TAKE NO EFFECT!

	render_type: INTEGER -- may be em_gl_point, em_gl_line or em_gl_fill

	shading: INTEGER -- may be em_gl_flat or em_gl_smooth

	faceted: BOOLEAN

	min_filter: BOOLEAN

	mag_filter: BOOLEAN

	name: STRING

feature -- Access

	last_material_list: ARRAYED_LIST[TE_MATERIAL_COMPLEX]
			-- the last built materiallist

	last_nametable: HASH_TABLE[INTEGER,STRING]
			-- hastable to get the index for the last_materia_list of the name of a material

feature -- Status report

feature -- Status setting

	set_ambient_color(r,g,b: DOUBLE) is
			-- sets ambient color
		do
			ambient_color.set_xyzt(r,g,b,1.0)
		end

	set_diffuse_color(r,g,b: DOUBLE) is
			-- sets ambient color
		do
			diffuse_color.set_xyzt(r,g,b,1.0)
		end

	set_specular_color(r,g,b: DOUBLE) is
			-- sets ambient color
		do
			specular_color.set_xyzt(r,g,b,1.0)
		end

	set_emissive_color(r,g,b: DOUBLE) is
			-- sets ambient color
		do
			emissive_color.set_xyzt(r,g,b,1.0)
		end

	set_shininess(a_value:DOUBLE) is
			-- sets the shininess value
		require
			value_is_in_range: a_value >= 0.0 and a_value <= 128.0
		do
			shininess.set_value(a_value)
		end

	set_diffuse_texture(a_texture:GL_TEXTURE) is
			-- sets the diffuse texture to be used as texture
		require
			texture_not_void: a_texture /= Void
		do
			diffuse_texture := a_texture
		end

	set_emissive_texture(a_texture:GL_TEXTURE) is
			-- sets the emissive texture to be used as texture
		require
			texture_not_void: a_texture /= Void
		do
			emissive_texture := a_texture
		end


	enable_blending is
			-- enables blending
		do
			blending := true
		end

	disable_blending is
			-- disables blending
		do
			blending := false
		end

	set_blend_func(sf, tf: INTEGER) is
			-- sets the blend function
		require
			valid_parameters: (sf=em_gl_zero or sf=em_gl_one or sf=em_gl_dst_color or sf=em_gl_one_minus_dst_color or sf=em_gl_src_alpha or sf=em_gl_one_minus_src_alpha or sf=em_gl_src_color or sf=em_gl_one_minus_src_color or sf=em_gl_dst_alpha or sf=em_gl_one_minus_dst_alpha or sf=em_gl_src_alpha_saturate) and (tf=em_gl_zero or tf=em_gl_one or tf=em_gl_dst_color or tf=em_gl_one_minus_dst_color or tf=em_gl_src_alpha or tf=em_gl_one_minus_src_alpha or tf=em_gl_src_color or tf=em_gl_one_minus_src_color or tf=em_gl_dst_alpha or tf=em_gl_one_minus_dst_alpha or tf=em_gl_src_alpha_saturate)
		do
			blend_source_func := sf
			blend_target_func := tf
		end

	enable_alpha_testing is
			-- enables alpha_testing
		do
			alpha_testing := true
		end

	disable_alpha_testing is
			-- disables alpha_testing
		do
			alpha_testing := false
		end

	set_opacity(new_opacity:DOUBLE) is
			-- sets opacity value -- ENABLE BLENDING WITH PROPPER SOURCE AND TARGET BLEND FUNCTIONS TO LET OPACITY TAKE EFFECT!!
		require
			opacity_in_range: new_opacity >= 0.0 and new_opacity <= 1.0
		do

		end

	set_visibility(front,back:BOOLEAN) is
			-- sets the front and backface visibility
		require
			one_face_visible: front=true or back=true
		do
			frontside_visible := front
			backside_visible := back
		end

	set_render_type (a_render_type: INTEGER) is
			-- sets the render type
		require
			valid_render_type: a_render_type = em_gl_point or a_render_type = em_gl_line or a_render_type = em_gl_fill
		do
			render_type := a_render_type
		end

	enable_shading is
			-- enables smooth shading
		do
			shading := em_gl_smooth
		end

	disable_shading is
			-- sets shading to flat
		do
			shading := em_gl_flat
		end

	enable_faceted is
			-- enables facetted rendering
		do
			faceted := true
		end

	disable_faceted is
			-- disables facetted rendering
		do
			faceted := false
		end

	set_texture_filtering(min,mag:BOOLEAN) is
			-- sets texture filtering
		do
			min_filter := min
			mag_filter := mag
		end

	set_name(a_name: STRING) is
			-- sets the name of the material
		do
			name := a_name
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

	reset_settings_to_default is
			-- resets settings to default values
		do
			ambient_color.set_xyzt (0.2,0.2,0.2,1.0)
			diffuse_color.set_xyzt (1.0,1.0,1.0,1.0)
			specular_color.set_xyzt (1.0,1.0,1.0,1.0)
			emissive_color.set_xyzt (0.0,0.0,0.0,1.0)
			name := ""
			shininess.set_value(0.0)
			opacity := 1.0
			frontside_visible := true
			backside_visible := false
			diffuse_texture := Void
			emissive_texture := Void
			alpha_testing := false
			blending := false
			blend_source_func := em_gl_src_alpha
			blend_target_func := em_gl_one_minus_src_alpha
			render_type := em_gl_fill
			shading := em_gl_smooth
			min_filter := true
			mag_filter := true
			faceted := false
		end




feature -- Obsolete

feature -- Inapplicable

feature {NONE} -- Implementation

	clear is
			-- clears the list in last_material_list as well as the hastable
		local
			empty_list: ARRAYED_LIST[TE_MATERIAL_COMPLEX]
			empty_hashtable: HASH_TABLE[INTEGER,STRING]
		do
			create empty_list.make(1)
			last_material_list := empty_list
			create empty_hashtable.make(1)
			last_nametable := empty_hashtable
		end


	build_and_push_material is
			-- builds the material from the currently set settings and pushes it to the end of the last_material_list and updates the hashtable
		local
			new_material: TE_MATERIAL_COMPLEX
		do
			create new_material.make

			new_material.set_ambient_color(ambient_color.x, ambient_color.y, ambient_color.z)
			new_material.set_diffuse_color(diffuse_color.x, diffuse_color.y, diffuse_color.z)
			new_material.set_specular_color(specular_color.x, specular_color.y, specular_color.z)
			new_material.set_emissive_color(emissive_color.x, emissive_color.y, emissive_color.z)
			new_material.set_shininess(shininess.value)

			if diffuse_texture /= Void then
				new_material.set_diffuse_texture(diffuse_texture)
			end
			if emissive_texture /= Void then
				new_material.set_emissive_pass(emissive_texture)
			end
			if blending then
				new_material.enable_blending
				new_material.set_blend_func(blend_source_func, blend_target_func)
			end
			if alpha_testing then
				new_material.enable_alpha_testing
			end
			new_material.set_visibility(frontside_visible, backside_visible)
			new_material.set_render_type (render_type)
			if shading = em_gl_flat then
				new_material.disable_shading
			end
			if faceted then
				new_material.enable_faceted
			end
			new_material.set_texture_filtering(min_filter, mag_filter)
			new_material.set_name(name.twin)

			last_material_list.extend(new_material)
			last_nametable.put(last_material_list.count, name.twin)

			-- Reset values to default
			reset_settings_to_default
		end


invariant
	opacity_in_range: opacity >= 0.0 and opacity <= 1.0
end
