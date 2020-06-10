note
	description: "Event taxi type."
	date: "$Date: 2006-06-26 $"
	revision: "$Revision: 602 $"

class
	TRAFFIC_TYPE_EVENT_TAXI

inherit
	TRAFFIC_TYPE

create
	make

feature -- Creation

	make 
			-- Create new event taxi type.
		do
			name := "event taxi"
		end
end
