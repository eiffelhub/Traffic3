note
	description: "[
		The DFS walker is a LINEAR abstraction of a graph, that starts
		on a specific node and will walk in a depth first search order
		over the graph nodes.
		The cursor of the graph will be moved accordingly.	
		
		Warning: The graph must not be changed in it's structure during
		walking.
	]"
	author: "Olivier Jeger, based on an initial design by Bernd Schoeller"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2009-04-06 14:42:41 +0200 (Пн, 06 апр 2009) $"
	revision: "$Revision: 1086 $"

class
	DFS_WALKER [G -> HASHABLE, reference L]

inherit
	ABSTRACT_FS_WALKER [G, L]

	ITERATION_CURSOR [G]


create
	make

feature -- Initialize

	create_dispenser 
			-- Create the dispenser for a DFS walker
		do
			create {LINKED_STACK [GRAPH_CURSOR[G, L]]} dispenser.make
		end


feature -- New Cursor

	new_cursor: DFS_WALKER [G, L]
		do
			Result := twin
			Result.start
		end

end -- class DFS_WALKER
