local commit
pcall(function()
	commit = readfile('nightrise/profiles/commit.txt')
end)

local function wipe(path)
	if isfolder(path) then
		for _, item in listfiles(path) do
			wipe(item)
		end
		pcall(delfolder, path)
	elseif isfile(path) then
		pcall(delfile, path)
	end
end

if isfolder('nightrise') then
	wipe('nightrise')
end

pcall(function()
	game:GetService('StarterGui'):SetCore('SendNotification', {
		Title = 'nightrise',
		Text = 'deleted nightrise, reinjecting now',
		Duration = 4
	})
end)

task.wait(0.67)

-- Points to sxyedowns/nightrise
loadstring(game:HttpGet('https://raw.githubusercontent.com/sxyedowns/nightrise/'..(commit or 'main')..'/main.lua', true))()
