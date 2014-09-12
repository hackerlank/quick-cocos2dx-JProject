--[[
系统时间
]]

local HelperSysTime = class("HelperSysTime",require("sdk.ui.JJViewGroup"))

--local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

function HelperSysTime:ctor(parent)
    HelperSysTime.super.ctor(self, {viewSize = CCSize(110, 24)})
    self.scene_ = parent
    self.dimens_ = parent.dimens_

    self.lastMin = -1
    self:initView()
    self:updateTime()

    self.scheduleHandler_ = self:schedule(function() self:updateTime() end, 1)
end

function HelperSysTime:unSchedule()
  if self.scheduleHandler_ then
    self:unschedule(self.scheduleHandler_)
    self.scheduleHandler_ = nil
  end
end

function HelperSysTime:onExit()
    self:unSchedule()
end

function HelperSysTime:initView()

--    local numWidth, numHeight = self.dimens_:getDimens(14), self.dimens_:getDimens(19)
    local numWidth, numHeight = 14, 19

    --小时
    self.hour1 = jj.ui.JJImage.new({
        viewSize = CCSize(numWidth, numHeight),
    })
    self.hour1:setAnchorPoint(CCPoint(0, 0))
    self.hour1:setPosition(0, 0)
    self:addView(self.hour1)

    self.hour2 = jj.ui.JJImage.new({
        viewSize = CCSize(numWidth, numHeight),
    })
    self.hour2:setAnchorPoint(CCPoint(0, 0))
    self.hour2:setPosition(numWidth, 0)
    self:addView(self.hour2)

    --冒号
    self.colon = jj.ui.JJImage.new({
        viewSize = CCSize(numWidth, numHeight),
    })
    self.colon:setAnchorPoint(CCPoint(0, 0))
    self.colon:setPosition(2 * numWidth, 0)
    self:addView(self.colon)

    --分钟
    self.min1 = jj.ui.JJImage.new({
        viewSize = CCSize(numWidth, numHeight),
    })
    self.min1:setAnchorPoint(CCPoint(0, 0))
    self.min1:setPosition(3 * numWidth, 0)
    self:addView(self.min1)

    self.min2 = jj.ui.JJImage.new({
        viewSize = CCSize(numWidth, numHeight),
    })
    self.min2:setAnchorPoint(CCPoint(0, 0))
    self.min2:setPosition(4 * numWidth, 0)
    self:addView(self.min2)
end


function HelperSysTime:updateTime()
    -- if self:getParentView() == nil then
    -- return

    local date = os.date("*t",  JJTimeUtil:getCurrentServerTime() / 1000)
    local hour, min = date.hour, date.min

    if min ~= self.lastMin then
        self.lastMin = min
        local nHour1, nHour2 = math.modf(date.hour / 10), date.hour % 10
        if self.hour1 then self.hour1:setImage("img/interim/ui/infobar_time_"..nHour1..".png") end
        if self.hour2 then self.hour2:setImage("img/interim/ui/infobar_time_"..nHour2..".png") end

        if self.colon then self.colon:setImage("img/interim/ui/infobar_time_colon.png") end

        local nMin1, nMin2 = math.modf(date.min / 10), date.min % 10
        if self.min1 then self.min1:setImage("img/interim/ui/infobar_time_"..nMin1..".png") end
        if self.min2 then self.min2:setImage("img/interim/ui/infobar_time_"..nMin2..".png") end
    end
end

return HelperSysTime
