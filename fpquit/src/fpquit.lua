CHAT_SYSTEM('fpquit is loaded')

local acutil = require('acutil')

local addon_name = 'fpquit'
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][addon_name] = _G['ADDONS'][addon_name] or {}
local g = _G['ADDONS'][addon_name]


g.message = {}
if option.GetCurrentCountry()=='Japanese' then
	g.message['GAME_TO_BARRACK'] = 'バラックへ移動しますか？'
	g.message['GAME_TO_LOGIN'] = 'ログアウトしますか？'
	g.message['DO_QUIT_GAME'] = 'ゲームを終了しますか？'
else
	g.message['GAME_TO_BARRACK'] = 'Do you want to move to the barrack?'
	g.message['GAME_TO_LOGIN'] = 'Do you want to logout?'
	g.message['DO_QUIT_GAME'] = 'Do you want to quit the game?'
end


function FPQUIT_ON_INIT(addon, frame)
	acutil.setupHook(GAME_TO_BARRACK_HOOKED, 'GAME_TO_BARRACK')
	acutil.setupHook(GAME_TO_LOGIN_HOOKED, 'GAME_TO_LOGIN')
	acutil.setupHook(DO_QUIT_GAME_HOOKED, 'DO_QUIT_GAME')
end


function GAME_TO_BARRACK_HOOKED()
	ui.MsgBox(g.message['GAME_TO_BARRACK'], 'GAME_TO_BARRACK_OLD()', 'None')
end

function GAME_TO_LOGIN_HOOKED()
	ui.MsgBox(g.message['GAME_TO_LOGIN'], 'GAME_TO_LOGIN_OLD()', 'None')
end

function DO_QUIT_GAME_HOOKED()
	ui.MsgBox(g.message['DO_QUIT_GAME'], 'DO_QUIT_GAME_OLD()', 'None')
end
