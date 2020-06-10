note
	description: "Vehicles of type bus"
	date: "$Date: 6/6/2006$"
	revision: "$Revision$"

class
	TRAFFIC_BUS

inherit
	TRAFFIC_LINE_VEHICLE

create
	make_with_line

feature -- Initialization	

	make_with_line (a_line: TRAFFIC_LINE)
			-- Create a bus following `a_line'.
			-- Set unit_capacity and speed to default values.
		require
			a_line_exists: a_line /= Void
			valid_line: is_valid_line (a_line)
		do
			set_line (a_line)
			speed := Default_virtual_speed
			unit_capacity := Default_capacity
			create changed_event
		end

feature -- Access

	count: INTEGER
			-- Current amount of load

feature -- Basic operations

	replace (a_line: TRAFFIC_LINE)
			-- Serve as replacement bus for `a_line'.
		require
			a_line_not_void: a_line /= void
		do
			set_line (a_line)
			changed_event.publish ([])
		ensure
			new_line_set:  line = a_line
		end

	load(a_quantity: INTEGER)
			-- Load cargo or a passenger.
    	do
			count := count + a_quantity
    	end

    unload(a_quantity: INTEGER)
			-- Load cargo or a passenger.
    	do
			count := count - a_quantity
    	end

feature-- Constants

	Default_capacity: INTEGER = 180
		-- Default capacity of a bus

	Default_virtual_speed: REAL_64
		-- Default speed of a bus
		do
			Result := line.type.speed
		end

feature -- Status report

	is_insertable (a_city: TRAFFIC_CITY): BOOLEAN
			-- Is `Current' insertable into `a_city'?
		do
			Result := True
		end

	is_removable: BOOLEAN
			-- Is `Current' removable from `a_city'?
		do
			Result := True
		end

	is_valid_line (a_line: TRAFFIC_LINE): BOOLEAN
			-- Is `a_line' valid for a tram to move on?
		do
			if a_line.type.is_equal (create {TRAFFIC_TYPE_TRAM}.make) or a_line.type.is_equal (create {TRAFFIC_TYPE_BUS}.make) then
				Result := True
			end
		end

end
