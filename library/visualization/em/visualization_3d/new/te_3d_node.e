indexing
	description: "Objects that represent nodes in the 3D object hierarchy."
	date: "$Date$"
	revision: "$Revision$"

class
	TE_3D_NODE inherit

		GL_FUNCTIONS
		export {NONE} all end

create
	make_as_child, make_as_root, make


feature -- Initialization

	make_as_child (a_parent: TE_3D_NODE) is
			-- Create the node as child of `a_parent'.
		do
			make
			if a_parent /= Void then
				a_parent.add_child (current)
			end
		ensure
			parent_set: parent = a_parent
			children_not_void: children /= Void
			transform_not_void: transform /= Void
		end

	make is
			-- Create the node without parent. Insert the node into the scene hierarchy to render it!
		do
			create transform.make
			--transform.event_channel.subscribe(agent feature name)
			create internal_children.make(0)
			create hierarchy_bounding_box.make(6)
			enable_hierarchy_renderable
		ensure
			children_not_void: children /= Void
			transform_not_void: transform /= Void
		end

feature {TE_3D_SHARED_GLOBALS} -- Initialization

	make_as_root is
			-- Create as root node (only callable from TE_3D_SHARED_ROOT so that there is only one root).
		do
			create transform.make
			create internal_children.make(0)
			create hierarchy_bounding_box.make(6)
			name := "scene_root"
			enable_hierarchy_renderable
		ensure
			parent_is_void: parent = Void
			children_not_void: children /= Void
			transform_not_void: transform /= Void
		end


feature -- Access

	hierarchy_bounding_box: ARRAYED_LIST[EM_VECTOR3D]
			-- Bounding box containing all children and sub-children

	transform : TE_3D_TRANSFORM
			-- Transform object, storing the model_matrix of the node

	world_transform : TE_3D_TRANSFORM is
			-- Transform object in worldspace
		do
			if is_root then -- happens only if a direct child of root calls parent.world_transform - in this case it returns a unit transform object
				create Result.make
			else
				if parent.is_root = true then
					Result := transform
				else
					Result := parent.world_transform * transform
				end
			end
		end

	name: STRING
			-- Name of the node

	parent: TE_3D_NODE
			-- Parent node (if this is void, this is the root of the hirarchy)

	children : like internal_children is
			-- List of all children nodes in the hierarchy
		do
			Result := internal_children
		end

	--key_frame_player: TE_3D_KEY_FRAME_PLAYER
			-- Keyframe player to use keyframe animations

	--constraints: LINKED_LIST[TE_3D_CONSTRAINT]
			-- List of 3d constraints

feature {TE_3D_NODE} -- Element Change

	set_parent (new_parent: TE_3D_NODE) is
			-- Set `parent' to the `new_parent'.
			-- Must be only called by the `add_child' and `remove_child' feature of another TE_3D_NODE.
		do
			parent := new_parent
		ensure
			parent_is_new_parent: parent = new_parent
		end

feature -- Element change

	set_hierarchy_bounding_box(a_bounding_box: ARRAYED_LIST[EM_VECTOR3D]) is
			-- Set `hierarchy_bounding_box' to `a_bounding_box' without calculating it.
		require
			a_bounding_box_exists: a_bounding_box /= Void
			must_countain_8_vertices: a_bounding_box.count = 8
		do
			hierarchy_bounding_box := a_bounding_box
		ensure
			hierarchy_bounding_box_set: hierarchy_bounding_box = a_bounding_box
		end

	set_name(a_name:STRING) is
			-- Set `name' to `a_name'.
		do
			name := a_name
		ensure
			name_set: name = a_name
		end

	set_as_child_of (a_parent: TE_3D_NODE) is
			-- Add the current node to `a_parent's childlist.
			-- Ensures that the current node is removed from the old parents childlist,
			-- sets the new parent, and makes the actual node a child of the new parent.
		require
			a_parent_exists: a_parent /= Void
			is_not_already_child_of: parent /= a_parent and not a_parent.is_parent_of(Current)
		do
			a_parent.add_child (Current)
		ensure
			is_child_of_new_parent: parent.is_parent_of(Current)
			has_right_parent: parent = a_parent
		end

	add_child (a_child: TE_3D_NODE) is
			-- Add `a_child' to the children of `Current' and set the parent of this child.
		require
			a_child_exists: a_child /= Void
			child_not_yet_added: not is_parent_of (a_child) and a_child.parent /= Current
		do
			-- Remove a_child from a_childs' current parents' child list
			if a_child.parent /= Void then
				a_child.parent.remove_child (a_child)
			end
			-- Add a_child to the current nodes' childlist
			children.force_last (a_child)
			-- Set the childs parent to the current node
			a_child.set_parent (Current)
		ensure
			child_is_inserted: children.has (a_child) = true
			child_has_right_parent: a_child.parent = current
		end

	remove_child (a_child: TE_3D_NODE) is
			-- Remove `a_child' from the list of children.
		require
			has_child: is_parent_of (a_child)
		do
			children.delete (a_child)
			a_child.set_parent (Void)
		ensure
			child_removed: not is_parent_of (a_child)
		end

	remove_all_children is
			-- Remove all children from the children list.
		do
			from
				children.start
			until
				children.off
			loop
				children.item_for_iteration.set_parent (Void)
				children.forth
			end
			children.wipe_out
		end


feature -- Status report

	is_root: BOOLEAN is
			-- Is this node the root?
		do
			if parent = void then
				result := true
			else
				result := false
			end
		end

	is_parent_of (a_node: TE_3D_NODE): BOOLEAN is
			-- Is `a_node' a child of `Current'?
		require
			a_node_exists: a_node /= Void
		do
			from
				children.start
			until
				children.after
			loop
				if children.item_for_iteration = a_node then
					Result := true
				end
				children.forth
			end
		end

	is_hierarchy_renderable: BOOLEAN
			-- Is the hierarchy (including this node as root of the hierarchy) renderable?
			-- If this is false, shadows of children will be disabled!

