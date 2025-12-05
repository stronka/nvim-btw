local M = {}

M.last_command = "make"

CommandTree = {}
CommandTree.__index = CommandTree

function CommandTree.create_node(value)
	return {
		value = value,
		children = {},
	}
end

function CommandTree.new(value)
	local self = setmetatable({}, CommandTree)
	self.root = self.create_node(value)
	return self
end

function CommandTree.append_node(node, value)
	if node.value == value then
		return node
	end

	for _, child in ipairs(node.children) do
		if child.value == value then
			return child
		end
	end

	local child = CommandTree.create_node(value)
	table.insert(node.children, child)

	return child
end

function CommandTree.get_path(t, path)
	local node = t.root

	for _, value in ipairs(path) do
		if node.value == value then
			goto continue
		end

		for _, child in ipairs(node.children) do
			if child.value == value then
				node = child
				goto continue
			end
		end

		if true then
			return nil
		end

		::continue::
	end

	return node
end

function CommandTree.add_path(t, path)
	local node = t.root

	for _, value in ipairs(path) do
		node = t.append_node(node, value)
	end

	return node
end

function CommandTree.render_children(node)
	local results = {}

	for _, child in ipairs(node.children) do
		table.insert(results, child.value)
	end

	return results
end

function CommandTree.deep_render_children(node, path, results)
	for _, child in ipairs(node.children) do
		local child_path = path
		table.insert(child_path, child.value)
		results = CommandTree.deep_render_children(child, child_path, results)
	end

	if #node.children == 0 then
		table.insert(results, table.concat(path, " "))
	end

	table.remove(path)
	return results
end

local command_index = CommandTree.new("Compile")

local function parse_command(input)
	local compile_input = {}

	for word in input:gmatch("[^ ]+") do
		table.insert(compile_input, word)
	end

	return compile_input
end

M.save_command = function(command)
	CommandTree.add_path(command_index, parse_command("Compile " .. command))
	M.last_command = command
end

M.complete = function(ArgLead, CmdLine, CursorPos)
	local compile_input = parse_command(CmdLine)
	local node = CommandTree.get_path(command_index, compile_input)

	if node == nil then
		return {}
	end

	local result = {}
	local suggestions = {}

	for _, item in ipairs(CommandTree.render_children(node, {}, {})) do
		suggestions[item] = true
	end

	for _, item in ipairs(CommandTree.deep_render_children(node, {}, {})) do
		suggestions[item] = true
	end

	for k, _ in pairs(suggestions) do
		table.insert(result, k)
	end

	return result
end

return M
