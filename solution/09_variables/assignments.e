note
	description: "Variables, Assignment and References (Chapter 9, Touch of Class)"
	author: "Corinne Mueller"
	date: "10.01.2008"
	revision: "1.0.0"

class
	ASSIGNMENTS

inherit

	TOURISM

feature -- Path building

	startup

		do
			paris.display
			console.show (highest_name (Line8))
			console.show (total_time8)
		end


	total_time8 : REAL_64
			-- Return the travel time on the Metro Line 8
		do
			from
				Line8.stops.start
				Result:=0.0
			invariant
				-- The value of Result is the time to travel from first station
				-- to station at cursor position
			variant
				Line8.stops.count-Line8.stops.index
			until
				Line8.stops.index = Line8.stops.count
			loop
				Result := Result + Line8.stops.item.time_to_next
				Line8.stops.forth
			end
		end

	highest_name(line: TRAFFIC_LINE): STRING 
			-- Alphabetically last of names of stations on line
		require
			line_exists: line /= void
		local
			i: INTEGER
			new: STRING
		do
			from
				Result := line.south_end.name
				i := 1
			invariant
				-- The value of `Result' is the the alphabetically last station name
				-- from the first station in the list to the current one
			variant
				line.count-i
			until
				i = line.count
			loop
				new := line.i_th (i).name
				if new > Result then
					Result := new
				end
				i := i + 1
			end
		end


end
