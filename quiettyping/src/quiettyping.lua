CHAT_SYSTEM('quiettyping is loaded')

local acutil = require('acutil')

local ADDON_NAME = 'quiettyping'
local APPEND_FILE_LOCATION = '../addons/' .. ADDON_NAME .. '/append.json'

local targets = 
{
	{'auction_popup', 'inputmoney'},
	{'chat', 'mainchat'},
	{'chatpopup', 'mainchat'},
	{'dialogselect', 'numberEdit'},
	{'friend', 'friendtree_normal_gbox', 'friendSearch'},
	{'inputstring', 'input'},
	{'inventory', 'inventoryGbox', 'ItemSearch'},
	{'operchat', 'mainchat'},
	{'party_search', 'party_search_pip', 'mainGbox', 'noteSearchEdit'},
	{'personal_shop_register', 'gbox', 'inputname'},
	{'tpitem', 'leftgFrame', 'leftgbox', 'alignmentgbox', 'editSkin', 'input'},
	{'worldmap', 'input_search'},
	{'worldpvp_observer_chat', 'mainchat'},
	{'barrackthema', 'input'},
	{'chatdrag', 'mainchat'}
}

local first_run = true

function QUIETTYPING_ON_INIT(addon, frame)
	if first_run then
		local tmp_table = acutil.loadJSON(APPEND_FILE_LOCATION, nil, true)

		for _, v in pairs(tmp_table) do
			table.insert(targets, v)
		end

		first_run = false
	end

	addon:RegisterMsg('GAME_START', 'QUIETTYPING_ON_GAME_START')
end

function QUIETTYPING_ON_GAME_START(frame)
	for _, target in pairs(targets) do
		local control = nil

		for index, name in pairs(target) do
			if 1 == index then
				control = ui.GetFrame(name)
			else
				control = GET_CHILD(control, name)
			end
	
			if nil == control then
				break
			end
		end

		if nil ~= control then
			control:SetTypingSound('')
		end
	end
end

--ui.CEditControl.SetTypingSound(ctrl, name)

