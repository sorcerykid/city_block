City Block II Mod v2.1
By Leslie E. Krause

City Block II disables use of water and lava buckets within a designated area and sends 
aggressive players to a central jail. The mod was inspired by the original "city_block", 
developed by lag01 for the just test server.

The default behavior of the city block is to intercept placement of lava buckets, lava 
nodes, water buckets, and water nodes according to the following validation logic (this 
is for lava, but the conditions are the same for water):

   1. If player has "server" privilege, then always allow placement of lava.
   2. If player is below -250 meters, then always allow placement of lava.
   3. Otherwise, check permissions of the most restrictive city block in range.
   4. If lava buckets are permitted by city block and player has "lava" privilege, then 
      allow placement of lava.
   5. Otherwise deny placement of lava under any other conditions.

There are also restrictions on TNT nodes (cannot be placed nor ignited above -500 meters) 
and on Protection nodes (cannot be placed anywhere closer than 21 meters from the world 
origin (0,0,0), which is usually spawn. This validation logic can be fully customized 
according to your world needs simply by editing the "hooks.lua" and "config.lua" files.

To craft a city block, you will need to arrange seven sandstone blocks in a square around 
one mese block in the craft grid (this is a less expensive recipe than the original mod, 
which hopefully encourages players to co-operatively protect public spaces from griefing.

The range of each city block is 21 meters in all four cardinal directions, extending
infinitely upward, but downward only to -100 meters. Placing a city block at any depth
below -100 will result in it being non-functional.

As a convenience, you can punch the city block to activate the boundary display which can 
aid in more accurate placement.

By right-clicking on a city block, you can override the default protection behavior and 
monitor the corresponding interception metrics.

 o Disable Jail on PvP
 o Allow Water Buckets
 o Allow Lava Buckets

Keep in mind, if you install this mod in a world that has city blocks from the original
"city_block" mod, then they will continue to function as expected. However, the interface 
to override the default protection behavior and to monitor the interception metrics will 
be unavailable until you manually dig and replace the city block.


Repository
----------------------

Browse source code...
  https://bitbucket.org/sorcerykid/city_block

Download archive...
  https://bitbucket.org/sorcerykid/city_block/get/master.zip
  https://bitbucket.org/sorcerykid/city_block/get/master.tar.gz

Compatability
----------------------

Minetest 0.4.14+ required

Dependencies
----------------------

Default Mod (required)
  https://github.com/minetest-game-mods/default

Protector Redo Mod (optional)
  https://notabug.org/TenPlus1/protector

TNT Mod (optional)
  https://github.com/minetest-game-mods/tnt

Bucket Mod (required)
  https://github.com/minetest-game-mods/bucket

ActiveFormspecs Mod (required)
  https://bitbucket.org/sorcerykid/formspecs

Job Control Mod (required)
  https://bitbucket.org/sorcerykid/cronjob

Configuration Panel Mod (required)
  https://bitbucket.org/sorcerykid/config

Installation
----------------------

  1) Unzip the archive into the mods directory of your game.
  2) Rename the city_block-master directory to "registry".
  3) Create a file named "city_blocks.txt" in the world directory.
  4) Set the permissions of the file to be writable by Minetest.

Source Code License
----------------------------------------------------------

GNU Lesser General Public License v3 (LGPL-3.0)

Copyright (c) 2016, AndrejIT
Copyright (c) 2016-2020, Leslie E. Krause

This program is free software; you can redistribute it and/or modify it under the terms of
the GNU Lesser General Public License as published by the Free Software Foundation; either
version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

http://www.gnu.org/licenses/lgpl-2.1.html

Multimedia License (textures, sounds, and models)
----------------------------------------------------------

Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)

   /textures/cityblock_cityblock.png
   created by AndrejIT
   obtained from https://github.com/AndrejIT/city_block

   /textures/cityblock_cityblock.png
   created by TenPlus1
   obtained from https://notabug.org/TenPlus1/protector

You are free to:
Share — copy and redistribute the material in any medium or format.
Adapt — remix, transform, and build upon the material for any purpose, even commercially.
The licensor cannot revoke these freedoms as long as you follow the license terms.

Under the following terms:

Attribution — You must give appropriate credit, provide a link to the license, and
indicate if changes were made. You may do so in any reasonable manner, but not in any way
that suggests the licensor endorses you or your use.

No additional restrictions — You may not apply legal terms or technological measures that
legally restrict others from doing anything the license permits.

Notices:

You do not have to comply with the license for elements of the material in the public
domain or where your use is permitted by an applicable exception or limitation.
No warranties are given. The license may not give you all of the permissions necessary
for your intended use. For example, other rights such as publicity, privacy, or moral
rights may limit how you use the material.

For more details:
http://creativecommons.org/licenses/by-sa/3.0/
