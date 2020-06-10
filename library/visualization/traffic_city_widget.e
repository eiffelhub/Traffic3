note
	description: "Widgets that display a city"
	date: "$Date$"
	revision: "$Revision$"

deferred class TRAFFIC_CITY_WIDGET

feature -- Access

	city: TRAFFIC_CITY
			-- City that is displayed

	factory: TRAFFIC_VIEW_FACTORY
			-- Factory for creating views
		deferred
		end

	line_representations:  TRAFFIC_VIEW_CONTAINER [TRAFFIC_LINE, TRAFFIC_VIEW [TRAFFIC_LINE]]
			-- Container for line segment views
		deferred
		end

	road_representations:  TRAFFIC_VIEW_CONTAINER [TRAFFIC_ROAD, TRAFFIC_VIEW [TRAFFIC_ROAD]]
			-- Container for road segment views
		deferred
		end

	station_representations: TRAFFIC_VIEW_CONTAINER [TRAFFIC_STATION, TRAFFIC_VIEW [TRAFFIC_STATION]]
			-- Container for station views
		deferred
		end

	building_representations: TRAFFIC_VIEW_CONTAINER [TRAFFIC_BUILDING, TRAFFIC_VIEW [TRAFFIC_BUILDING]]
			-- Container for building views
		deferred
		end

	moving_representations: TRAFFIC_VIEW_CONTAINER [TRAFFIC_MOVING, TRAFFIC_VIEW [TRAFFIC_MOVING]]
			-- Container for moving views
		deferred
		end

	route_representations: TRAFFIC_VIEW_CONTAINER [TRAFFIC_ROUTE, TRAFFIC_VIEW [TRAFFIC_ROUTE]]
			-- Container for route views
		deferred
		end

feature -- Element change

	set_city (a_city: TRAFFIC_CITY)
			-- Set city that is displayed to `a_city'.
		require
			line_representations_exists: line_representations /= Void
			station_representations_exists: station_representations /= Void
			building_representations_exists: building_representations /= Void
			moving_representations_exists: moving_representations /= Void
			route_representations_exists: route_representations /= Void
		local
			l: TRAFFIC_VIEW [TRAFFIC_LINE]
			p: TRAFFIC_VIEW [TRAFFIC_STATION]
			r: TRAFFIC_VIEW [TRAFFIC_ROAD]
		do
			city := a_city
			from
				city.roads.start
			until
				city.roads.after
			loop
				r := factory.new_road_view (city.roads.item_for_iteration)
				road_representations.put_last (r)
				city.roads.forth
			end
			from
				city.lines.start
			until
				city.lines.after
			loop
				l := factory.new_line_view (city.lines.item_for_iteration)
				line_representations.put_last (l)
				city.lines.forth
			end
			from
				city.stations.start
			until
				city.stations.after
			loop
				p := factory.new_station_view (city.stations.item_for_iteration)
				station_representations.put_last (p)
				city.stations.forth
			end
			from
				city.buildings.start
			until
				city.buildings.after
			loop
				add_building (city.buildings.item_for_iteration)
				city.buildings.forth
			end
			from
				city.landmarks.start
			until
				city.landmarks.after
			loop
				add_building (city.landmarks.item_for_iteration)
				city.landmarks.forth
			end
			from
				city.trams.start
			until
				city.trams.after
			loop
				add_tram (city.trams.item_for_iteration)
				city.trams.forth
			end
			from
				city.busses.start
			until
				city.busses.after
			loop
				add_bus (city.busses.item_for_iteration)
				city.busses.forth
			end
			from
				city.free_movings.start
			until
				city.free_movings.after
			loop
				add_free_moving (city.free_movings.item_for_iteration)
				city.free_movings.forth
			end
			from
				city.passengers.start
			until
				city.passengers.after
			loop
				add_passenger (city.passengers.item_for_iteration)
				city.passengers.forth
			end
			from
				city.routes.start
			until
				city.routes.after
			loop
				add_route (city.routes.item_for_iteration)
				city.routes.forth
			end
			from
				city.taxis.start
			until
				city.taxis.after
			loop
				add_taxi (city.taxis.item_for_iteration)
				city.taxis.forth
			end
			city.lines.element_inserted_event.subscribe (agent add_line)
			city.lines.element_removed_event.subscribe (agent remove_line)
			city.roads.element_inserted_event.subscribe (agent add_road)
			city.roads.element_removed_event.subscribe (agent remove_road)
			city.stations.element_inserted_event.subscribe (agent add_station)
			city.stations.element_removed_event.subscribe (agent remove_station)
			city.buildings.element_inserted_event.subscribe (agent add_building)
			city.buildings.element_removed_event.subscribe (agent remove_building)
			city.landmarks.element_inserted_event.subscribe (agent add_landmark)
			city.landmarks.element_removed_event.subscribe (agent remove_landmark)
			city.trams.element_inserted_event.subscribe (agent add_tram)
			city.trams.element_removed_event.subscribe (agent remove_tram)
			city.busses.element_inserted_event.subscribe (agent add_bus)
			city.busses.element_removed_event.subscribe (agent remove_bus)
			city.free_movings.element_inserted_event.subscribe (agent add_free_moving)
			city.free_movings.element_removed_event.subscribe (agent remove_free_moving)
			city.passengers.element_inserted_event.subscribe (agent add_passenger)
			city.passengers.element_removed_event.subscribe (agent remove_passenger)
			city.routes.element_inserted_event.subscribe (agent add_route)
			city.routes.element_removed_event.subscribe (agent remove_route)
			city.taxis.element_inserted_event.subscribe (agent add_taxi)
			city.taxis.element_removed_event.subscribe (agent remove_taxi)
		ensure
			city_set: city = a_city
		end

feature -- Status report

	is_city_hidden: BOOLEAN
			-- Is the city hidden?

	are_buildings_hidden: BOOLEAN
			-- Are the buildings displayed?

feature -- Status setting

	enable_city_hidden
			-- Set `is_city_hidden' to `True'.
		do
			is_city_hidden := True
		ensure
			city_hidden: is_city_hidden
		end

	disable_city_hidden
			-- Set `is_city_hidden' to `False'.
		do
			is_city_hidden := False
		ensure
			city_not_hidden: not is_city_hidden
		end

