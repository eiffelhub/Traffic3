note
	description: "Factory for vision2 city item views"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_VS_VIEW_FACTORY

inherit

	TRAFFIC_VIEW_FACTORY

	KL_SHARED_FILE_SYSTEM

feature -- Factory methods

	new_station_view (a_station: TRAFFIC_STATION): TRAFFIC_STATION_VIEW  
			-- New station view for `a_station'
		do
			create Result.make (a_station)
		end

	new_line_view (a_line: TRAFFIC_LINE): TRAFFIC_LINE_VIEW
			-- New line view for `a_line'
		do
			create Result.make (a_line)
			if a_line.color /= Void then
				Result.set_color (create {TRAFFIC_COLOR}.make_with_rgb (a_line.color.red, a_line.color.green, a_line.color.blue))
			end
		end

	new_road_view (a_road: TRAFFIC_ROAD): TRAFFIC_ROAD_VIEW
			-- New road view for `a_road'
		do
			create Result.make (a_road)
			Result.set_width (10)
		end

	new_route_view (a_route: TRAFFIC_ROUTE): TRAFFIC_ROUTE_VIEW
			-- New route view for `a_route'
		do
			create Result.make (a_route)
		end

	new_building_view (a_building: TRAFFIC_BUILDING): TRAFFIC_BUILDING_VIEW
			-- New building view for `a_building'
		local
			l: TRAFFIC_LANDMARK
		do
			if not a_building.is_landmark then
				create {TRAFFIC_BUILDING_SIMPLE_VIEW} Result.make (a_building)
			else
				l ?= a_building
				create {TRAFFIC_BUILDING_ICON_VIEW} Result.make_with_filename (a_building, l.filename)
			end
		end

	new_tram_view (a_tram: TRAFFIC_TRAM): TRAFFIC_MOVING_ICON_VIEW [TRAFFIC_TRAM]
			-- New tram view for `a_tram'
		do
			create Result.make_with_pix (a_tram, tram_pix)
			Result.set_color (create {TRAFFIC_COLOR}.make_with_rgb (40, 30, 230))
		end

	new_bus_view (a_bus: TRAFFIC_BUS): TRAFFIC_MOVING_ICON_VIEW [TRAFFIC_BUS]
			-- New bus view for `a_bus'
		do
			create Result.make_with_pix (a_bus, bus_pix)
			Result.set_color (create {TRAFFIC_COLOR}.make_with_rgb (40, 30, 230))
		end

	new_taxi_view (a_taxi: TRAFFIC_TAXI): TRAFFIC_MOVING_ICON_VIEW [TRAFFIC_TAXI]
			-- New taxi view for `a_taxi'
		do
			create Result.make_with_pix (a_taxi, taxi_pix)
			Result.set_color (create {TRAFFIC_COLOR}.make_with_rgb (40, 30, 230))
		end

	new_passenger_view (a_passenger: TRAFFIC_PASSENGER): TRAFFIC_MOVING_ICON_VIEW [TRAFFIC_PASSENGER]
			-- New passenger view for `a_passenger'
		do
			create Result.make_with_pix (a_passenger, passenger_pix)
			Result.set_color (create {TRAFFIC_COLOR}.make_with_rgb (140, 200, 225))
		end

	new_free_moving_view (a_free_moving: TRAFFIC_FREE_MOVING): TRAFFIC_MOVING_ICON_VIEW [TRAFFIC_FREE_MOVING]
			-- New free_moving view for `free_moving'
		do
			create Result.make_with_pix (a_free_moving, free_moving_pix)
			Result.set_color (create {TRAFFIC_COLOR}.make_with_rgb (40, 30, 230))
		end

feature {NONE} -- Implementation

	free_moving_pix: EV_PIXMAP
			-- Shared pixmap
		once
			create Result
			Result.set_with_named_file (File_system.absolute_pathname (File_system.pathname_from_file_system ("..\image\free_moving.png", Windows_file_system)))
		end

	passenger_pix: EV_PIXMAP
			-- Shared pixmap
		once
			create Result
			Result.set_with_named_file (File_system.absolute_pathname (File_system.pathname_from_file_system ("..\image\man.png", Windows_file_system)))
		end

	taxi_pix: EV_PIXMAP
			-- Shared pixmap
		once
			create Result
			Result.set_with_named_file (File_system.absolute_pathname (File_system.pathname_from_file_system ("..\image\taxi.png", Windows_file_system)))
		end

	bus_pix: EV_PIXMAP
			-- Shared pixmap
		once
			create Result
			Result.set_with_named_file (File_system.absolute_pathname (File_system.pathname_from_file_system ("..\image\bus.png", Windows_file_system)))
		end

	tram_pix: EV_PIXMAP
			-- Shared pixmap
		once
			create Result
			Result.set_with_named_file (File_system.absolute_pathname (File_system.pathname_from_file_system ("..\image\tram.png", Windows_file_system)))
		end

end
