note
	description: "Bus type."
	date: "$Date: 2006-06-26 20:01:11$"
	revision: "$Revision: 737 $"

class
	TRAFFIC_TYPE_BUS

inherit
	TRAFFIC_TYPE_LINE

create
	make

feature -- Creation

	make 
			-- Create new bus type.
		do
			name := "bus"
		end

end
