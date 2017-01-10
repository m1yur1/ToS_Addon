CHAT_SYSTEM('durdetail is loaded')

local acutil = require('acutil')

local ADDON_NAME = 'durdetail'
local SETTINGS_FILE_LOCATION = '../addons/' .. ADDON_NAME .. '/settings.json'

_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][ADDON_NAME] = _G['ADDONS'][ADDON_NAME] or {}
local g = _G['ADDONS'][ADDON_NAME]

g.settings = {}
g.settings.font_size = 15
g.settings.font_bold = true
g.settings.font_outline = true
g.settings.font_color = '#ffffff'
g.settings.font_color_dur_zero = '#ffffff'
g.settings.font_color_dur_under_10 = '#ffffff'


function DURDETAIL_ON_INIT(addon, frame)
	g.settings = acutil.loadJSON(SETTINGS_FILE_LOCATION, g.settings, true)
	local slotset = GET_CHILD_RECURSIVELY(frame, 'slotlist', 'ui::CSlotSet')
	slotset:ClearIconAll()

	for i = 0, slotset:GetSlotCount() - 1 do
		local slot = slotset:GetSlotByIndex(i)
		local txt = slot:CreateOrGetControl('richtext', 'durdetail_txt_' .. i, 0, 0, 32, 16)
		tolua.cast(txt, 'ui::CRichText')

		txt:SetGravity(ui.RIGHT, ui.BOTTOM)
		txt:EnableResizeByText(1)
		txt:SetTextFixWidth(1)
		txt:SetLineMargin(0)
		txt:SetTextAlign('right', 'bottom')
		txt:ShowWindow(0)
		slot:ShowWindow(0)
	end

	addon:RegisterOpenOnlyMsg('UPDATE_ITEM_REPAIR', 'DURDETAIL_UPDATE')
	addon:RegisterOpenOnlyMsg('ITEM_PROP_UPDATE', 'DURDETAIL_UPDATE')
	addon:RegisterOpenOnlyMsg('EQUIP_ITEM_LIST_GET', 'DURDETAIL_UPDATE')
	addon:RegisterOpenOnlyMsg('MYPC_CHANGE_SHAPE', 'DURDETAIL_UPDATE')
	addon:RegisterMsg('GAME_START', 'DURDETAIL_ON_START')
end

function DURDETAIL_OPEN(frame)
	DURDETAIL_UPDATE(frame)
end

function DURDETAIL_CLOSE(frame)
end

function DURDETAIL_ON_START(frame)
	local frame_flag = frame:GetValue()
	if frame_flag == 0 then
		frame:SetValue(1)
	end

	DURDETAIL_UPDATE(frame)
end

function DURDETAIL_UPDATE(frame, notOpenFrame)
	if frame:IsVisible() == 0 then
		frame:ShowWindow(1)
	end

	local equip_list = session.GetEquipItemList()
	local slotset = GET_CHILD_RECURSIVELY(frame, 'slotlist', 'ui::CSlotSet')

	for i = 0, slotset:GetSlotCount() - 1 do
		local slot = slotset:GetSlotByIndex(i)
		local txt = slot:GetChild('durdetail_txt_' .. i)
		tolua.cast(txt, 'ui::CRichText')

		txt:ShowWindow(0)
		slot:ShowWindow(0)
	end

	local slot_count = 0
	local frame_flag = frame:GetValue()
	local flag = 1

	for i = 0, equip_list:Count() - 1 do
		local equip_item = equip_list:Element(i)
		local tmp_object = equip_item:GetObject()

		if tmp_object ~= nil then
			local equip_object = GetIES(tmp_object)

			if IS_DUR_ZERO(equip_object) then
				local slot = slotset:GetSlotByIndex(slot_count)
				local txt = slot:GetChild('durdetail_txt_' .. slot_count)
				tolua.cast(txt, 'ui::CRichText')
				DURDETAIL_SET_TXT(txt, 0)
				slot_count = slot_count + 1

				if flag < 3 then
					flag = 3
				end

				txt:ShowWindow(1)
				slot:ShowWindow(1)

			elseif IS_DUR_UNDER_10PER(equip_object) then
				local slot = slotset:GetSlotByIndex(slot_count)
				local txt = slot:GetChild('durdetail_txt_' .. slot_count)
				tolua.cast(txt, 'ui::CRichText')
				DURDETAIL_SET_TXT(txt, equip_object.Dur)
				slot_count = slot_count + 1

				if flag < 2 then
					flag = 2
				end

				txt:ShowWindow(1)
				slot:ShowWindow(1)
			end
		end
	end

	if flag == 1 then
		frame:SetValue(1)

	elseif flag == 2 and frame_flag < flag then
		frame:SetValue(2)

	elseif flag == 3 and frame_flag < flag then
		frame:SetValue(3)
	end
end

function DURDETAIL_SET_TXT(txt, value)
	local size = '{s' .. g.settings.font_size .. '}'
	local bold = g.settings.font_bold and '{b}' or ''
	local outline = g.settings.font_outline and '{ol}' or ''

	if 0 == value then
		txt:SetText(size .. bold .. outline .. '{' .. g.settings.font_color_dur_zero .. '}0')

	elseif 100 > value then
		txt:SetText(size .. bold .. outline .. '{' .. g.settings.font_color_dur_under_10 .. '}*' .. value)

	else
		txt:SetText(size .. bold .. outline .. '{' .. g.settings.font_color .. '}' .. math.floor(value / 100))
	end
end
