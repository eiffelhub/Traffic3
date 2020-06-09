note
	description: "Superclass of containers that throw events when elements are added or removed"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TRAFFIC_EVENT_CONTAINER [G]

feature -- Access

	element_inserted_event: TRAFFIC_EVENT_CHANNEL [TUPLE [G]]
			-- Insertion event ([Inserted element])

	element_removed_event: TRAFFIC_EVENT_CHANNEL [TUPLE [G]]
			-- Deletion event ([Removed element])

invariant

	inserted_initialized: element_inserted_event /= Void
	removed_initialized: element_removed_event /= Void

end
