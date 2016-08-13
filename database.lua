-- database.lua


function ConfigureDatabase()
	-- Create tables
	local sqlCreate = {
		"PRAGMA foreign_keys = ON",
	    "CREATE TABLE IF NOT EXISTS servers (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, player STRING NOT NULL UNIQUE, name STRING NOT NULL UNIQUE,  posx INTEGER NOT NULL, posy INTEGER NOT NULL, posz INTEGER NOT NULL, ipv4 STRING, creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP)",
	};
	for key in pairs(sqlCreate) do
		ExecuteStatement(sqlCreate[key]);
	end
end

function ExecuteStatement(sql, parameters)
	local stmt = db:prepare(sql);
	local result;

	if not (parameters == nil) then
		for key, value in pairs(parameters) do
			stmt:bind(key, value);
		end
	end

	local result = {};
	if (sql:match("SELECT")) then
		local x = 1;
		while (stmt:step() == sqlite3.ROW) do
			result[x] = stmt:get_values();
			x = x + 1;
		end
	else
		stmt:step();
	end

	stmt:finalize();

	if (sql:match("INSERT")) then
		result = db:last_insert_rowid();
	end


	if not (result == nil) then
		return result;
	else
		return 0;
	end
end
