note
	description: "Routes class (Chapter 8, Touch of Class)"
	date: "$Date$"
	revision: "$Revision$"

class
	ROUTES

inherit

	TOURISM

feature -- Traversing

	traverse
			--  Traverse Line8.
		do
			Paris.display

			from
				line8.start
			invariant
				not_before_unless_empty: (not Line8.is_empty) implies (not Line8.is_before)
				-- "For all stations before cursor position, a spot has been displayed"
			variant
				Line8.count - Line8.index + 1
			until
				line8.after
			loop
				show_station(line8.item)
				line8.forth
			end

		end

	show_station(s:TRAFFIC_STATION) 
			-- Highlights s in a form adapted to its status
		require
			station_exists: s /= Void
		do
			if Line8.item.is_railway_connection then
				show_big_red_spot (Line8.item.location)
			elseif Line8.item.is_exchange then
				show_blinking_spot (Line8.item.location)
			else
				show_spot (line8.item.location)
			end
		end


feature -- Access

end
