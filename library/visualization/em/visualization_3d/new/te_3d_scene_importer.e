indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TE_3D_SCENE_IMPORTER

	create
		make

feature {TE_3D_SHARED_GLOBALS} -- Initialization

	make is
			-- creates the scene importer and the factory hastable
		do
			create factory_table.make(1)
			factory_table.put(create {TE_3D_MEMBER_FACTORY_FROMFILE_OBJ}, "obj")
		end


feature -- Member Import

	import_3d_scene(a_filename:STRING): TE_3D_NODE is
			-- imports a 3d scene from a file
			-- depending on what is stored in that file it will return any decendant of TE_3D_NODE or the root of a hirarchy of them
		local
			factory: TE_3D_MEMBER_FACTORY_FROMFILE
		do
			factory := factory_table.item(a_filename.substring (a_filename.count - 2, a_filename.count))
			factory.create_3d_member_from_file(a_filename)
			Result := factory.last_3d_member
		end


feature -- Factory Table

	factory_table: HASH_TABLE[TE_3D_MEMBER_FACTORY_FROMFILE, STRING]

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

feature -- Obsolete

feature -- Inapplicable

feature {NONE} -- Implementation

invariant
	invariant_clause: True -- Your invariant here

end
