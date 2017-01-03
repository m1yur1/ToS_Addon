CHAT_SYSTEM('tsepprice is loaded')

local acutil = require('acutil')

local ADDON_NAME = 'tsepprice'
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][ADDON_NAME] = _G['ADDONS'][ADDON_NAME] or {}
local g = _G['ADDONS'][ADDON_NAME]


function TSEPPRICE_ON_INIT(addon, frame)
	-- Pardoner: Spell Shop
	acutil.setupHook(UPDATE_BUFFSELLER_SLOT_TARGET_HOOKED, 'UPDATE_BUFFSELLER_SLOT_TARGET')

	-- Squire: Repair
	acutil.setupHook(SCP_LBTDOWN_SQIOR_REPAIR_HOOKED, 'SCP_LBTDOWN_SQIOR_REPAIR')
	acutil.setupHook(SQUIRE_REAPIR_SELECT_ALL_HOOKED, 'SQUIRE_REAPIR_SELECT_ALL')

	-- Squire: Weapon/Armor Maintenance
	acutil.setupHook(SQIORE_SLOT_DROP_HOOKED, 'SQIORE_SLOT_DROP')

	-- Alchemist: Gem Roasting
	acutil.setupHook(GEMROASTING_SLOT_DROP_HOOKED, 'GEMROASTING_SLOT_DROP')

	-- Enchanter: Enchant Armor
	acutil.setupHook(ENCHANTAROMOROPEN_UPDATE_STORINFO_HOOKED, 'ENCHANTAROMOROPEN_UPDATE_STORINFO')

	-- Oracle: Gender Switch
	acutil.setupHook(SWITCHGENDER_UI_OPEN_HOOKED, 'SWITCHGENDER_UI_OPEN')
end


function UPDATE_BUFFSELLER_SLOT_TARGET_HOOKED(ctrlSet, info)
	UPDATE_BUFFSELLER_SLOT_TARGET_OLD(ctrlSet, info)

	local ctrl_price = ctrlSet:GetChild('price')
	local price = ctrl_price:GetTextByKey('value')
	local separated_price = g.GetThousandSeparatedText(price)

	if separated_price then
		ctrl_price:SetTextByKey('value', separated_price)
	end
end

function SCP_LBTDOWN_SQIOR_REPAIR_HOOKED(frame, ctrl)
	SCP_LBTDOWN_SQIOR_REPAIR_OLD(frame, ctrl)

	local ctrl_reqitemMoney = frame:GetTopParentFrame():GetChild('repair'):GetChild('reqitemMoney')
	local price = ctrl_reqitemMoney:GetTextByKey('txt')
	local separated_price = g.GetThousandSeparatedText(price)

	if separated_price then
		ctrl_reqitemMoney:SetTextByKey('txt', separated_price)
	end
end

function SQUIRE_REAPIR_SELECT_ALL_HOOKED(frame, ctrl)
	SQUIRE_REAPIR_SELECT_ALL_OLD(frame, ctrl)

	local ctrl_reqitemMoney = frame:GetTopParentFrame():GetChild('repair'):GetChild('reqitemMoney')
	local price = ctrl_reqitemMoney:GetTextByKey('txt')
	local separated_price = g.GetThousandSeparatedText(price)

	if separated_price then
		ctrl_reqitemMoney:SetTextByKey('txt', separated_price)
	end
end

function SQIORE_SLOT_DROP_HOOKED(parent, ctrl)
	SQIORE_SLOT_DROP_OLD(parent, ctrl)

	local ctrl_reqitemMoney = parent:GetTopParentFrame():GetChild('repair'):GetChild('reqitemMoney')
	local price = ctrl_reqitemMoney:GetTextByKey('txt')
	local separated_price = g.GetThousandSeparatedText(price)

	if separated_price then
		ctrl_reqitemMoney:SetTextByKey('txt', separated_price)
	end
end

function GEMROASTING_SLOT_DROP_HOOKED(parent, ctrl)
	GEMROASTING_SLOT_DROP_OLD(parent, ctrl)

	local ctrl_reqitemMoney = parent:GetTopParentFrame():GetChild('roasting'):GetChild('reqitemMoney')
	local price = ctrl_reqitemMoney:GetTextByKey('txt')
	local separated_price = g.GetThousandSeparatedText(price)

	if separated_price then
		ctrl_reqitemMoney:SetTextByKey('txt', separated_price)
	end
end

function ENCHANTAROMOROPEN_UPDATE_STORINFO_HOOKED(frame, groupName)
	ENCHANTAROMOROPEN_UPDATE_STORINFO_OLD(frame, groupName)

	local ctrl_money = frame:GetChild('moneyGbox'):GetChild('money')
	local price = ctrl_money:GetTextByKey('txt')
	local separated_price = g.GetThousandSeparatedText(price)

	if separated_price then
		ctrl_money:SetTextByKey('txt', separated_price)
	end
end

function SWITCHGENDER_UI_OPEN_HOOKED(frame, showWindow)
	SWITCHGENDER_UI_OPEN_OLD(frame, showWindow)

	local ctrl_money = frame:GetChild('moneyGbox'):GetChild('money')
	local price = ctrl_money:GetTextByKey('txt')
	local separated_price = g.GetThousandSeparatedText(price)

	if separated_price then
		ctrl_money:SetTextByKey('txt', separated_price)
	end
end

g.GetThousandSeparatedText = function (string_value)
	local num = tonumber(string_value)

	if not num then
		return nil
	end

	return GetCommaedText(num)
end
