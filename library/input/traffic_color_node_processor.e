indexing
	description: "XML processors for <color> elements."
	date: "$Date: 2007-09-24 11:12:13 +0200 (Пн, 24 сен 2007) $"
	revision: "$Revision: 931 $"

class
	TRAFFIC_COLOR_NODE_PROCESSOR

inherit
	TRAFFIC_NODE_PROCESSOR

create
	make

feature -- Access

	Name: STRING is
			-- Name of element to process
		once
			Result := "color"
		end

	Mandatory_attributes: ARRAY [STRING] is
			-- Table of mandatory attributes
		once
			Result := << "red", "green", "blue" >>
			Result.compare_objects
		end

feature -- Basic operations

	process is
			-- Process element.
		do
			if not has_attribute ("red") and has_attribute ("green") and has_attribute ("blue") then
				set_error (Mandatory_attribute_missing, << "color attribute missing" >>)
			elseif not valid_color then
				set_error (Wrong_color_value, << >>)
			else
				parent.send_data (new_color)
			end
		end

feature {NONE} -- Implementation

	valid_color: BOOLEAN is
			-- Does node contain a valid color?
		require
			red_exists: has_attribute ("red")
			green_exists: has_attribute ("green")
			blue_exists: has_attribute ("blue")
		do
			Result := valid_color_value ("red") and
				valid_color_value ("green") and
				valid_color_value ("blue")
		end

	valid_color_value (attr: STRING): BOOLEAN is
			-- Does attribute `attr' contain a valid color value?
		require
			attribute_exists: attr /= Void
			attribute_not_empty: not attr.is_empty
		local
			v: INTEGER
		do
			if is_attribute_integer (attr) then
				v := attribute_integer (attr)
				Result := 0 <= v and v <= 255
			end
		end

	new_color: TRAFFIC_COLOR is
			-- Color specified by node
		require
			valid_color: valid_color
		do
			create Result.make_with_rgb (
				attribute_integer ("red"),
				attribute_integer ("green"),
				attribute_integer ("blue"))
		ensure
			Result_exists: Result /= Void
		end

end
