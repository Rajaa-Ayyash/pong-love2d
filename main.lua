
local W, H = 800, 600
local player1, player2, ball
local speedIncrease = 1.05
local dots, ballTrail = {}, {}

local score1, score2 = 0, 0
local winningScore = 5
local gameState, winner = "start", ""
local titleFont, scoreFont, smallFont

function love.load()
    love.window.setTitle("Neon Pong")
    love.window.setMode(W, H)
    love.graphics.setBackgroundColor(0.05, 0.06, 0.15)

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

    -- Score and game state
    score1, score2 = 0, 0
    gameState, winner = "start", ""

    titleFont = love.graphics.newFont(36)
    scoreFont = love.graphics.newFont(30)
    smallFont = love.graphics.newFont(16)

    -- Background dots
    dots = {}
    ballTrail = {}

    math.randomseed(42)

    for i = 1, 65 do
        dots[i] = {
            x = math.random(25, 775),
            y = math.random(25, 575),
            size = math.random(1, 3),
            alpha = math.random(25, 65) / 100
        }
    end
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
    ballTrail = {}
end

function love.update(dt)
    if gameState ~= "playing" then
        return
    end

    movePaddles(dt)

    -- Save ball trail
    table.insert(ballTrail, 1, {
        x = ball.x + ball.width / 2,
        y = ball.y + ball.height / 2
    })

    if #ballTrail > 12 then
        table.remove(ballTrail)
    end

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

    -- Give a point when someone misses
    if ball.x + ball.width < 0 then
        score2 = score2 + 1
        resetBall()

    elseif ball.x > W then
        score1 = score1 + 1
        resetBall()
    end

    -- Check winner
    if score1 >= winningScore then
        winner = "PLAYER 1 WINS!"
        gameState = "gameover"

    elseif score2 >= winningScore then
        winner = "PLAYER 2 WINS!"
        gameState = "gameover"
    end
end

-- Draw neon background
function drawBackground()
    -- Gradient
    for y = 0, H, 2 do
        local t = y / H

        love.graphics.setColor(
            0.06 + t * 0.04,
            0.05 + t * 0.02,
            0.17 + t * 0.07
        )

        love.graphics.rectangle("fill", 0, y, W, 2)
    end

    -- Pink and blue sides
    love.graphics.setColor(0.45, 0.05, 0.35, 0.12)
    love.graphics.rectangle("fill", 0, 0, W / 2, H)

    love.graphics.setColor(0.02, 0.30, 0.65, 0.10)
    love.graphics.rectangle("fill", W / 2, 0, W / 2, H)

    -- Small dots
    for i, dot in ipairs(dots) do
        if i % 2 == 0 then
            love.graphics.setColor(1, 0.40, 0.85, dot.alpha)
        else
            love.graphics.setColor(0.35, 0.75, 1, dot.alpha)
        end

        love.graphics.circle(
            "fill", dot.x, dot.y, dot.size
        )
    end

    -- Center line
    love.graphics.setColor(0.55, 0.50, 1, 0.55)

    for y = 25, 575, 28 do
        love.graphics.rectangle(
            "fill", 398, y, 4, 14, 2, 2
        )
    end

    -- Arena border
    love.graphics.setLineWidth(9)
    love.graphics.setColor(0.9, 0.2, 0.8, 0.12)
    love.graphics.rectangle(
        "line", 15, 15, 770, 570, 16, 16
    )

    love.graphics.setLineWidth(3)

    love.graphics.setColor(0.95, 0.35, 0.95)
    love.graphics.line(18, 580, 18, 20, 400, 20)

    love.graphics.setColor(0.25, 0.85, 1)
    love.graphics.line(400, 20, 782, 20, 782, 580)

    love.graphics.setColor(0.55, 0.45, 1)
    love.graphics.line(18, 580, 782, 580)

    love.graphics.setLineWidth(1)
end

-- Draw glowing paddle
function drawPaddle(paddle, r, g, b)
    love.graphics.setColor(r, g, b, 0.10)
    love.graphics.rectangle(
        "fill",
        paddle.x - 9, paddle.y - 9,
        paddle.width + 18, paddle.height + 18,
        10, 10
    )

    love.graphics.setColor(r, g, b, 0.25)
    love.graphics.rectangle(
        "fill",
        paddle.x - 4, paddle.y - 4,
        paddle.width + 8, paddle.height + 8,
        7, 7
    )

    love.graphics.setColor(r, g, b)
    love.graphics.rectangle(
        "fill",
        paddle.x, paddle.y,
        paddle.width, paddle.height,
        5, 5
    )

    love.graphics.setColor(1, 1, 1, 0.65)
    love.graphics.rectangle(
        "fill",
        paddle.x + 3, paddle.y + 5,
        3, paddle.height - 10,
        2, 2
    )
