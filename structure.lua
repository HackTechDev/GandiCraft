
-- /structure build house 4 6 3
function Structure(World, Player, Split)
    LOG("Structure")
    x = Player:GetPosX()
    y = Player:GetPosY() 
	z = Player:GetPosZ() 
	

	length = Split[4]
	width  = Split[5]
	height = Split[6]


	-- Build 4 walls
	if Split[2] == "build" then
		if Split[3] == "house" then
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

end