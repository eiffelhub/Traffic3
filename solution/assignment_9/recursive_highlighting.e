note
	description: "Recursive highlighting class (Assignment 9)"
	date: "$Date$"
	revision: "$Revision$"

class
	RECURSIVE_HIGHLIGHTING

inherit
	TOURISM

feature -- Explore Paris
	show
			-- Highlight stations that are reachable within a certain time limit.
		do
			Paris.display
			highlight_reachable_stations (Station_chatelet, 10.0)
		end

	highlight_reachable_stations (s: TRAFFIC_STATION; t: REAL_64)
			-- Highlight all stations that are reachable from `s' within travel time `t'.
		require
			s_exists: s /= Void
			t_positive: t > 0.0
		local
			stop: TRAFFIC_STOP
			i: INTEGER
		do
			s.highlight
			from
				i := 1
			until
				i > s.stops.count
			loop
				stop := s.stops.i_th (i)
				if stop.right /= Void and then (t - stop.time_to_next) >= 0.0 then
					highlight_reachable_stations (stop.right.station, t - stop.time_to_next)
				end
				i := i + 1
			end
		end

end
