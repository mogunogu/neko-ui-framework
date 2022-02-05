

### 예제

```lua
local ui = require('ui-framework.index')

local selectWorld = ui.BaseComponent({
    panel = Panel,
    root = true,
    showOnTop = true,
    visible = false,
    color = Color(0,0,0,255),
    children = {
        ui.ContainerComponent{
            margin = ui.mx(50),
            color = Color(0,0,0, 120),
            children = {
                ui.RowComponent{
                    color = Color(255, 255, 255, 100),
                    margin = ui.mx(60):my(10),
                    pHeight = 20,
                    children = {
                        ui.TextComponent{
                            margin = ui.ma(5),
                            text = '월드선택',
                            textSize = 15
                        }
                    }
                },
                ui.RowComponent{
                    color = Color(255, 255, 255, 100),
                    margin = ui.mx(10),
                    pHeight = 60,
                    children = {
                        ui.ScrollRowPannel{
                            margin = ui.ma(5),
                            color = Color(100,0,0)
                        }
                    }
                },
                ui.RowComponent{
                    color = Color(255, 255, 255, 100),
                    margin = ui.mx(10):my(10),
                    pHeight = 20,
                    children = {
                        ui.ButtonComponent{
                            margin = ui.mx(10),
                            text = '확인',
                            onAfterBuild = function(this, panel)
                                panel.onClick.Add(function ()
                                    this.root:visible(false)
                                end)
                            end
                        }
                    }
                }
            }
        }
    }
})

--  ui빌드
selectWorld:build()

```