CHAT_SYSTEM('sortexample is loaded')

local acutil = require('acutil')

local ADDON_NAME = 'sortexample'
local SETTINGS_FILE_LOCATION = '../addons/' .. ADDON_NAME .. '/settings.json'

_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][ADDON_NAME] = _G['ADDONS'][ADDON_NAME] or {}
local g = _G['ADDONS'][ADDON_NAME]

g.settings = {}
g.settings.sort_locked = false


function SORTEXAMPLE_ON_INIT(addon, frame)
	g.settings = acutil.loadJSON(SETTINGS_FILE_LOCATION, g.settings, true)
	acutil.setupHook(SORT_ITEM_INVENTORY_HOOKED, 'SORT_ITEM_INVENTORY')
end

function SORT_ITEM_INVENTORY_HOOKED()
	local menu = ui.CreateContextMenu('CONTEXT_INV_SORT', '', 0, 0, 170, 100)
	local handler_string = string.format("_G['ADDONS']['%s'].SortInventoryBy", ADDON_NAME)
	local menu_string = ''
	local menu_script = ''
	local sort_type_table = {'price', 'name', 'stacksize', 'weight', 'itemweight', 'type', 'grade', 'icon'}
	local order_table = {'ascending', 'descending'}
	local sort_type_string_table = {'Price', 'Name', 'Stack Size', 'Stack Weight', 'Item Weight', 'Type', 'Grade', 'Icon'}
	local order_string_table = {'Asc', 'Desc'}

	for i = 1, #sort_type_table do
		for j = 1, #order_table do
			menu_string = string.format('By %s (%s)', sort_type_string_table[i], order_string_table[j])
			menu_script = string.format("%s('%s', '%s')", handler_string, sort_type_table[i], order_table[j])
			ui.AddContextMenuItem(menu, menu_string, menu_script)
		end
	end

	menu_script = string.format("_G['ADDONS']['%s'].ChangeSortLocked()", ADDON_NAME)

	if g.settings.sort_locked then
		ui.AddContextMenuItem(menu, 'Sort locked items: on', menu_script)
	else
		ui.AddContextMenuItem(menu, 'Sort locked items: off', menu_script)
	end

	ui.OpenContextMenu(menu)
end


