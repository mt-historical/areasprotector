local function cyan(str)
	return minetest.colorize("#00FFFF",str)
end

local function red(str)
	return minetest.colorize("#FF5555",str)
end

minetest.register_node("areasprotector:protector",{
	description = "Protector Block",
	groups = {cracky=1},
	tiles = {
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png^areasprotector_protector.png"
	},
	on_place = function(itemstack,player,pointed)
		local radius = minetest.setting_get("areasprotector_radius") or 8
		local pos = pointed.above
		local pos1 = vector.add(pos,vector.new(radius,radius,radius))
		local pos2 = vector.add(pos,vector.new(-1*radius,-1*radius,-1*radius))
		local name = player:get_player_name()
		local perm,err = areas:canPlayerAddArea(pos1,pos2,name)
		if not perm then
			minetest.chat_send_player(name,red("You are not allowed to protect that area: ")..err)
			return itemstack
		end
		local id = areas:add(name,"Protected by Protector Block",pos1,pos2)
		areas:save()
		local msg = string.format("The area from %s to %s has been protected as #%s",cyan(minetest.pos_to_string(pos1)),cyan(minetest.pos_to_string(pos2)),cyan(id))
		minetest.chat_send_player(name,msg)
		minetest.set_node(pos,{name="areasprotector:protector"})
		local meta = minetest.get_meta(pos)
		local infotext = string.format("Protecting area %d owned by %s",id,name)
		meta:set_string("infotext",infotext)
		meta:set_int("area_id",id)
		meta:set_string("owner",name)
		if not minetest.setting_getbool("creative_mode") then
			itemstack:take_item()
		end
		return itemstack
	end,
	on_destruct = function(pos)
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		local id = meta:get_int("area_id")
		if areas.areas[id] and areas:isAreaOwner(id,owner) then
			areas:remove(id)
			areas:save()
		end
	end,
})

minetest.register_craft({
	output = "areasprotector:protector",
	type = "shapeless",
	recipe = {"default:steelblock","default:steel_ingot"},
})
