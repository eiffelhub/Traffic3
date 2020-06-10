note
	description: "Cursor for TRAFFIC_LINE objects (to avoid moving internal cursors of the line)"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_LINE_CURSOR

create
	make

feature {NONE} -- Initialization

	make (a_line: TRAFFIC_LINE)
			-- Create for `a_line' and set direction to forward.
		require
			a_line_exists: a_line /= Void
		do
			create internal_cursor.make (a_line.one_direction)
			line := a_line
		ensure
			line_set: line = a_line
			internal_cursor_exists: internal_cursor /= Void
		end

feature -- Access

	item_for_iteration: TRAFFIC_LINE_SEGMENT
			-- Item at internal cursor position of line
		require
			not_after: not after
		do
			Result := internal_cursor.item
		end

	line: TRAFFIC_LINE
			-- Line that the cursor traverses

feature -- Cursor movement

	set_cursor_direction (forward: BOOLEAN)
			-- Use `True' for traversal from `terminal_1' to `terminal_2', `false' otherwise.
		do
			if forward then
				create internal_cursor.make (line.one_direction)
				internal_cursor.start
			else
				create internal_cursor.make (line.other_direction)
				internal_cursor.start
			end
		ensure
			internal_cursor_exists: internal_cursor /= Void
		end

	start
			-- Move internal cursor to first position.
		do
			internal_cursor.start
		end

	forth
			-- Move internal cursor to next position.
		require
			not_after: not after
		do
			internal_cursor.forth
		end

feature -- Status report

	is_cursor_one_direction: BOOLEAN
			-- Is the cursor currently working on the direction from `terminal_1' to `terminal_2'?
		do
			Result := internal_cursor.container = line.one_direction
		end

	after: BOOLEAN 
			-- Is there no valid position to right of internal cursor?
		do
			Result := internal_cursor.after
		end

feature {NONE} -- Implementation

	internal_cursor: DS_LINKED_LIST_CURSOR [TRAFFIC_LINE_SEGMENT]
			-- Internal cursor used for traversal

end
