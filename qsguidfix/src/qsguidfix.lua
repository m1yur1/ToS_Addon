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

function SET_QUICK_SLOT(slot, category, type, iesID, makeLog, sendSavePacket)
	local icon 	= CreateIcon(slot);
	local imageName = "";

	if category == 'Action' then
		icon:SetColorTone("FFFFFFFF");
		icon:ClearText();
	elseif category == 'Skill' then
		local skl = session.GetSkill(type);
		if skl == nil then
			slot:ClearIcon();
			QUICKSLOT_SET_GAUGE_VISIBLE(slot, 0);
			return;
		end
		imageName = 'icon_' .. GetClassString('Skill', type, 'Icon');
		icon:SetOnCoolTimeUpdateScp('ICON_UPDATE_SKILL_COOLDOWN');
		icon:SetEnableUpdateScp('ICON_UPDATE_SKILL_ENABLE');
		icon:SetColorTone("FFFFFFFF");
		icon:ClearText();
		quickSlot.OnSetSkillIcon(slot, type);
	elseif category == 'Item' then
		local itemIES = GetClassByType('Item', type);
		if itemIES ~= nil then
			imageName = itemIES.Icon;
			
			local invenItemInfo = nil

			if iesID == "" then
				invenItemInfo = session.GetInvItemByType(type);
			else
				invenItemInfo = session.GetInvItemByGuid(iesID);
			end

			local skill_scroll = 910001;
			if invenItemInfo == nil then
				if skill_scroll ~= type then
					invenItemInfo = session.GetInvItemByType(type);
				else
					slot:ClearIcon()
					slot:Invalidate()
					return
				end
			end

			if invenItemInfo ~= nil and invenItemInfo.type == math.floor(type) then
				itemIES = GetIES(invenItemInfo:GetObject());
				local result = CHECK_EQUIPABLE(itemIES.ClassID);
				icon:SetEnable(1);
				icon:SetEnableUpdateScp('None');
				if result == 'OK' then
					icon:SetColorTone("FFFFFFFF");
				else
					icon:SetColorTone("FFFF0000");
				end

				if itemIES.MaxStack > 0 or itemIES.GroupName == "Material" then
					if itemIES.MaxStack > 1 then -- 개수는 스택형 아이템만 표시해주자
						icon:SetText(invenItemInfo.count, 'quickiconfont', 'right', 'bottom', -2, 1);
					end
					icon:SetColorTone("FFFFFFFF");
				end

				tolua.cast(icon, "ui::CIcon");
				local iconInfo = icon:GetInfo();
				iconInfo.count = invenItemInfo.count;

				if skill_scroll == type then
					icon:SetUserValue("IS_SCROLL","YES")
				else
					icon:SetUserValue("IS_SCROLL","NO")
				end

			else
				icon:SetColorTone("FFFF0000");
				icon:SetText(0, 'quickiconfont', 'right', 'bottom', -2, 1);
			end

			ICON_SET_ITEM_COOLDOWN_OBJ(icon, itemIES);
		end
	end

	if imageName ~= "" then
		if iesID == nil then
			iesID = ""
		end
		
		local category = category;
		local type = type;

		if category == 'Item' then
			icon:SetTooltipType('wholeitem');
			
			local invItem = nil

			if iesID == '0' then
				invItem = session.GetInvItemByType(type);
			elseif iesID == "" then
				invItem = session.GetInvItemByType(type);
			else
				invItem = session.GetInvItemByGuid(iesID);
			end

			if invItem ~= nil and invItem.type == type then
				iesID = invItem:GetIESID();
			end

			if invItem ~= nil then
				icon:Set(imageName, 'Item', invItem.type, invItem.invIndex, invItem:GetIESID(), invItem.count);
				ICON_SET_INVENTORY_TOOLTIP(icon, invItem, "quickslot", GetIES(invItem:GetObject()));
			else
				icon:Set(imageName, category, type, 0, iesID);
				icon:SetTooltipNumArg(type);
				icon:SetTooltipIESID(iesID);
			end
		else
			if category == 'Skill' then
				icon:SetTooltipType('skill');
				local skl = session.GetSkill(type);
				if skl ~= nil then
					iesID = skl:GetIESID();
				end
			end
		
			icon:Set(imageName, category, type, 0, iesID);
			icon:SetTooltipNumArg(type);
			icon:SetTooltipIESID(iesID);		
		end

		local quickSlotList = session.GetQuickSlotList();
		local isLockState = quickSlotList:GetQuickSlotLockState();	
		if isLockState == 1 then
			slot:EnableDrag(0);
		else
			slot:EnableDrag(1);
		end

		INIT_QUICKSLOT_SLOT(slot, icon);
		local sendPacket = 1;
		if false == sendSavePacket then
			sendPacket = 0;
		end

		session.SetQuickSlotInfo(slot:GetSlotIndex(), category, type, iesID, makeLog, sendPacket);

		icon:SetDumpArgNum(slot:GetSlotIndex());
	else
		slot:EnableDrag(0);
	end

	if category == 'Skill' then
		SET_QUICKSLOT_OVERHEAT(slot);
		SET_QUICKSLOT_TOOLSKILL(slot);
	end

	slot:Invalidate();
end
