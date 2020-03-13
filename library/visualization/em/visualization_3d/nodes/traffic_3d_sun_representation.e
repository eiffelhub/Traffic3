indexing
	description: "A 3D Representation of the Sun and Sunlight"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_3D_SUN_REPRESENTATION

inherit
	EM_CONSTANTS
		 export {NONE} all end

	GL_FUNCTIONS
		export {NONE} all end

	GLU_FUNCTIONS
		export {NONE} all end

	MATH_CONST
		export {NONE} all end

	TRAFFIC_SHARED_TIME

	DOUBLE_MATH

	TE_3D_SHARED_GLOBALS

	TRAFFIC_CONSTANTS

create
	make

feature {NONE} -- Initialization

	make is
			-- Initialize `Current'.
		local
			fs: KL_FILE_SYSTEM
			s: STRING
		do
			-- Create the Sun Object and Sunlight
			create traffic_sun.make
			create traffic_sun_light.make_as_child(root);
			beauty_pass ?= (create{TE_3D_SHARED_GLOBALS}).renderpass_manager.renderpasses.i_th(1)
			beauty_pass.add_light_source (traffic_sun_light)


			-- Set Sunight values
			traffic_sun_light.set_diffuse_color (1.0, 1.0, 0.8, 1.0)
			traffic_sun_light.set_name ("sun_light")

			-- Create sun_model
			fs := (create {KL_SHARED_FILE_SYSTEM}).file_system
			s := fs.pathname ("..", "objects")
			s := fs.pathname (s, "sun.obj")
			sun_model := scene_importer.import_3d_scene(s)
			sun_model.set_as_child_of(root)
			sun_model.set_name("sun_model")

			create shadow_pass.make
			shadow_pass.set_shadow_light(traffic_sun_light)
			shadow_pass.set_camera(beauty_pass.camera)
			shadow_pass.disable
			renderpass_manager.add_renderpass(shadow_pass)

			create lensflare_pass.make
			lensflare_pass.set_camera(beauty_pass.camera)
			lensflare_pass.trace_3d_node(sun_model)
			renderpass_manager.add_renderpass (lensflare_pass)
			update
		ensure
			sun_model_created: sun_model /= Void
			sun_created: traffic_sun /= Void
			sun_light_created: traffic_sun_light /= Void
		end

feature -- Access

	traffic_sun_light: TE_3D_INFINITE_LIGHT
		-- The Sun Light

	shadows_enabled: BOOLEAN

	sun_model: TE_3D_NODE

	lensflare_pass: TE_RENDERPASS_LENSFLARE

	shadow_pass: TE_RENDERPASS_STENCILSHADOW

	beauty_pass: TE_RENDERPASS_BEAUTY

feature -- Status setting

	enable_sunlight is
			-- Enable the Sunlight.
		do
			traffic_sun_light.enable
		end

	disable_sunlight is
			-- Disable the Sunlight.
		do
			traffic_sun_light.disable
		end

	enable_shadows is
			-- enables shadows at day
		do
			shadows_enabled := true
			update
		end

	disable_shadows is
			-- does not enable shadows at day
		do
			shadows_enabled := false
			update
		end

feature -- Basic operations

	update is
			-- Draw the sun.
		local
			sun_pos, up_vector: EM_VECTOR3D
			normalized_angle, ambient_component, diffuse_B, diffuse_R: DOUBLE
		do
				sun_pos.set(traffic_sun.position.x,traffic_sun.position.y,traffic_sun.position.z)

				-- Set Lightposition
				traffic_sun_light.transform.set_position(sun_pos.x,sun_pos.y,sun_pos.z)
				sun_model.transform.set_position(sun_pos.x, sun_pos.y, sun_pos.z)
				-- Set ambient_Lightcolor
				up_vector.set(0.0,1.0,0.0)
				normalized_angle := (1.0-(2.0*arc_cosine(up_vector.dot_product(sun_pos)/sun_pos.length)/PI))
				ambient_component := normalized_angle*(sun_pos.y.sign+1.0).sign
				traffic_sun_light.set_ambient_color (ambient_component*0.7,ambient_component*0.73, ambient_component*0.8,1.0)
				-- Set diffuse_lightcolor
				diffuse_R := (1.0-(normalized_angle-1.0)^2.0)*(sun_pos.y.sign+1.0).sign
				diffuse_B := normalized_angle*(sun_pos.y.sign+1.0).sign
				traffic_sun_light.set_diffuse_color (diffuse_R*3.0, (diffuse_B+diffuse_R)*1.5, diffuse_B*2.4, 1.0)
				-- Set Background color
				beauty_pass.set_background_color(ambient_component*0.4+0.1, ambient_component*0.8+0.1, ambient_component*1.0+0.2)

				--activate/deactivate shadows at night/day
				if sun_pos.y > 0 and shadows_enabled then
					shadow_pass.enable
				else
					shadow_pass.disable
				end
		end


feature {NONE} -- Implementation

	traffic_sun: TRAFFIC_SUN
		-- The Sun Object
end
