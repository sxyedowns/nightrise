local playersService = game:GetService("Players")

local _args = ...
if type(_args) ~= "table" then _args = {} end

local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil and res ~= ''
end
local delfile = delfile or function(file) writefile(file, '') end

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			-- Updated to sxyedowns/nightrise
			return game:HttpGet('https://raw.githubusercontent.com/sxyedowns/nightrise/'..readfile('nightrise/profiles/commit.txt')..'/'..select(1, path:gsub('nightrise/', '')), true)
		end)
		if not suc or res == '404: Not Found' then error(res) end
		if path:find('%.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function wipeFolder(path)
	if not isfolder(path) then return end
	for _, file in listfiles(path) do
		if file:find('loader') then continue end
		if isfile(file) and select(1, readfile(file):find('--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.')) == 1 then
			delfile(file)
		end
	end
end

-- Changed local folders from senvi to nightrise
for _, folder in {'nightrise', 'nightrise/games', 'nightrise/profiles', 'nightrise/assets', 'nightrise/libraries', 'nightrise/guis'} do
	if not isfolder(folder) then makefolder(folder) end
end

if not isfile('nightrise/profiles/commit.txt') then
	writefile('nightrise/profiles/commit.txt', 'main')
end

local function downloadPremadeProfiles(commit)
	local httpService = game:GetService('HttpService')
	if isfolder('nightrise/profiles/premade') then
		for _, file in listfiles('nightrise/profiles/premade') do
			pcall(function() if isfile(file) then delfile(file) end end)
		end
	else
		makefolder('nightrise/profiles/premade')
	end
	local success, response = pcall(function()
		-- Updated to sxyedowns/nightrise
		return game:HttpGet('https://api.github.com/repos/sxyedowns/nightrise/contents/profiles/premade?ref=' .. commit)
	end)
	if success and response then
		local ok, files = pcall(function() return httpService:JSONDecode(response) end)
		if ok and type(files) == 'table' then
			for _, file in pairs(files) do
				if file.name and file.name:find('.txt') and file.name ~= 'commit.txt' then
					local baseName = (file.name:match('^(.-)%.txt$') or file.name):gsub('%d+$', '')
					local fileId = (game.GameId == 2619619496) and game.GameId or game.PlaceId
					local filePath = 'nightrise/profiles/premade/' .. baseName .. tostring(fileId) .. '.txt'
					local ds, dc = pcall(function() return game:HttpGet(file.download_url, true) end)
					if ds and dc and dc ~= '404: Not Found' then writefile(filePath, dc) end
				end
			end
		end
	end
end

if not shared.VapeDeveloper then
	local commit = isfile('nightrise/profiles/commit.txt') and readfile('nightrise/profiles/commit.txt') or ''
	local latest = isfile('nightrise/profiles/latest.txt') and readfile('nightrise/profiles/latest.txt') or ''
	if #commit ~= 40 then
		local ok, res = pcall(function()
			-- Updated to sxyedowns/nightrise
			return game:HttpGet('https://api.github.com/repos/sxyedowns/nightrise/commits/main', true)
		end)
		if ok and res then
			local h = res:match('"sha":"([a-f0-9]+)"')
			if h and #h == 40 then commit = h end
		end
		if #commit ~= 40 then commit = 'main' end
		latest = commit
		pcall(writefile, 'nightrise/profiles/latest.txt', latest)
	elseif #latest == 40 and latest ~= commit then
		commit = latest
	end
	task.spawn(function()
		local ok, res = pcall(function()
			-- Updated to sxyedowns/nightrise
			return game:HttpGet('https://api.github.com/repos/sxyedowns/nightrise/commits/main', true)
		end)
		if ok and res then
			local h = res:match('"sha":"([a-f0-9]+)"')
			if h and #h == 40 then
				pcall(writefile, 'nightrise/profiles/latest.txt', h)
			end
		end
	end)
	if commit ~= 'main' and (isfile('nightrise/profiles/commit.txt') and readfile('nightrise/profiles/commit.txt') or '') ~= commit then
		-- Changed local wipe paths from senvi to nightrise
		wipeFolder('nightrise')
		wipeFolder('nightrise/games')
		wipeFolder('nightrise/guis')
		pcall(function() if isfile('nightrise/guis/new.lua') then delfile('nightrise/guis/new.lua') end end)
		wipeFolder('nightrise/libraries')
		if isfolder('nightrise/profiles/premade') then
			for _, file in listfiles('nightrise/profiles/premade') do
				pcall(function() if isfile(file) then delfile(file) end end)
			end
		end
	end
	local oldCommit = isfile('nightrise/profiles/commit.txt') and readfile('nightrise/profiles/commit.txt') or ''
	writefile('nightrise/profiles/commit.txt', commit)
	local needPremade = (oldCommit ~= commit)
	if not needPremade then
		needPremade = true
		if isfolder('nightrise/profiles/premade') then
			for _ in listfiles('nightrise/profiles/premade') do
				needPremade = false
				break
			end
		end
	end
	if needPremade then
		pcall(downloadPremadeProfiles, commit)
	end
end

return loadstring(downloadFile('nightrise/main.lua'), 'main')({
	Closet = _args.Closet,
})
