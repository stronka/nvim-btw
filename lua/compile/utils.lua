local M = {}

ParserState = {
	REGULAR = 1,
	NESTED = 2,
}

M.split_cmd = function(cmd)
	if rawequal(cmd, nil) then
		return {}
	end

	local tokens = {}
	local current_token = ""
	local state = ParserState.REGULAR

	for c in cmd:gmatch(".") do
		if c == "'" or c == '"' then
			if state == ParserState.REGULAR then
				state = ParserState.NESTED
			else
				state = ParserState.REGULAR
			end

			current_token = current_token .. c
		end

		if c == " " and state == ParserState.REGULAR then
			table.insert(tokens, current_token)
			current_token = ""
		else
			current_token = current_token .. c
		end
	end

	if not rawequal(current_token, "") then
		table.insert(tokens, current_token)
		current_token = ""
	end

	return tokens
end

return M
