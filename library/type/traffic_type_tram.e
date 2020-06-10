note
	description: "Tram type."
	date: "$Date: 2009-08-21 13:35:22 +0200 (Пт, 21 авг 2009) $"
	revision: "$Revision: 1098 $"

class
	TRAFFIC_TYPE_TRAM

inherit
	TRAFFIC_TYPE_LINE
	redefine is_allowed_type end

create
	make

feature -- Creation

	make
			-- Create new tram type.
		do
			name := "tram"
		end

feature -- Basic

	is_allowed_type(a_moving: TRAFFIC_MOVING): BOOLEAN 
			-- Is 'a_moving' allowed to go on a walk road?
		local
			tram: TRAFFIC_PASSENGER
		do
			tram?=a_moving
			if tram/=Void then
				Result:=true
			end
		end

end
