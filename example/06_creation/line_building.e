class LINE_BUILDING inherit
	TOURISM

feature -- Line building

	build_a_line
			-- Build an imaginary line and highlight it on the map.
		do
			Paris.display
			-- "Create new line, fill in its stations and add it to Paris"
			-- "Hightlight the new line on the map"
		end

end
