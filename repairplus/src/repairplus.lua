local cwAPI = require('cwapi')

local ADDON_NAME = 'repairplus'
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][ADDON_NAME] = _G['ADDONS'][ADDON_NAME] or {}
local g = _G['ADDONS'][ADDON_NAME]

g.initialized = false


function REPAIRPLUS_ON_INIT()
	if g.initialized then
		return
	end

	if not cwAPI then
		CHAT_SYSTEM(ADDON_NAME .. ' requires cwAPI to run.')
		return
	end

	cwAPI.events.on('UPDATE_REPAIR140731_LIST', g.OnUpdateList, 1)
	g.initialized = true
end


g.OnUpdateList = function (frame)
	local slotset = GET_CHILD_RECURSIVELY(frame, 'slotlist', 'ui::CSlotSet')
	local slot_count = slotset:GetSlotCount()


	for i = 0, slot_count-1 do
		local slot = slotset:GetSlotByIndex(i)
		local icon = slot:GetIcon()
		local gauge = slot:GetSlotGauge()

		if nil == icon then
			--
		else
			if nil == gauge then
				local x = 2
				local y = slot:GetHeight() - 10
				local width = slot:GetWidth() - x * 2
				local height = 8

				gauge = slot:MakeSlotGauge(x, y, width, height)
				gauge:SetSkinName('gauge')
				gauge:SetDrawStyle(ui.GAUGE_DRAW_CONTINOUS)
			end


			local icon_info = icon:GetInfo()
			local item_id = GET_ITEM_BY_GUID(icon_info:GetIESID())
			local item_object = GetIES(item_id:GetObject())

			if IS_DUR_UNDER_10PER(item_object) then
				slot:SetBlink(0.0, 0.5, 'ff990000')
				gauge:SetBarColor(0xff990000)
			else
				slot:ReleaseBlink()
				gauge:SetBarColor(0xffffffff)
			end

			gauge:SetPoint(item_object.Dur, item_object.MaxDur)
			gauge:ShowWindow(1)
			slot:InvalidateGauge()
		end
	end
end
