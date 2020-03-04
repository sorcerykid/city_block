--------------------------------------------------------
-- Minetest :: City Block II Mod v2.0 (city_block)
--
-- See README.txt for licensing and other information.
-- Copyright (c) 2017-2020, Leslie E. Krause
--
-- ./games/minetest_game/mods/city_block/init.lua
--------------------------------------------------------

city_block = { }

local block_list = { }
local config = minetest.load_config( )
local world_path = minetest.get_worldpath( )
local mod_path = minetest.get_modpath( "city_block" )

---------------------
-- Private Methods --
---------------------

local define_hooks = loadfile( mod_path .. "/hooks.lua" )

local function export_blocks( )
	local data = minetest.serialize( block_list )
	if not data then
		error( "Could not serialize city block data." )
	end

	local file = io.open( world_path .. "/" .. config.filename, "w" )
	if not file then
		error( "Could not save city block data." )
	end
	file:write( data )
	file:close( )
end

local function import_blocks( )
	local file = io.open( world_path .. "/" .. config.filename, "r" )
	if not file then
		error( "Could not load city block data." )
	end

	local data = file:read( "*all" )
	if data == "" then
		block_list = { }   -- initialize if empty file
	else
		block_list = minetest.deserialize( data )
		if type( block_list ) ~= "table" then
			error( "Could not deserialize city block data." )
		end
	end
	file:close( )
end

local function insert_block( pos, owner, options, metrics )
	table.insert( block_list, { pos = pos, owner = owner, options = options, metrics = metrics } )
end

local function remove_block( pos )
	for idx, block in ipairs( block_list ) do
		if vector.equals( block.pos, pos ) then
			table.remove( block_list, idx )
			return true
		end
	end
	return false
end

local function get_block( pos )
	for idx, block in ipairs( block_list ) do
		if vector.equals( block.pos, pos ) then
			return block
		end
	end
	return nil
end

--------------------
-- Public Methods --
--------------------

city_block.is_near_spawn = function ( pos, off )
	return math.abs( config.spawn_pos.x - pos.x ) <= off and math.abs( config.spawn_pos.z - pos.z ) <= off
end

city_block.find_nearby_block = function ( pos, opt )
	for i, block in ipairs( block_list ) do
		local options = block.options or { disable_jail = false, allow_lava = false, allow_water = false }

		if math.abs( block.pos.x - pos.x ) <= config.active_block_range and math.abs( block.pos.z - pos.z ) <= config.active_block_range and block.pos.y >= config.active_block_depth then
			-- short-circuit on first instance of false option
			if not opt or not options[ opt ] then
				return block
			end
		end
	end
	return nil
end

city_block.record_block_metric = function ( block, type )
	-- legacy blocks don't have metrics
	if block.metrics then
		block.metrics[ type ] = block.metrics[ type ] + 1
	end
end

---------------------------
-- Registered Privileges --
---------------------------

minetest.register_privilege( "lava", "Can use buckets of lava.")
minetest.register_privilege( "water", "Can use buckets of water.")

----------------------
-- Registered Nodes --
----------------------

minetest.register_node( "city_block:cityblock", {
	description = "City Block (mark 42x42 area as part of city)",
	tiles = { "cityblock_cityblock.png" },
	is_ground_content = false,
	groups = { cracky = 1, level = 3 },
	sounds = default.node_sound_stone_defaults( ),
	light_source = LIGHT_MAX,
	send_formspec_meta = true,

	on_construct = function ( pos )
		local meta = minetest.get_meta( pos )
		meta:set_int( "oldtime", os.time( ) )
		meta:set_int( "newtime", os.time( ) )
	end,
	after_place_node = function ( pos, placer )
		local player_name = placer:get_player_name( )
		local options = { disable_jail = false, allow_lava = false, allow_water = false }
		local metrics = { jail = 0, lava = 0, water = 0 }

		if pos.y < config.active_block_depth then
			minetest.chat_send_player( player_name, "This city block is below the allowable depth of " .. config.active_block_depth .. "." )
			insert_block( pos, placer:get_player_name( ) )
		else
			minetest.chat_send_player( player_name, "This city block has been activated. Right-click to set options and view metrics." )
			insert_block( pos, placer:get_player_name( ), options, metrics )
		end
		export_blocks( )
	end,
	on_destruct = function ( pos )
		remove_block( pos )
		export_blocks( )
	end,
	on_punch = function ( pos, node, player, pointed_thing )
		minetest.add_entity( pos, "city_block:bounds" )
	end,
	before_open = function ( pos, node, player )
		return { block = get_block( pos ), pos = pos }
	end,
	on_open = function ( state, player )
		local player_name = player:get_player_name( )
		local block = state.block

		if not block or not block.options or not block.metrics then
			minetest.chat_send_player( player_name, "This city block is outdated or defective and must be replaced." )
			return
		elseif block.owner ~= player_name then
			return
		end

		local options = block.options or { disable_jail = false, allow_lava = false, allow_water = false }
		local metrics = block.metrics or { jail = 0, water = 0, lava = 0 }
		local formspec = "size[7.5,4.5]" ..
			default.gui_bg_img ..
			default.gui_slots ..

			"label[0.0,0.0;City Block Properties]" ..
			"box[0.0,0.6;7.3,0.1;#111111]" ..
			"box[0.0,3.6;7.3,0.1;#111111]" ..
			"label[0.0,1.0;Punch stone to show range.]" ..

			string.format( "checkbox[0.0,1.4;disable_jail;Disable Jail on PvP;%s]",
				options.disable_jail and "true" or "false" ) ..
			string.format( "checkbox[0.0,1.9;allow_water;Allow Water Buckets;%s]",
				options.allow_water and "true" or "false" ) ..
			string.format( "checkbox[0.0,2.4;allow_lava;Allow Lava Buckets;%s]",
				options.allow_lava and "true" or "false" ) ..

			"box[3.8,0.8;3.5,2.6;#222222]" ..
			"label[4.2,1.0;Interception Metrics]" ..
			string.format( "label[4.2,1.6;Sent to Jail: %s]", minetest.colorize( "#AAAAAA", metrics.jail ) ) ..
			string.format( "label[4.2,2.1;Water Checks: %s]", minetest.colorize( "#AAAAAA", metrics.water ) ) ..
			string.format( "label[4.2,2.6;Lava Checks: %s]", minetest.colorize( "#AAAAAA", metrics.lava ) ) ..

			"button_exit[3.5,4.0;2.0,0.5;close;Close]"

		state.block = block

		return formspec
	end,
	on_close = function ( state, player, fields )
		if fields.quit then
			export_blocks( )
		elseif fields.disable_jail then
			state.block.options.disable_jail = fields.disable_jail == "true" and true or false
		elseif fields.allow_water then
			state.block.options.allow_water = fields.allow_water == "true" and true or false
		elseif fields.allow_lava then
			state.block.options.allow_lava = fields.allow_lava == "true" and true or false
		end
	end,
} )

