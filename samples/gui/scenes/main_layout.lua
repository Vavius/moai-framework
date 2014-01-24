--------------------------------------------------------------------------------
--
--
--------------------------------------------------------------------------------

Button = Gui.Button
ScrollView = Gui.ScrollView

local function MainLayout(layer, owner)
    local group = Group {
        name = 'mainGroup',
        children = {
            Button {
                name = 'btnLoadScene',
                normalSprite = Sprite("btn_next.png"),
                activeSprite = Sprite("btn_next_active.png"),
                label = Label("Load Scene", 200, 100, "Verdana.ttf", 24),
                onClick = function(e) owner:onLoadSceneClick(e) end,
                layer = layer,
            },
            
            Button {
                name = 'btnLoadScene',
                normalSprite = Sprite("btn_next.png"),
                activeSprite = Sprite("btn_next_active.png"),
                label = Label("Load Scene", 200, 100, "Verdana.ttf", 24),
                onClick = function(e) owner:onLoadSceneClick(e) end,
                layer = layer,
            },

            Button {
                name = 'btnLoadScene',
                normalSprite = Sprite("btn_next.png"),
                activeSprite = Sprite("btn_next_active.png"),
                label = Label("Load Scene", 200, 100, "Verdana.ttf", 24),
                onClick = function(e) owner:onLoadSceneClick(e) end,
                layer = layer,
                loc = {0, -100, 0},
            },
        },

    }

    return group
end

return MainLayout