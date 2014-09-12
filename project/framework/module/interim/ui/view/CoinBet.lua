local JJViewGroup = require("sdk.ui.JJViewGroup")
local CoinBet = class("CoinBet", JJViewGroup)
local InterimUtil = require("interim.util.InterimUtil")

function CoinBet:ctor(parentView)
	CoinBet.super.ctor(self, parentView)
	self.parentView = parentView
	self.dimens_ = parentView.dimens_
	self:initView()
    self.coin = 0
end

function CoinBet:initView()

    self.coin = 0

    local chip = jj.ui.JJImage.new({
         image = "img/interim/ui/chip_blue.png",
      })
    chip:setAnchorPoint(ccp(0.5, 0.5))
    chip:setPosition(self.dimens_:getDimens(-50), 0)
    chip:setScale(self.dimens_.scale_)
    self:addView(chip)
    
    -- self.coinLabel = jj.ui.JJLabelBMFont.new({
    --      text="000",
    --      font="img/interim/ui/pool_num.fnt",
    --      textAlign = ui.TEXT_ALIGN_LEFT
    -- })
    -- self.coinLabel:setScale(self.dimens_.scale_)
    -- self.coinLabel:setAnchorPoint(ccp(0.5,0.5))
    -- self.coinLabel:setPosition(0, 0)
    -- self:addView(self.coinLabel)

    self.coinLabel = jj.ui.JJLabel.new({
        fontSize = 18*self.dimens_.scale_,
        color = ccc3(255, 252, 157),
        textAlign = ui.TEXT_ALIGN_LEFT
    })
    self.coinLabel:setScale(self.dimens_.scale_)
    self.coinLabel:setAnchorPoint(ccp(0.5,0.5))
    self.coinLabel:setPosition(0, 0)
    self:addView(self.coinLabel)
end
        
function CoinBet:setCoin(coin)
    self.coin = coin

    if coin ~= nil then
       local scoreString = InterimUtil:getStandBetChipsDisp(coin)
       self.coinLabel:setText(scoreString)
    end
   
end

function CoinBet:hide()
    self:setVisible(false)
end

return CoinBet
