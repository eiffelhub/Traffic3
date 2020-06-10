note
	description: "Taxi used for taxi dispatcher application using method call communication"
	date: "$Date: 6/6/2006$"
	revision: "$Revision$"

class
	TRAFFIC_DISPATCH_TAXI

inherit
	TRAFFIC_TAXI
		undefine
			remove_from_city,
			add_to_city
		redefine
			make_random, advance, take, color
		end

	TRAFFIC_CITY_ITEM
		export
			{TRAFFIC_TAXI_OFFICE} remove_from_city
		redefine
			add_to_city
		end

create
	make_random, make_with_office

feature -- Initialization

	make_random (a_point_list: DS_ARRAYED_LIST [TRAFFIC_POINT])
			-- Create a taxi with an associated 'a_taxi_office'.
			-- Random speed and stops at 'stops' random positions.
			-- Set seed of random_number to 'a_seed'.
		do
			Precursor (a_point_list)
			create office.default_create
			office.enlist(Current)
		ensure then
			taxi_office_set: office /= Void
		end

	make_with_office (a_taxi_office: TRAFFIC_TAXI_OFFICE; a_point_list: DS_ARRAYED_LIST [TRAFFIC_POINT])
			-- Create a taxi with an associated 'a_taxi_office'.
			-- Random speed and stops at 'stops' random positions.
			-- Set seed of random_number to 'a_seed'.
		require
            a_taxi_office_not_void: a_taxi_office /= void
            valid_number_of_stops: a_point_list /= Void and then a_point_list.count >= 2
		do
			make_random (a_point_list)
			office := a_taxi_office
			office.enlist(Current)
        ensure
            taxi_office_set: office /= Void
            polypoints_not_empty: polypoints /= Void and then polypoints.count >= a_point_list.count
		end

feature -- Access

	office : TRAFFIC_TAXI_OFFICE
			-- Taxi office `Current' works for

	color: TRAFFIC_COLOR
			-- Color of the taxi office
		do
			Result := office.color
		end


feature -- Basic operations

	advance
			-- Take a tour in the city.
			-- Set new random directions and if 'Current' has done a request and is available again.
		do
			Precursor
			if has_finished and busy then
				office.enlist(Current)
			end
		end

feature {TRAFFIC_TAXI_OFFICE} -- Basic operations

	add_to_city (a_city: TRAFFIC_CITY)
			-- Add `Current' and all taxis to `a_city'.
		do
			Precursor (a_city)
			if not city.taxi_offices.has (office) then
					city.taxi_offices.put (office)
			end
		end

feature {TRAFFIC_TAXI_OFFICE} -- Basic operations

	take (from_location: TRAFFIC_POINT; to_location: TRAFFIC_POINT)
			-- Take a request. Pick somebody up at from_location and bring him or her to to_location.
			-- If busy inform the taxi office to recall it.
		require else
			locations_exist: from_location /= Void and to_location /= Void
			within_city_bounds: from_location.distance (city.center) <= city.radius
		do
			Precursor (from_location, to_location)
			if not busy then
				office.delist(Current)
			else
				office.recall(from_location, to_location)
			end
		end

end
