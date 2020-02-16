---
-- Author: Martin Fabík
-- Email: mar.fabik@gmail.com
-- 
-- Free for non-comerecial usage
--
-- GitHub project: https://github.com/LoogleCZ/FS19-DisplayOwner
-- If anyone found errors, please contact me at mar.fabik@gmail.com or report it on GitHub
--
-- version ID   - 1.0.0
-- version date - 2020-02-15
--
-- Internal namespace of this mod is: LDO
--

DisplayOwner = {
	LDO = {
		ownerFarmId    = nil, -- Farm ID - will be mapped to name
		name           = nil, -- Name of the object
		distanceFactor = 2    -- NON-CONFIGURABLE
	}
};

---
--	Update event. We will calculate avaialble objects here
--
-- @param dt - difference between ticks
--
function DisplayOwner:update(dt)
	-- handle picking up of objects
	self.LDO.ownerFarmId = nil;
	self.LDO.name        = nil;
	if g_currentMission ~= nil and g_currentMission.player ~= nil and g_currentMission.player.isControlled then
		local player = g_currentMission.player;
		if player.isClient and not player.isCarryingObject then
			local x,y,z = localToWorld(player.cameraNode, 0,0,1.0);
			local dx,dy,dz = localDirectionToWorld(player.cameraNode, 0,0,-1);
			raycastAll(x,y,z, dx,dy,dz, "objectRaycastCallback", Player.MAX_PICKABLE_OBJECT_DISTANCE*self.LDO.distanceFactor, self);
		end
	end;
end;

---
--	Raycast callback function
--
-- @param hitObjectId
-- @param x
-- @param y
-- @param z
-- @param distance
--
-- @return boolean True if object hit by raycast is valid, thus raycast will continue. False to stop raycast
--
function DisplayOwner:objectRaycastCallback(hitObjectId, x, y, z, distance)
	if hitObjectId ~= g_currentMission.terrainDetailId and Player.PICKED_UP_OBJECTS[hitObjectId] ~= true then
		local object = g_currentMission:getNodeObject(hitObjectId)
		
		if object ~= nil then
			if object.getOwnerFarmId ~= nil and object.getName ~= nil then
				self.LDO.ownerFarmId = object:getOwnerFarmId();
				self.LDO.name        = object:getName();
				-- this will stop raycast (we need only one object)
				return false
			end;
		end;
	end;
	return true;
end

---
--	Draw event. Here we will display our computed values
--
function DisplayOwner:draw()
	if self.LDO.ownerFarmId ~= nil and self.LDO.name ~= nil then
		if self.LDO.ownerFarmId ~= 0 and g_farmManager.farmIdToFarm[self.LDO.ownerFarmId] ~= nil then
			g_currentMission:addExtraPrintText(string.format(
				g_i18n:getText("LDO_object_owner"),
				tostring(self.LDO.name),
				tostring(g_farmManager.farmIdToFarm[self.LDO.ownerFarmId].name)
			));
		end;
	end;
end;

---
--	Register for the game events
--
addModEventListener(DisplayOwner);
