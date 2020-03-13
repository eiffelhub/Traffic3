indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TE_3D_SHARED_GLOBALS

feature -- Singleton access

	root: TE_3D_NODE is
			-- root singleton
		once
			create Result.make_as_root
		ensure
			root_not_void: Result /= Void
		end

	default_material : TE_MATERIAL_SIMPLE
			--default material singleton
		once
			create Result.make
		ensure
			default_material_not_void: Result /= Void
		end

	scene_importer : TE_3D_SCENE_IMPORTER
			--scene importer to load 3d content from files
		once
			create Result.make
		ensure
			scene_importer_not_void: Result /= Void
		end

	renderpass_manager: TE_RENDERPASS_MANAGER is
			-- Bitamp factory singleton
		once
			create Result.make
		ensure
			renderpass_manager_not_void: Result /= Void
		end

invariant
	root_MUST_NOT_BE_MOVED: root.transform.position.x = 0 and root.transform.position.y = 0 and root.transform.position.z = 0

end
