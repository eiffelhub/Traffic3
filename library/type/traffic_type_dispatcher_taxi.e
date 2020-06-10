note
	description: "Dispatcher taxi type."
	date: "$Date: 2006-06-26 20:01:11 $"
	revision: "$Revision: 602 $"

class
	TRAFFIC_TYPE_DISPATCHER_TAXI

inherit
	TRAFFIC_TYPE

create
	make

feature -- Creation

	make 
			-- Create new dispatcher taxi type.
		do
			name := "dispatcher taxi"
		end
end
