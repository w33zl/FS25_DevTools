PixelSpy = {
	SIZE = 5,
	RANGE = 25,
	densityMaps = {},
	bitVectorMaps = {},
	bitVectorMapsByName = {},
}

local function appendCreateBitVectorMap(bitVectorMap, name)
	PixelSpy.bitVectorMaps[bitVectorMap] = name
	PixelSpy.bitVectorMapsByName[name] = bitVectorMap
end
local oldCreateBitVectorMap = getmetatable(_G).__index.createBitVectorMap
getmetatable(_G).__index.createBitVectorMap = function(...) local res = oldCreateBitVectorMap(...) appendCreateBitVectorMap(res, ...) return res end

local function appendDelete(bitVectorMap)
	if PixelSpy.bitVectorMaps[bitVectorMap] then
		name = PixelSpy.bitVectorMaps[bitVectorMap]
		PixelSpy.bitVectorMapsByName[name] = nil
		PixelSpy.bitVectorMaps[bitVectorMap] = nil
	end
end
local oldDelete = getmetatable(_G).__index.delete
getmetatable(_G).__index.delete = function(...) local res = oldDelete(...) appendDelete(...) return res end


local PixelSpy_mt = Class(PixelSpy)

function PixelSpy.new()
	local self = {}
    setmetatable(self, PixelSpy_mt)
	return self
end

function PixelSpy:drawOverlay(name, targetNode, sizeX, sizeZ)

	local id = PixelSpy.bitVectorMapsByName[name]
		
	if id == nil or id == 0 then
		return
	end

	local densityMap
	if PixelSpy.densityMaps[id] then
		densityMap = PixelSpy.densityMaps[id]
	else
		PixelSpy.densityMaps[id] = {}
		densityMap = PixelSpy.densityMaps[id]
		densityMap.id = id
		densityMap.size = getBitVectorMapSize(id) --getDensityMapSize(id)
		densityMap.scale = g_currentMission.terrainSize / densityMap.size
		densityMap.numChannels = getBitVectorMapNumChannels(id) --getTerrainDetailNumChannels(id)
	end
	
	if densityMap then
	
		local numChannels = densityMap.numChannels
		
		local startWorldX, startWorldZ
		if targetNode then
			startWorldX, _, startWorldZ = getWorldTranslation(targetNode)
		elseif self:raycastGround() then
			startWorldX, startWorldZ = self.target.x, self.target.z
		end
		
		if startWorldX and startWorldZ then
			g_currentMission:addExtraPrintText("Density Map: " .. id)

			local scale = densityMap.scale
			local sizeX = sizeX or PixelSpy.SIZE
			local sizeZ = sizeZ or sizeX or PixelSpy.SIZE
			DebugUtil.drawDebugAreaRectangle(startWorldX-sizeX/2,0,startWorldZ-sizeZ/2, startWorldX+sizeX/2,0,startWorldZ-sizeZ/2, startWorldX-sizeX/2,0,startWorldZ+sizeZ/2, true, 1,1,1)
			
			--print(value .. " = " .. decimalToBinary(value, numChannels) .. " / " .. decimalToBinary(bitShiftRight(bits, numChannels), 6))
			--bitAND(densityBits, 2^numChannels - 1)
			--bitAND(bitShiftRight(densityBits, groundTypeFirstChannel), 2^groundTypeNumChannels - 1)
			
			for x = -sizeX, sizeX do
				for z = -sizeZ, sizeZ do
					local rx, rz = math.floor((startWorldX+x*scale)/scale)*scale, math.floor((startWorldZ+z*scale)/scale)*scale
	
					local densityMapX = (rx + g_currentMission.terrainSize * 0.5) / g_currentMission.terrainSize * densityMap.size
					local densityMapZ = (rz + g_currentMission.terrainSize * 0.5) / g_currentMission.terrainSize * densityMap.size
					
					local bits = getBitVectorMapPoint(id, densityMapX+scale/2, densityMapZ+scale/2, firstChannel or 0, numChannels)
					
					--local bits = getBitVectorMapPoint(id, startWorldX+x*scale, startWorldZ+z*scale, firstChannel or 0, numChannels)
					--local bits = getDensityAtWorldPos(id, startWorldX+x*scale, 0, startWorldZ+z*scale)
					
					local value = bitAND(bits, 2^numChannels - 1)
					--local shift = bitShiftRight(bits, numChannels)
					
					local d = 0.025
					local yg = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, rx+scale/2,0,rz+scale/2)
					if value > 0 then
						DebugUtil.drawDebugAreaRectangle(rx+d,0,rz+d, rx+scale-d,0,rz+d, rx+d,0,rz+scale-d, true, 0,1,0)
						Utils.renderTextAtWorldPosition(rx+scale/2, yg+0.1, rz+scale/2, string.format("%d", value), getCorrectTextSize(0.015), 0, {1,1,1})
						--Utils.renderTextAtWorldPosition(rx+scale/2, yg+0.1, rz+scale/2, string.format("%d - %d", value, shift), getCorrectTextSize(0.015), 0, {1,1,1})
					else
						DebugUtil.drawDebugAreaRectangle(rx+d,0,rz+d, rx+scale-d,0,rz+d, rx+d,0,rz+scale-d, true, 0.15,0.15,0.15)
						--Utils.renderTextAtWorldPosition(rx+scale/2, yg+0.1, rz+scale/2, string.format("%d", value), getCorrectTextSize(0.015), 0, {0.3,0.3,0.3})
						--Utils.renderTextAtWorldPosition(rx+scale/2, yg+0.1, rz+scale/2, string.format("%d - %d", value, shift), getCorrectTextSize(0.015), 0, {0.3,0.3,0.3})
					end
				end
			end
			
		end
		
	end
end


function PixelSpy:cutRaycastCallback(hitObjectId, x, y, z, distance)
	self.targetOnGround = hitObjectId==g_currentMission.terrainRootNode
	self.target = {x=x, y=y, z=z}
	self.distance = distance
end

function PixelSpy:raycastGround()
	self.distance = -1

	local x, y, z = getWorldTranslation(g_currentMission.player.cameraNode)
	local dx, dy, dz = unProject(0.5, 0.5, 1)
	dx, dy, dz = dx-x, dy-y, dz-z
	dx, dy, dz = MathUtil.vector3Normalize(dx, dy, dz)
	local collisionMask = CollisionFlag.DEFAULT + CollisionFlag.STATIC_WORLD + CollisionFlag.VEHICLE

	raycastClosest(x, y, z, dx, dy, dz, "cutRaycastCallback", self.RANGE, self, collisionMask)
	
	return self.distance > 0 and self.targetOnGround
end

local function decimalToBinary(number, desiredLength)
	local binaryString = ""
	local num = math.floor(number)

	repeat
		local remainder = num % 2
		binaryString = remainder .. binaryString
		num = math.floor(num / 2)
	until num == 0

	local currentLength = #binaryString
	local paddingLength = math.max(0, desiredLength - currentLength)

	if paddingLength > 0 then
		binaryString = string.rep("0", paddingLength) .. binaryString
	end

	return binaryString
end