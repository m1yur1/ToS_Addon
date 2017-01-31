function JOYSTICK_QUICKSLOT_ON_MSG(frame, msg, argStr, argNum)
--[[
	local Set1 			= frame:GetChildRecursively("Set1");
	local Set2 			= frame:GetChildRecursively("Set2");
	local visible = 0;

	if Set1:IsVisible() == 1 then
		visible = 1
	elseif Set2:IsVisible() == 1 then
		visible = 2
	end
	]]--
	--tolua.cast(slot, "ui::CSlot");
	--print(msg)
-- 什迭引 昔坤塘軒 舛左研 亜走壱 紳陥.
	local skillList 		= session.GetSkillList();
	local skillCount 		= skillList:Count();
	local invItemList 		= session.GetInvItemList();
	local itemCount 		= invItemList:Count();

	local MySession		= session.GetMyHandle();
	local MyJobNum		= info.GetJob(MySession);
	local JobName		= GetClassString('Job', MyJobNum, 'ClassName');

	if msg == 'GAME_START' then
		--ON_PET_SELECT(frame);
	end
	
	if msg == 'JOYSTICK_QUICKSLOT_LIST_GET' or msg == 'GAME_START' or msg == 'EQUIP_ITEM_LIST_GET' or msg == 'PC_PROPERTY_UPDATE' 
	or  msg == 'INV_ITEM_ADD' or msg == 'INV_ITEM_POST_REMOVE' or msg == 'INV_ITEM_CHANGE_COUNT' then
		DebounceScript("JOYSTICK_QUICKSLOT_UPDATE_ALL_SLOT", 0.1);
	end

	if msg == 'CHANGE_INVINDEX' then
		local toInvIndex = tonumber(argStr);
		local fromInvIndex = argNum;
		local toQuickIndex = -1;
		local fromQuickIndex = -1;

		local invenItemInfo = session.GetInvItem(toInvIndex);

		for i = 0, MAX_QUICKSLOT_CNT - 1 do
			local slot = GET_CHILD_RECURSIVELY(frame, "slot"..i+1, "ui::CSlot");
			local icon = slot:GetIcon();
			if icon ~= nil then
				local iconInfo = icon:GetInfo();
				if fromInvIndex == 0 then
					if iconInfo.type == invenItemInfo.type then
						iconInfo.ext = toInvIndex;
						--session.SetQuickSlotInfo(slot:GetSlotIndex(), iconInfo.category, iconInfo.type, iconInfo.ext, 0);
						session.SetQuickSlotInfo(slot:GetSlotIndex(), iconInfo.category, iconInfo.type, iconInfo:GetIESID(), 0)
					end
				else
					if iconInfo.ext == toInvIndex then
						toQuickIndex = i;
					elseif iconInfo.ext == fromInvIndex then
						fromQuickIndex = i;
					end
				end
			end
		end
		if toQuickIndex ~= -1 and fromQuickIndex ~= -1 then
			QUICKSLOTNEXPBAR_CHANGE_INVINDEX(quickslot, toQuickIndex, fromInvIndex);
			QUICKSLOTNEXPBAR_CHANGE_INVINDEX(quickslot, fromQuickIndex, toInvIndex);
		end
	end

	local quickSlotList = session.GetQuickSlotList();
	local curCnt = quickSlotList:GetQuickSlotActiveCnt();	

	curCnt = 40;

	JOYSTICK_QUICKSLOT_REFRESH(curCnt);

	--UI_MODE_CHANGE()

end

function QUICKSLOTNEXPBAR_CHANGE_INVINDEX(quickslot, quickIndex, changeIndex)
	local slot = quickslot:GetChild("slot" .. quickIndex + 1);
	tolua.cast(slot, "ui::CSlot");	
	local icon = slot:GetIcon();
	if icon ~= nil then
		local iconInfo = icon:GetInfo();
		iconInfo.ext = changeIndex;
		--session.SetQuickSlotInfo(slot:GetSlotIndex(), iconInfo.category, iconInfo.type, changeIndex, 0);
		session.SetQuickSlotInfo(slot:GetSlotIndex(), iconInfo.category, iconInfo.type, iconInfo:GetIESID(), 0)
	end
end

function QUICKSLOT_ON_CHANGE_INVINDEX(fromIndex, toIndex)
	local frame = ui.GetFrame("quickslotnexpbar");
		local toInvIndex = toIndex;
		local fromInvIndex = fromIndex;
		local toQuickIndex = -1;
		local fromQuickIndex = -1;

		local invenItemInfo = session.GetInvItem(toInvIndex);

		for i = 0, MAX_QUICKSLOT_CNT - 1 do
			local slot = GET_CHILD_RECURSIVELY(frame, "slot"..i+1, "ui::CSlot");
			local icon = slot:GetIcon();
			if icon ~= nil then
				local iconInfo = icon:GetInfo();
				if fromInvIndex == 0 then
					if iconInfo.type == invenItemInfo.type then
						iconInfo.ext = toInvIndex;
						--session.SetQuickSlotInfo(slot:GetSlotIndex(), iconInfo.category, iconInfo.type, iconInfo.ext, 0);
						session.SetQuickSlotInfo(slot:GetSlotIndex(), iconInfo.category, iconInfo.type, iconInfo:GetIESID(), 0)
					end
				else

					if iconInfo.ext == toInvIndex then
						toQuickIndex = i;
					elseif iconInfo.ext == fromInvIndex then
						fromQuickIndex = i;
					end
				end
			end
		end

		if toQuickIndex ~= -1 then
			QUICKSLOTNEXPBAR_CHANGE_INVINDEX(frame, toQuickIndex, fromIndex);
		end

		if fromQuickIndex ~= -1 then
			QUICKSLOTNEXPBAR_CHANGE_INVINDEX(frame, fromQuickIndex, toIndex);
		end
end


