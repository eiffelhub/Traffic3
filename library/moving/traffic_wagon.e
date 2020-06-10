note
	description: "Wagon objects can be used to increase the capacity of trams."
	date: "$Date: 6/6/2006$"
	revision: "$Revision$"

class
	TRAFFIC_WAGON

create
	make_default

feature -- Initialization

	make_default
			-- Set capacity to Default_capacity
		do
			capacity := Default_capacity
		end

feature -- Basic operations

	load (a_quantity: INTEGER)
			-- load `a_quantity' of passengers in the vagon
		require
			valid_quantity: a_quantity > 0
			not_too_much: count + a_quantity <= capacity
		do
			count := count + a_quantity
		ensure
			loaded: count = old count + a_quantity
		end

	unload (a_quantity: INTEGER)
			-- load `a_quantity' of passengers in the vagon
		require
			valid_quantity: a_quantity > 0
			not_too_much: count - a_quantity >= 0
		do
			count := count + a_quantity
		ensure
			loaded: count = old count - a_quantity
		end

feature --Access

	capacity: INTEGER
			-- Load allowed

	count: INTEGER
			-- number of passengers

feature --Constants

	Default_capacity: INTEGER = 100
			-- Default capacity

invariant
	capacity >= 0
	not_to_many: count <= capacity
	not_to_few: count >= 0
end

