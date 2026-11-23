NoIndoorRespawn = NoIndoorRespawn or {}

local LOG_PREFIX = "[NoIndoorRespawn] "

local Utils = {}
NoIndoorRespawn.Utils = Utils

function Utils.Log(message)

    print(LOG_PREFIX .. message)

end

function Utils.RoomDefOf(square)

    if square == nil then
        return nil
    end

    local room = square:getRoom()
    if room == nil then
        return nil
    end

    return room:getRoomDef()

end

function Utils.RoomName(room_def)

    if room_def == nil then
        return "?"
    end

    return tostring(room_def:getName())

end

function Utils.SquareToString(square)

    if square == nil then
        return "?"
    end

    return string.format("%s,%s,%s", square:getX(), square:getY(), square:getZ())

end
