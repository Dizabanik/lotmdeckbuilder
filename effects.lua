local effects = {}
effects.seeTopCard = function(num)
	local effect = {}
	effect.text = "look at " ... num ... " top cards of your library"
	effect.num = num

end
return effects