g.SortInventoryBy = function (sort_type, order)
	local inventoryGbox = GET_CHILD(ui.GetFrame('inventory'), 'inventoryGbox', 'ui::CGroupBox')
	sort_type = string.lower(sort_type)
	order = string.lower(order)

	for inventory_type_index = 1, #g_invenTypeStrList do
		local treeGbox = GET_CHILD(inventoryGbox, 'treeGbox_' .. g_invenTypeStrList[inventory_type_index], 'ui::CGroupBox')
		local inventree = GET_CHILD(treeGbox, 'inventree_' .. g_invenTypeStrList[inventory_type_index], 'ui::CTreeControl')

		for slotset_index = 1, #SLOTSET_NAMELIST do
			local slotset = GET_CHILD(inventree, SLOTSET_NAMELIST[slotset_index], 'ui::CSlotSet')

			if slotset ~= nil then
				local compare_data = g.CreateCompareData(slotset, sort_type, g.settings.sort_locked)

				if 2 <= #compare_data then
					if order ~= 'descending' then
						g.QuickSort(slotset, compare_data, 1, #compare_data, function (a, b) return a.string_value < b.string_value end)
					else
						g.QuickSort(slotset, compare_data, 1, #compare_data, function (a, b) return a.string_value > b.string_value end)
					end

					UPDATE_INV_LIST(ui.GetFrame('inventory'), slotset)
				end
			end
		end
	end
end

g.CreateCompareData = function (slotset, sort_type, remove_locked_item)
	local compare_data = {}
	local child_count = slotset:GetChildCount()
	local item_count = 1

	for child_index = 0, child_count - 1 do
		local slot = slotset:GetChildByIndex(child_index)
		local item = GET_SLOT_ITEM(slot)

		if item ~= nil and not (remove_locked_item and item.isLockState) then
			local item_class = GetIES(item:GetObject())

			if item_class ~= nil then
				compare_data[item_count] = {}
				compare_data[item_count].invIndex = item.invIndex
				local item_name = dictionary.ReplaceDicIDInCompStr(item_class.Name)

				if sort_type == 'price' then
					local item_property = geItemTable.GetPropByName(item_class.ClassName)
					local price = geItemTable.GetSellPrice(item_property)
					compare_data[item_count].string_value = acutil.leftPad('' .. price, 11, '0') .. item_name

				elseif sort_type == 'name' then
					compare_data[item_count].string_value = item_name

				elseif sort_type == 'stacksize' then
					local remain_count = GET_REMAIN_INVITEM_COUNT(item)
					compare_data[item_count].string_value = acutil.leftPad('' .. remain_count, 11, '0') .. item_name

				elseif sort_type == 'weight' then
					local weight = item_class.Weight
					local remain_count = GET_REMAIN_INVITEM_COUNT(item)
					compare_data[item_count].string_value = acutil.leftPad('' .. (weight * remain_count), 11, '0') .. item_name

				elseif sort_type == 'itemweight' then
					local weight = item_class.Weight
					compare_data[item_count].string_value = acutil.leftPad('' .. weight, 11, '0') .. item_name

				elseif sort_type == 'type' then
					compare_data[item_count].string_value = item_class.StringArg .. item_name

				elseif sort_type == 'grade' then
					local grade = item_class.ItemGrade

					if item_class.ItemType == 'Recipe' then
						local recipe_grade = string.match(item_class.Icon, 'misc(%d)')

						if recipe_grade ~= nil then
							grade = tonumber(recipe_grade) - 1
						end
					end

					compare_data[item_count].string_value = acutil.leftPad('' .. grade, 11, '0') .. item_name

				elseif sort_type == 'icon' then
					compare_data[item_count].string_value = acutil.leftPad('' .. item_class.Icon, 64, ' ') .. item_name
				end

				item_count = item_count + 1
			end
		end
	end

	return compare_data
end

g.QuickSort = function (slotset, tbl, first_index, last_index, compare_function)
	local i = first_index
	local j = last_index
	local pivot = g.GetMedian(compare_function, tbl[i], tbl[math.floor((i+j) / 2)], tbl[j])

	while true do
		while compare_function(tbl[i], pivot) do
			i = i + 1
		end

		while compare_function(pivot, tbl[j]) do
			j = j - 1
		end

		if i >= j then
			break
		end

		g.SwapItem(slotset, tbl[j].invIndex, tbl[i].invIndex)
		tbl[i].string_value, tbl[j].string_value = tbl[j].string_value, tbl[i].string_value

		i = i + 1
		j = j - 1
	end

	if first_index < i - 1 then
		g.QuickSort(slotset, tbl, first_index, i - 1, compare_function)
	end

	if j + 1 < last_index then
		g.QuickSort(slotset, tbl, j + 1, last_index, compare_function)
	end
end

g.GetMedian = function (compare_function, a, b, c)
	local result = {}

	if compare_function(a, b) then
		if compare_function(b, c) then
			result.string_value = b.string_value
			return result

		elseif compare_function(c, a) then
			result.string_value = a.string_value
			return result

		else
			result.string_value = c.string_value
			return result
		end
	else
		if compare_function(c, b) then
			result.string_value = b.string_value
			return result

		elseif compare_function(a, c) then
			result.string_value = a.string_value
			return result

		else
			result.string_value = c.string_value
			return result
		end
	end
end

g.SwapItem = function (slotset, from_InvIndex, to_InvIndex)
	local to_frame = slotset:GetTopParentFrame()
	local from_slot_index = GET_SLOT_INDEX_BY_INVINDEX(slotset, from_InvIndex)
	local to_slot_index = GET_SLOT_INDEX_BY_INVINDEX(slotset, to_InvIndex)

	if from_slot_index ~= nil and to_slot_index ~= nil then
        item.SwapSlotIndex(IT_INVENTORY, from_InvIndex, to_InvIndex)
        ON_CHANGE_INVINDEX(to_frame, nil, from_InvIndex, to_InvIndex)

        slotset:SwapSlot(from_slot_index, to_slot_index, 'ONUPDATE_SLOT_INVINDEX')
        QUICKSLOT_ON_CHANGE_INVINDEX(from_InvIndex, to_InvIndex)
	end
end

g.ChangeSortLocked = function ()
	g.settings.sort_locked = not g.settings.sort_locked
	acutil.saveJSON(SETTINGS_FILE_LOCATION, g.settings)
end
