INITwindowWidth = love.graphics.getWidth()
INITwindowHeight = love.graphics.getHeight()
function refreshWindowValues()
    windowWidth = love.graphics.getWidth()
    windowHeight = love.graphics.getHeight()
    gameWidth = 200
    gameHeight = 200
    gameSpeed = (100 * (((((windowWidth + windowHeight) / 2)) / ((gameWidth + gameHeight) / 2)) / ((INITwindowWidth + INITwindowHeight) / 2)))
end
refreshWindowValues()

function renderObject(obj)
    if not obj["animation"]["parallax"] then
        love.graphics.draw(obj["texture"], obj["coords"][1][1], obj["coords"][1][2], 0, obj["scale"])
    else
        for k, v in pairs(obj["coords"]) do
            love.graphics.draw(obj["texture"], obj["coords"][k][1], obj["coords"][k][2], 0, obj["scale"])
        end
    end
end

function loadObjects()
    for k, v in pairs(RAW_objects) do
        objects[k]["texture"] = love.graphics.newImage(v["texture"])
        local xC, yC = 0, 0
        if not v["x"] then xC = 0 elseif v["x"] == "window" then xC = windowWidth else xC = (v["x"] / gameWidth) * windowWidth end
        if not v["y"] then yC = 0 elseif v["y"] == "window" then xY = windowHeight else yC = (v["y"] / gameHeight) * windowHeight  end
        objects[k]["coords"] = {{xC, yC}}
        if v["scale"] == "auto" then
            objects[k]["scale"] = ((math.max(windowWidth, windowHeight) / math.max(objects[k]["texture"]:getWidth(),objects[k]["texture"]:getHeight())))
        else
            objects[k]["scale"] = v["scale"] * gameSpeed
        end
        if v["animation"]["anim8"] == true then
            objects[k]["animation"]["SPRITEMAP"] = anim8.newGrid(objects[k]["animation"]["frameWidth"], objects[k]["animation"]["frameHeight"], objects[k]["texture"]:getWidth(), objects[k]["texture"]:getHeight())
            objects[k]["animation"]["ANIM"] = anim8.newAnimation(objects[k]["animation"]["SPRITEMAP"](objects[k]["animation"]["frameCount"], 1), objects[k]["animation"]["frameTiming"], objects[k]["animation"]["loopCondition"])
        end
        if v["animation"]["parallax"] == true then
            objects[k]["animation"]["MAX_parallaxRepeats"] = math.ceil((windowWidth + (objects[k]["texture"]:getWidth() * objects[k]["scale"])) / (objects[k]["texture"]:getWidth() * objects[k]["scale"]))
            if v["animation"]["parallaxRepeats"] == "auto" or not v["animation"]["parallaxRepeats"] then objects[k]["animation"]["parallaxRepeats"] = objects[k]["animation"]["MAX_parallaxRepeats"] end
            local offsetX = objects[k]["coords"][1][1]
            for i = 1, objects[k]["animation"]["parallaxRepeats"] - 1, 1 do
                if v["animation"]["parallaxRepeats"] == "auto" or not v["animation"]["parallaxRepeats"] then
                    offsetX = offsetX + (objects[k]["texture"]:getWidth() * objects[k]["scale"])
                else
                    offsetX = offsetX + ((objects[k]["texture"]:getWidth() * objects[k]["scale"]) * ((objects[k]["animation"]["MAX_parallaxRepeats"] / objects[k]["animation"]["parallaxRepeats"]) * (i)))
                end
                --if v == RAW_objects["pillar"] then for c, f in pairs(objects["pillar"]["coords"]) do print("pillar",f[1]) end end
                table.insert(objects[k]["coords"], {offsetX,0})
            end
            objects[k]["animation"]["parallaxSpeed"] = (objects[k]["animation"]["parallaxSpeed"] / ((gameWidth + gameHeight)/2)) * ((windowWidth + windowHeight)/2)
        end
        if v["hitboxes"] then
            for n, l in pairs(objects[k]["hitboxes"]) do
                for c, j in pairs(l) do
                    if j[1] == "width" then j[1] = objects[k]["texture"]:getWidth() end
                    if j[2] == "height" then j[2] = objects[k]["texture"]:getHeight() end
                    j[1], j[2] = (j[1] * objects[k]["scale"]),(j[2] * objects[k]["scale"])
                    print(j[1], j[2])
                end
            end
        end
        objects[k]["drawObject"] = function(x) renderObject(x) end
    end
end

function isColliding(collider1, collider2)
    for u, f in pairs(collider1["coords"]) do
        for o, l in pairs(collider1["hitboxes"]) do
            for k, j in pairs(collider2["coords"]) do
                for v, h in pairs(collider2["hitboxes"]) do
                    --continue writing collision detection here
                    --print(f[1] + l[1][1],j[1] + h[1][1])
                    if (((f[1] + l[1][1]) >= (j[1] + h[1][1]) and (f[1] + l[1][1]) <= (j[1] + h[2][1])) or ((f[1] + l[2][1]) >= (j[1] + h[1][1]) and (f[1] + l[2][1]) <= (j[1] + h[2][1]))) and (((f[2] + l[1][2]) >= (j[2] + h[1][2]) and (f[2] + l[1][2]) <= (j[2] + h[2][2])) or ((f[2] + l[2][2]) >= (j[2] + h[1][2]) and (f[2] + l[2][2]) <= (j[2] + h[2][2]))) then
                        return true
                    end
                end
            end
        end
    end
    return false
end