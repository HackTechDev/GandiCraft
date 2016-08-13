-- function.lua


function GetTimestampFromString(timestring) --Returns the Lua timestamp from a string which is formatted as "YYYY-mm-dd HH:MM:SS"
	local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)";
	local year, month, day, hour, minute, second = timestring:match(pattern);
	local convertedTimestamp = os.time({year = year, month = month, day = day, hour = hour, min = minute, sec = second});

	return convertedTimestamp;
end

function DisplayVersion(Split, Player)
    if not (Player == nil) then
        Player:SendMessageInfo("GandiCraft version: " .. PLUGIN:GetVersion());
    else
        LOG("GandiCraft version: " .. PLUGIN:GetVersion());
    end

    return true;
end
