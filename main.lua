repeat task.wait() until game:IsLoaded()

local playersService = game:GetService("Players")
local KICK_MESSAGE = "Get a key from 52.22"
if type(getgenv().script_key) ~= "string" or #getgenv().script_key == 0 then
	return playersService.LocalPlayer:Kick(KICK_MESSAGE)
end

if shared.vape then shared.vape:Uninject() end

local LOADER_URL = "https://script-whitelist.weikauth.workers.dev/loader" 
local _initArgs = ...
if type(_initArgs) ~= "table" then _initArgs = {} end
shared.senviUser = "spookers 👻"

if identifyexecutor then
	if table.find({'Wave', 'Seliware', 'Volt'}, ({identifyexecutor()})[1]) then
		getgenv().setthreadidentity = nil
	end
end

local args = _initArgs
if type(args) == "table" and args.Closet then
	getgenv().Closet = true
else
	if getgenv().Closet == nil then
		getgenv().Closet = false
	end
end

local vape
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local clear_teleport_queue = clear_teleport_queue or clearteleportqueue or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end

if identifyexecutor and table.find({'Madium', 'Medium'}, ({identifyexecutor()})[1]) then
	local realgca = getcustomasset or getsynasset
	if realgca then
		getgenv().getcustomasset = function(path, ...)
			local args = {...}
			local function try()
				if not isfile(path) then return nil end
				local ok, res = pcall(function() return realgca(path, table.unpack(args)) end)
				if ok and res and res ~= '' then return res end
				return nil
			end
			local res = try()
			if res then return res end
			for _ = 1, 60 do
				task.wait(0.05)
				res = try()
				if res then return res end
			end
			return 'rbxassetid://0'
		end
	end
end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))
local httpService = cloneref(game:GetService('HttpService'))
local teleportService = cloneref(game:GetService('TeleportService'))

