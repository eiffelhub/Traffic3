note
	description: "Base class for line types."
	date: "$Date: 6/6/2006$"
	revision: "$Revision$"

deferred class
	TRAFFIC_TYPE_LINE

inherit
	TRAFFIC_TYPE

feature -- Basic

	is_allowed_type(a_moving: TRAFFIC_MOVING): BOOLEAN 
			-- Is 'a_moving' allowed to go on a route?
		local
			line_vehicle: TRAFFIC_LINE_VEHICLE
		do
			line_vehicle?=a_moving
			if line_vehicle/=Void then
				Result:=true
			else
				Result:=false
			end
		end


end
