local config = ...

function allow_place_protector( node_pos, player )
	local player_name = player:get_player_name( )

	print( "allow_place_protector at " .. minetest.pos_to_string( node_pos ) )

	if city_block.is_near_spawn( node_pos, config.active_block_range + 5 ) and not default.is_superuser( player_name ) then
        	minetest.chat_send_player( player_name, "You are not allowed to place protectors near spawn!" )
		minetest.log( "action", player_name .. " tried to place protector:protect near static spawnpoint " .. minetest.pos_to_string( node_pos ) )
		return false
	end
       	return true
end

function allow_place_explosive( node_pos, player )
	local player_name = player:get_player_name( )

	print( "allow_place_explosive at " .. minetest.pos_to_string( node_pos ) )

	if node_pos.y > config.tnt_place_depth and not default.is_superuser( player_name ) then
        	minetest.chat_send_player( player_name, "You are not allowed to place explosives above " .. config.tnt_place_depth .. "!" )
		minetest.log( "action", player_name .. " tried to place tnt:tnt above " .. config.tnt_place_depth )
		return false
	end
	return true
end

function allow_punch_explosive( node_pos, player )
	local player_name = player:get_player_name( )

	print( "allow_punch_explosive at " .. minetest.pos_to_string( node_pos ) )

	if node_pos.y > config.tnt_place_depth and player:get_wielded_item( ):get_name( ) == "default:torch" and not default.is_superuser( player_name ) then
        	minetest.chat_send_player( player_name, "You are not allowed to ignite explosives above " .. config.tnt_place_depth .. "!" )
		minetest.log( "action", player_name .. " tried to ignite tnt:tnt above " .. config.tnt_place_depth )
		player:set_hp( 0 )
		return false
	end
	return true
end

function allow_place_water( pos, player )
	local player_name = player:get_player_name( )
	local block = city_block.find_nearby_block( pos, "allow_water" )

	print( "allow_place_water at " .. minetest.pos_to_string( pos ) )

	if block and not default.is_superuser( player_name ) then
        	minetest.chat_send_player( player_name, "You are not allowed to place water in town!" )
		minetest.chat_send_player( block.owner, "Player " .. player_name .. " attempted to place water in town at " .. minetest.pos_to_string( pos ) .. "." )
		minetest.log( "action", player_name .. " tried to place default:water_source within city boundaries " .. minetest.pos_to_string( pos ) )

		city_block.record_block_metric( block, "water" )
		return false

	elseif pos.y > config.water_place_depth and not minetest.check_player_privs( player, "water" ) then
        	minetest.chat_send_player( player_name, "You are not allowed to place water above " .. config.water_place_depth .. "!" )
		minetest.log( "action", player_name .. " tried to place default:water_source above " .. config.water_place_depth )
		return false
	end
       	return true
end

function allow_place_lava( pos, player )
	local player_name = player:get_player_name( )
	local block = city_block.find_nearby_block( pos, "allow_lava" )

	print( "allow_place_lava at " .. minetest.pos_to_string( pos ) )

	if block and not default.is_superuser( player_name ) then
        	minetest.chat_send_player( player_name, "You are not allowed to place lava in town!" )
		minetest.chat_send_player( block.owner, "Player " .. player_name .. " attempted to place lava in town at " .. minetest.pos_to_string( pos ) .. "." )

		minetest.log( "action", player_name .. " tried to place default:lava_source within city boundaries " .. minetest.pos_to_string( pos ) )
		city_block.record_block_metric( block, "lava" )
		return false

	elseif pos.y > config.lava_place_depth and not minetest.check_player_privs( player, "lava" ) then
	        minetest.chat_send_player( player_name, "You are not allowed to place lava above " .. config.lava_place_depth .. "!" )
		minetest.log( "action", player_name .. " tried to place default:lava_source above " .. config.lava_place_depth )
		return false
	end
	return true
end

minetest.override_item( "tnt:tnt", {
	allow_place = allow_place_explosive,
	allow_punch = allow_punch_explosive
} )

minetest.override_item( "protector:protect", {
	allow_place = allow_place_protector
} )

minetest.override_item( "protector:protect2", {
	allow_place = allow_place_protector
} )

minetest.override_item( "protector:protect3", {
	allow_place = allow_place_protector
} )

minetest.override_item( "bucket:bucket_water", {
	allow_place = allow_place_water
} )

minetest.override_item( "bucket:bucket_lava", {
	allow_place = allow_place_lava
} )

minetest.override_item( "default:water_source", {
	allow_place = allow_place_water
} )

minetest.override_item( "default:lava_source", {
	allow_place = allow_place_lava
} )
