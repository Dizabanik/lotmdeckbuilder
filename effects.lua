local effects = {}
effects.types = {}
effects.types.none = 1
effects.types.seeTopCard = 1
effects.combine = function(...)
	local prevWithThen = false
	local combined = {}
	local t = {}
	for i,v in ipairs(arg) do
		if prevWithThen then
			t[#t+1] = ", then "
			t[#t+1] = v.text
		else
			t[#t+1] = ". "
			t[#t+1] = v.text:gsub("^%l", string.upper)
		end
		prevWithThen = v.continueWithThen
	end
	combined.text = table.concat(t)
end
effects.seeTopCard = function(num)
	local effect = {}
	effect.text = "look at " ... num ... " top cards of your library"
	effect.type = effects.types.seeTopCard
	effect.num = num
	effect.continueWithThen = true
	return effect
end
return effects