indexing
	description: "Factory for moving drawables"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_3D_MOVING_FACTORY

feature -- Factory methods

	new_default_member (a_moving: TRAFFIC_MOVING): TRAFFIC_3D_MOVING_RENDERABLE [TRAFFIC_MOVING] is
			-- New man drawable
		require
			a_moving_exists: a_moving /= Void
		do
			if error_template = Void then
				error_template := load_template ("error.obj")
			end
			create Result.make (a_moving)
			Result.add_child (error_template.create_deep_instance)
			Result.transform.set_scaling (50, 50, 50)
		end

	new_free_moving_member (a_moving: TRAFFIC_FREE_MOVING): TRAFFIC_3D_MOVING_RENDERABLE [TRAFFIC_FREE_MOVING] is
			-- New man drawable
		require
			a_moving_exists: a_moving /= Void
		do
			if man_template = Void then
				man_template := load_template ("man.obj")
			end
			create Result.make (a_moving)
			Result.add_child (man_template.create_deep_instance)
			Result.transform.set_scaling (50, 50, 50)
		end

	new_person_member (a_passenger: TRAFFIC_PASSENGER): TRAFFIC_3D_MOVING_RENDERABLE [TRAFFIC_PASSENGER] is
			-- New person drawable (toggling between man and woman)
		require
			a_passenger_exists: a_passenger /= Void
		do
			if not is_woman then
				Result := new_man_member (a_passenger)
				is_woman := True
			else
				Result := new_woman_member (a_passenger)
				is_woman := False
			end
		end

	new_man_member (a_passenger: TRAFFIC_PASSENGER): TRAFFIC_3D_MOVING_RENDERABLE [TRAFFIC_PASSENGER] is
			-- New man drawable
		require
			a_passenger_exists: a_passenger /= Void
		do
			if man_template = Void then
				man_template := load_template ("man.obj")
			end
			create Result.make (a_passenger)
			Result.add_child (man_template.create_deep_instance)
			Result.transform.set_scaling (50, 50, 50)
		end

	new_woman_member (a_passenger: TRAFFIC_PASSENGER): TRAFFIC_3D_MOVING_RENDERABLE [TRAFFIC_PASSENGER] is
			-- New woman drawable
		require
			a_passenger_exists: a_passenger /= Void
		do
			if woman_template = Void then
				woman_template := load_template ("woman.obj")
			end
			create Result.make (a_passenger)
			Result.add_child (woman_template.create_deep_instance)
			Result.transform.set_scaling (50, 50, 50)
		end

	new_taxi_daynight_member (a_taxi: TRAFFIC_TAXI): TRAFFIC_3D_MOVING_DAYNIGHT_RENDERABLE [TRAFFIC_TAXI] is
			-- New taxi drawable with two representations
		require
			a_taxi_exists: a_taxi /= Void
		do
			if taxi_template = Void then
				taxi_template := load_template ("taxi.obj")
			end
			if taxi_night_template = Void then
				taxi_night_template := load_template ("taxi_night.obj")
			end
			create Result.make_with_item (a_taxi, taxi_template.create_deep_instance, taxi_night_template.create_deep_instance)
			Result.day_graphical.transform.set_scaling (50, 50, 50)
			Result.night_graphical.transform.set_scaling (50, 50, 50)
		end

	new_tram_daynight_member (a_tram: TRAFFIC_TRAM): TRAFFIC_3D_MOVING_DAYNIGHT_RENDERABLE [TRAFFIC_TRAM] is
			-- New taxi drawable with two representations
		require
			a_tram_exists: a_tram /= Void
		do
			if tram_template = Void then
				tram_template := load_template ("tram2000_small.obj")
			end
			if tram_night_template = Void then
				tram_night_template := load_template ("tram2000_small_night.obj")
			end
			create Result.make_with_item (a_tram, tram_template.create_deep_instance, tram_night_template.create_deep_instance)
			Result.day_graphical.transform.set_scaling (50, 50, 50)
			Result.night_graphical.transform.set_scaling (50, 50, 50)
		end

	new_bus_daynight_member (a_bus: TRAFFIC_BUS): TRAFFIC_3D_MOVING_DAYNIGHT_RENDERABLE [TRAFFIC_BUS] is
			-- New bus drawable with two representations
		require
			a_bus_exists: a_bus /= Void
		do
			if bus_template = Void then
				bus_template := load_template ("bus.obj")
			end
			if bus_night_template = Void then
				bus_night_template := load_template ("bus.obj")
			end
			create Result.make_with_item (a_bus, bus_template.create_deep_instance, bus_night_template.create_deep_instance)
--			Result.set_color (create {TRAFFIC_COLOR}.make_with_rgb (255, 0, 0))
			Result.day_graphical.transform.set_scaling (0.1, 0.1, 0.1)
			Result.night_graphical.transform.set_scaling (0.1, 0.1, 0.1)
		end

feature {NONE} -- Implementation

	taxi_template: TE_3D_NODE
			-- template to create a taxi traveler

	taxi_night_template: TE_3D_NODE
			-- template to create a taxi traveler

	tram_template: TE_3D_NODE
			-- template to create a tram traveler

	bus_template: TE_3D_NODE
			-- template to create a bus traveler

	bus_night_template: TE_3D_NODE
			-- template to create a bus traveler

	tram_night_template: TE_3D_NODE
			-- template to create a tram traveler

	man_template: TE_3D_NODE
			-- template to create a man traveler

	woman_template: TE_3D_NODE
			-- template to create a woman traveler

	error_template: TE_3D_NODE
			-- template which is returned when a wrong name is passed

	is_woman: BOOLEAN
			-- Toggle between man and woman (True: woman; False: man)

	load_template (a_file_name: STRING): TE_3D_NODE is
			-- load the traveler templates
		local
			fs: KL_FILE_SYSTEM
			s: STRING --path string
			scene_importer: TE_3D_SCENE_IMPORTER
		do
			fs := (create {KL_SHARED_FILE_SYSTEM}).file_system
			scene_importer := (create {TE_3D_SHARED_GLOBALS}).scene_importer

			s := fs.pathname ("..", "objects")
			s := fs.pathname (s, a_file_name)
			Result := scene_importer.import_3d_scene (s)
			Result.calculate_hierarchy_bounding_box
		end

end
