if isClient() then
    return
end

require "NoIndoorRespawn/Utils"

NoIndoorRespawn = NoIndoorRespawn or {}

local Utils = NoIndoorRespawn.Utils

local CHUNK_SIZE = 8

local RespawnGuard = {}
RespawnGuard.Candidates      = {}
RespawnGuard.ZombiesToRemove = {}
RespawnGuard.RoomsFirstSeen  = {}

NoIndoorRespawn.Guard = RespawnGuard

-- First population follows this event
function RespawnGuard.OnSeeNewRoom(room)

    if room == nil then
        return
    end

    local room_def = room:getRoomDef()
    if room_def ~= nil then
        RespawnGuard.RoomsFirstSeen[room_def:getID()] = true
    end

end

function RespawnGuard.OnZombieCreate(zombie)

    if zombie == nil or not RespawnGuard.IsRespawnOff() then
        return
    end

    local ok, exc = pcall(RespawnGuard.NoteCandidate, zombie)
    if not ok then
        Utils.Log(string.format("error in OnZombieCreate: %s", tostring(exc)))
    end

end

function RespawnGuard.OnLoadChunk(chunk)

    if RespawnGuard.IsRespawnOff() then
        local ok, exc = pcall(RespawnGuard.MarkExploredRooms, chunk)
        if not ok then
            Utils.Log(string.format("error while marking rooms: %s", tostring(exc)))
        end
    end

    if #RespawnGuard.Candidates == 0 then
        return
    end

    local rest = {}
    for index, candidate in ipairs(RespawnGuard.Candidates) do
        if candidate.Chunk == chunk then
            table.insert(RespawnGuard.ZombiesToRemove, candidate.Zombie)
        else
            table.insert(rest, candidate)
        end
    end
    RespawnGuard.Candidates = rest

end

function RespawnGuard.OnTick()

    -- candidates left until now didn't come from a chunk load
    RespawnGuard.RoomsFirstSeen = {}
    RespawnGuard.Candidates     = {}

    if #RespawnGuard.ZombiesToRemove == 0 then
        return
    end

    local zombies = RespawnGuard.ZombiesToRemove
    RespawnGuard.ZombiesToRemove = {}

    for index, zombie in ipairs(zombies) do
        local ok, exc = pcall(RespawnGuard.RemoveZombie, zombie)
        if not ok then
            Utils.Log(string.format("error while removing zombie: %s", tostring(exc)))
        end
    end

end

function RespawnGuard.IsRespawnOff()

    if SandboxVars == nil or SandboxVars.ZombieConfig == nil then
        return false
    end

    local respawn_hours = SandboxVars.ZombieConfig.RespawnHours
    return respawn_hours == nil or respawn_hours <= 0

end

-- Only notes, the zombie isn't in the world yet
function RespawnGuard.NoteCandidate(zombie)

    local square   = zombie:getCurrentSquare()
    local room_def = Utils.RoomDefOf(square)
    if room_def == nil or not room_def:isExplored() then
        return
    end

    if RespawnGuard.RoomsFirstSeen[room_def:getID()] then
        return
    end

    table.insert(RespawnGuard.Candidates, { Zombie = zombie, Chunk = square:getChunk() })

end

-- All levels, spawning only hits floors near a player
function RespawnGuard.MarkExploredRooms(chunk)

    local seen = {}
    for z = chunk:getMinLevel(), chunk:getMaxLevel() do
        for x = 0, CHUNK_SIZE - 1 do
            for y = 0, CHUNK_SIZE - 1 do
                local room_def = Utils.RoomDefOf(chunk:getGridSquare(x, y, z))
                if room_def ~= nil and not seen[room_def] then
                    seen[room_def] = true
                    if room_def:isExplored() and not chunk:isSpawnedRoom(room_def:getID()) then
                        chunk:addSpawnedRoom(room_def:getID())
                    end
                end
            end
        end
    end

end

function RespawnGuard.RemoveZombie(zombie)

    if zombie:isDead() or zombie:isReanimatedPlayer() then
        return
    end

    local square    = zombie:getCurrentSquare()
    local room_name = Utils.RoomName(Utils.RoomDefOf(square))
    local location  = Utils.SquareToString(square)

    zombie:removeFromWorld()
    zombie:removeFromSquare()

    local message = "removed zombie re-spawned on chunk load in explored room '%s' at %s"
    Utils.Log(string.format(message, room_name, location))

end

Events.OnSeeNewRoom.Add(RespawnGuard.OnSeeNewRoom)
Events.OnZombieCreate.Add(RespawnGuard.OnZombieCreate)
Events.LoadChunk.Add(RespawnGuard.OnLoadChunk)
Events.OnTick.Add(RespawnGuard.OnTick)

Utils.Log("loaded (active only while zombie respawn is off)")
