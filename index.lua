


local class = require('middleclass')

-- 상수
local CONST = {
    ANCHOR = {
        TopLeft = 0,
        TopCenter = 1,
        TopRight = 2,
        MiddleLeft = 3,
        MiddleCenter = 4,
        MiddleRight = 5,
        BottomLeft = 6,
        BottomCenter = 7,
        BottomRight = 8
    }
}

local _newIndexMap = {
    ['x'] = function(self, key, newVal)
        -- self._pObj.width = self:getParentWidth() - self._ml - self._mr - newVal
        self._pObj.x = newVal + self._ml
    end,
    ['y'] = function(self, key, newVal)
        -- self._pObj.height = self:getParentHeight() - self._mb - self._mt - newVal
        self._pObj.y = newVal + self._mt
    end,
    ['width'] = function(self, key, newVal)
        self._pObj.width = newVal
    end
}

local _indexMap = {
    ['width'] = function(self, key)
        if not self._pObj then return 0 end
        return self._pObj.width
    end,
    ['height'] = function(self, key)
        if not self._pObj then return 0 end
        return self._pObj.height + self._mt + self._mb
    end,
    ['x'] = function(self, key)
        if not self._pObj then return 0 end
        return self._pObj.x
    end,
    ['y'] = function(self, key)
        if not self._pObj then return 0 end
        return self._pObj.y
    end,
}
local BaseComponent = class('Component')

function BaseComponent:initialize (option)
    if option.panel then
        self._panel = option.panel
    end
    self._option = option
    self._mt = 0
    self._ml = 0
    self._mr = 0
    self._mb = 0
    self.builded = false
end


function BaseComponent:getParentWidth()
    if not self.parent then
        return Client.width
    end
    return self.parent.width
end

function BaseComponent:getParentHeight()
    if not self.parent then
        return Client.height
    end
    return self.parent:getPanelObject().height
end


-- setter
function BaseComponent:__newindex (key, newVal, curVal)
    if (_newIndexMap[key]) then
        _newIndexMap[key](self, key, newVal, curVal)
        return
    end
    -- 기본동작
    rawset(self, key, newVal)
end

-- getter
function BaseComponent:__index (key)
    if (_indexMap[key]) then
        return _indexMap[key](self, key)
    end
    -- 기본동작
    return rawget(self, key)
end

function BaseComponent:_addChildren()
    if type(self._option.children) == 'table' and #self._option.children > 0 then
        for index, child in ipairs(self._option.children) do
            if type(child.isInstanceOf) and child:isInstanceOf(BaseComponent) then
                self:addChild(child)
            end
        end
    end
end

function BaseComponent:_makePanel()
    return self._panel()
end

function BaseComponent:build ()
    -- if self.builded then return end
    self._pObj = self:_makePanel()
    if (self._option.margin) then
        self._mt = self._option.margin.t
        self._ml = self._option.margin.l
        self._mr = self._option.margin.r
        self._mb = self._option.margin.b
    end

    self._option.rect = self._option.rect or {}
    
    if self._option.showOnTop then
        self._pObj.showOnTop = self._option.showOnTop
    end

   
    local pHeight = 1
    local pWidth = 1
    local pX = 0 
    if (self._option.pHeight) then
        pHeight = self._option.pHeight / 100
    end
    if (self._option.pWidth) then
        pWidth = self._option.pWidth / 100
    end

    if (self._option.pX) then
        pX = self:getParentWidth() * self._option.pX / 100
    end
    self._pObj.x = (self._option.rect.x or self._pObj.x + pX) + self._ml
    self._pObj.y = (self._option.rect.y or self._pObj.y) + self._mt
    self._pObj.width = (self._option.rect.width or self:getParentWidth() * pWidth) - self._ml - self._mr
    self._pObj.height = (self._option.rect.height or self:getParentHeight() * pHeight) - self._mb - self._mt
    if self._option.root then
        self.root = self
        -- listeners.onChangeWindowSize.addListener(function(width, height)
        --     self._pObj.width = width - self._mr * 2
        --     self._pObj.height = height - self._mb * 2
        -- end)
    end

    if self._option.color then
        self._pObj.color = self._option.color
    end

    self:_addChildren()


    self.builded = true

    if self._option.onAfterBuild then
        self._option.onAfterBuild(self, self._pObj)
    end
