-- Gandi CLI: Assemble a server
-- Assemble Gandi server
-- http://api-docs.cuberite.org/Globals.html 

function AssembleServer(World, Player)
    LOG("Assemble server")
    y = Player:GetPosY() 

    for x  = Player:GetPosX() + 2, Player:GetPosX() + 4 
    do
        for z = Player:GetPosZ() + 2, Player:GetPosZ() + 4 
        do
            setBlock(UpdateQueue, x, y, z, E_BLOCK_STONE, E_META_STONE_GRANITE)
        end
    end

    for x  = Player:GetPosX() + 2, Player:GetPosX() + 4 
    do
        for z = Player:GetPosZ() + 2, Player:GetPosZ() + 4 
        do
            setBlock(UpdateQueue, x, y + 1, z, E_BLOCK_WOOL,E_META_WOOL_WHITE)
        end
    end


    -- Lever
    setBlock(UpdateQueue, Player:GetPosX() + 2, Player:GetPosY() + 2,  Player:GetPosZ() + 2, 69, 14) 
    setBlock(UpdateQueue, Player:GetPosX() + 2, Player:GetPosY() + 2,  Player:GetPosZ() + 3, 69, 14) 
    setBlock(UpdateQueue, Player:GetPosX() + 2, Player:GetPosY() + 2,  Player:GetPosZ() + 4, 69, 14) 

    -- Button
    setBlock(UpdateQueue, Player:GetPosX() + 3, Player:GetPosY() + 2, Player:GetPosZ() + 2, 77, 5)
    setBlock(UpdateQueue, Player:GetPosX() + 3, Player:GetPosY() + 2, Player:GetPosZ() + 3, 77, 5)
    setBlock(UpdateQueue, Player:GetPosX() + 3, Player:GetPosY() + 2, Player:GetPosZ() + 4, 77, 5)

    signPosX = Player:GetPosX() + 2
    signPosY = y + 1
    signPosZ = Player:GetPosZ() + 1
    addSign(Player, signPosX,signPosY,signPosZ)
    updateSign(UpdateQueue,signPosX,signPosY,signPosZ, "", "Player", "", "", 2)

    signPosX = Player:GetPosX() + 3
    signPosY = y + 1
    signPosZ = Player:GetPosZ() + 1
    addSign(Player, signPosX,signPosY,signPosZ)
    updateSign(UpdateQueue,signPosX,signPosY,signPosZ, "Server01", "192.16.1.1", "", "", 2)

    signPosX = Player:GetPosX() + 4
    signPosY = y + 1
    signPosZ = Player:GetPosZ() + 1
    addSign(Player, signPosX,signPosY,signPosZ)
    updateSign(UpdateQueue,signPosX,signPosY,signPosZ, "CPU: 16", "Mem: 24", "", "", 2)

end


function addSign(Player, signPosX,signPosY,signPosZ)
    Player:GetWorld():SetBlock(signPosX,signPosY,signPosZ, E_BLOCK_WALLSIGN, E_META_CHEST_FACING_ZM)
    Player:GetWorld():SetSignLines(signPosX,signPosY,signPosZ, "", "", "", "")
    return true
end

-- Gandi CLI: Disassemble a server
-- Disassemble Gandi server
-- http://api-docs.cuberite.org/Globals.html 
function DisassembleServer(World, Player)
    LOG("Disassemble server")

    LOG(tostring(CURRENTSERVERBLOCKX) .. "," .. tostring( CURRENTSERVERBLOCKY) .. "," .. tostring( CURRENTSERVERBLOCKZ))

    y = CURRENTSERVERBLOCKY 

    for x  = CURRENTSERVERBLOCKX, CURRENTSERVERBLOCKX + 2
    do
        for z = CURRENTSERVERBLOCKZ, CURRENTSERVERBLOCKZ + 2 
        do
            digBlock(UpdateQueue, x, y, z)
        end
    end


    for x  = CURRENTSERVERBLOCKX, CURRENTSERVERBLOCKX + 2
    do
        for z = CURRENTSERVERBLOCKZ, CURRENTSERVERBLOCKZ + 2 
        do
            digBlock(UpdateQueue, x, y - 1, z)
        end
    end


    for x  = CURRENTSERVERBLOCKX, CURRENTSERVERBLOCKX + 2
    do
        for z = CURRENTSERVERBLOCKZ, CURRENTSERVERBLOCKZ + 2 
        do
            digBlock(UpdateQueue, x, y - 2, z)
        end
    end

end


-- Server creation
function CreateServer(Split, Player)
    if (Split[3] == nil) then
        Player:SendMessageFailure("Usage: /gandi create <name>");
        return true;
    end

    local sql = "INSERT INTO servers (player, name, posx, posy, posz, ipv4) VALUES (?, ?, ?, ?, ?, ?)";
    local parameters = {Player:GetName(), Split[3], CURRENTSERVERBLOCKX, CURRENTSERVERBLOCKY, CURRENTSERVERBLOCKZ, "127.0.0.1"};

    ExecuteStatement(sql, parameters);

    Player:SendMessageSuccess("Created a new server called " .. Split[3]);

    return true;
end


-- Server deletetion
function DeleteServer(Split, Player)
    if (Split[3] == nil) then
        Player:SendMessageFailure("Usage: /gandi delete <name>");
        return true;
    end

    -- local sql = "DELETE FROM servers WHERE player = ? AND name = ?";
    local sql = "DELETE FROM servers WHERE player = ? AND name = ? AND posx = ? AND  posy = ? AND  posz = ?";
    local parameters = {Player:GetName(), Split[3], CURRENTSERVERBLOCKX, CURRENTSERVERBLOCKY, CURRENTSERVERBLOCKZ};

    ExecuteStatement(sql, parameters);

    Player:SendMessageSuccess("Deleted a server called " .. Split[3]);

    return true;
end


-- Server updating
-- (name, field, value)
-- /gandi update server01 ipv4 6.6.6.6

function UpdateServer(Split, Player)
    LOG("Update server with name: " .. Split[3])
    
    if Split[4] == "ipv4" then
        local sql = "UPDATE servers SET ipv4 = ? WHERE name = ?";
        local parameters = {Split[5], Split[3]};
        ExecuteStatement(sql, parameters);
    end

    Player:SendMessageSuccess("Updating done")   
end


-- Server information
function GetServer(Split, Player)
    if (Split[3] == nil) then
        Player:SendMessageFailure("Usage: /gandi get <name>");
        return true;
    end

    local sql = "SELECT name, ipv4 FROM servers WHERE name = ? AND player = ?";
    local parameters = {Split[3], Player:GetName()}
    local server = ExecuteStatement(sql, parameters)[1];

    Player:SendMessageSuccess("[ Server ]")

    if (server == nil) then
        Player:SendMessageSuccess("Server information: Server unknown")
    else
        Player:SendMessageSuccess("Server information: " .. server[1] .. ":" .. server[2])
    end
        
    return true;
end


-- Server list
function ListServer(Split, Player)
    local sql = "SELECT name, ipv4 FROM servers WHERE player = ?"
    local parameters = {Player:GetName()}
    local servers = ExecuteStatement(sql, parameters);

    Player:SendMessageSuccess("[ Servers ]")

    for key, value in pairs(servers) do
        Player:SendMessageSuccess(value[1] .. ":" .. value[2]);
    end

    return true;
end