local REPO = "soryedforgive/senvi"  -- same as myscript
local BRANCH = "main"
local function downloadFile(path, func)
	if not isfile(path) then
		local repoPath = select(1, path:gsub('senvi/', ''))
		local url = "https://raw.githubusercontent.com/" .. REPO .. "/" .. BRANCH .. "/" .. repoPath
		local res
		local success = false
		for attempt = 1, 3 do
			local suc, result = pcall(function()
				return game:HttpGet(url, true)
			end)
			if suc and result and result ~= "404: Not Found" then
				res = result
				success = true
				break
			end
			task.wait(1)
		end
		if not success then
			error("Failed to download " .. path .. " (" .. url .. ")")
		end
		if path:find("%.lua") then
			res = "--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n" .. res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function migrateProfiles()
	if isfile('senvi/profiles/migrated_placeid.txt') then return end

	local oldId = tostring(game.GameId)
	local newId = tostring(game.PlaceId)

	if oldId == newId then
		pcall(writefile, 'senvi/profiles/migrated_placeid.txt', 'done')
		return
	end

	local suffix = oldId .. '.txt'
	for _, path in ipairs(listfiles('senvi/profiles')) do
		local name = path:gsub('\\', '/')
		if name:sub(-#suffix) == suffix then
			local newPath = name:sub(1, -#suffix - 1) .. newId .. '.txt'
			if not isfile(newPath) then
				pcall(function() writefile(newPath, readfile(path)) end)
			end
		end
	end

	if isfolder('senvi/profiles/premade') then
		for _, path in ipairs(listfiles('senvi/profiles/premade')) do
			local name = path:gsub('\\', '/')
			if name:sub(-#suffix) == suffix then
				local newPath = name:sub(1, -#suffix - 1) .. newId .. '.txt'
				if not isfile(newPath) then
					pcall(function() writefile(newPath, readfile(path)) end)
				end
			end
		end
	end

	pcall(writefile, 'senvi/profiles/migrated_placeid.txt', 'done')
end

pcall(migrateProfiles)

local function finishLoading()
	vape.Init = nil
	if not vape.Load then
		warn('[senvi] vape.Load is nil skipping load')
		return
	end
	vape:Load()
	vape:Clean(task.spawn(function()
		repeat
			pcall(vape.Save, vape)
			task.wait(10)
		until vape.Loaded == nil
	end))

	local function buildTeleportScript()
		if shared.VapeIndependent then return nil end

		local closetArg = getgenv().Closet and '({Closet=true})' or '()'
		local teleportScript = 'shared.vapereload = true\nloadstring(game:HttpGet("' .. LOADER_URL .. '", true), "loader")' .. closetArg
		if type(getgenv().script_key) == 'string' and #getgenv().script_key > 0 then
			teleportScript = 'getgenv().script_key = "' .. getgenv().script_key:gsub('"', '\\"') .. '"\n' .. teleportScript
		end

		if identifyexecutor and ({identifyexecutor()})[1] == 'Potassium' then
			teleportScript = 'task.wait(12)\n' .. teleportScript
		end
		if shared.VapeDeveloper then
			teleportScript = 'shared.VapeDeveloper = true\n' .. teleportScript
		end
		if shared.VapeCustomProfile then
			teleportScript = 'shared.VapeCustomProfile = "' .. shared.VapeCustomProfile .. '"\n' .. teleportScript
		end
		return teleportScript
	end

	local function queueTeleport()
		local teleportScript = buildTeleportScript()
		if not teleportScript then return end
		pcall(clear_teleport_queue)
		pcall(queue_on_teleport, teleportScript)
	end

	queueTeleport()

	vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function(state)
		if state == Enum.TeleportState.Failed then return end
		pcall(function() vape:Save() end)
		queueTeleport()
	end))

	vape:Clean(function()
		pcall(clear_teleport_queue)
	end)

	if not shared.vapereload then
		if not vape.Categories then return end
		if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
			vape:CreateNotification('[senvi] Finished Loading', 'wsg ' .. shared.senviUser .. ' ' .. (vape.VapeButton and 'Press the button in the top right to open GUI' or 'Press ' .. table.concat(vape.Keybind, ' + '):upper() .. ' to open GUI'), 5)
		end
	end
end

if not isfile('senvi/profiles/gui.txt') then
	writefile('senvi/profiles/gui.txt', 'new')
end
local gui = readfile('senvi/profiles/gui.txt')

if not isfolder('senvi/assets/' .. gui) then
	makefolder('senvi/assets/' .. gui)
end

local guiSource = downloadFile('senvi/guis/' .. gui .. '.lua')
local guiFunc, guiErr = loadstring(guiSource, 'gui')
if not guiFunc then
	local errMsg = tostring(guiErr)
	local lineNum = errMsg:match(':(%d+):')
	local context = ''
	if lineNum then
		local n = tonumber(lineNum)
		local lines = guiSource:split('\n')
		local from = math.max(1, n - 2)
		local to   = math.min(#lines, n + 2)
		local parts = {}
		for i = from, to do
			local marker = i == n and '>>> ' or '    '
			table.insert(parts, marker .. i .. ': ' .. (lines[i] or ''))
		end
		context = '\n\nContext:\n' .. table.concat(parts, '\n')
	end
	error('[senvi] syntax error in ' .. gui .. '.lua' .. '\n' .. errMsg .. context)
end
vape = guiFunc()
if not vape then
	error('[senvi] GUI returned nil file may be corrupted try deleting senvi/guis/' .. gui .. '.lua and reinjecting.')
end
if not vape.Load then
	if delfile then pcall(function() delfile('senvi/guis/' .. gui .. '.lua') end) end
	error('[senvi] gui file corrupted (missing load) reinject..')
end
if not vape.Init and not vape.Load then
	error('[senvi] failed to initialize properly reinject to fix this bs')
end
shared.vape = vape
task.wait(0.1)

if getgenv().Closet then
	local LogService = cloneref(game:GetService('LogService'))
	local originals = {}
	local function hook(funcName)
		if typeof(getgenv()[funcName]) == 'function' then
			local original = hookfunction(getgenv()[funcName], function() end)
			originals[funcName] = original
		end
	end
	hook('print')
	hook('warn')
	hook('error')
	hook('info')
	pcall(function() LogService:ClearOutput() end)
	local conn = LogService.MessageOut:Connect(function()
		LogService:ClearOutput()
	end)
	getgenv()._vape_log_connection = conn
	getgenv()._vape_originals = originals
end

if not shared.VapeIndependent then
	loadstring(downloadFile('senvi/games/universal.lua'), 'universal')()
	local gameFileId = (game.GameId == 2619619496) and (game.PlaceId == 6872265039 and 6872265039 or 6872274481) or (game.GameId == 10516888336 and 10516888336 or game.PlaceId)

	if isfile('senvi/games/' .. gameFileId .. '.lua') then
		local gameSrc = downloadFile('senvi/games/' .. gameFileId .. '.lua')
		local gameFunc, gameErr = loadstring(gameSrc, tostring(gameFileId))
		if not gameFunc then
			local ls = gameSrc:split('\n')
			local msg = gameErr and tostring(gameErr) or 'executor didnt say why'
			local n = tonumber(msg:match(':(%d+):'))
			local where = ''
			if not n then
				local starts = {1}
				for i = 2, #ls do
					if ls[i]:match('^run%(function%(%)') then
						table.insert(starts, i)
					end
				end
				for idx, s in starts do
					local e = (starts[idx + 1] or (#ls + 1)) - 1
					if not loadstring(table.concat(ls, '\n', s, e), 'check') then
						local name
						for i = s, e do
							name = ls[i]:match("Name = '([^']+)'")
							if name then break end
						end
						where = '\nbroken part is lines ' .. s .. ' to ' .. e .. (name and ' in ' .. name or '')
						break
					end
				end
				if where == '' then
					where = '\ncouldnt find the broken part, prob a missing end between 2 modules'
				end
			end
			local ctx = ''
			if n then
				local parts = {}
				for i = math.max(1, n - 3), math.min(#ls, n + 3) do
					table.insert(parts, (i == n and '>>> ' or '    ') .. i .. ': ' .. (ls[i] or ''):gsub('\r', ''))
				end
				ctx = '\n\naround here:\n' .. table.concat(parts, '\n')
			end
			error('[senvi] syntax error in ' .. gameFileId .. '.lua\n' .. msg .. where .. ctx)
		end
		gameFunc(...)
	else
		if not shared.VapeDeveloper then
			local path = 'senvi/games/' .. gameFileId .. '.lua'
			local suc, res = pcall(function()
				return downloadFile(path)
			end)
			if suc and isfile(path) then
				loadstring(readfile(path), tostring(gameFileId))(...)
			end
		end
	end
	finishLoading()
else
	vape.Init = finishLoading
	return vape
end
