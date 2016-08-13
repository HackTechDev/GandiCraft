-- main.lua


GROUND_LEVEL = 63

GROUND_MIN_X = -50
GROUND_MAX_X = 50
GROUND_MIN_Z = -50
GROUND_MAX_Z = 50

MAX_BLOCK_UPDATE_PER_TICK = 50

UpdateQueue = nil

PLUGIN = nil;

CANCREATESERVER = 0;

CURRENTSERVERBLOCKX = 0;
CURRENTSERVERBLOCKY = 0;
CURRENTSERVERBLOCKZ = 0;


-- Production
PRODUCTION = 1


-- Tick is triggered by cPluginManager.HOOK_TICK
function Tick(TimeDelta)
    UpdateQueue:update(MAX_BLOCK_UPDATE_PER_TICK)
end


-- Plugin initialization
function Initialize(Plugin)
    PLUGIN = Plugin;
    PLUGIN:SetName("GandiCraft");
    PLUGIN:SetVersion(1);

    -- Load the Info shared library:
    dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua");
  
    UpdateQueue = NewUpdateQueue()

    -- Hooks

    cPluginManager:AddHook(cPluginManager.HOOK_WORLD_STARTED, WorldStarted);
    cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_JOINED, PlayerJoined);
    cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_USING_BLOCK, PlayerUsingBlock);

    cPluginManager:AddHook(cPluginManager.HOOK_CHUNK_GENERATING, OnChunkGenerating);

    cPluginManager:AddHook(cPluginManager.HOOK_WEATHER_CHANGING, OnWeatherChanging);

    cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_FOOD_LEVEL_CHANGE, OnPlayerFoodLevelChange);

    cPluginManager:AddHook(cPluginManager.HOOK_SPAWNING_MONSTER, OnSpawningMonster);

    cPluginManager:AddHook(cPluginManager.HOOK_TICK, Tick);

    -- Command Bindings

    cPluginManager.BindCommand("/gandi", "*", GandiCommand, " - Gandi CLI commands")
    cPluginManager.BindCommand("/structure", "*", StructureCommand, " - Structure CLI commands")

    -- Web request
    Plugin:AddWebTab("Gandi",HandleRequest_Gandi)

    -- make all players admin
    cRankManager:SetDefaultRank("Admin")

    ini = cIniFile();

    --Create a new config if this is the first load, otherwise load the existing config file
    LoadConfig();

    --Create a new database if this is the first load, otherwise open the existing one
    if not (cFile:IsFile(Plugin:GetLocalFolder() .. cFile:GetPathSeparator() .. config.dbname)) then -- If true, means database is deleted, or the plugin runs for the first time
        LOG("[" .. Plugin:GetName() .. "] It looks like this is the first time running this plugin. Creating database...")
    else
        LOG("[" .. Plugin:GetName() .. "] Opening database");
    end 
    db = sqlite3.open(PLUGIN:GetLocalFolder() .. cFile:GetPathSeparator() .. config.dbname);
    ConfigureDatabase();

    
    LOG("Initialised " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())

    return true
end


--
function OnDisable() -- Gets called when the plugin is unloaded, mostly when shutting down the server
    LOG("[" .. PLUGIN:GetName() .. "] Disabling " .. PLUGIN:GetName() .. " v" .. PLUGIN:GetVersion());
    db:close();
end


-- No monster
function OnSpawningMonster()
    return true
end


--
function WorldStarted(World)
    y = GROUND_LEVEL
    -- just enough to fit one container
    -- then it should be dynamic
    for x = GROUND_MIN_X, GROUND_MAX_X
    do
        for z = GROUND_MIN_Z,GROUND_MAX_Z
        do
            setBlock(UpdateQueue, x, y, z, E_BLOCK_WOOL, E_META_WOOL_WHITE)
        end
    end 
end


--
function PlayerJoined(Player)
    -- enable flying
    Player:SetCanFly(true)

    -- refresh containers
    LOG("player joined")
end


-- 
function PlayerUsingBlock(Player, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ, BlockType, BlockMeta)
    LOG("Using block: " .. tostring(BlockX) .. "," .. tostring(BlockY) .. "," .. tostring(BlockZ) .. " - " .. tostring(BlockType) .. " - " .. tostring(BlockMeta))
    CURRENTSERVERBLOCKX = BlockX;
    CURRENTSERVERBLOCKY = BlockY;
    CURRENTSERVERBLOCKZ = BlockZ;

    -- lever: 1->OFF 9->ON (in that orientation)
    -- lever
    if BlockType == 69
    then
        Player:SendMessage("Gandi CLI:")
        Player:SendMessage("Using block: " .. tostring(BlockX) .. "," .. tostring(BlockY) .. "," .. tostring(BlockZ) .. " - " .. tostring(BlockType) .. " - " .. tostring(BlockMeta))
        
        -- Activation lever
        if BlockMeta == 14
        then
            CANCREATESERVER = 1
            Player:SendMessage("Server can be create : " .. CANCREATESERVER)
            LOG("Server can be create : " .. CANCREATESERVER)
        end    

        -- Desactivation lever
        if BlockMeta == 6
        then
            CANCREATESERVER = 0
            Player:SendMessage("Server can not be create : " .. CANCREATESERVER)
            LOG("Server can not be create : " .. CANCREATESERVER)  
        end    

    end

    if BlockType == 77
    then
        Player:SendMessage("Gandi CLI:")
        Player:SendMessage("Using block: " .. tostring(BlockX) .. "," .. tostring(BlockY) .. "," .. tostring(BlockZ) .. " - " .. tostring(BlockType) .. " - " .. tostring(BlockMeta))
    end
