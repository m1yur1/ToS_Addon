CHAT_SYSTEM('durdetail is loaded')

local addon_name = 'durdetail'
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][addon_name] = _G['ADDONS'][addon_name] or {}
local g = _G['ADDONS'][addon_name]

g.font_size = 15

function DURDETAIL_ON_INIT(addon, frame)
	local slotSet = GET_CHILD_RECURSIVELY(frame, 'slotlist', 'ui::CSlotSet')
	slotSet:ClearIconAll()

	for i = 0, slotSet:GetSlotCount() - 1 do
		local slot = slotSet:GetSlotByIndex(i)
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
	local initvalue = frame:GetValue()
	if initvalue == 0 then
		frame:SetValue(1)
	end

	DURDETAIL_UPDATE(frame)
end

function DURDETAIL_UPDATE(frame, notOpenFrame)
	if frame:IsVisible() == 0 then
		frame:ShowWindow(1)
	end

	local equiplist = session.GetEquipItemList()
	local slotSet = GET_CHILD_RECURSIVELY(frame, 'slotlist', 'ui::CSlotSet')

	for i = 0, slotSet:GetSlotCount() - 1 do
		local slot = slotSet:GetSlotByIndex(i)
		local txt = slot:GetChild('durdetail_txt_' .. i)
		tolua.cast(txt, 'ui::CRichText')

		txt:ShowWindow(0)
		slot:ShowWindow(0)
	end

	local slotcnt = 0
	local nowvalue = frame:GetValue()
	local someflag = 1

	for i = 0, equiplist:Count() - 1 do
		local equipItem = equiplist:Element(i)
		local tempobj = equipItem:GetObject()

		if tempobj ~= nil then
			local obj = GetIES(tempobj)

			if IS_DUR_ZERO(obj) then
				local slot = slotSet:GetSlotByIndex(slotcnt)
				local txt = slot:GetChild('durdetail_txt_' .. slotcnt)
				tolua.cast(txt, 'ui::CRichText')
				DURDETAIL_SET_TXT(txt, 0)
				slotcnt = slotcnt + 1

				if someflag < 3 then
					someflag = 3
				end

				txt:ShowWindow(1)
				slot:ShowWindow(1)

			elseif IS_DUR_UNDER_10PER(obj) then
				local slot = slotSet:GetSlotByIndex(slotcnt)
				local txt = slot:GetChild('durdetail_txt_' .. slotcnt)
				tolua.cast(txt, 'ui::CRichText')
				DURDETAIL_SET_TXT(txt, obj.Dur)
				slotcnt = slotcnt + 1

				if someflag < 2 then
					someflag = 2
				end

				txt:ShowWindow(1)
				slot:ShowWindow(1)
			end
		end
	end

	if someflag == 1 then
		frame:SetValue(1)
	elseif someflag == 2 and nowvalue < someflag then
		frame:SetValue(2)
	elseif someflag == 3 and nowvalue < someflag then
		frame:SetValue(3)
	end
end

function DURDETAIL_SET_TXT(txt, value)
	if 0 == value then
		txt:SetText('{s' .. g.font_size .. '}{#ffffff}0')
	elseif 100 > value then
		txt:SetText('{s' .. g.font_size .. '}{#ffffff}*' .. value)
	else
		txt:SetText('{s' .. g.font_size .. '}{#ffffff}' .. math.floor(value / 100))
	end
end