feature {NONE} -- Implementation (view adding)

	add_station (a_station: TRAFFIC_STATION)
			-- Add station view for `a_station'.
		require
			a_station_exists: a_station /= Void
		do
			station_representations.put_last (factory.new_station_view (a_station))
		end

	add_line (a_line: TRAFFIC_LINE)
			-- Add line view for `a_line'.
		require
			a_line_exists: a_line /= Void
		do
			line_representations.put_last (factory.new_line_view (a_line))
		end

	add_road (a_road: TRAFFIC_ROAD)
			-- Add road view for `a_road'.
		require
			a_road_exists: a_road /= Void
		do
			road_representations.put_last (factory.new_road_view (a_road))
		end

	add_route (a_route: TRAFFIC_ROUTE)
			-- Add route view for `a_route'.
		require
			a_route_exists: a_route /= Void
		do
			route_representations.put_last (factory.new_route_view (a_route))
		end

	add_building (a_building: TRAFFIC_BUILDING)
			-- Add building view for `a_building'.
		require
			a_building_exists: a_building /= Void
		do
			building_representations.put_last (factory.new_building_view (a_building))
		end

	add_landmark (a_building: TRAFFIC_LANDMARK)
			-- Add building view for `a_building'.
		require
			a_building_exists: a_building /= Void
		do
			building_representations.put_last (factory.new_building_view (a_building))
		end

	add_tram (a_tram: TRAFFIC_TRAM)
			-- Add tram view for `a_tram'.
		require
			a_tram_exists: a_tram /= Void
		do
			moving_representations.put_last (factory.new_tram_view (a_tram))
		end

	add_bus (a_bus: TRAFFIC_BUS)
			-- Add bus view for `a_bus'.
		require
			a_bus_exists: a_bus /= Void
		do
			moving_representations.put_last (factory.new_bus_view (a_bus))
		end

	add_free_moving (a_free_moving: TRAFFIC_FREE_MOVING)
			-- Add free moving view for `a_free_moving'.
		require
			a_free_moving_exists: a_free_moving /= Void
		do
			moving_representations.put_last (factory.new_free_moving_view (a_free_moving))
		end

	add_passenger (a_passenger: TRAFFIC_PASSENGER)
			-- Add passenger view for `a_passenger'.
		require
			a_passenger_exists: a_passenger /= Void
		do
			moving_representations.put_last (factory.new_passenger_view (a_passenger))
		end

	add_taxi (a_taxi: TRAFFIC_TAXI)
			-- Add taxi view for `a_taxi'.
		require
			a_taxi_not_void: a_taxi /= Void
		do
			moving_representations.put_last (factory.new_taxi_view (a_taxi))
		end

feature {NONE} -- Implementation (view removing)

	remove_station (a_station: TRAFFIC_STATION)
			-- Remove view for `a_station'.
		require
			a_station_exists: a_station /= Void
		do
			station_representations.delete (station_representations.view_for_item (a_station))
		end

	remove_line (a_line: TRAFFIC_LINE)
			-- Remove view for `a_line'.
		require
			a_line_exists: a_line /= Void
		do
			line_representations.delete (line_representations.view_for_item (a_line))
		end

	remove_road (a_road: TRAFFIC_ROAD)
			-- Remove view for `a_road'.
		require
			a_road_exists: a_road /= Void
		do
			road_representations.delete (road_representations.view_for_item (a_road))
		end

	remove_route (a_route: TRAFFIC_ROUTE)
			-- Remove view for `a_route'.
		require
			a_route_exists: a_route /= Void
		do
			route_representations.delete (route_representations.view_for_item (a_route))
		end

	remove_free_moving (a_free_moving: TRAFFIC_FREE_MOVING)
			-- Remove view for `a_free_moving'.
		require
			a_free_moving_exists: a_free_moving /= Void
		do
			moving_representations.delete (moving_representations.view_for_item (a_free_moving))
		end

	remove_tram (a_tram: TRAFFIC_TRAM)
			-- Remove view for `a_tram'.
		require
			a_tram_exists: a_tram /= Void
		do
			moving_representations.delete (moving_representations.view_for_item (a_tram))
		end

	remove_bus (a_bus: TRAFFIC_BUS)
			-- Remove view for `a_bus'.
		require
			a_bus_exists: a_bus /= Void
		do
			moving_representations.delete (moving_representations.view_for_item (a_bus))
		end

	remove_passenger (a_passenger: TRAFFIC_PASSENGER)
			-- Remove view for `a_passenger'.
		require
			a_passenger_exists: a_passenger /= Void
		do
			moving_representations.delete (moving_representations.view_for_item (a_passenger))
		end

	remove_building (a_building: TRAFFIC_BUILDING)
			-- Remove view for `a_building'.
		require
			a_building_exists: a_building /= Void
		do
			building_representations.delete (building_representations.view_for_item (a_building))
		end

	remove_landmark (a_building: TRAFFIC_LANDMARK)
			-- Remove view for `a_building'.
		require
			a_building_exists: a_building /= Void
		do
			building_representations.delete (building_representations.view_for_item (a_building))
		end

	remove_taxi (a_taxi: TRAFFIC_TAXI)
			-- Remove view for `a_taxi'.
		require
			a_taxi_exists: a_taxi /= Void
		do
			moving_representations.delete (moving_representations.view_for_item (a_taxi))
		end

feature {NONE} -- Implementation (Agent references)

	add_taxi_agent: PROCEDURE [ANY, TUPLE [TRAFFIC_TAXI]]

	remove_taxi_agent: PROCEDURE [ANY, TUPLE [TRAFFIC_TAXI]]

invariant

	factory_exists: factory /= Void
	line_representations_exists: line_representations /= Void
	road_representations_exists: road_representations /= Void
	station_representations_exists: station_representations /= Void
	building_representations_exists: building_representations /= Void
	moving_representations_exists: moving_representations /= Void
	route_representations_exists: route_representations /= Void
	add_taxi_agent_exists: add_taxi_agent /= Void
	remove_taxi_agent_exists: remove_taxi_agent /= Void

end
