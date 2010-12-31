-- Grab environment
local utils = require("freedesktop.utils")
local io = io
local ipairs = ipairs
local pairs = pairs
local table = table
local os = os
local string = string
local print = print

module("freedesktop.menu")

local function comp(e1,e2)
	if (e1[1] < e2[1]) then
		return true
	else
		return false
	end
end

function new()
	-- the categories and their synonyms where shamelessly copied from lxpanel
	-- source code.
	local programs = {}
	--programs['AudioVideo'] = {}
	--programs['Audio'] = {}
	--programs['Video'] = {}
	--programs['Development'] = {}
	--programs['Education'] = {}
	--programs['Game'] = {}
	--programs['Graphics'] = {}
	--programs['Network'] = {}
	--programs['Office'] = {}
	--programs['Settings'] = {}
	--programs['System'] = {}
	--programs['Utility'] = {}
	--programs['Other'] = {}
	--
	
	local mergelist = {
		{"Audio", "Multimedia"},
		{"Video", "Multimedia"},
		{"Player", "Multimedia"},
		{"Java", "Development"},
		{"Qt", "Development"},
		{"IDE", "Development"},
		{"GUIDesign", "Development"},
		{"Profiling", "Development"},
		{"Debugger", "Development"},
		{"Translation", "Development"},
		{"Documentation", "Development"},
		{"Player", "Multimedia"},
		{"Game", "Games"},
		{"LogicGame", "Games"},
		{"BoardGame", "Games"},
		{"CardGame", "Games"},
		{"ArcadeGame", "Games"},
		{"BlocksGame", "Games"},
		{"DesktopSettings", "Settings"},
		{"HardwareSettings", "Settings"},
		{"VectorGraphics", "Graphics"},
		{"RasterGraphics", "Graphics"},
		{"2DGraphics", "Graphics"},
		{"Viewer", "Office"},
		{"Security", "System"},
		{"Printing", "System"},
		{"Filesystem", "System"},
		{"FileTools", "System"},
		{"Monitor", "System"},
		{"Instant", "Network"},
		{"Email", "Network"},
		{"WebBrowser", "Network"},
		{"FileTransfer", "Network"},
		{"TelephonyTools", "Network"},
		{"ContactManag", "PIM"},
		{"Calendar", "PIM"},
		{"DiskBurning", "Disc Burning"},
		{"DiscBurning", "Disc Burning"},
		{"Calendar", "PIM"},
		{"P2P", "Network"}
	}

	local excludelist = {
		"X-",
		"Core",
		"GTK",
		"GNOME",
		"Gtk",
		"Application",
		"Utility",
		"TerminalEmula",
		"Emulator",
		"Recorder",
		"PackageMan"
	}

	local categories = {}

	local apps = utils.parse_dir("/usr/share/applications/")
	local found = false

	table.insert(categories, "Other")
	programs["Other"] = {}

	for i, program in pairs(apps) do
	    if program.show and program.Name and program.cmdline then

		if not program.categories then
			program.categories = {"Other"}
		end

		for mk, m in pairs(mergelist) do
			found1 = false
			found2 = false

			for k, c in pairs(program.categories) do
				if string.find(c, m[1]) then
					table.remove(program.categories, k)
					found1 = true
				end
			end

			for k1, c1 in pairs(program.categories) do
				if c1 == m[2] then
					found2 = true
				end
			end

			if found1 and not found2 then
				table.insert(program.categories, m[2])
			end
		end


		for _, category in pairs(program.categories) do
			found = false
			for _, cat in pairs(categories) do
				if cat == category then
					program.Name = string.gsub(program.Name, "OpenOffice.org 3..", "OO")
					table.insert(programs[category], { program.Name, program.cmdline, program.icon_path })
					found = true
				end
			end
			if not found then
				table.insert(categories, category)
				programs[category] = {}
				program.Name = string.gsub(program.Name, "OpenOffice.org 3..", "OO")
				table.insert(programs[category], { program.Name, program.cmdline, program.icon_path })
				found = true
			end
		end
	    end
	end

	local menu = {}
	for _, category in pairs(categories) do

		local condition = true

		for _,ex in pairs(excludelist) do
			if string.find(category, ex, 1, true) then
				condition = false
			end
		end

		if (not programs[category]) or table.maxn(programs[category]) == 0 then
			condition = false
		end

		table.sort(programs[category], comp)

		if condition then
			table.insert(menu, {category, programs[category]})
		end

	end

	table.sort(menu, comp)


--	for i, program in ipairs(utils.parse_dir('/usr/share/applications/')) do
--
--		-- check whether to include in the menu
--		if program.show and program.Name and program.cmdline then
--			local target_category = nil
--			if program.categories then
--				for _, category in ipairs(program.categories) do
--					if programs[category] the
--						target_category = category
--						break
--					end
--				end
--			end
--			if not target_category then
--				target_category = 'Other'
--			end
--			if target_category then
--				table.insert(programs[target_category], { program.Name, program.cmdline, program.icon_path })
--			end
--		end
--
--	end

--	local menu = {
--		{ "Accessories", programs["Utility"], utils.lookup_icon({ icon = 'applications-accessories.png' }) },
--		{ "Development", programs["Development"], utils.lookup_icon({ icon = 'applications-development.png' }) },
--		{ "Education", programs["Education"], utils.lookup_icon({ icon = 'applications-science.png' }) },
--		{ "Games", programs["Game"], utils.lookup_icon({ icon = 'applications-games.png' }) },
--		{ "Graphics", programs["Graphics"], utils.lookup_icon({ icon = 'applications-graphics.png' }) },
--		{ "Internet", programs["Network"], utils.lookup_icon({ icon = 'applications-internet.png' }) },
--		{ "Multimedia", programs["AudioVideo"], utils.lookup_icon({ icon = 'applications-multimedia.png' }) },
--		{ "Office", programs["Office"], utils.lookup_icon({ icon = 'applications-office.png' }) },
--		{ "Other", programs["Other"], utils.lookup_icon({ icon = 'applications-other.png' }) },
--		{ "Settings", programs["Settings"], utils.lookup_icon({ icon = 'applications-utilities.png' }) },
--		{ "System Tools", programs["System"], utils.lookup_icon({ icon = 'applications-system.png' }) },
--	}

	-- Removing empty entries from menu
	--local bad_indexes = {}
	--for index , item in ipairs(menu) do
	--	if not item[2] then
	--		table.insert(bad_indexes, index)
	--	end
	--end
	--table.sort(bad_indexes, function (a,b) return a > b end)
	--for _, index in ipairs(bad_indexes) do
	--	table.remove(menu, index)
	--end

	return menu
end

