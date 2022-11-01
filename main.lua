anim8 = require 'libraries/anim8'
json = require 'libraries/json'
require('libraries/randomlua')
mwc = mwc(os.time())
require('libraries/libcatstack')

RAW_objects = json.decode(love.filesystem.read("objects.json"))
objects = json.decode(love.filesystem.read("objects.json"))
function nextParallaxFrame(delta, ...)
    local args = {...}
    for k, v in pairs(args) do
        if v["animation"]["parallax"] == true then
            for d, f in pairs(v["coords"]) do
                if v["animation"]["parallaxAxis"] == "x" then
                    f[1] = f[1] + ((v["animation"]["parallaxSpeed"] * gameSpeed) * (60*delta))
                elseif v["animation"]["parallaxAxis"] == "y" then
                    f[2] = f[2] + ((v["animation"]["parallaxSpeed"] * gameSpeed) * (60*delta))
                elseif v["animation"]["parallaxAxis"] == "xy" then
                    f[1] = f[1] + ((v["animation"]["parallaxSpeed"] * gameSpeed) * (60*delta))
                    f[2] = f[2] + ((v["animation"]["parallaxSpeed"] * gameSpeed) * (60*delta))
                end
                if ((v["texture"]:getWidth() * v["scale"]) * -1) >= f[1] then
                    if v == objects[area .. "_pillar"] then
                        f[2] = mwc:random(-10,-v["hitboxes"][1][2][2] + 10)
                        v["health"] = 1
                    end
                    f[1] = f[1] + ((v["animation"]["MAX_parallaxRepeats"] * (v["texture"]:getWidth() * v["scale"])))
                end
            end
        end
    end
end

function calc_physics(delta,player)
    if love.keyboard.isDown("space") and currentState == "gameActive" then
        if isMoving == false then
            player["animation"]["ANIM"]:gotoFrame(1)
            player["animation"]["ANIM"]:resume()
            player["animation"]["velocity"] = 4.25
        end
        isMoving = true
    else
        isMoving = false
    end
    player["coords"][1][2] = player["coords"][1][2] - player["animation"]["velocity"] * ((3) * (60 * delta))
    if player["animation"]["velocity"] >= -11 * gameSpeed then
        player["animation"]["velocity"] = player["animation"]["velocity"] - ((0.22) * (60 * delta))
    end
    if currentState == "gameActive" then
    if player["coords"][1][2] + player["hitboxes"][1][1][2] <= 0 then
        player["coords"][1][2] = 0 - player["hitboxes"][1][1][2]
    end
    if player["coords"][1][2] + player["hitboxes"][1][2][2] >= windowHeight then
        player["coords"][1][2] = windowHeight - player["hitboxes"][1][2][2]
    end
end
end
area = "desert"
function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    loadObjects()
    WIDTH, HEIGHT, FLAGS = love.window.getMode()
    print(HEIGHT)
    isMoving = false
    points = 0
    font = love.graphics.newFont(22)
    love.graphics.setFont(font)
    for d, f in pairs(objects[area .. "_pillar"]["coords"]) do
        f[2] = mwc:random(-10,-objects[area .. "_pillar"]["hitboxes"][1][2][2] + 10)
    end
    --objects["bird"]["animation"]["ANIM"]:flipV()
    currentState = "titleScreen"
    states = {}
    function states.gameOver()
        currentState = "gameOver"
    end
    function states.gameActive()
        currentState = "gameActive"
        area = "desert"
        objects = json.decode(love.filesystem.read("objects.json"))
        loadObjects()
        for d, f in pairs(objects[area .. "_pillar"]["coords"]) do
            f[2] = mwc:random(-10,-objects[area .. "_pillar"]["hitboxes"][1][2][2] + 10)
        end
        points = 0
    end
    function states.titleScreen()
        currentState = "titleScreen"
    end
end

function love.keypressed(key)
    if key == "1" then
        states.gameActive()
    end
end

function love.update(dt)
    WIDTH, HEIGHT, FLAGS = love.window.getMode()
    calc_physics(dt,objects["bird"])
    objects["bird"]["animation"]["ANIM"]:update(dt)
    objects["spacebar"]["animation"]["ANIM"]:update(dt)
    if currentState ~= "gameOver" then nextParallaxFrame(dt, objects[area .. "_1"],objects[area .. "_2"],objects[area .. "_3"],objects[area .. "_4"],objects[area .. "_pillar"]) end
    if currentState == "gameActive" then
        if isColliding(objects["bird"],objects[area .. "_pillar"]) then
            states.gameOver()
            objects["bird"]["animation"]["velocity"] = 4.25
            --objects = json.decode(love.filesystem.read("objects.json"))
            --loadObjects()
            --for d, f in pairs(objects[area .. "_pillar"]["coords"]) do
            --    f[2] = mwc:random(-10,-objects[area .. "_pillar"]["hitboxes"][1][2][2] + 10)
            --end
    --else
    --    print("Alive")
        end
        for d, f in pairs(objects[area .. "_pillar"]["coords"]) do
            if objects[area .. "_pillar"]["coords"][d][1] <= 66 and objects[area .. "_pillar"]["health"] >= 1 then
                points = points +1
                objects[area .. "_pillar"]["health"] = 0
            end
        end
    end
    if currentState == "gameOver" then 
        if objects["bird"]["coords"][1][2] > windowHeight + 100 then
            states.titleScreen()
        end
    end
    if currentState == "titleScreen" then
        if love.keyboard.isDown("space") then
            states.gameActive()
        end
    end
end

function love.draw()
    objects[area .. "_sky"]:drawObject()
    objects[area .. "_1"]:drawObject()
    objects[area .. "_2"]:drawObject()
    objects[area .. "_3"]:drawObject()
    objects[area .. "_pillar"]:drawObject()
    objects[area .. "_4"]:drawObject()
    if currentState == "gameActive" or currentState == "gameOver" then 
        objects["bird"]["animation"]["ANIM"]:draw(objects["bird"]["texture"], objects["bird"]["coords"][1][1], objects["bird"]["coords"][1][2], (objects["bird"]["animation"]["velocity"]) * -0.05, objects["bird"]["scale"], objects["bird"]["scale"])
        font = love.graphics.newFont(36)
        love.graphics.printf(points, font ,0, 30, windowWidth,"center")
    end
    if currentState == "titleScreen" then
        font = love.graphics.newFont(26)
    objects["spacebar"]["animation"]["ANIM"]:draw(objects["spacebar"]["texture"], windowWidth / 2 - (objects["spacebar"]["scale"] * 32), 500,0, objects["spacebar"]["scale"], objects["spacebar"]["scale"])
    love.graphics.printf("Press space to play!", font ,0, 450, windowWidth,"center")
    love.graphics.draw(objects["title_logo"]["texture"], ((windowWidth / 2) - ((objects["title_logo"]["texture"]:getWidth() * 4) / 2)) , ((windowHeight / 2) - ((objects["title_logo"]["texture"]:getHeight() * 4) / 2)) - 100, 0, 4)
    if points > 0 then
        font = love.graphics.newFont(36)
        love.graphics.printf(points, font ,0, 600, windowWidth,"center")
    end
    end
    --love.graphics.draw(, objects["desert_1"]["X"], objects["desert_1"]["Y"], 0, objects["desert_1"]["scale"])
    --love.graphics.print(love.timer.getFPS())
    --love.graphics.print("You Died!", 360, 510)
    
    
end
