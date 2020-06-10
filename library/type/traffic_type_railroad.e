note
	description: "Railroad type."
	date: "$Date: 6/6/2006$"
	revision: "$Revision$"

class
	TRAFFIC_TYPE_RAILROAD

inherit

	TRAFFIC_TYPE_ROAD
		redefine
			is_allowed_type
		end

create
	make

feature -- Creation

	make
			-- Create new street type.
		do
			name := "railroad"
		end


feature -- Basic

	is_allowed_type(a_moving: TRAFFIC_MOVING): BOOLEAN 
			-- Is 'a_moving' allowed to go on a walk road?
		local
			line_vehicle: TRAFFIC_LINE_VEHICLE
		do
			line_vehicle?=a_moving
			if line_vehicle/=Void then
				Result:=true
			end
		end

end
