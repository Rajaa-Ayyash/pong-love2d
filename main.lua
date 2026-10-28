
local W, H = 800, 600
local player1, player2, ball
local speedIncrease = 1.05

function love.load()
    love.window.setTitle("Pong Game")
    love.window.setMode(W, H)
    love.graphics.setBackgroundColor(0.08, 0.08, 0.12)

    -- Players and ball
    player1 = {
        x = 30, y = 250,
        width = 15, height = 100,
        speed = 300
    }

    player2 = {
        x = 755, y = 250,
        width = 15, height = 100,
        speed = 300
    }

    ball = {
        x = 390, y = 290,
        width = 20, height = 20,
        dx = 220, dy = 160
    }
end

function movePaddles(dt)
    -- Player movement
    if love.keyboard.isDown("w") then
        player1.y = player1.y - player1.speed * dt
    end

    if love.keyboard.isDown("s") then
        player1.y = player1.y + player1.speed * dt
    end

    if love.keyboard.isDown("up") then
        player2.y = player2.y - player2.speed * dt
    end

    if love.keyboard.isDown("down") then
        player2.y = player2.y + player2.speed * dt
    end

    -- Keep paddles inside the screen
    player1.y = math.max(0, math.min(player1.y, H - player1.height))
    player2.y = math.max(0, math.min(player2.y, H - player2.height))
end

-- Check rectangle collision
function checkCollision(a, b)
    return a.x < b.x + b.width
       and a.x + a.width > b.x
       and a.y < b.y + b.height
       and a.y + a.height > b.y
end

function resetBall()
    ball.x = W / 2 - ball.width / 2
    ball.y = H / 2 - ball.height / 2
    ball.dx = ball.dx > 0 and -220 or 220
    ball.dy = 160
end

function love.update(dt)
    movePaddles(dt)

    -- Ball movement
    ball.x = ball.x + ball.dx * dt
    ball.y = ball.y + ball.dy * dt

    -- Wall collision
    if ball.y <= 0 then
        ball.y = 0
        ball.dy = -ball.dy

    elseif ball.y + ball.height >= H then
        ball.y = H - ball.height
        ball.dy = -ball.dy
    end

    -- Paddle collision
    if ball.dx < 0 and checkCollision(ball, player1) then
        ball.x = player1.x + player1.width
        ball.dx = -ball.dx * speedIncrease
        ball.dy = ball.dy * speedIncrease

    elseif ball.dx > 0 and checkCollision(ball, player2) then
        ball.x = player2.x - ball.width
        ball.dx = -ball.dx * speedIncrease
        ball.dy = ball.dy * speedIncrease
    end

    -- Reset ball when a player misses
    if ball.x + ball.width < 0 or ball.x > W then
        resetBall()
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1)

    -- Draw players and ball
    love.graphics.rectangle(
        "fill",
        player1.x, player1.y,
        player1.width, player1.height
    )

    love.graphics.rectangle(
        "fill",
        player2.x, player2.y,
        player2.width, player2.height
    )

    love.graphics.rectangle(
        "fill",
        ball.x, ball.y,
        ball.width, ball.height
    )
end

function love.keypressed(key)
    if key == "f5" then
        love.event.quit("restart")
    end
end
