
function love.load()
    love.window.setTitle("Pong Game")
    love.window.setMode(800, 600)
    love.graphics.setBackgroundColor(0.08, 0.08, 0.12)

    -- Left paddle
    player1 = {
        x = 30,
        y = 250,
        width = 15,
        height = 100,
        speed = 300
    }

    -- Right paddle
    player2 = {
        x = 755,
        y = 250,
        width = 15,
        height = 100,
        speed = 300
    }
end


function love.update(dt)
    -- Left paddle movement
    if love.keyboard.isDown("w") then
        player1.y = player1.y - player1.speed * dt
    end

    if love.keyboard.isDown("s") then
        player1.y = player1.y + player1.speed * dt
    end

    -- Right paddle movement
    if love.keyboard.isDown("up") then
        player2.y = player2.y - player2.speed * dt
    end

    if love.keyboard.isDown("down") then
        player2.y = player2.y + player2.speed * dt
    end

    -- Keep paddles inside the window
    player1.y = math.max(
        0,
        math.min(player1.y, 600 - player1.height)
    )

    player2.y = math.max(
        0,
        math.min(player2.y, 600 - player2.height)
    )
end


function love.draw()
    love.graphics.setColor(1, 1, 1)

    -- Draw left paddle
    love.graphics.rectangle(
        "fill",
        player1.x,
        player1.y,
        player1.width,
        player1.height
    )

    -- Draw right paddle
    love.graphics.rectangle(
        "fill",
        player2.x,
        player2.y,
        player2.width,
        player2.height
    )
end

function love.keypressed(key)
    if key == "f5" then
        love.event.quit("restart")
    end
end
