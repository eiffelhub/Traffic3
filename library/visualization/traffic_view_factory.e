indexing
	description: "Factory for city item views"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TRAFFIC_VIEW_FACTORY

feature -- Factory methods

	new_station_view (a_station: TRAFFIC_STATION): TRAFFIC_VIEW [TRAFFIC_STATION] is
			-- New station view for `a_station'
		require
			a_station_exists: a_station /= Void
		deferred
		ensure
			Result_exists: Result /= Void
		end

	new_route_view (a_route: TRAFFIC_ROUTE): TRAFFIC_VIEW [TRAFFIC_ROUTE] is
			-- New route view for `a_route'
		require
			a_route_exists: a_route /= Void
		deferred
		ensure
			Result_exists: Result /= Void
		end

	new_line_view (a_line: TRAFFIC_LINE): TRAFFIC_VIEW [TRAFFIC_LINE] is
			-- New line segment view for `a_segment'
		require
			a_line_exists: a_line /= Void
		deferred
		ensure
			Result_exists: Result /= Void
		end

	new_road_view (a_road: TRAFFIC_ROAD): TRAFFIC_VIEW [TRAFFIC_ROAD] is
			-- New road view for `a_road'
		require
			a_road_exists: a_road /= Void
		deferred
		ensure
			Result_exists: Result /= Void
		end

	new_building_view (a_building: TRAFFIC_BUILDING): TRAFFIC_VIEW [TRAFFIC_BUILDING] is
			-- New building view for `a_building'
		require
			a_building_exists: a_building /= Void
		deferred
		ensure
			Result_exists: Result /= Void
		end

	new_tram_view (a_tram: TRAFFIC_TRAM): TRAFFIC_VIEW [TRAFFIC_TRAM] is
			-- New tram view for `a_tram'
		require
			a_tram_exists: a_tram /= Void
		deferred
		ensure
			Result_exists: Result /= Void
		end

	new_bus_view (a_bus: TRAFFIC_BUS): TRAFFIC_VIEW [TRAFFIC_BUS] is
			-- New bus view for `a_bus'
		require
			a_bus_exists: a_bus /= Void
		deferred
		ensure
			Result_exists: Result /= Void
		end

	new_taxi_view (a_taxi: TRAFFIC_TAXI): TRAFFIC_VIEW [TRAFFIC_TAXI] is
			-- New taxi view for `a_taxi'
		require
			a_taxi_exists: a_taxi /= Void
		deferred
		ensure
			Result_exists: Result /= Void
		end

	new_passenger_view (a_passenger: TRAFFIC_PASSENGER): TRAFFIC_VIEW [TRAFFIC_PASSENGER] is
			-- New passenger view for `a_passenger'
		require
			a_passenger_exists: a_passenger /= Void
		deferred
		ensure
			Result_exists: Result /= Void
		end

	new_free_moving_view (a_free_moving: TRAFFIC_FREE_MOVING): TRAFFIC_VIEW [TRAFFIC_FREE_MOVING] is
			-- New free_moving view for `free_moving'
		require
			a_free_moving_exists: a_free_moving /= Void
		deferred
		ensure
			Result_exists: Result /= Void
		end

end
