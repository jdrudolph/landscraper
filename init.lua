-- Convert a lua table into a lua syntactically correct string
function table_to_string(tbl)
    local result = "{"
    for k, v in pairs(tbl) do
        -- Check the key type (ignore any numerical keys - assume its an array)
        if type(k) == "string" then
            result = result.."[\""..k.."\"]".."="
        end

        -- Check the value type
        if type(v) == "table" then
            result = result..table_to_string(v)
        elseif type(v) == "boolean" then
            result = result..tostring(v)
        else
            result = result.."\""..v.."\""
        end
        result = result..","
    end
    -- Remove leading commas from the result
    if result ~= "" then
        result = result:sub(1, result:len()-1)
    end
    return result.."}"
end

minetest.register_node("stihl:node", {
    description = {"some block"},
    tiles = {"stihl_logo.png",},
	groups = {stihl_chainsawy=1},
})

minetest.register_node("stihl:tree", {
    description = {"tree"},
    tiles = {"stihl_default_tree_top.png", "stihl_default_tree.png"},
	groups = {stihl_chainsawy=1},
})


minetest.register_node("stihl:leaves", {
    description = {"some block"},
    tiles = {"stihl_default_leaves.png",},
	groups = {stihl_blowy=1},
})

minetest.register_node("stihl:autumn_leaves", {
    description = {"some block"},
    tiles = {"stihl_leaves.png", "stihl_default_grass_side.png"},
	groups = {stihl_blowy=1},
})

minetest.register_node("stihl:high_grass", {
    description = {"some block"},
    tiles = {"stihl_default_grass.png","stihl_default_grass_side.png"},
	groups = {choppy=1},
})

minetest.register_tool("stihl:stihl_pick", {
    description = "Stihl chainsaw",
    inventory_image = "stihl_chainsaw1.png",
    visual_scale = 3.0,
    tool_capabilities = {
        max_drop_level=3,
        groupcaps= {
            stihl_chainsawy={times={[1]=4.00, [2]=1.50, [3]=1.00}, uses=150, maxlevel=1}
        }
    }
})

stihl_leaf_blower = {};

minetest.register_tool("stihl:stihl_leaf_blower", {
    description = "Stihl leaf blower",
    inventory_image = "stihl_leaf_blower1.png",
    
    groups = {},

    node_placement_prediction = nil,
    metadata = "stihl:high_grass",
 
     on_use = function(itemstack, user, pointed_thing)
 
        return stihl_leaf_blower.replace(itemstack, user, pointed_thing, above );
     end,
 })
 
 
blocks_file = io.output(minetest.get_worldpath().."\\blocks.txt")
stihl_leaf_blower.replace = function(itemstack, user, pointed_thing, mode )
        if( user == nil or pointed_thing == nil) then
           return nil;
        end
  
        if( pointed_thing.type ~= "node" ) then
           minetest.chat_send_all("  Error: No node. "..pointed_thing.type);
           return nil;
        end

        local pos  = minetest.get_pointed_thing_position( pointed_thing, mode );
        local node = minetest.get_node_or_nil( pos );

        if( node.name ~= "stihl:autumn_leaves" ) then
            minetest.chat_send_all("  Error: Kein Laub.");
            return nil;
         end
        
        if( node == nil ) then
           minetest.chat_send_all( "Error: Target node not yet loaded. Please wait a moment for the server to catch up.");
           return nil;
        end
 
        local item = itemstack:to_table();
 
        item["metadata"] = "stihl:high_grass 0 0";
 
        local daten = item[ "metadata"]:split( " " );
        if( #daten < 3 ) then
           daten[2] = 0;
           daten[3] = 0;
        end
 
        minetest.add_node( pos, { name =  daten[1], param1 = daten[2], param2 = daten[3] } );
	blocks_file:write("-,stihl:autumn_leaves,stihl:stihl_leaf_blower\n")
	blocks_file:flush()
        return nil;
     end

minetest.register_on_leaveplayer(function(ObjectRef, timed_out) io.close(blocks_file) end)
minetest.register_on_dignode(
	function(pos, oldnode, digger)
		blocks_file:write("-", ",", oldnode.name, ",", digger:get_wielded_item():get_name(), '\n')
		blocks_file:flush()
	 end)
minetest.register_on_placenode(
	function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
		blocks_file:write("+", ",", newnode.name, ",", '\n')
		blocks_file:flush()
	 end)
minetest.register_node("stihl:node", {
	description = "this is a node, lol",
	tiles = {
		"stihl_logo.png",
	},
	groups = { cracky = 1 }
})
minetest.register_chatcommand("export", {
	privs = {
		interact = true
	},
	func = function(name, param)
		local filename = minetest.get_worldpath() .. "\\".. param
		local vm = minetest.get_voxel_manip()
		local player_pos = minetest.get_player_by_name("singleplayer"):get_pos()
		minetest.chat_send_all("player "..table_to_string(player_pos))
		local pos1 = {x = player_pos.x - 200, y = player_pos.y - 2, z = player_pos.z - 200}
		local pos2 = {x = player_pos.x + 200, y = player_pos.y + 50, z = player_pos.z + 200}
		minetest.chat_send_all("pos1 "..table_to_string(pos1).."pos2 "..table_to_string(pos2))
		local emin, emax = vm:read_from_map(pos1, pos2)
		local data = vm:get_data()
		local a = VoxelArea:new {
			MinEdge = emin,
			MaxEdge = emax
		}
		export_file = io.output(minetest.get_worldpath().."\\export.txt")
		for z = pos1.z, pos2.z do
			for y = pos1.y, pos2.y do
				for x = pos1.x, pos2.x do
					local vi = a:index(x, y, z)
					local node = minetest.get_name_from_content_id(data[vi])
					export_file:write(x , "," , y , "," , z , "," , node , "\n")
					export_file:flush()
				end
			end
		end
		return true, "export done"
	 end
})
