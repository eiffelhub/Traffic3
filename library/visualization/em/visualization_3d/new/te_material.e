indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TE_MATERIAL

feature -- Initialization

	make is
			-- create the material with default vaules
		do
			create name.make_empty
			create specify_material_pass.make(0)
		end


feature -- Access

	name: STRING

	material_passes: INTEGER is
			-- how many material passes are defined in this material?
		do
			Result := specify_material_pass.count
		end


feature -- Measurement

feature -- Status report

feature -- Status setting

feature -- Cursor movement

feature -- Element change

feature -- Removal

feature -- Resizing

feature -- Transformation

feature -- Conversion

feature -- Duplication

feature -- Miscellaneous

feature -- Basic operations

	specify_material_pass: ARRAYED_LIST[EM_EVENT_CHANNEL[TUPLE[]]]
		-- add for each material_pass an event channel to the list and subscribe the corresponding feature to the event channel

feature -- Obsolete

feature -- Inapplicable

feature -- Implementation

	remove is
			-- removes the mateiral. use glPushAtrib and glPopAtrib
		deferred
		end



invariant
	at_least_one_material_pass: specify_material_pass.count >=1 -- Your invariant here
end
