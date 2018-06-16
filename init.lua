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
        return nil;
     end