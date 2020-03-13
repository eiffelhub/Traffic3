indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_TIME_COUNTER

inherit

	EM_FRAME_COUNTER
		rename
			update_fps as update_time,
			time as em_time
		redefine
			make,
			update_time
		end

	TRAFFIC_SHARED_TIME

create
	make

feature -- Initialization

	make is
			-- Initialize time counter.
		do
			Precursor
			str.set_value("??:??:??")
		end

feature {NONE} -- Implementation		

	update_time is
			-- Update with new time
		do
			str.set_value(time.out)
		end

end
