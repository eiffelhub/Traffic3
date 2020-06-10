note
	description: "XML parser for the traffic map data."
	date: "$Date: 2007-09-24 11:12:13 +0200 (Пн, 24 сен 2007) $"
	revision: "$Revision: 931 $"

class
	TRAFFIC_MAP_PARSER

inherit

	TRAFFIC_XML_INPUT_FILE_PARSER

	TRAFFIC_NODE_PROCESSOR_REGISTRY

create
	make_with_factory

feature -- Initialization

	make_with_factory (a_traffic_map_factory: TRAFFIC_MAP_FACTORY)
			-- Create parser with `a_traffic_map_factory'.
		require
			a_traffic_map_factory_exists: a_traffic_map_factory /= Void
		do
			make
			from
				Processor_registry.start
			until
				Processor_registry.off
			loop
				Processor_registry.item_for_iteration.set_map_factory (a_traffic_map_factory)
				Processor_registry.forth
			end
		end

feature -- Status report

	can_process: BOOLEAN
			-- Can document tree be processed?
		do
			Result := is_parsed and then has_processor (root_element.name)
		end

feature -- Basic operations

	process
			-- Process document tree.
		local
			p: TRAFFIC_NODE_PROCESSOR
		do
			p := processor (root_element.name)
			p.set_source (root_element)
			if p.has_error then
				set_error (p.error_code, p.slots)
				is_parsed := False
			end
			if not has_error then
				p.process
				if p.has_error then
					set_error (p.error_code, p.slots)
					is_parsed := False
				end
			end
			set_map_factory (p.map_factory)
		end

invariant

	can_process_definition: can_process = (is_parsed and
			has_processor (root_element.name))

end
