note
	description: "Manager for road ids"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_ID_MANAGER

inherit
	ANY
		redefine
			default_create
		end

feature -- Initialization

	default_create 
			-- Create `id_list'.
		do
			create id_list.make_default
		ensure then
			id_list_created: id_list /= Void
		end

feature -- Element change

	take (an_id: INTEGER)
			-- Set `an_id' to be taken.
		do
			id_list.force (True, an_id)
		ensure
			is_taken: is_taken (an_id)
		end

	free (an_id: INTEGER)
			-- Set `an_id' to be free.
		do
			id_list.force (False, an_id)
		ensure
			is_taken: not is_taken (an_id)
		end

feature -- Status report

	is_taken (an_id: INTEGER): BOOLEAN
			-- Is `an_id' taken?
		do
			if an_id <= id_list.count then
				Result := id_list.item (an_id)
			else
				Result := False
			end
		end

feature -- Search

	next_free_index: INTEGER
			-- Get the next free index.
		do
			-- Todo improve implementation
			Result := id_list.count + 1
		end

feature {NONE} -- Implementation

	id_list: DS_ARRAYED_LIST [BOOLEAN]

end
