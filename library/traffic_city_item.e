note
	description: "Elements that belong to the city"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TRAFFIC_CITY_ITEM

feature -- Status report

	is_in_city: BOOLEAN
		-- Is `Current' a member of the city?

feature {TRAFFIC_EVENT_CONTAINER} -- Basic operations

	add_to_city (a_city: TRAFFIC_CITY) 
			-- Add `Current' to `a_city'.
		require
			a_city_exists: a_city /= Void
			not_in_city: not is_in_city
			insertable: is_insertable (a_city)
		do
			is_in_city := True
			city := a_city
		ensure
			is_in_city: is_in_city
			city_set: city = a_city
		end

	remove_from_city
			-- Remove `Current' from `city'.
		require
			is_in_city: is_in_city
			is_removable: is_removable
		do
			is_in_city := False
			city := Void
		ensure
			not_in_city: not is_in_city
			city_unset: city = Void
		end

feature -- Status setting

	highlight
			-- Highlight.
		do
			is_highlighted := True
			changed_event.publish ([])
		ensure
			highlighted: is_highlighted
		end

	unhighlight
			-- Unhighlight.
		do
			is_highlighted := False
			changed_event.publish ([])
		ensure
			unhighlighted: not is_highlighted
		end

feature -- Access

	city: TRAFFIC_CITY
			-- City to which the item belongs (may be void)

	changed_event: TRAFFIC_EVENT_CHANNEL [TUPLE []]
			-- Event to publish when `Current'  changed

feature -- Status report

	is_insertable (a_city: TRAFFIC_CITY): BOOLEAN
			-- Is `Current' insertable into `a_city'?
			-- E.g. are all needed elements already inserted in the city?
		deferred
		end

	is_removable: BOOLEAN
			-- Is `Current' removable from `city'?
			-- E.g. no other elements need it any more?
		deferred
		end

	is_highlighted: BOOLEAN
			-- Is `Current' highlighted?

invariant

	changed_event_exists: changed_event /= Void

end
