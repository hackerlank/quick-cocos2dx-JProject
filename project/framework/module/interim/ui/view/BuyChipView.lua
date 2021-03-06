local JJViewGroup = require("sdk.ui.JJViewGroup")
local BuyChipView = class("BuyChipView", JJViewGroup)
local InterimUtilDefine = require("interim.util.InterimUtilDefine")
local INTERIM_SOUND = InterimUtilDefine.INTERIM_SOUND
function BuyChipView:ctor(parentView)
	BuyChipView.super.ctor(self, parentView)
	self.parentView = parentView
	self.dimens_ = parentView.dimens_
    self.theme_ = parentView.theme_
	self:initView()
end

function BuyChipView:buyChip(coin, target)
    local gameData = GameDataContainer:getGameData(INTERIM_MATCH_ID)
    gameData.shouldShowBuyChipResult = false
    
    JJLog.i("我的筹码：" .. gameData.myCoin)
    if gameData.myCoin >= coin then    
        self.parentView:showForceMessage("玩家筹码充足，不需要补充", 2)
        if target == self.autoBuyMax then
            gameData.autoBuyChip = false
            target:setChecked(false)
            MatchMsg:sendMarkAutoAddHPReq(INTERIM_MATCH_ID, gameData.autoBuyChip )
        end
        return
    end

    local exchangerate = gameData.exchangerate
    if exchangerate == 0 then
        return
    end


    local max = UserInfo.gold_*exchangerate
    if coin > max then
        self:showNotEnoughMoney()
    else
        gameData.shouldShowBuyChipResult = true
        MatchMsg:sendAddHPReq(INTERIM_MATCH_ID, coin)
        JJLog.i("MatchMsg:sendAddHPReq :coin " .. coin)
        --self.parentView:hideBuyChipView()
    end
end

function BuyChipView:initView()

    function onButtonClicked(sender)
        if sender.name == "buyMin" then
            local gameData = GameDataContainer:getGameData(INTERIM_MATCH_ID)
            self:buyChip(gameData.minaddtohp ,sender)

        elseif sender.name == "button_2" then
            --local gameData = GameDataContainer:getGameData(INTERIM_MATCH_ID)
            --self:buyChip(gameData.maxaddtohp)

        elseif sender.name == "chart" then            
            MainController:pushScene(MainController.packageId_, JJSceneDef.ID_CHARGE_SELECT)
        end
    end

	local background = jj.ui.JJImage.new({
		 image = "img/interim/ui/pop_up_bg.png",
      })
    background:setAnchorPoint(ccp(0.5, 0.5))
    background:setPosition(0, 0)
    background:setScale(self.dimens_.scale_)
    self:addView(background)

    self:setAnchorPoint(ccp(0.5, 0.5))
    self.bgSize = CCSizeMake(background:getViewSize().width*background:getScaleX(),
     background:getViewSize().height*background:getScaleY())

    local titleBg = jj.ui.JJImage.new({
         image = "img/interim/ui/titleBg.png",
      })
    titleBg:setAnchorPoint(ccp(0.5, 0.5))
    titleBg:setPosition(-10, self.bgSize.height*0.4)
    titleBg:setScale(self.dimens_.scale_)
    self:addView(titleBg)
    
    local titleLabel = jj.ui.JJLabel.new({
    	fontSize = 30*self.dimens_.scale_,
        color = ccc3(252, 212, 97),
        text = "补充筹码",
    })
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setPosition(-10, self.bgSize.height*0.4)
    self:addView(titleLabel)

    local separatorUp = jj.ui.JJImage.new({
         image = "img/interim/ui/buychipbg.png",
      })
    separatorUp:setAnchorPoint(ccp(0.5, 0.5))
    separatorUp:setPosition(self.dimens_:getDimens(-10), self.dimens_:getDimens(85))
    separatorUp:setScale(self.dimens_.scale_)
    self:addView(separatorUp)

    local goldImage = jj.ui.JJImage.new({
         image = "img/interim/ui/deposit_gold.png",
      })
    goldImage:setAnchorPoint(ccp(0.5, 0.5))
    goldImage:setPosition(self.dimens_:getDimens(-110), self.dimens_:getDimens(85))
    goldImage:setScale(self.dimens_.scale_)
    self:addView(goldImage)
   
    self.goldLabel = jj.ui.JJLabelBMFont.new({
         text="0",
         font="img/interim/ui/deposit_num.fnt",
       -- fontSize = 30*self.dimens_.scale_,
    })
    self.goldLabel:setScale(self.dimens_.scale_)
    self.goldLabel:setAnchorPoint(ccp(0.5,0.5))
    self:addView(self.goldLabel)
    self.goldLabel:setPosition(self.dimens_:getDimens(30), self.dimens_:getDimens(85))

    local button = jj.ui.JJButton.new({
        images = {
            normal = "img/interim/ui/buychipNormal.png",
            highlight = "img/interim/ui/buychipClicked.png"
        },
    })
    button:setAnchorPoint(ccp(0.5, 0.5))
    button:setScale(self.dimens_.scale_)
    button.name = "chart"
    button:setPosition(ccp(self.dimens_:getDimens(155),
        self.dimens_:getDimens(85)))
    button:setOnClickListener(onButtonClicked)
    self:addView(button)

    -- --自动买入最小值
    -- self.autoBuyMin = jj.ui.JJCheckBox.new({
    --     images={
    --        on="img/interim/ui/button.png",
    --        off="img/interim/ui/button_f.png" 
    --     },
    --     clickSound = "sound/BackButtonSound.mp3"
    -- })
    -- self:addView(self.autoBuyMin)

    -- self.autoBuyMin:setScale(self.dimens_.scale_)
    -- self.autoBuyMin:setAnchorPoint(ccp(0.5, 0.5))
    -- self.autoBuyMin:setPosition(self.dimens_:getDimens(-215), self.dimens_:getDimens(-25))
    -- self.autoBuyMin:setId(1)
    -- self.autoBuyMin:setTouchEnable(true)
    -- self.autoBuyMin:setOnCheckedChangeListener(handler(self, self.onCheckedChangeListener))

    self.buyMinChipButton = jj.ui.JJButton.new({
        images = {
            normal = "img/interim/ui/buymin_normal.png",
            highlight = "img/interim/ui/buymin_pressed.png"
        },
        text = "自动补码至买入筹码数自动补码至买入筹码数",
        fontSize = 20,
        color = ccc3(0, 0, 0),
    })
    self.buyMinChipButton:setAnchorPoint(ccp(0.5, 0.5))
    self.buyMinChipButton:setScale(self.dimens_.scale_)
    self.buyMinChipButton.name = "buyMin"
    self.buyMinChipButton:setPosition(ccp(self.dimens_:getDimens(-6),
        self.dimens_:getDimens(0)))
    self.buyMinChipButton:setOnClickListener(onButtonClicked)
    self:addView(self.buyMinChipButton)

  --自动买入最大值 
    self.autoBuyMax = jj.ui.JJCheckBox.new({
        images={
           on="img/interim/ui/button.png",
           off="img/interim/ui/button_f.png" 
        },
        clickSound = "sound/BackButtonSound.mp3"
    })
    self:addView(self.autoBuyMax)
    self.autoBuyMax:setScale(self.dimens_.scale_)
    self.autoBuyMax:setAnchorPoint(ccp(0.5, 0.5))
    self.autoBuyMax:setPosition(self.dimens_:getDimens(-215), self.dimens_:getDimens(-115))
    self.autoBuyMax:setId(2)
    self.autoBuyMax:setTouchEnable(true)
    self.autoBuyMax:setOnCheckedChangeListener(handler(self, self.onCheckedChangeListener))
   
    self.buyMaxChipLabel = jj.ui.JJLabel.new({
         text="自动补码至买入筹码数",
         fontSize = 20,
         color = ccc3(0, 0, 0)
    })
    self.buyMaxChipLabel:setScale(self.dimens_.scale_)
    self.buyMaxChipLabel:setAnchorPoint(ccp(0.5,0.5))
    self:addView(self.buyMaxChipLabel)
    self.buyMaxChipLabel:setPosition(self.dimens_:getDimens(0), self.dimens_:getDimens(-90))


    -- self.tipLabel = jj.ui.JJLabel.new({
    --      text="选中后可再次点击取消",
    --      fontSize = 20,
    --      color = ccc3(255, 10, 10)
    -- })
    -- self.tipLabel:setScale(self.dimens_.scale_)
    -- self.tipLabel:setAnchorPoint(ccp(0.5,0.5))
    -- --self:addView(self.tipLabel)
    -- self.tipLabel:setPosition(self.dimens_:getDimens(0), self.dimens_:getDimens(-150))


    self:setTouchEnable(true)
