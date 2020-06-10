note
	description: "A simple version of the class TRAFFIC_STOP"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_SIMPLE_STOP

feature

	station: TRAFFIC_STATION
		-- Station which this stop represents

	right: TRAFFIC_SIMPLE_STOP
		-- Next stop on same line

	set_station(s: TRAFFIC_STATION)
		--Associate this stop with `s'
		require
			station_exists: s/= void
		do
			station := s
		ensure
			station_set: station = s
		end

	link(s: TRAFFIC_SIMPLE_STOP) 
			-- make `s' the next stop on the line
		do
			right := s
		ensure
			right_set: right = s
		end


end
