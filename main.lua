local moonshine = require 'moonshine'
local cards = require 'cards'
function love.load()
    effect = moonshine(moonshine.effects.filmgrain)
                    .chain(moonshine.effects.sketch)
    effect.filmgrain.size = 10
    -- Window properties
    love.window.setMode(800, 600)
    
    -- Hand configuration
    hand = {
        x = 100,
        y = 450,
        width = 600,
        cards = {},
        cardWidth = 100,
        cardHeight = 150,
        minCardSpacing = 30,
        insertPreviewIndex = nil  -- New: shows where card will be inserted
    }
    
    -- Create some test cards
    for i = 1, 7 do
        table.insert(hand.cards, {
            x = 0,
            y = hand.y,
            dragging = { active = false, diffX = 0, diffY = 0 },
            velocity = { x = 0, y = 0 },
            originalIndex = i
        })
    end
    
    updateCardPositions()
end

function updateCardPositions()
    local numCards = #hand.cards
    local spacing = math.min(
        hand.width / numCards,
        hand.cardWidth + 20
    )
    local totalWidth = spacing * (numCards - 1)
    local startX = hand.x + (hand.width - totalWidth) / 2
    
    for i, card in ipairs(hand.cards) do
        card.targetX = startX + (i - 1) * spacing
        card.targetY = hand.y
        
        if not card.dragging.active and not card.x then
            card.x = card.targetX
            card.y = card.targetY
        end
    end
end

function getInsertIndex(x, y)
    if y < hand.y - 100 or y > hand.y + hand.cardHeight + 100 then
        return nil
    end
    
    local numCards = #hand.cards
    local spacing = math.min(
        hand.width / numCards,
        hand.cardWidth + 20
    )
    local totalWidth = spacing * (numCards - 1)
    local startX = hand.x + (hand.width - totalWidth) / 2
    
    -- Find the nearest gap between cards
    for i = 1, numCards + 1 do
        local gapX = startX + (i - 1.5) * spacing
        if i == 1 and x < startX then return 1 end
        if i == numCards + 1 and x > startX + totalWidth then return numCards + 1 end
        if math.abs(x - gapX) < spacing / 2 then return i end
    end
    
    return nil
end

function love.update(dt)
    local draggedCardIndex = nil
    
    -- Find the dragged card
    for i, card in ipairs(hand.cards) do
        if card.dragging.active then
            draggedCardIndex = i
        end
    end
    
    -- Update insert preview if a card is being dragged
    if draggedCardIndex then
        local mouseX, mouseY = love.mouse.getPosition()
        local insertIndex = getInsertIndex(mouseX, mouseY)
        
        -- Adjust insert index to account for the removed card
        if insertIndex and insertIndex > draggedCardIndex then
            insertIndex = insertIndex - 1
        end
        
        hand.insertPreviewIndex = insertIndex
    else
        hand.insertPreviewIndex = nil
    end
    
    -- Update card positions
    for i, card in ipairs(hand.cards) do
        if card.dragging.active then
            -- Smooth dragging movement
            local targetX = love.mouse.getX() - card.dragging.diffX
            local targetY = love.mouse.getY() - card.dragging.diffY
            
            card.velocity.x = (targetX - card.x) * 0.85
            card.velocity.y = (targetY - card.y) * 0.85
            
            card.x = card.x + card.velocity.x
            card.y = card.y + card.velocity.y
        else
            -- Snap back to position in hand
            local dx = card.targetX - card.x
            local dy = card.targetY - card.y
            
            card.velocity.x = dx * 15 * dt
            card.velocity.y = dy * 15 * dt
            
            card.x = card.x + card.velocity.x
            card.y = card.y + card.velocity.y
        end
    end
end

function love.draw()
    effect(function()
        -- Draw hand area
        love.graphics.setColor(0.2, 0.2, 0.2, 0.5)
        love.graphics.rectangle("fill", hand.x, hand.y, hand.width, hand.cardHeight)
        
        -- Draw insert preview
        if hand.insertPreviewIndex then
            local numCards = #hand.cards
            local spacing = math.min(
                hand.width / numCards,
                hand.cardWidth + 20
            )
            local totalWidth = spacing * (numCards - 1)
            local startX = hand.x + (hand.width - totalWidth) / 2
            local previewX = startX + (hand.insertPreviewIndex - 1) * spacing
            
            -- love.graphics.setColor(0, 1, 0, 0.5)
            -- love.graphics.rectangle("fill", previewX - 2, hand.y, 4, hand.cardHeight)
        end
        
        -- Draw non-dragged cards
        for i, card in ipairs(hand.cards) do
            if not card.dragging.active then
                drawCard(card, card.originalIndex)
            end
        end
        
        -- Draw dragged card last
        for i, card in ipairs(hand.cards) do
            if card.dragging.active then
                drawCard(card, card.originalIndex)
            end
        end
    end)
end

function drawCard(card, index)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", card.x, card.y, hand.cardWidth, hand.cardHeight)
    
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.rectangle("line", card.x, card.y, hand.cardWidth, hand.cardHeight)
    
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(index, card.x + 10, card.y + 10)
end

function love.mousepressed(x, y, button, istouch)
    if button == 1 then
        for i = #hand.cards, 1, -1 do
            local card = hand.cards[i]
            if x > card.x and x < card.x + hand.cardWidth
            and y > card.y and y < card.y + hand.cardHeight then
                card.dragging.active = true
                card.dragging.diffX = x - card.x
                card.dragging.diffY = y - card.y
                card.velocity.x = 0
                card.velocity.y = 0
                return
            end
        end
    end
end

function love.mousereleased(x, y, button, istouch)
    if button == 1 then
        local draggedCardIndex = nil
        for i, card in ipairs(hand.cards) do
            if card.dragging.active then
                draggedCardIndex = i
                card.dragging.active = false
            end
        end
        
        -- If we found a dragged card and have a valid insert position
        if draggedCardIndex and hand.insertPreviewIndex then
            local card = table.remove(hand.cards, draggedCardIndex)
            if hand.insertPreviewIndex > draggedCardIndex then
                hand.insertPreviewIndex = hand.insertPreviewIndex - 1
            end
            table.insert(hand.cards, hand.insertPreviewIndex, card)
        end
        
        hand.insertPreviewIndex = nil
        updateCardPositions()
    end
end

function love.keypressed(key)
    if key == "space" then
        table.insert(hand.cards, {
            x = hand.x + hand.width/2,
            y = hand.y,
            dragging = { active = false, diffX = 0, diffY = 0 },
            velocity = { x = 0, y = 0 },
            originalIndex = #hand.cards + 1
        })
        updateCardPositions()
    end
end