note
	description: "Lightrail road type."
	date: "$Date: 6/6/2006$"
	revision: "$Revision$"

class
	TRAFFIC_TYPE_LIGHTRAIL

inherit
	TRAFFIC_TYPE_STREET
		redefine make end

create
	make


feature -- Creation

	make 
			-- Create new street type.
		do
			name := "lightrail"
		end

feature -- Basic




end