end


--
function StructureCommand(Split, Player)
    LOG("StructureCommand")

    if table.getn(Split) > 0
    then
        LOG("Split[1]: " .. Split[1])

        if Split[1] == "/structure"
        then
            Structure(World, Player, Split)
        end
    end

    return true
end 


--
function GandiCommand(Split, Player)

    if table.getn(Split) > 0
    then

        LOG("Split[1]: " .. Split[1])

        if Split[1] == "/gandi"
        then
            if table.getn(Split) > 1
            then
                -- Assemble a server
                if Split[2] == "assemble"
                then
                    -- /gandi assemble server
                    if Split[3] == "server" 
                    then
                        EntireCommand = table.concat(Split, "_")
                        -- remove '/' at the beginning
                        command = string.sub(EntireCommand, 2, -1)
                        
                        Player:SendMessage("Gandi CLI: " .. command)

                        AssembleServer(World, Player) 
                    else
                        Player:SendMessage("Gandi CLI: assemble error command")
                    end
                end

                -- Disassemble a server
                if Split[2] == "disassemble"
                then
                    -- /gandi disassemble server
                    if Split[3] == "server" 
                    then
                        EntireCommand = table.concat(Split, "_")
                        -- remove '/' at the beginning
                        command = string.sub(EntireCommand, 2, -1)
                        
                        Player:SendMessage("Gandi CLI: " .. command)

                        DisassembleServer(World, Player) 
                    else
                        Player:SendMessage("Gandi CLI: disassemble error command")
                    end
                end

                -- Create/Initialize a server 
                -- with a fake ip address      
                -- /gandi create <server name>         
                if Split[2] == "create" 
                then
                    command = "GandiCreateServer"

                    CreateServer(Split, Player)

                    -- Create the server via the Gandi API
                    -- Assign the "real life" ip address
                    if PRODUCTION == 1
                    then
                        Player:SendMessage("Execute Python script")
                        r = os.execute("python3 " .. PLUGIN:GetLocalFolder() .. "/gandiapi/" .. command .. ".py" .. " " .. Split[3] .. " &")
                    end

                    Player:SendMessage("Gandi CLI: " .. command)
    
                    -- LOG("executed: " .. command .. " -> " .. tostring(r))
                end

                -- Delete a server 
                -- /gandi delete <server name>
                if Split[2] == "delete" 
                then
                    command = "GandiDeleteServer"

                    DeleteServer(Split, Player)

                    -- Delete the server via the Gandi API
                    if PRODUCTION == 1
                    then
                        Player:SendMessage("Execute Python script")
                        r = os.execute("python3 " .. PLUGIN:GetLocalFolder() .. "/gandiapi/" .. command .. ".py" .. " " .. Split[3] .. " &")
                    end

                    Player:SendMessage("Gandi CLI: " .. command)
    
                    LOG("executed: " .. command .. " -> " .. tostring(r))
                end

                --               (name, field, value)
                -- /gandi update server01 ipv3 6.6.6.6
                if Split[2] == "update" 
                then
                    Player:SendMessage("Gandi CLI: update")
    
                    UpdateServer(Split, Player)
                end

                if Split[2] == "get" 
                then
                    EntireCommand = table.concat(Split, "_")
                    -- remove '/' at the beginning
                    command = string.sub(EntireCommand, 2, -1)
                    
                    GetServer(Split, Player)

                    Player:SendMessage("Gandi CLI: " .. command)
                end

                if Split[2] == "list" 
                then
                    EntireCommand = table.concat(Split, "_")
                    -- remove '/' at the beginning
                    command = string.sub(EntireCommand, 2, -1)
                    
                    ListServer(Split, Player)

                    Player:SendMessage("Gandi CLI: " .. command)
                end

            end
        end
    end

    return true
end


-- Generate flat world
function OnChunkGenerating(World, ChunkX, ChunkZ, ChunkDesc)
    -- override the built-in chunk generator
    -- to have it generate empty chunks only
    ChunkDesc:SetUseDefaultBiomes(false)
    ChunkDesc:SetUseDefaultComposition(false)
    ChunkDesc:SetUseDefaultFinish(false)
    ChunkDesc:SetUseDefaultHeight(false)
    return true
end


-- Make it sunny all the time!
function OnWeatherChanging(World, Weather)
    return true, wSunny
end


--
function OnPlayerFoodLevelChange(Player, NewFoodLevel)
    -- Don't allow the player to get hungry
    return true, Player, NewFoodLevel
end
