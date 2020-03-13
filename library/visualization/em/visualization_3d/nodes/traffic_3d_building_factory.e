indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_3D_BUILDING_FACTORY

feature -- Factory methods

	new_villa_member (a_building: TRAFFIC_BUILDING): TRAFFIC_3D_DAYNIGHT_RENDERABLE [TRAFFIC_BUILDING] is
			-- New villa drawable
		require
			a_building_exists: a_building /= Void
		do
			if is_blue then
				Result := new_blue_villa_member (a_building)
				is_blue := False
			else
				Result := new_brown_villa_member (a_building)
				is_blue := True
			end
		end

	new_blue_villa_member (a_building: TRAFFIC_BUILDING): TRAFFIC_3D_DAYNIGHT_RENDERABLE [TRAFFIC_BUILDING] is
			-- New villa drawable
		require
			a_building_exists: a_building /= Void
		local
			bb: ARRAYED_LIST[EM_VECTOR3D]
			w, d, h: DOUBLE
		do
			if villa_blue_template = Void then
				villa_blue_template := load_template ("villa_blue.obj")
			end
			if villa_blue_night_template = Void then
				villa_blue_night_template := load_template ("villa_blue_night.obj")
			end
			create Result.make_with_item (a_building, villa_blue_template.create_deep_instance, villa_blue_night_template.create_deep_instance)
			Result.transform.set_position (a_building.center.x, 0, a_building.center.y)
			bb := Result.day_graphical.hierarchy_bounding_box
			w := (bb.i_th (1).x - bb.i_th (3).x).abs
			d := (bb.i_th (1).z - bb.i_th (3).z).abs
			h := (bb.i_th (1).y - bb.i_th (5).y).abs
			Result.day_graphical.transform.set_scaling (a_building.width/w, a_building.depth/d, a_building.height/h)
			Result.night_graphical.transform.set_scaling (a_building.width/w, a_building.depth/d, a_building.height/h)
		end

	new_brown_villa_member (a_building: TRAFFIC_BUILDING): TRAFFIC_3D_DAYNIGHT_RENDERABLE [TRAFFIC_BUILDING] is
			-- New villa drawable
		require
			a_building_exists: a_building /= Void
		local
			bb: ARRAYED_LIST[EM_VECTOR3D]
			w, d, h: DOUBLE
		do
			if villa_brown_template = Void then
				villa_brown_template := load_template ("villa_brown.obj")
			end
			if villa_brown_night_template = Void then
				villa_brown_night_template := load_template ("villa_brown_night.obj")
			end
			create Result.make_with_item (a_building, villa_brown_template.create_deep_instance, villa_brown_night_template.create_deep_instance)
			Result.transform.set_position (a_building.center.x, 0, a_building.center.y)
			bb := Result.day_graphical.hierarchy_bounding_box
			w := (bb.i_th (1).x - bb.i_th (3).x).abs
			d := (bb.i_th (1).z - bb.i_th (3).z).abs
			h := (bb.i_th (1).y - bb.i_th (5).y).abs
			Result.day_graphical.transform.set_scaling (a_building.width/w, a_building.depth/d, a_building.height/h)
			Result.night_graphical.transform.set_scaling (a_building.width/w, a_building.depth/d, a_building.height/h)
		end

	new_apartment_building_member (a_building: TRAFFIC_BUILDING): TRAFFIC_3D_DAYNIGHT_RENDERABLE [TRAFFIC_BUILDING] is
			-- New apartment building drawable
		require
			a_building_exists: a_building /= Void
		local
			bb: ARRAYED_LIST[EM_VECTOR3D]
			w, d, h: DOUBLE
		do
			if apartment_building_template = Void then
				apartment_building_template := load_template ("apartment_building.obj")
			end
			if apartment_building_night_template = Void then
				apartment_building_night_template := load_template ("apartment_building_night.obj")
			end
			create Result.make_with_item (a_building, apartment_building_template.create_deep_instance, apartment_building_night_template.create_deep_instance)
			Result.transform.set_position (a_building.center.x, 0, a_building.center.y)
			bb := Result.day_graphical.hierarchy_bounding_box
			w := (bb.i_th (1).x - bb.i_th (3).x).abs
			d := (bb.i_th (1).z - bb.i_th (3).z).abs
			h := (bb.i_th (1).y - bb.i_th (5).y).abs
			Result.day_graphical.transform.set_scaling (a_building.width/w, a_building.depth/d, a_building.height/h)
			Result.night_graphical.transform.set_scaling (a_building.width/w, a_building.depth/d, a_building.height/h)
		end

	new_skyscraper_member (a_building: TRAFFIC_BUILDING): TRAFFIC_3D_DAYNIGHT_RENDERABLE [TRAFFIC_BUILDING] is
			-- New skyscraper drawable
		require
			a_building_exists: a_building /= Void
		local
			bb: ARRAYED_LIST[EM_VECTOR3D]
			w, d, h: DOUBLE
		do
			if skyscraper_template = Void then
				skyscraper_template := load_template ("skyscraper.obj")
			end
			if skyscraper_night_template = Void then
				skyscraper_night_template := load_template ("skyscraper_night.obj")
			end
			create Result.make_with_item (a_building, skyscraper_template.create_deep_instance, skyscraper_night_template.create_deep_instance)
			Result.transform.set_position (a_building.center.x, 0, a_building.center.y)
			bb := Result.day_graphical.hierarchy_bounding_box
			w := (bb.i_th (1).x - bb.i_th (3).x).abs
			d := (bb.i_th (1).z - bb.i_th (3).z).abs
			h := (bb.i_th (1).y - bb.i_th (5).y).abs
			Result.day_graphical.transform.set_scaling (a_building.width/w, a_building.depth/d, a_building.height/h)
			Result.night_graphical.transform.set_scaling (a_building.width/w, a_building.depth/d, a_building.height/h)
		end

