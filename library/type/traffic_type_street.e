note
	description: "Street type."
	date: "$Date: 2006-07-25 17:14:39 +0200 (Вт, 25 июл 2006) $"
	revision: "$Revision: 742 $"

class
	TRAFFIC_TYPE_STREET

inherit
	TRAFFIC_TYPE_ROAD

create
	make

feature -- Creation

	make 
			-- Create new street type.
		do
			name := "street"
		end

end
