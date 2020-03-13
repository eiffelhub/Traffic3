indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TE_3D_LIGHT_SOURCE inherit

		TE_3D_NODE
		redefine
			make, make_as_child
		end

		GL_FUNCTIONS export {NONE} all end

		EM_GL_CONSTANTS export {NONE} all end

feature -- Initialization

	make is
			-- creates the lightsource with defined color and intensity
		do
			Precursor
			create diffuse_color.make_xyzt(1.0,1.0,1.0,0.0)
			create specular_color.make_xyzt(1.0,1.0,1.0,0.0)
			create ambient_color.make_xyzt(0.0,0.0,0.0,1.0)
			reset_to_defaults
		end

	make_as_child(a_parent: TE_3D_NODE) is
			-- creates the lightsource with defined color and intensity and makes it child of a_parent
		do
			Precursor(a_parent)
			create diffuse_color.make_xyzt(1.0,1.0,1.0,0.0)
			create specular_color.make_xyzt(1.0,1.0,1.0,0.0)
			create ambient_color.make_xyzt(0.0,0.0,0.0,1.0)
			reset_to_defaults
		end


feature -- Access

	specular: BOOLEAN
		-- does the lightsource cause specular highlights?

	diffuse: BOOLEAN
		-- does the lightsource cause diffuse lighting?

	movable: BOOLEAN
		-- if this is true, the position gets updated every frame. disable it for static lightsources to improve performance

	intensity: REAL
		-- intensity of the lightsource

	diffuse_color: GL_VECTOR_4D[REAL]
		-- color of the light for diffuse lighting

	specular_color: GL_VECTOR_4D[REAL]
		-- color of the light for specular highlights

	ambient_color: GL_VECTOR_4D[REAL]
		-- color of the light for ambient color

	light_position: GL_VECTOR_4D[REAL] is
		-- returns the position of the node as GL_VECTOR_4D with the last component either 0.0 or 1.0 - 0.0 being an infinite (direct) light and 1.0 a position light
		deferred
		end

feature -- Status report

	enabled: BOOLEAN
		-- is the light enabled

	--color_or_intensity_has_changed: BOOLEAN
			-- indicates wether the diffuse_color or the intensity of the lightsource has changed since the last gl update

	--other_parameter_has_changed: BOOLEAN
			-- indicates wether a parameter other than diffuse_color, intensity or position of the lightsource has changed since the last gl update

feature -- Status setting

	enable is
			-- enables the lightsource
		do
			enabled := true
		end

	disable is
			-- disables the lightsource
		do
			enabled := false
		end


	reset_to_defaults is
			-- resets settings to default values
		do
			enabled := true
			specular := true
			diffuse := true
			movable := true
			intensity := 1.0
			set_diffuse_color(1.0,1.0,1.0,1.0)
			set_specular_color(1.0,1.0,1.0,1.0)
			set_ambient_color(0.0,0.0,0.0,1.0)
		end

	enable_movable is
			-- sets movable to true - the position of the lightsource will be updated if it's position in space changes
		do
			movable := true
		end

	disable_movable is
			-- sets movable to false - slightly better performance, but the lightdirection won't be updated
		do
			movable := false
		end

	set_diffuse_color(r,g,b,a: DOUBLE) is
			-- sets diffuse_color
		do
			diffuse_color.set_xyzt(r,g,b,a)
			--color_or_intensity_has_changed := true	
		end

	set_specular_color(r,g,b,a: DOUBLE) is
			-- sets diffuse_color
		do
			specular_color.set_xyzt(r,g,b,a)
			--other_parameter_has_changed := true
		end

	set_ambient_color(r,g,b,a: DOUBLE) is
			-- sets diffuse_color
		do
			ambient_color.set_xyzt(r,g,b,a)
			--other_parameter_has_changed := true
		end

	set_intensity(new_intensity: DOUBLE) is
			-- sets intensity
		do
			intensity := new_intensity
			--other_parameter_has_changed := true
		end


feature {TE_RENDERPASS} -- Basic operations

	specify(id: INTEGER) is
			-- specifies the lightsettings. MUST BE CALLED WHEN THE MODELVIEW MATRIX IS IN ROOT SPACE! I.E. BEFORE THE HIERARCHY GETS DRAWN!
		require
			id_is_valid: id >=0 and id <8
			is_in_hierarchy: parent /= Void
		local
			global_ambient: GL_VECTOR_4D [REAL]
		do
			create global_ambient.make_xyzt (0.25, 0.25, 0.25, 1.0)
			gl_light_modelfv (em_gl_light_model_ambient, global_ambient.pointer)
			--if movable then
				update_position(id)
			--end
			--if color_or_intensity_has_changed then
				update_color_and_intensity(id)
				--color_or_intensity_has_changed := false
			--end
			--if other_parameter_has_changed then
				update_other_parameters(id)
				--other_parameter_has_changed := false
			--end
		end

feature {NONE} -- Implementation

	update_position(id:INTEGER) is
			-- updates the openGL position of the lightsource
		require
			id_is_valid: id >=0 and id <8
		do
			gl_lightfv(em_GL_LIGHT0 + id, em_GL_POSITION, light_position.pointer)
		end

	update_color_and_intensity(id:INTEGER) is
			-- updates the openGL diffuse_color and constant_attenuation of the lightsource
		require
			id_is_valid: id >=0 and id <8
		do
			gl_lightfv(em_GL_LIGHT0 + id, em_GL_DIFFUSE, diffuse_color.pointer)
		--gl_lightf(em_GL_LIGHT0 + id, em_GL_CONSTANT_ATTENUATION, intensity)
		end

	update_other_parameters(id:INTEGER) is
			-- updates other openGL lightspecific parameters of the lightsource
		require
			id_is_valid: id >=0 and id <8
		do
			gl_lightfv(em_GL_LIGHT0 + id, em_GL_AMBIENT, ambient_color.pointer)
			gl_lightfv(em_GL_LIGHT0 + id, em_GL_SPECULAR, specular_color.pointer)
		end

end