--	new_free_moving_member (a_moving: TRAFFIC_FREE_MOVING): TRAFFIC_3D_MOVING_RENDERABLE [TRAFFIC_FREE_MOVING] is
--			-- New man drawable
--		do
--			if man_template = Void then
--				man_template := load_template ("man.obj")
--			end
--			create Result.make_with_item (a_moving, man_template.create_deep_instance)
--			Result.graphical.transform.set_scaling (50, 50, 50)
--			Result.set_color (create {EM_COLOR}.make_with_rgb (0, 255, 0))
--		end

--	new_person_member (a_passenger: TRAFFIC_PASSENGER): TRAFFIC_3D_MOVING_RENDERABLE [TRAFFIC_PASSENGER] is
--			-- New person drawable (toggling between man and woman)
--		do
--			if not is_woman then
--				Result := new_man_member (a_passenger)
--				is_woman := True
--			else
--				Result := new_woman_member (a_passenger)
--				is_woman := False
--			end
--		end

--	new_man_member (a_passenger: TRAFFIC_PASSENGER): TRAFFIC_3D_MOVING_RENDERABLE [TRAFFIC_PASSENGER] is
--			-- New man drawable
--		do
--			if man_template = Void then
--				man_template := load_template ("man.obj")
--			end
--			create Result.make_with_item (a_passenger, man_template.create_deep_instance)
--			Result.graphical.transform.set_scaling (50, 50, 50)
--		end

--	new_woman_member (a_passenger: TRAFFIC_PASSENGER): TRAFFIC_3D_MOVING_RENDERABLE [TRAFFIC_PASSENGER] is
--			-- New woman drawable
--		do
--			if woman_template = Void then
--				woman_template := load_template ("woman.obj")
--			end
--			create Result.make_with_item (a_passenger, woman_template.create_deep_instance)
--			Result.graphical.transform.set_scaling (50, 50, 50)
--		end

--	new_taxi_daynight_member (a_taxi: TRAFFIC_TAXI): TRAFFIC_3D_MOVING_DAYNIGHT_RENDERABLE [TRAFFIC_TAXI] is
--			-- New taxi drawable with two representations
--		do
--			if taxi_template = Void then
--				taxi_template := load_template ("taxi.obj")
--			end
--			if taxi_night_template = Void then
--				taxi_night_template := load_template ("taxi_night.obj")
--			end
--			create Result.make_with_item (a_taxi, taxi_template.create_deep_instance, taxi_night_template.create_deep_instance)
--			Result.day_graphical.transform.set_scaling (50, 50, 50)
--			Result.night_graphical.transform.set_scaling (50, 50, 50)
--		end

--	new_tram_daynight_member (a_tram: TRAFFIC_TRAM): TRAFFIC_3D_MOVING_DAYNIGHT_RENDERABLE [TRAFFIC_TRAM] is
--			-- New taxi drawable with two representations
--		do
--			if tram_template = Void then
--				tram_template := load_template ("tram2000_small.obj")
--			end
--			if tram_night_template = Void then
--				tram_night_template := load_template ("tram2000_small_night.obj")
--			end
--			create Result.make_with_item (a_tram, tram_template.create_deep_instance, tram_night_template.create_deep_instance)
--			Result.day_graphical.transform.set_scaling (50, 50, 50)
--			Result.night_graphical.transform.set_scaling (50, 50, 50)
--		end

--	new_bus_daynight_member (a_bus: TRAFFIC_BUS): TRAFFIC_3D_MOVING_DAYNIGHT_RENDERABLE [TRAFFIC_BUS] is
--			-- New bus drawable with two representations
--		do
--			if tram_template = Void then
--				tram_template := load_template ("tram2000_small.obj")
--			end
--			if tram_night_template = Void then
--				tram_night_template := load_template ("tram2000_small_night.obj")
--			end
--			create Result.make_with_item (a_bus, tram_template.create_deep_instance, tram_night_template.create_deep_instance)
--			Result.set_color (create {EM_COLOR}.make_with_rgb (255, 0, 0))
--			Result.day_graphical.transform.set_scaling (50, 50, 50)
--			Result.night_graphical.transform.set_scaling (50, 50, 50)
--		end

feature {NONE} -- Implementation

	villa_brown_template: TE_3D_NODE
			-- Template for brown villa

	villa_brown_night_template: TE_3D_NODE
			-- Template for brown villa at night

	villa_blue_template: TE_3D_NODE
			-- Template for blue villa

	villa_blue_night_template: TE_3D_NODE
			-- Template for blue villa at night

	apartment_building_template: TE_3D_NODE
			-- Template for apartment building

	apartment_building_night_template: TE_3D_NODE
			-- Template for apartment building at night

	skyscraper_template: TE_3D_NODE
			-- Template for skyscraper

	skyscraper_night_template: TE_3D_NODE
			-- Template for skyscraper at night

	is_blue: BOOLEAN
			-- Toggle between blue and brown villa

	load_template (a_file_name: STRING): TE_3D_NODE is
			-- load the traveler templates
		local
			fs: KL_FILE_SYSTEM
			s: STRING --path string
			scene_importer: TE_3D_SCENE_IMPORTER
		do
			fs := (create {KL_SHARED_FILE_SYSTEM}).file_system
			scene_importer := (create {TE_3D_SHARED_GLOBALS}).scene_importer

			s := fs.pathname ("..", "buildings")
			s := fs.pathname (s, a_file_name)
			Result := scene_importer.import_3d_scene (s)
			Result.calculate_hierarchy_bounding_box
		end

end
