CHAT_SYSTEM('rmbuff is loaded')

local acutil = require('acutil')

local ADDON_NAME = 'rmbuff'
local SETTINGS_FILE_LOCATION = '../addons/' .. ADDON_NAME .. '/settings.json'

_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][ADDON_NAME] = _G['ADDONS'][ADDON_NAME] or {}
local g = _G['ADDONS'][ADDON_NAME]

g.team_name = nil
g.char_name = nil
g.settings = {}
g.settings.ind = {}
g.settings.remove_enable = true
g.settings.trace_enable = false


function RMBUFF_ON_INIT(addon, frame)
	addon:RegisterMsg('BUFF_ADD', 'RMBUFF_ON_BUFF_ADD')
	addon:RegisterMsg('GAME_START', 'RMBUFF_ON_GAME_START')
	acutil.slashCommand('/rmbuff', RMBUFF_COMMAND_HANDLER)
end


function RMBUFF_ON_BUFF_ADD(frame, msg, argStr, argNum)
	if msg ~= 'BUFF_ADD' then
		return
	end

	-- trace
	if g.settings.trace_enable then
		local cls = GetClassByType('Buff', argNum)

		if cls and cls.Name and cls.Name ~= '' then
			CHAT_SYSTEM(ADDON_NAME .. ': ' .. cls.Name .. '(' .. argNum .. ')')
		else
			CHAT_SYSTEM(ADDON_NAME .. ': trace error')
		end
	end

	-- remove buff
	if g.settings.remove_enable then
		if g.settings.ind[g.team_name][g.char_name].buff_id['' .. argNum] then
			packet.ReqRemoveBuff(argNum)
		end
	end
end

function RMBUFF_ON_GAME_START(frame)
	g.team_name = info.GetFamilyName(session.GetMyHandle())
	g.char_name = info.GetName(session.GetMyHandle())

	g.load_settings()
	g.settings.ind[g.team_name] = g.settings.ind[g.team_name] or {}
	g.settings.ind[g.team_name][g.char_name] = g.settings.ind[g.team_name][g.char_name] or {}
	g.settings.ind[g.team_name][g.char_name].buff_id = g.settings.ind[g.team_name][g.char_name].buff_id or {}
	g.settings.ind[g.team_name][g.char_name].buff_id['dummy'] = false
	g.save_settings()
end

function RMBUFF_COMMAND_HANDLER(words)
	if #words <= 0 then 
		return
	end

	local do_save_settings = true
	local cmd = string.lower(table.remove(words, 1))

	if cmd == 'on' then
		g.settings.remove_enable = true
		CHAT_SYSTEM(ADDON_NAME .. ': remove enable.')
	elseif cmd == 'off' then
		g.settings.remove_enable = false
		CHAT_SYSTEM(ADDON_NAME .. ': remove disable.')
	elseif cmd == 'tron' then
		g.settings.trace_enable = true
		CHAT_SYSTEM(ADDON_NAME .. ': trace enable.')
	elseif cmd == 'troff' then
		g.settings.trace_enable = false
		CHAT_SYSTEM(ADDON_NAME .. ': trace disable.')
	elseif cmd == 'reload' then
		do_save_settings = false
		local t, err = g.load_settings()
		if err then
			CHAT_SYSTEM(ADDON_NAME .. ': failed load settings.')
		else
			CHAT_SYSTEM(ADDON_NAME .. ': load settings.')
		end
	else
		return
	end

	if do_save_settings then
		g.save_settings()
	end
end


g.load_settings = function ()
	return acutil.loadJSON(SETTINGS_FILE_LOCATION, g.settings)
end

g.save_settings = function ()
	return acutil.saveJSON(SETTINGS_FILE_LOCATION, g.settings)
end
