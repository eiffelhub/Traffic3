indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TE_RENDERPASS

feature -- Initialization

	make is
			-- creates the pass
		do
			enabled := true
		end


feature -- Access

	name: STRING

	enabled: BOOLEAN

feature -- Measurement

feature -- Status report

feature -- Status setting

	enable is
			-- enables the pass
		do
			enabled := true
		end

	disable is
			-- disables the pass
		do
			enabled := false
		end

feature -- Cursor movement

feature -- Element change

feature -- Removal

feature -- Resizing

feature -- Transformation

feature -- Conversion

feature -- Duplication

feature -- Miscellaneous

feature -- Basic operations

feature -- Obsolete

feature -- Inapplicable

feature {TE_RENDERPASS_MANAGER} -- Implementation

	render is
			-- renders the current pass
		deferred
		end


invariant
	invariant_clause: True -- Your invariant here

end
