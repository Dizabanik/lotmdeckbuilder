local effects = require 'effects'
local cards = {
    { name = "Arrodes", type = "SArtifact", image = love.graphics.newImage("images/cards/01-Arrodes.jpg"), cost = 1, premonition = effects.combine(effects.seeTopCard(1), effects.receiveMadness(3)), focused = effects.combine(effects.seeTopCard(3), effects.receiveMadness(2)) },
}
return cards