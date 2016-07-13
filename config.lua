config = {};

function LoadConfig()
	local newconfig = {};
	ini:ReadFile(PLUGIN:GetLocalFolder() .. "/config.ini");
	ini:DeleteHeaderComments();
	ini:AddHeaderComment("Configuration for GandiCraft");

	if not (ini:FindKey("General")) then
		ini:AddKeyName("General");
	end

	ini:DeleteKeyComments("General");

	ini:AddKeyComment("General", "dbname - Filename of the database. REQUIRES PLUGIN RELOAD");
	newconfig.dbname = ini:GetValueSet("General", "dbname", "database.sqlite3");
	config = newconfig;

	LOG("[GandiCraft] Config succesfully reloaded");

	return true;
end