end

-- Draw player scores
function drawScoreboard()
    love.graphics.setFont(scoreFont)

    -- Left score
    love.graphics.setColor(1, 0.35, 0.78, 0.15)
    love.graphics.rectangle(
        "fill", 100, 35, 130, 65, 10, 10
    )

    love.graphics.setColor(1, 0.45, 0.85)
    love.graphics.rectangle(
        "line", 100, 35, 130, 65, 10, 10
    )

    love.graphics.printf(
        tostring(score1), 100, 49, 130, "center"
    )

    -- Right score
    love.graphics.setColor(0.25, 0.85, 1, 0.15)
    love.graphics.rectangle(
        "fill", 570, 35, 130, 65, 10, 10
    )

    love.graphics.setColor(0.45, 0.95, 1)
    love.graphics.rectangle(
        "line", 570, 35, 130, 65, 10, 10
    )

    love.graphics.printf(
        tostring(score2), 570, 49, 130, "center"
    )

    love.graphics.setFont(smallFont)
    love.graphics.setColor(1, 1, 1, 0.65)

    love.graphics.printf(
        "FIRST TO 5", 300, 40, 200, "center"
    )

    love.graphics.setColor(1, 1, 1)
end

-- Draw start and winner screens
function drawGameScreen()
    if gameState == "playing" then
        return
    end

    love.graphics.setColor(0.04, 0.05, 0.14, 0.88)
    love.graphics.rectangle("fill", 0, 0, W, H)

    love.graphics.setFont(titleFont)

    if gameState == "start" then
        love.graphics.setColor(1, 0.45, 0.85)
        love.graphics.printf(
            "NEON PONG", 0, 205, W, "center"
        )
    else
        love.graphics.setColor(0.45, 0.95, 1)
        love.graphics.printf(
            winner, 0, 205, W, "center"
        )
    end

    love.graphics.setFont(smallFont)
    love.graphics.setColor(1, 1, 1)

    local prompt = gameState == "start"
        and "Press SPACE to start"
        or "Press SPACE to play again"

    love.graphics.printf(
        prompt, 0, 285, W, "center"
    )

    love.graphics.setColor(0.65, 0.70, 0.90)
    love.graphics.printf(
        "Player 1: W / S     Player 2: UP / DOWN",
        0, 345, W, "center"
    )

    love.graphics.setColor(1, 1, 1)
end

function love.draw()
    drawBackground()

    -- Draw paddles
    drawPaddle(player1, 1, 0.35, 0.78)
    drawPaddle(player2, 0.35, 0.90, 1)

    -- Ball trail
    for i, point in ipairs(ballTrail) do
        local alpha = (1 - i / 13) * 0.35
        local radius = math.max(1, 7 - i * 0.45)

        love.graphics.setColor(
            1, 0.75, 0.40, alpha
        )

        love.graphics.circle(
            "fill", point.x, point.y, radius
        )
    end

    local cx = ball.x + ball.width / 2
    local cy = ball.y + ball.height / 2

    -- Ball glow
    love.graphics.setColor(1, 0.70, 0.35, 0.10)
    love.graphics.circle("fill", cx, cy, 22)

    love.graphics.setColor(1, 0.82, 0.45, 0.25)
    love.graphics.circle("fill", cx, cy, 15)

    -- Ball
    love.graphics.setColor(1, 0.95, 0.75)
    love.graphics.circle("fill", cx, cy, 10)

    drawScoreboard()
    drawGameScreen()

    love.graphics.setColor(1, 1, 1)
end

function love.keypressed(key)
    if key == "f5" then
        love.event.quit("restart")
    end

    -- Start game
    if key == "space" then
        if gameState == "start" then
            resetBall()
            gameState = "playing"

        elseif gameState == "gameover" then
            score1, score2 = 0, 0
            winner = ""
            resetBall()
            gameState = "playing"
        end
    end
end