minetest.register_node( "city_block:bounds_display", {
	tiles = { "cityblock_display.png^[colorize:#FFFF00" },
	use_texture_alpha = true,
	walkable = false,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			-- west face
			{ -21.5, -1.5, -21.5, -21.5, 1.5, 21.5 },
			-- north face
			{ -21.5, -1.5, 21.5, 21.5, 1.5, 21.5 },
			-- east face
			{ 21.5, -1.5, -21.5, 21.5, 1.5, 21.5 },
			-- south face
			{ -21.5, -1.5, -21.5, 21.5, 1.5, -21.5 },
			-- top face
		--	{ -21.5, 0.55, -21.5, 21.5, 0.55, 21.5 },
		},
	},
	selection_box = {
		type = "regular",
	},
	paramtype = "light",
	groups = { dig_immediate = 3, not_in_creative_inventory = 1 },
	drop = "",
} )

minetest.register_craft( {
	output = 'city_block:cityblock',
	recipe = {
		{ 'default:sandstone', 'default:sandstone', 'default:sandstone' },
		{ 'default:sandstone', 'default:mese', 'default:sandstone' },
		{ 'default:sandstone', 'default:sandstone', 'default:sandstone' },
	}
} )

--------------------------
-- Registered Callbacks --
--------------------------

local attacks = { }	-- victim is first dimension, attacker is second dimension

minetest.register_on_punchplayer( function( player, hitter, time_from_last_punch, tool_capabilities, dir, damage )
	if not hitter or not hitter:is_player( ) then return end

	local hitter_name = hitter:get_player_name( )
	local player_name = player:get_player_name( )
	local player_hp = player:get_hp( );

	-- make exception if attack is in self-defense (hitter provoked by player)
	if attacks[ hitter_name ][ player_name ] or minetest.check_player_privs( hitter_name, "kill" ) then
		return
	end

	local attack_timer = attacks[ player_name ][ hitter_name ]

	if player_hp > 0 and player_hp - damage <= 0 then
		-- player will die, so assess whether penalty is due
		local block = city_block.find_nearby_block( player:getpos( ), "disable_jail" )

		if attack_timer and block then
			attack_timer.cancel( )

--			minetest.sound_play( )
			hitter:setpos( config.jail_pos )
			city_block.record_block_metric( block, "jail" )

			minetest.chat_send_all( "*** " .. hitter_name .. " warned for killing " .. player_name .. " in town." )
			chat_history.add_message( "_infobot", nil, hitter_name .. " warned for killing " .. player_name .. " in town." )
			minetest.log( "action", "Player ".. hitter_name.. " warned for killing in town" )
		end
	else
		-- each subsequent attack expires after 10 seconds
		if attack_timer then
			attack_timer.restart( )
		else
			attack_timer = minetest.after( config.attack_timeout, function ( )
				-- abort if victim is no longer online
				if attacks[ player_name ] then
					attacks[ player_name ][ hitter_name ] = nil
				end
			end )
			attacks[ player_name ][ hitter_name ] = attack_timer
		end
	end
end )

minetest.register_on_joinplayer( function( player )
	local player_name = player:get_player_name( )
	attacks[ player_name ] = { }
end )

minetest.register_on_leaveplayer( function( player, is_timeout )
	local player_name = player:get_player_name( )
	attacks[ player_name ] = nil
end )

-------------------------
-- Registered Entities --
-------------------------

minetest.register_entity( "city_block:bounds",{
	hp_max = 1,
	visual = "wielditem",
	visual_size = { x = 1 / 1.5, y = 1 / 1.5 },
	collisionbox = { 0, 0, 0, 0, 0, 0 },
	physical = false,
	textures = { "city_block:bounds_display" },
	timeout = 10,

	on_step = function( self, dtime )
		self.timeout = self.timeout - dtime

		if self.timeout < 0 then
			self.object:remove( )
		end
	end,
} )

------------------------
-- Launchpad Callback --
------------------------

if launchpad then
	launchpad.register_mod( "city_block", function( player )
		local count = 0
		local owner = player:get_player_name( )

		for i, block in ipairs( block_list ) do
			if block.owner == owner then
				count = count + 1
			end
		end

		return count .. " records found."
	end )
end

--------------------------

define_hooks( config )
import_blocks( )