end

function BaseComponent:setParent(parent)
    self.parent = parent
end

function BaseComponent:setRoot(root)
    self.root = root
end

function BaseComponent:visible(bool)
    self._pObj.visible = bool
end

function BaseComponent:addChild(child)
    child:setParent(self)
    child:setRoot(self.root)
    child:build()
    self._pObj.AddChild(child:getPanelObject())
end

function BaseComponent:getPanelObject()
    return self._pObj
end


local UrlImageComponent = class('ImageComponent', BaseComponent)

function UrlImageComponent:_makePanel()
    if self._option.url then
       return URLImage(self._option.url)
    end
    return URLImage()
end

function UrlImageComponent:build()
    BaseComponent.build(self)
    self._pObj.image = "Icons/08.png"
end


local RowComponent  = class('RowComponent', BaseComponent)

function RowComponent:_makePanel()
    local panel = Panel()
    panel.SetOpacity(0)
    return panel
end

function RowComponent:build()
    BaseComponent.build(self)
end


local ContainerComponent = class('ContainerComponent', BaseComponent)

function ContainerComponent:_makePanel()
    local panel = Panel()
    panel.SetOpacity(0)
    return panel
end

function ContainerComponent:_addChildren()
    if type(self._option.children) == 'table' and #self._option.children > 0 then
        local y = 0
        for index, child in ipairs(self._option.children) do
            if type(child.isInstanceOf) and child:isInstanceOf(RowComponent) then
                self:addChild(child)
                child.y = y
                y = y + child.height
            else
                error('컨테이너에는 Row컴포넌트만 추가할 수 있습니다.')
            end
        end
    end
end

function ContainerComponent:build()
    BaseComponent.build(self)

end

function ContainerComponent:addChild(child)
    child:setParent(self)
    child:setRoot(self.root)
    child:build()
    self._pObj.AddChild(child:getPanelObject())
end

local ButtonComponent = class('ButtonComponent', BaseComponent)

function ButtonComponent:_makePanel()
    local panel = Button()
    return panel
end

function ButtonComponent:build()
    BaseComponent.build(self)
    self._pObj.text = self._option.text
end

local TextComponent = class('ButtonComponent', BaseComponent)

function TextComponent:_makePanel()
    local panel = Text()
    return panel
end

function TextComponent:build()
    BaseComponent.build(self)
    self._pObj.text = self._option.text
    self._pObj.textAlign = self._option.textAlign or CONST.ANCHOR.MiddleCenter
    self._pObj.textSize = self._option.textSize or 12
end

local ScrollRowPannel = class('ScrollRowPannel', BaseComponent)

function ScrollRowPannel:_makePanel()
    local panel = ScrollPanel()
    return panel
end

function ScrollRowPannel:build()
    self._sPobj = Panel()
    BaseComponent.build(self)
    self._pObj.content = self._sPobj
end

function ScrollRowPannel:addChild(child)
    child:setParent(self)
    child:setRoot(self.root)
    child:build()
    self._sPobj.AddChild(child:getPanelObject())
end


local _margin = {}

setmetatable(_margin, { __call = function (self, t, b, l, r)
    local obj = {
        t = t or 0,
        b = b or 0,
        l = l or 0,
        r = r or 0
    }
    setmetatable(obj, {__index=self})
    return obj
end})

function _margin:ma(a)
    self.t = a
    self.b = a
    self.l = a
    self.r = a
    return self
end

function _margin:my(my)
    self.t = my
    self.b = my
    return self
end

function _margin:mx(mx)
    self.l = mx
    self.r = mx
    return self
end

function _margin:mt(mt)
    self.t = mt
    return self
end

function _margin:mb(mb)
    self.b = mb
    return self
end


return {
    BaseComponent = BaseComponent,
    UrlImageComponent = UrlImageComponent,
    ContainerComponent = ContainerComponent,
    RowComponent = RowComponent,
    ButtonComponent = ButtonComponent,
    TextComponent = TextComponent,
    ScrollRowPannel = ScrollRowPannel,
    ma = function (m)
        return _margin():ma(m)
    end,
    my = function (m)
        return _margin():my(m)
    end,
    mx = function (m)
        return _margin():mx(m)
    end,
    CONST = CONST
}