feature -- Status setting

	enable_hierarchy_renderable is
			-- Set the hierarchy to be renderable.
		do
			is_hierarchy_renderable := True
		ensure
			hierarchy_renderable: is_hierarchy_renderable
		end

	disable_hierarchy_renderable is
			-- Set the hierarchy to not be renderable.
		do
			is_hierarchy_renderable := False
		ensure
			hierarchy_not_renderable: not is_hierarchy_renderable
		end

feature -- Basic operations

	calculate_hierarchy_bounding_box is
			-- updates the hierarchy_bounding_box. DON'T USE THIS EVERY FRAME CAUSE IT'S NOT PERFORMANT!
		local
			max_x, min_x, max_y, min_y, max_z, min_z: DOUBLE
			vec1,vec2,vec3,vec4,vec5,vec6,vec7,vec8: EM_VECTOR3D
			current_node: TE_3D_NODE
			current_vertex: EM_VECTOR3D
		do
			from
				children.start
			until
				children.after
			loop
				current_node := children.item_for_iteration
				current_node.calculate_hierarchy_bounding_box
				from
					current_node.hierarchy_bounding_box.start
				until
					current_node.hierarchy_bounding_box.after
				loop
					current_vertex := worldspace_to_localspace(current_node.localspace_to_worldspace(current_node.hierarchy_bounding_box.item))

					if current_vertex.x > max_x then max_x := current_vertex.x
					elseif current_vertex.x < min_x then min_x := current_vertex.x end
					if current_vertex.y > max_y then max_y := current_vertex.y
					elseif current_vertex.y < min_y then min_y := current_vertex.y end
					if current_vertex.z > max_z then max_z := current_vertex.z
					elseif current_vertex.z < min_z then min_z := current_vertex.z end
					current_node.hierarchy_bounding_box.forth
				end
				children.forth
			end

			--define bounding_box
			vec1.set(max_x,min_y,max_z) --bottom quad
			vec2.set(max_x,min_y,min_z) --bottom quad
			vec3.set(min_x,min_y,min_z) --bottom quad
			vec4.set(min_x,min_y,max_z) --bottom quad
			vec5.set(max_x,max_y,max_z) --top quad
			vec6.set(min_x,max_y,max_z) --top quad
			vec7.set(min_x,max_y,min_z) --top quad
			vec8.set(max_x,max_y,min_z) --top quad

			hierarchy_bounding_box.wipe_out --remove all items
			hierarchy_bounding_box.extend(vec1)
			hierarchy_bounding_box.extend(vec2)
			hierarchy_bounding_box.extend(vec3)
			hierarchy_bounding_box.extend(vec4)
			hierarchy_bounding_box.extend(vec5)
			hierarchy_bounding_box.extend(vec6)
			hierarchy_bounding_box.extend(vec7)
			hierarchy_bounding_box.extend(vec8)
		end



	hierarchy_bounding_sphere is
			-- TODO
		do

		end

feature -- Cloning

	create_deep_instance: like Current is
			-- Cloned instance of the 3D member and instances of all childs and subchilds of the 3d member as hirarchy
		do
			create Result.make_as_child(parent)
			from
				children.start
			until
				children.after
			loop
				Result.add_child (children.item_for_iteration.create_deep_instance)
				children.forth
			end
		end

feature -- Conversion

	worldspace_to_localspace (a_vector: EM_VECTOR3D): EM_VECTOR3D is
			-- Worldspace vector `a_vector' converted to localspace of the current 3D node
			-- `a_vector' MUST BE IN WORLDSPACE!!
		require
			a_vector_exists: a_vector /= Void
		do
			Result := world_transform.inverse_vectortransform(a_vector)
		ensure
			Result_exists: Result /= Void
		end

	localspace_to_worldspace (a_vector: EM_VECTOR3D): EM_VECTOR3D is
			-- Localspace vector `a_vector' converted to worldspace
			-- `a_vector' MUST BE IN LOCAL SPACE OF THE CURRENT 3D_NODE!!
		require
			a_vector_exists: a_vector /= Void
		do
			Result := world_transform.vectortransform(a_vector)
		ensure
			Result_exists: Result /= Void
		end

feature {TE_3D_NODE, TE_RENDERPASS} -- Drawing

	draw is
			-- Draw the hierarchy if `is_hierarchy_renderable'.
		do
			if is_hierarchy_renderable then
				gl_push_matrix

				gl_mult_matrixd(transform.to_opengl)

				--render the node
				render_node

				--draw the children
				from
					children.start
				until
					children.after
				loop
					children.item_for_iteration.draw
					children.forth
				end
				gl_pop_matrix
			end
		end

	render_node is
			-- Perform openGL commands to display the node on the display.
		do
			-- Do nothing, since the simple 3D_node has got no graphical representation
		end

feature {NONE} -- Implementation

	internal_children: DS_ARRAYED_LIST [TE_3D_NODE]

invariant

	children_not_void: children /= Void
	transform_not_void: transform /= Void

end
