local ADDON_NAME = 'removeqst'
CHAT_SYSTEM(ADDON_NAME .. ' is loaded')
--[[
local SETTINGS_FILE_LOCATION = '../addons/' .. ADDON_NAME .. '/settings.json'

_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][ADDON_NAME] = _G['ADDONS'][ADDON_NAME] or {}
local g = _G['ADDONS'][ADDON_NAME]

local FRAME_NAMES = {'quickslotnexpbar', 'joystickquickslot'}

g.already_on_init = false
g.tooltip_type = {}
g.tooltip_type.quickslotnexpbar = {}
g.tooltip_type.joystickquickslot = {}
]]

local acutil = require('acutil')

function REMOVEQST_ON_INIT(addon, frame)
	acutil.setupHook(SET_QUICK_SLOT_HOOKED, 'SET_QUICK_SLOT')
end

function SET_QUICK_SLOT_HOOKED(slot, category, type, iesID, makeLog, sendSavePacket)
	--g.tooltip_type[slot:GetSlotIndex() + 1] = slot:GetIcon():GetTooltipType()

	SET_QUICK_SLOT_OLD(slot, category, type, iesID, makeLog, sendSavePacket)
	local icon = slot:GetIcon()
	icon:SetTooltipType('')
end

--[[
g.SaveCurrentTooltipType = function ()
	for _, name in pairs(FRAME_NAMES) do
		local frame = ui.GetFrame(name)

		for i = 0, MAX_QUICKSLOT_CNT - 1 do
			local slot = GET_CHILD_RECURSIVELY(frame, 'slot' .. i+1, 'ui::CSlot')
			if slot ~= nil then
				g.tooltip_type[name][i + 1] = slot:GetIcon():GetTooltipType()
			else
				g.tooltip_type[name][i + 1] = ''
			end
		end
	end
end

g.RestoreTooltipType = function ()
	for _, name in pairs(FRAME_NAMES) do
		local frame = ui.GetFrame(name)

		for i = 0, MAX_QUICKSLOT_CNT - 1 do
			local slot = GET_CHILD_RECURSIVELY(frame, 'slot' .. i+1, 'ui::CSlot')

			if slot ~= nil then
				local icon = slot:GetIcon()

				if icon ~= nil then
					icon:SetTooltipType(g.tooltip_type[name][i + 1])
				end
			end
		end
	end
end
]]