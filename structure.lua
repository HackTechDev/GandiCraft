-- structure

-- /structure house build 4 6 3
function Structure(World, Player, Split)
    LOG("Structure")
    x = Player:GetPosX()
    y = Player:GetPosY()
    z = Player:GetPosZ()

    -- Build 4 walls
    if Split[2] == "house" then
        if Split[3] == "build" then

            if Split[6] ~= nil then
                if Split[5] ~= nil then
                    if Split[4] ~= nil then

                        length = Split[4]
                        width  = Split[5]
                        height = Split[6]

                        for y  = Player:GetPosY() + 1, Player:GetPosY() + 1 + height
                        do
                            for x  = Player:GetPosX(), Player:GetPosX() + length
                            do
                                setBlock(UpdateQueue, x, y, z, E_BLOCK_STONE, E_META_STONE_GRANITE)
                            end


                            for x  = Player:GetPosX(), Player:GetPosX() + length
                            do
                                setBlock(UpdateQueue, x, y, z + width, E_BLOCK_STONE, E_META_STONE_GRANITE)
                            end


                            for z  = Player:GetPosZ() , Player:GetPosZ() + width
                            do
                                setBlock(UpdateQueue, x, y, z, E_BLOCK_STONE, E_META_STONE_GRANITE)
                            end


                            for z  = Player:GetPosZ() , Player:GetPosZ() + width
                            do
                                setBlock(UpdateQueue, x + length, y, z, E_BLOCK_STONE, E_META_STONE_GRANITE)
                            end
                        end

                        -- Build floor
                        for x  = Player:GetPosX(), Player:GetPosX() + length
                        do
                            for z  = Player:GetPosZ() , Player:GetPosZ() + width
                            do
                                setBlock(UpdateQueue, x, y, z, E_BLOCK_STONE, E_META_STONE_GRANITE)
                            end
                        end

                        -- Build roof
                        for x  = Player:GetPosX(), Player:GetPosX() + length
                        do
                            for z  = Player:GetPosZ() , Player:GetPosZ() + width
                            do
                                setBlock(UpdateQueue, x, y + 1 + height, z, E_BLOCK_STONE, E_META_STONE_GRANITE)
                            end
                        end

                     else
                        LOG("Help: /structure build house <length> <width> <height>")
                        Player:SendMessage("Help: /structure build house <length> <width> <height>")
                    end
                else
                    LOG("Help: /structure build house <length> <width> <height>")
                    Player:SendMessage("Help: /structure build house <length> <width> <height>")
                end
            else
                LOG("Help: /structure build house <length> <width> <height>")
                Player:SendMessage("Help: /structure build house <length> <width> <height>")
            end

        else
            LOG("Help: /structure house <action>")
            Player:SendMessage("Help: /structure house <action>")
        end
    else
        LOG("Help: /structure <structure name>")
        Player:SendMessage("Help: /structure <structure>")
    end

end
