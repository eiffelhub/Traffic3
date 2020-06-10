note
	description: "Rail type."
	date: "$Date: 2006-07-25 14:34:57 +0200 (Вт, 25 июл 2006) $"
	revision: "$Revision: 737 $"

class
	TRAFFIC_TYPE_RAIL

inherit
	TRAFFIC_TYPE_LINE

create
	make

feature -- Creation

	make 
			-- Create new rail type.
		do
			name := "rail"
		end

end
