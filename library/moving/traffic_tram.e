note
	description: "Tram"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_TRAM

inherit

	TRAFFIC_LINE_VEHICLE
		rename
			unit_capacity as engine_capacity
		redefine
			capacity
		end

create
	make_with_line

feature -- Initialization

	make_with_line (a_line: TRAFFIC_LINE)
			-- Create a tram, set default values for capacity, number of wagons and speed.
		require
			a_line_not_void: a_line /= Void
			valid_line: is_valid_line (a_line)
		do
			set_line (a_line)
			set_reiterate (True)

			engine_capacity := Default_engine_capacity
			wagon_limitation := Default_wagon_limitation
			wagons := create {ARRAYED_LIST[TRAFFIC_WAGON]}.make(wagon_limitation)

			speed := Default_virtual_speed
			create changed_event

		end


feature -- Access

	wagon_limitation: INTEGER
			-- Maximum number of wagons allowed for this engine

	wagons: ARRAYED_LIST[TRAFFIC_WAGON]
			-- List of the wagons

	capacity: INTEGER
			-- Capacity as the sum of wagons' capacities plus engine_capacity
		do
			Result := engine_capacity
			from
				wagons.start
			until
				wagons.after
			loop
				Result := Result + wagons.item.capacity
				wagons.forth
			end
		end

	 count: INTEGER
	 		-- Current amount of load
	 	do
			Result := engine_count
			from
				wagons.start
			until
				wagons.after
			loop
				Result := Result + wagons.item.count
				wagons.forth
			end
	 	end

feature -- Basic operations

	add_wagon
			-- Attach new wagon.
		require
			not_too_many_wagons: wagon_limitation >= wagons.count + 1
		local
			wagon: TRAFFIC_WAGON
		do
			wagon := create {TRAFFIC_WAGON}.make_default
			wagons.force (wagon)
		ensure
			wagon_added: wagons.count = old wagons.count + 1
		end

	remove_wagon(i: INTEGER)
			-- Remove wagon at position i.
		require
			there_are_wagons: wagons.count > 0
			wagon_is_empty: wagons.i_th (i).count = 0
		do
			wagons.start
			wagons.go_i_th (i)
			wagons.remove
		ensure
			wagon_removed: wagons.count = old wagons.count -1
		end


	load(a_quantity: INTEGER)
			-- Load tram with `a_quantity'
		local
			l_quantity,
			l_free_places: INTEGER
    	do
    		l_quantity := a_quantity
			if engine_capacity - engine_count > l_quantity then
				engine_count :=  engine_count + l_quantity
			else
				l_free_places := engine_capacity - engine_count
				if l_free_places > 0  then
					l_quantity := l_quantity - l_free_places
					engine_count := engine_capacity
				end
				from
					wagons.start
				until
					l_quantity = 0
				loop
					l_free_places := wagons.item.capacity - wagons.item.count
					if l_quantity >= l_free_places and l_free_places > 0  then
						l_quantity := l_quantity - l_free_places
						wagons.item.load (l_free_places)
					elseif l_quantity < l_free_places and l_free_places > 0 then
						wagons.item.load (l_quantity)
						l_quantity := 0
					end
					wagons.forth
				end
			end
    	end

	unload(a_quantity: INTEGER)
			-- Unoad tram with `a_quantity'
		local
			l_quantity,
			l_free_places: INTEGER
    	do
    		l_quantity := a_quantity
			if engine_count - l_quantity >= 0 then
				engine_count :=  engine_count - l_quantity
			else
				if engine_count - l_quantity < 0  then
					l_quantity := l_quantity - engine_count
					engine_count := 0
				end
				from
					wagons.start
				until
					l_quantity = 0
				loop
					l_free_places := wagons.item.capacity - wagons.item.count

					if wagons.item.count - l_quantity <= 0 then
						l_quantity := l_quantity - wagons.item.count
						wagons.item.unload (wagons.item.count)
					elseif wagons.item.count > 0 then
						wagons.item.unload (l_quantity)
						l_quantity := 0
					end
				end
			end
    	end

feature -- Constants

	Default_engine_capacity: INTEGER = 200
			-- Default load capacity of the motorized carriage

	Default_wagon_limitation: INTEGER = 2
			-- Default number of wagons attached

	Default_virtual_speed: REAL_64
			-- Default speed
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
			-- Is `Current' removable from `city'?
		do
			Result := True
		end

	is_valid_line (a_line: TRAFFIC_LINE): BOOLEAN
			-- Is `a_line' valid for a tram to move on?
		do
			if a_line.type.is_equal (create {TRAFFIC_TYPE_TRAM}.make) then
				Result := True
			end
		end

feature -- Implementation

	engine_count: INTEGER
			-- Current amount of load in "engine wagon"

invariant
	wagons_not_void: wagons /= void
	wagons_count_allowed: wagon_limitation >= wagons.count
	valid_line_type: line.type.name.is_equal ("tram") or line.type.name.is_equal ("rail") or line.type.name.is_equal ("bus")
	--TODO: change this, use a new objects rail and bus instead
end
