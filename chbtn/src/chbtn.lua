function CHBTN_ON_INIT(addon, frame)
	addon:RegisterMsg('GAME_START', 'CHBTN_CREATE_BUTTONS');
end


function CHBTN_CHANGE_CHANNEL(channel)
	local zoneInsts = session.serverState.GetMap();
	if zoneInsts == nil or zoneInsts.pcCount == -1 then
		ui.SysMsg(ClMsg("ChannelIsClosed")); 
		return; 
	end 

	--GAME_MOVE_CHANNEL(channel);
	RUN_GAMEEXIT_TIMER("Channel", channel);
end

function CHBTN_GET_NEXT_CHANNEL()
	local zoneInsts = session.serverState.GetMap();
	local numberOfChannels = zoneInsts:GetZoneInstCount();
	local currentChannel = session.loginInfo.GetChannel();
	local nextChannel = (currentChannel + 1) % numberOfChannels;

	return nextChannel;
end

function CHBTN_GET_PREV_CHANNEL()
	local zoneInsts = session.serverState.GetMap();
	local numberOfChannels = zoneInsts:GetZoneInstCount();
	local currentChannel = session.loginInfo.GetChannel();
	local prevChannel = (numberOfChannels + currentChannel - 1) % numberOfChannels;

	return prevChannel;
end

function CHBTN_CREATE_BUTTONS()
	local frame = ui.GetFrame("minimap");
	local btnsize = 30;

	local nextbutton = frame:CreateOrGetControl('button', "nextbutton", 5+34, 5, btnsize, btnsize);
	tolua.cast(nextbutton, "ui::CButton");
	nextbutton:SetText("{s22}>");
	nextbutton:SetEventScript(ui.LBUTTONUP, "CHBTN_CHANGE_CHANNEL(CHBTN_GET_NEXT_CHANNEL())");
	nextbutton:SetClickSound('button_click_big');
	nextbutton:SetOverSound('button_over');

	local prevbutton = frame:CreateOrGetControl('button', "prevbutton", 5, 5, btnsize, btnsize);
	tolua.cast(prevbutton, "ui::CButton");
	prevbutton:SetText("{s22}<");
	prevbutton:SetEventScript(ui.LBUTTONUP, "CHBTN_CHANGE_CHANNEL(CHBTN_GET_PREV_CHANNEL())");
	prevbutton:SetClickSound('button_click_big');
	prevbutton:SetOverSound('button_over');
end
