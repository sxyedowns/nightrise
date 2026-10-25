local commit
pcall(function()
	commit = readfile('senvi/profiles/commit.txt')
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

if isfolder('senvi') then
	wipe('senvi')
end

pcall(function()
	game:GetService('StarterGui'):SetCore('SendNotification', {
		Title = 'senvi',
		Text = 'deleted senvi, reinjecting now',
		Duration = 4
	})
end)

task.wait(0.67)

loadstring(game:HttpGet('https://raw.githubusercontent.com/soryedforgive/senvi/'..(commit or 'main')..'/main.lua', true))()