end

function BuyChipView:showNotEnoughMoney()
    self.parentView:showNotEnoughMoney()
end

function BuyChipView:onCheckedChangeListener(target)
    local gameData = GameDataContainer:getGameData(INTERIM_MATCH_ID)
    
    gameData.autoBuyChip = target:isSelected()
    MatchMsg:sendMarkAutoAddHPReq(INTERIM_MATCH_ID, gameData.autoBuyChip )
    self:buyChip(gameData.maxaddtohp, target)
    
end

function BuyChipView:createButton(buttonText)
     local button = jj.ui.JJButton.new({
        images = {
            normal = "img/interim/ui/button.png",   
            highlight = "img/interim/ui/button_f.png",
        },
      --  fontSize = 23*self.dimens_.scale_,
        text = buttonText,
        color = ccc3(0,0,0)
    })
    button:setAnchorPoint(ccp(0.5, 0.5))
    button:setScale(self.dimens_.scale_)
    return button
end

function BuyChipView:onTouchBegan(x, y)
    if self:isTouchInside(x, y) == true and self.bTouchEnable_ then
        self:setTouchedIn(true)
        local pos = self:convertToNodeSpace(ccp(x,y))
        -- JJLog.i("x y " .. pos.x .. " " .. pos.y)
         if pos.x > 199*self.dimens_.scale_
         and pos.y > 88*self.dimens_.scale_ then
            self.parentView:hideBuyChipView()
            SoundManager:playEffect(INTERIM_SOUND.BUTTON)
        
        end
        return true
    end
    return false
end

function BuyChipView:show()
    self.goldLabel:setText(tostring(UserInfo.gold_))
    local gameData = GameDataContainer:getGameData(INTERIM_MATCH_ID)

    if gameData.minaddtohp ~= nil then
       local scoreString = InterimUtil:getStandBetChipsDisp(gameData.minaddtohp)
       self.buyMinChipButton:setText("补充到 " .. scoreString) 
    end
    
    if gameData.minaddtohp ~= nil then
       local scoreString = InterimUtil:getStandBetChipsDisp(gameData.minaddtohp)
       self.buyMaxChipLabel:setText("自动补充到 " .. scoreString) 
    end
    
    self.autoBuyMax:setChecked(gameData.autoBuyChip) 
end

return BuyChipView
