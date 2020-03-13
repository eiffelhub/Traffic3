indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_2D_VIEW_FACTORY

inherit

	TRAFFIC_VIEW_FACTORY

feature -- Factory methods

	new_place_view (a_place: TRAFFIC_PLACE): TRAFFIC_VIEW [TRAFFIC_PLACE] is
			-- New place view for `a_place'
		do
			create {TRAFFIC_2D_PLACE_VIEW} Result.make (a_place)
		end

	new_path_view (a_path: TRAFFIC_PATH): TRAFFIC_VIEW [TRAFFIC_PATH] is
			-- New path view for `a_path'
		do
			create {TRAFFIC_2D_PATH_VIEW} Result.make (a_path)
		end

	new_line_view (a_line: TRAFFIC_LINE): TRAFFIC_VIEW [TRAFFIC_LINE] is
			-- New line view for `a_line'
		do
			create {TRAFFIC_2D_LINE_VIEW} Result.make (a_line)
		end

	new_road_view (a_road: TRAFFIC_ROAD): TRAFFIC_VIEW [TRAFFIC_ROAD] is
			-- New road view for `a_road'
		do
			create {TRAFFIC_2D_ROAD_VIEW} Result.make (a_road)
		end

	new_building_view (a_building: TRAFFIC_BUILDING): TRAFFIC_VIEW [TRAFFIC_BUILDING] is
			-- New building view for `a_building'
		do
			create {TRAFFIC_2D_BUILDING_VIEW} Result.make (a_building)
		end

	new_tram_view (a_tram: TRAFFIC_TRAM): TRAFFIC_VIEW [TRAFFIC_TRAM] is
			-- New tram view for `a_tram'
		do
			create {TRAFFIC_2D_MOVING_VIEW [TRAFFIC_TRAM]} Result.make (a_tram)
			Result.set_color (create {TRAFFIC_COLOR}.make_with_rgb (0, 0, 180))
		end

	new_bus_view (a_bus: TRAFFIC_BUS): TRAFFIC_VIEW [TRAFFIC_BUS] is
			-- New bus view for `a_bus'
		do
			create {TRAFFIC_2D_MOVING_VIEW [TRAFFIC_BUS]} Result.make (a_bus)
			Result.set_color (create {TRAFFIC_COLOR}.make_with_rgb (230, 130, 25))
		end

	new_taxi_view (a_taxi: TRAFFIC_TAXI): TRAFFIC_VIEW [TRAFFIC_TAXI] is
			-- New taxi view for `a_taxi'
		do
			create {TRAFFIC_2D_MOVING_VIEW [TRAFFIC_TAXI]} Result.make (a_taxi)
			Result.set_color (create {TRAFFIC_COLOR}.make_with_rgb (255, 255, 0))
		end

	new_passenger_view (a_passenger: TRAFFIC_PASSENGER): TRAFFIC_VIEW [TRAFFIC_PASSENGER] is
			-- New passenger view for `a_passenger'
		do
			create {TRAFFIC_2D_MOVING_VIEW [TRAFFIC_PASSENGER]} Result.make (a_passenger)
			Result.set_color (create {TRAFFIC_COLOR}.make_with_rgb (130, 255, 255))
		end

	new_free_moving_view (a_free_moving: TRAFFIC_FREE_MOVING): TRAFFIC_VIEW [TRAFFIC_FREE_MOVING] is
			-- New free_moving view for `free_moving'
		do
			create {TRAFFIC_2D_MOVING_VIEW [TRAFFIC_FREE_MOVING]} Result.make (a_free_moving)
			Result.set_color (create {TRAFFIC_COLOR}.make_with_rgb (0, 255, 0))
		end

end
