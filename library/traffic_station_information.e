note
	description: "Additional information on a station."
	date: "$Date: 2009-08-21 13:35:22 +0200 (Пт, 21 авг 2009) $"
	revision: "$Revision: 1098 $"

class
	TRAFFIC_STATION_INFORMATION

inherit
	ANY
		redefine
			out
		end

create
	make

feature {NONE} -- Initialization

	make 
			-- Create empty information.
		do
			create pictures.make
		ensure
			pictures_exists: pictures /= Void
		end

feature -- Access

	pictures: LINKED_LIST [STRING]
		-- Path to picture

	description: STRING
		-- Description

feature -- Element change

	extend_picture (a_picture_path: STRING)
			-- Set picture path to `a_picture_path'.
		require
			a_picture_path_exists: a_picture_path /= Void
		do
			pictures.extend (a_picture_path)
		ensure
			picture_set: pictures.has (a_picture_path)
		end

	set_description (a_description: STRING)
			-- Set description to `a_desciption'.
		require
			a_description_exists: a_description /= Void
		do
			description := a_description
		ensure
			description_set: description = a_description
		end

feature -- Removal

	remove_picture (a_picture_path: STRING)
			-- Remove picture path from pictures.
		require
			picture_in_pictures: pictures.has (a_picture_path)
		do
			pictures.prune (a_picture_path)
		ensure
			picture_removed: not pictures.has (a_picture_path)
		end

	remove_description
			-- Remove desription.
		do
			description := Void
		ensure
			description_removed: description = Void
		end

feature -- Output

	out: STRING
			-- Textual representation.
		do
			Result := ""
			if pictures.count > 0 then
				from
					pictures.start
					Result := Result + "pictures: "
				until
					pictures.after
				loop
					Result := Result + pictures.item
					pictures.forth
					if not pictures.after then
						Result := Result + ", "
					end
				end
			end
			if description /= Void then
				if pictures.count > 0 then
					Result := Result + ", "
				end
				Result := Result + "description: " + description
			end
		end

invariant
	pictures_exists: pictures /= Void

end
