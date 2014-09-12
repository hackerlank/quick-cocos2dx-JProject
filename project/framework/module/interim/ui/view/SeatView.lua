
local JJViewGroup = require("sdk.ui.JJViewGroup")
local CardView = require("interim.ui.view.CardView")
local PlayerView = require("interim.ui.view.PlayerView")
local CardGroup = require("interim.ui.view.CardGroup")
local CoinBet = require("interim.ui.view.CoinBet")
local AnimationFactory = require("interim.util.AnimationFactory")
local EmoteFactory = require("interim.util.EmoteFactory")
local InterimUtil = require("interim.util.InterimUtil")
local SeatView = class("SeatView", JJViewGroup)

local InterimUtilDefine = require("interim.util.InterimUtilDefine")
local INTERIM_PLAYER_STATUS_EMPTY = InterimUtilDefine.INTERIM_PLAYER_STATUS_EMPTY
local INTERIM_PLAYER_STATUS_ENGAGED = InterimUtilDefine.INTERIM_PLAYER_STATUS_ENGAGED
local INTERIM_PLAYER_STATUS_STANDBY = InterimUtilDefine.INTERIM_PLAYER_STATUS_STANDBY
local INTERIM_PLAYER_STATUS_FOLD = InterimUtilDefine.INTERIM_PLAYER_STATUS_FOLD

local INTERIM_RESULT = InterimUtilDefine.INTERIM_RESULT 
local INTERIM_SOUND = InterimUtilDefine.INTERIM_SOUND
local COIN_MOVE_DURATION  = 0.4

function SeatView:ctor(parentView)
	SeatView.super.ctor(self)
	self.parentView = parentView
	self.theme_ = parentView.theme_
    self.dimens_ = parentView.dimens_
	self.positionConfig = parentView.positionConfig
	-- JJLog.i("SeatView positionConfig")
	-- JJLog.i(self.positionConfig)
	self:initView()
end

function SeatView:initView()
 	-- 布局号为0无效，需要设置布局号才会正常显示布局
 	self.layoutIndex = 0
 	self.myself = false
 	self.cardConcealed = true
 	self:setVisible(false)
 	self.seatIndex = 0
 	self.userid = 0

 	-- self.playerInfo = nil
 	self.score = 0
	self.drawCard = 0
	self.coinWon = 0
	self.coinBet = 0
	self.enResult = 0
	self.handCard = {}

	self.dealtCount = 0

 	self.playerView = PlayerView.new(self)
 	self:addView(self.playerView)

 	
 	self.cardGroup = CardGroup.new(self)
 	self:addView(self.cardGroup)
	        
	self.indexLabel = jj.ui.JJLabel.new({
    	fontSize = 20,
    	color = ccc3(255, 0, 0),
    	text = "0",
    })
    self.indexLabel:setAnchorPoint(ccp(0.5, 0.5))
    self.indexLabel:setPosition(ccp(0,0))
    self:addView(self.indexLabel)
	-- 测试标签
	self.indexLabel:setVisible(false)

	self.nameLabel = jj.ui.JJLabel.new({
    	fontSize = 20,
    	color = ccc3(255, 0, 0),
    	text = "name",
    })
    self.nameLabel:setAnchorPoint(ccp(0.5, 0.5))
    self.nameLabel:setPosition(ccp(0,-30))
    self:addView(self.nameLabel)

    self.nameLabel:setVisible(false)

    self.scoreLabel = jj.ui.JJLabel.new({
    	fontSize = 18*self.dimens_.scale_,
    	color = ccc3(255, 255, 255),
    	text = "score",
    })
    self.scoreLabel:setAnchorPoint(ccp(0.5, 0.5))
    self.scoreLabel:setPosition(ccp(0,-50))
    self:addView(self.scoreLabel)
    self.scoreLabel:setVisible(false)

    self.dealerIcon = jj.ui.JJImage.new({
        image = "img/interim/ui/dealer_icon.png",
      })
    self.dealerIcon:setAnchorPoint(ccp(0.5, 0.5))
    self.dealerIcon:setPosition(0, self.dimens_:getDimens(50))
    self:addView(self.dealerIcon)
    self.dealerIcon:setVisible(false)
   	self.dealerIcon:setScale(self.dimens_.scale_)
 
 	self.coinBetView = CoinBet.new(self)
 	self:addView(self.coinBetView)
 	self.coinBetView:setPosition(self.positionConfig.seatViewLayoutTableLeft.chip)
 	self.coinBetView:setVisible(false)

 	self.coinWonView = CoinBet.new(self)
 	self:addView(self.coinWonView)
 	self.coinWonView:setPosition(self.positionConfig.seatViewLayoutTableLeft.chip)
 	self.coinWonView:setVisible(false)

 	self.passIcon = display.newSprite("#fold_1.png")
    self.passIcon:setScale(self.dimens_.scale_*0.5)
    self:getNode():addChild(self.passIcon)
    self.passIcon:setVisible(false)

 	-- self.hitIcon = jj.ui.JJImage.new({
  --       image = "img/interim/common/in.png",
  --     })
 	-- self:addView(self.hitIcon)
 	-- self.hitIcon:setVisible(false)

 	self.missIcon = jj.ui.JJImage.new({
        image = "img/interim/animate/miss.png",
      })
 	self.missIcon:setScale(self.dimens_.scale_*0.8)
 	self:addView(self.missIcon)
 	self.missIcon:setVisible(false)

	-- self.emoteView = jj.ui.JJLabel.new({
	--   	fontSize = 45,
	--   	color = ccc3(255, 0, 255),
	--   	text = "表情",
	--   })
	--   self.emoteView:setAnchorPoint(ccp(0.5, 0.5))
	--   self.emoteView:setPosition(ccp(0,0))
	--   self:addView(self.emoteView)
	--   self.emoteView:setVisible(false)

  	self.emoteFactory = EmoteFactory.new()

    self.emoteView = display.newSprite("#emote_1_1.png")
    self.emoteView:setScale(self.dimens_.scale_)
    self:getNode():addChild(self.emoteView)
    self.emoteView:setVisible(false)
     
    self.hitIcon = display.newSprite("#hit_1.png")
    self.hitIcon:setScale(self.dimens_.scale_*0.8)
    self:getNode():addChild(self.hitIcon)
    self.hitIcon:setVisible(false)

    self.hitPillar = display.newSprite("#hit_p_1.png")
    self.hitPillar:setScale(self.dimens_.scale_*0.8)
    self:getNode():addChild(self.hitPillar)
    self.hitPillar:setVisible(false)

    self.kadang = display.newSprite("#kadang_1.png")
    self.kadang:setScale(self.dimens_.scale_*0.75)
    self:getNode():addChild(self.kadang)
    self.kadang:setVisible(false)
   -- self.kadang:setPosition(self:getKadangPos())
 	

    self.kabz = display.newSprite("#kabz_1.png")
    self.kabz:setScale(self.dimens_.scale_*0.7)
    self:getNode():addChild(self.kabz)
    self.kabz:setVisible(false)

    self.KainSametraight = display.newSprite("#BG_1.png")
    self.KainSametraight:setScale(self.dimens_.scale_*0.8)
    self:getNode():addChild(self.KainSametraight)
    self.KainSametraight:setVisible(false)

    -- local midCardPos = self.cardGroup:getCardPosition(self.)

    --前后台切换时只显示最终状态不播放动画 
    self.hitImg = display.newSprite("#hit_9.png")
    self.hitImg:setScale(self.dimens_.scale_*0.8)
    self:getNode():addChild(self.hitImg)
    self.hitImg:setVisible(false)

    self.hitPillarImg = display.newSprite("#hit_p_9.png")
    self.hitPillarImg:setScale(self.dimens_.scale_*0.8)
    self:getNode():addChild(self.hitPillarImg)
    self.hitPillarImg:setVisible(false)

    self.kadangImg = display.newSprite("#kadang_27.png")
    self.kadangImg:setScale(self.dimens_.scale_*0.75)
    self:getNode():addChild(self.kadangImg)
    self.kadangImg:setVisible(false)
 
    self.kabzImg = display.newSprite("#kabz_21.png")
    self.kabzImg:setScale(self.dimens_.scale_*0.7)
    self:getNode():addChild(self.kabzImg)
    self.kabzImg:setVisible(false)

end

function SeatView:reset()
	self.emoteView:setVisible(false)
	self.hitPillar:setVisible(false)
	self.missIcon:setVisible(false)
	self.kadang:setVisible(false)
	self.kabz:setVisible(false)
	self.KainSametraight:setVisible(false)
	
--	JJLog.i("隐藏卡飞:" .. self.seatIndex)

--前后台切换时显示的图片
    self.hitImg:setVisible(false)
    self.hitPillarImg:setVisible(false)
    self.kadangImg:setVisible(false)
    self.kabzImg:setVisible(false)
end

function SeatView:showResult( enResult )

	self.enResult = enResult

	if self.enResult == INTERIM_RESULT.Kain then
		self.hitImg:setVisible(true)
	elseif self.enResult == INTERIM_RESULT.Kain4 then
		self.hitImg:setVisible(true)
	elseif self.enResult == INTERIM_RESULT.Kain2 then
		self.hitImg:setVisible(true)
	elseif self.enResult == INTERIM_RESULT.Kain3 then
		self.hitImg:setVisible(true)
	elseif self.enResult == INTERIM_RESULT.Kainth2 then             --同花双卡
		self.hitImg:setVisible(true)
	elseif self.enResult == INTERIM_RESULT.Kainth3 then   			--同花三卡
		self.hitImg:setVisible(true)
	elseif self.enResult == INTERIM_RESULT.Kamid then               --普通卡当
		self.kadangImg:setVisible(true)
	elseif self.enResult == INTERIM_RESULT.Threesamestraight then   --同花顺卡当
		self.kadangImg:setVisible(true)
	elseif self.enResult == INTERIM_RESULT.Kapillar then
		self.hitPillarImg:setVisible(true)
	elseif self.enResult == INTERIM_RESULT.Kasame then
		self.kabzImg:setVisible(true)
	elseif self.enResult == INTERIM_RESULT.Kaout then
		self.missIcon:setVisible(true)
	end

end

function SeatView:stopCountDown()
	self.playerView:stopCountDown()
end 

function SeatView:alertStopAnimation()
	self.playerView:alertStopAnimation()
end

function SeatView:showBreakNetState(state)
    self.playerView:showBreakNetState(state)
end

function SeatView:hideCards()
	self.cardGroup:hideCards()
	self.coinBetView:stopAllActions()
	self.coinBetView:setVisible(false)

	--self.passIcon:stopAllActions()
	self.passIcon:setVisible(false)
	JJLog.i("隐藏弃牌hideCards")

	self.hitIcon:stopAllActions()
	self.hitIcon:setVisible(false)

	self.hitPillar:stopAllActions()
	self.hitPillar:setVisible(false)

	self.kadang:stopAllActions()
	self.kadang:setVisible(false)

	self.kabz:stopAllActions()
	self.kabz:setVisible(false)

	self.KainSametraight:stopAllActions()
	self.KainSametraight:setVisible(false)

	self.missIcon:stopAllActions()
	self.missIcon:setVisible(false)
--	JJLog.i("隐藏卡飞:" .. self.seatIndex)

--前后台切换时显示的图片
    self.hitImg:setVisible(false)
    self.hitPillarImg:setVisible(false)
    self.kadangImg:setVisible(false)
    self.kabzImg:setVisible(false)
end

function SeatView:setDealer(var)
	if var == true then
		self.dealerIcon:setVisible(true)
		self:refreshDealer()
	else
		self.dealerIcon:setVisible(false)
		self:refreshDealer()
	end
end

function SeatView:setPlayerInfo(playerInfo)
	local gameData = GameDataContainer:getGameData(INTERIM_MATCH_ID)
	if playerInfo == nil then
		if gameData.property.isTourny == true  then
			self.playerView:setVisible(false)           --比赛桌不显示空位
			print("gameData.property.isTourny == true **1 *** SeatView:setPlayerInfo")
		else
			self.playerView:setVisible(true)             --自由桌显示空位
			print("gameData.property.isTourny == false **1*** SeatView:setPlayerInfo")
		end
		return
	end

	self.userid = playerInfo.tkInfo.userid

	if self.userid ~= 0 then
		self.score = playerInfo.tkInfo.score
		self.scoreLabel:setVisible(true)
		self.nameLabel:setText(playerInfo.tkInfo.nickname)	
		--self.nameLabel:setVisible(true)
		self.playerView:setVisible(true) 
		self.playerView:setPlayerData(playerInfo)

		print("*************playerView:setPlayerData************")
	else
		self.score = 0
		self.scoreLabel:setVisible(false)
		self.nameLabel:setText("")
		--self.nameLabel:setVisible(false)
		if gameData.property.isTourny == true  then
			self.playerView:setVisible(false)           --比赛桌不显示空位
			print("gameData.property.isTourny == true **2 *** SeatView:setPlayerInfo")
		else
			self.playerView:setVisible(true)             --自由桌显示空位
			print("gameData.property.isTourny == false **2*** SeatView:setPlayerInfo")
		end
		
		self.playerView:setPlayerData(nil)
		self:hideCards()
		self.dealerIcon:setVisible(false)
		self.cardGroup:setTipe("")
	end
	self:refreshScore()

	if self.userid == UserInfo.userId_ then
		self:setMyself(true)
	else
		self:setMyself(false)
	end

	self.showingPassIcon = true
end

function SeatView:setLayoutIndex(layoutIndex)
	self.layoutIndex = layoutIndex
	if layoutIndex == 0 then
		self:setVisible(false)
		return
	end
	
	self:setVisible(true)
	self:setPosition(self.positionConfig.seatPositionTable[self.layoutIndex])
	self:refreshLayout()

	self.emoteView:setPosition(self:getEmotePos())
	local posx, posy = self:getResultIconPos()
	self.hitPillar:setPosition(posx, posy)
	self.missIcon:setPosition(posx, posy)
	self.kadang:setPosition(self:getKadangPos())
	self.kabz:setPosition(posx, posy)
	
	posy = posy + self.dimens_:getDimens(12)
	self.hitIcon:setPosition(posx, posy)

	self.coinWonView:setPosition(self:getCoinBetPos())

end
	
function SeatView:moveToNewIndex(layoutIndex)
	if self.layoutIndex == layoutIndex then
		return
	elseif math.abs(self.layoutIndex - layoutIndex) == 1
		or math.abs(self.layoutIndex - layoutIndex) == 4 then
		
		self.layoutIndex = layoutIndex
		local targetPos = self:getSeatPosByIndex(layoutIndex)
		local array = CCArray:create()
	    array:addObject(CCMoveTo:create(0.3, targetPos))
	    array:addObject(CCCallFunc:create(handler(self, self.moveFinshed)))
	    local seq = CCSequence:create(array)
		self:runAction(seq)
	else
		local pointArray = CCPointArray:create(3)
		local pos = self:getSeatPosByIndex(self.layoutIndex)
		pointArray:add(pos)
		-- 逆时针2格 1->3, 2->4, 3->5
		if layoutIndex - self.layoutIndex == 2 then
			local pos = self:getSeatPosByIndex(self.layoutIndex + 1)
			pointArray:add(pos)
			pos = self:getSeatPosByIndex(layoutIndex)
			pointArray:add(pos)
		-- 逆时针2格 4->1, 5->2
		elseif self.layoutIndex - layoutIndex == 3 then
			local tempIndex = self.layoutIndex
			
			tempIndex = self:getNextIndex(tempIndex)
			local pos = self:getSeatPosByIndex(tempIndex)
			pointArray:add(pos)
			
			tempIndex = self:getNextIndex(tempIndex)
			pos = self:getSeatPosByIndex(layoutIndex)
			pointArray:add(pos)
		-- 顺时针2格 1->4, 2->5
		elseif layoutIndex - self.layoutIndex == 3  then
			local tempIndex = self.layoutIndex
			
			tempIndex = self:getPrevIndex(tempIndex)
			local pos = self:getSeatPosByIndex(tempIndex)
			pointArray:add(pos)
			
			tempIndex = self:getPrevIndex(tempIndex)
			pos = self:getSeatPosByIndex(layoutIndex)
			pointArray:add(pos)
		-- 顺时针2格 3->1, 4->2, 5->3
		elseif self.layoutIndex - layoutIndex == 2  then
			local tempIndex = self.layoutIndex
			
			tempIndex = self:getPrevIndex(tempIndex)
			local pos = self:getSeatPosByIndex(tempIndex)
			pointArray:add(pos)
			
			tempIndex = self:getPrevIndex(tempIndex)
			pos = self:getSeatPosByIndex(layoutIndex)
			pointArray:add(pos)		
		end

		local action = CCCardinalSplineTo:create(1.0, pointArray, 0)
		local array = CCArray:create()
	    array:addObject(action)
	   	array:addObject(CCCallFunc:create(handler(self, self.moveFinshed)))
	    local seq = CCSequence:create(array)
		self.layoutIndex = layoutIndex
		self:runAction(seq)
	end
end

function SeatView:moveFinshed()
	-- JJLog.i("moveFinshed")
	-- self:setSeatIndex(self.layoutIndex)
end

function SeatView:setSeatIndex(seatIndex)
	if seatIndex <= 0 or seatIndex > 5 then
		return
	end
	self.seatIndex = seatIndex
	local text = self.seatIndex .. ""
	self.indexLabel:setText(text)
end

function SeatView:getSeatPosByIndex(layoutIndex)
	local pos = self.positionConfig.seatPositionTable[layoutIndex]
	return pos
end

function SeatView:getNextIndex(index)
	index = index + 1
	if index > 5 then
		index = 1
	end
	return index
end

function SeatView:getPrevIndex(index)
	index = index - 1
	if index < 1 then
		index = 5
	end
	return index
end

function SeatView:refreshDealer()
	if self.layoutIndex == 1 then
		local pos = self.positionConfig.seatViewLayoutTableLeft.dealer
		self.dealerIcon:setPosition(pos)
	elseif self.layoutIndex == 2 or self.layoutIndex == 3 then
		local pos = self.positionConfig.seatViewLayoutTableRight.dealer
		self.dealerIcon:setPosition(pos)
	elseif self.layoutIndex == 4 or self.layoutIndex == 5 then
		local pos = self.positionConfig.seatViewLayoutTableLeft.dealer
		self.dealerIcon:setPosition(pos)
	end
end

function SeatView:refreshScore()
	-- local playerInfo = self
	local gameData = GameDataContainer:getGameData(INTERIM_MATCH_ID)
	local playerInfo = gameData:getPlayerInfoBySeatIndex(self.seatIndex)
	if playerInfo.tkInfo.userid == UserInfo.userId_ then
		JJLog.i("显示玩家积分:" .. tostring(self.score) .. " my coin : " .. gameData.myCoin)
	end

	--local scoreString = string.format("%d", self.score) --string.formatNumberThousands(self.score)
	--local scoreString = tostring(self.score)
	--scoreString = string.gsub(scoreString, ",", string.rep(" ", 1))
	local scoreString = InterimUtil:getStandBetChipsDisp(self.score)
	self.scoreLabel:setText(scoreString)
end

function SeatView:refreshLayout()

	-- self.emoteView:setPosition(self:getEmotePos())
	-- local resultPos = self:getResultIconPos()
	-- self.hitPillar:setPosition(resultPos)
	-- self.missIcon:setPosition(resultPos)
	-- self.kadang:setPosition(self:getKadangPos())
	-- self.kabz:setPosition(resultPos)

	if self.layoutIndex == 1 then
		local pos = self.positionConfig.seatViewLayoutTableLeft.playerView
		self.playerView:setPosition(pos)
		self.coinBetView:setPosition(self.positionConfig.chipTop)
		self.scoreLabel:setPosition(self.positionConfig.seatViewLayoutTableLeft.playerScore)

	elseif self.layoutIndex == 2 or self.layoutIndex == 3 then
		local pos = self.positionConfig.seatViewLayoutTableRight.playerView
		self.playerView:setPosition(pos)
		self.coinBetView:setPosition(self.positionConfig.seatViewLayoutTableRight.chip)
		self.scoreLabel:setPosition(self.positionConfig.seatViewLayoutTableRight.playerScore)
	
	elseif self.layoutIndex == 4 or self.layoutIndex == 5 then
		local pos = self.positionConfig.seatViewLayoutTableLeft.playerView
		self.coinBetView:setPosition(self.positionConfig.seatViewLayoutTableLeft.chip)
		self.playerView:setPosition(pos)
		self.scoreLabel:setPosition(self.positionConfig.seatViewLayoutTableLeft.playerScore)
	
	end

	self:refreshDealer()
	self.cardGroup.layoutIndex = self.layoutIndex
	self.cardGroup:refreshLayout()
end

function SeatView:resetCoinBetPos()
	if self.layoutIndex == 1 then
		self.coinBetView:setPosition(self.positionConfig.chipTop)
	elseif self.layoutIndex == 2 or self.layoutIndex == 3 then
		self.coinBetView:setPosition(self.positionConfig.seatViewLayoutTableRight.chip)
	elseif self.layoutIndex == 4 or self.layoutIndex == 5 then
		self.coinBetView:setPosition(self.positionConfig.seatViewLayoutTableLeft.chip)
	end
end

function SeatView:getCoinBetPos()
	if self.layoutIndex == 1 then
		return self.positionConfig.chipTop
	elseif self.layoutIndex == 2 or self.layoutIndex == 3 then
		return self.positionConfig.seatViewLayoutTableRight.chip
	elseif self.layoutIndex == 4 or self.layoutIndex == 5 then
		return self.positionConfig.seatViewLayoutTableLeft.chip
	end
	return ccp(0,0)
end

function SeatView:resetCard()
	self.dealtCount = 0

	self.cardGroup:resetCard()

	local gameData = GameDataContainer:getGameData(INTERIM_MATCH_ID)
	local playerInfo = gameData:getPlayerInfoBySeatIndex(self.seatIndex)
	-- playerInfo.cardLeft = nil
	-- playerInfo.cardRight = nil
	-- playerInfo.cardMiddle = nil
end

function SeatView:setCalling(countDown)
	self.playerView:setCalling(countDown)
end

function SeatView:setNormal()
	self.playerView:setNormal()
end

function SeatView:dealCard(cardID)
	self.dealtCount = self.dealtCount + 1
	self:hideIcons()
	self.cardGroup:dealCard(cardID)
end

function SeatView:showFoldCard()
	local gameData = GameDataContainer:getGameData(INTERIM_MATCH_ID)
	local playerInfo = gameData:getPlayerInfoBySeatIndex(self.seatIndex)
	if playerInfo.status == INTERIM_PLAYER_STATUS_STANDBY then 
		return
	end

	if self.passIcon:isVisible() then
		return
	end

	
	if self.myself == true then
		local pos = self.cardGroup:getMiddlePosition()
		pos = ccp(pos.x + self.cardGroup:getPositionX(), pos.y + self.cardGroup:getPositionY())
		self.passIcon:setPosition(pos)


	else
		local pos = self.cardGroup:getPassPosition()
		pos = ccp(pos.x + self.cardGroup:getPositionX(), pos.y + self.cardGroup:getPositionY())
		self.passIcon:setPosition(pos)

	end

	
	SoundManager:playEffect(INTERIM_SOUND.PASS)

	local function onComplete()
		self.showingPassIcon = false
    end
    if self.passIcon:isVisible() == false then
    	if self.myself == true then
			JJLog.i("播放弃牌")
    	end
    	local animation = AnimationFactory:createFold()
        self.passIcon:stopAllActions()
  		local frame = display.newSpriteFrame("fold_1.png")
    	self.passIcon:setDisplayFrame(frame)
  		self.passIcon:playAnimationOnce(animation, false, onComplete)
  		self.passIcon:setVisible(true)
	   	
	end
	
end

function SeatView:getResultIconPos()
	local pos = self.cardGroup:getMiddlePosition()
	return pos.x + self.cardGroup:getPositionX(), pos.y + self.cardGroup:getPositionY() + self.dimens_:getDimens(-20)
end

function SeatView:getKadangPos()
	local pos = self.cardGroup:getMiddlePosition()
	return pos.x + self.cardGroup:getPositionX(), pos.y + self.cardGroup:getPositionY() + self.dimens_:getDimens(-5)
end

function SeatView:showHit()
	SoundManager:playEffect(INTERIM_SOUND.KAIN)

	self.hitIcon:setVisible(true)
	local posx, posy = self:getResultIconPos()
	posy = posy + self.dimens_:getDimens(12)
	self.hitIcon:setPosition(posx, posy)

	local function onComplete()
     --   JJLog.i("play animation finished")
	end

    local animation = AnimationFactory:createHit()
  
    self.hitIcon:playAnimationOnce(animation, false, onComplete)
end

function SeatView:showMiss()
	SoundManager:playEffect(INTERIM_SOUND.KAOUT)
	JJLog.i("显示卡飞:" .. self.seatIndex)
	self.missIcon:setVisible(true)
	self.missIcon:setPosition(self:getResultIconPos())

end

function SeatView:showHitPillar()
	SoundManager:playEffect(INTERIM_SOUND.KAPILLAR)
	self.hitPillar:setVisible(true)

    local animation = AnimationFactory:createHitPillar()
  
    self.hitPillar:playAnimationOnce(animation, false, nil)
    self.hitPillar:setPosition(self:getResultIconPos())

end

function SeatView:showKadang()
	SoundManager:playEffect(INTERIM_SOUND.KAIN)
	self.kadang:setVisible(true)
    local animation = AnimationFactory:createKadang()
  
    self.kadang:playAnimationOnce(animation, false, nil)
    self.kadang:setPosition(self:getKadangPos())
end

function SeatView:showKabz()
	SoundManager:playEffect(INTERIM_SOUND.KASAME)
	self.kabz:setVisible(true)
    local animation = AnimationFactory:createKabz()
  
    self.kabz:playAnimationOnce(animation, false, nil)
    self.kabz:setPosition(self:getResultIconPos())
end

function SeatView:showKainSametraight()
	SoundManager:playEffect(INTERIM_SOUND.KASAME)
	self.KainSametraight:setVisible(true)
    local animation = AnimationFactory:createKainSametraight()
  
    self.KainSametraight:playAnimationOnce(animation, false, nil)
    self.KainSametraight:setPosition(self:getResultIconPos())
end


function SeatView:hideFoldCard()
	self.passIcon:setVisible(false)
	JJLog.i("隐藏弃牌hideFoldCard")
end

function SeatView:hideIcons()
	self.coinBetView:stopAllActions()
	self.coinBetView:setVisible(false)

	--self.passIcon:stopAllActions()
	self.passIcon:setVisible(false)
	JJLog.i("隐藏弃牌hideIcons")

	self.hitIcon:stopAllActions()
	self.hitIcon:setVisible(false)

	self.hitPillar:stopAllActions()
	self.hitPillar:setVisible(false)

	self.kadang:stopAllActions()
	self.kadang:setVisible(false)

	self.kabz:stopAllActions()
	self.kabz:setVisible(false)

	self.KainSametraight:stopAllActions()
	self.KainSametraight:setVisible(false)

	self.missIcon:stopAllActions()
	self.missIcon:setVisible(false)
end

function SeatView:cancelCoinData()
	self:stopAllActions()

	self.coinBetView:stopAllActions()
	self.coinBetView:setVisible(false)

	self.coinWonView:stopAllActions()
	self.coinWonView:setVisible(false)

	self.cardGroup:stopAllActions()
	self.cardGroup.middleCard:stopAllActions()
	self.cardGroup.cards[1]:stopAllActions()
	self.cardGroup.cards[2]:stopAllActions()
	--local pos = self.cardGroup:getCardPosition(self.cardGroup.layoutIndex, "middle")
	--self.cardGroup.middleCard:setPosition(pos)
	--self.cardGroup:hideCards()

	self.coinBet = 0
end

function SeatView:playCoinData(data)
	local gameData = GameDataContainer:getGameData(INTERIM_MATCH_ID)
	local playerInfo = gameData:getPlayerInfoBySeatIndex(self.seatIndex)

	self:hideIcons()

	JJLog.i("开始播放叫牌")
	self.enResult = data.enResult
	self.drawCard = data.drawCard
	self.handCard[1] = data.abyCard[1]
	self.handCard[2] = data.abyCard[2]
	self.coinWon = data.coinWin
	self.coinBet = data.coin

	local point1 = self.handCard[1]%13
	if point1 == 0 then
		point1 = 13
	end

	local point2 = self.handCard[2]%13
	if point2 == 0 then
		point2 = 13
	end

	if point1 > point2 then
		self.handCard[1], self.handCard[2] = self.handCard[2], self.handCard[1]
	end

	self.cardGroup.cards[1]:setCardID(self.handCard[1])
	self.cardGroup.cards[2]:setCardID(self.handCard[2])

	self:callBet(self.coinBet)
	
end

function SeatView:playCoinDataInstant(data)
	local gameData = GameDataContainer:getGameData(INTERIM_MATCH_ID)
	local playerInfo = gameData:getPlayerInfoBySeatIndex(self.seatIndex)

	JJLog.i("直接显示叫牌结果")
	self.enResult = data.enResult
	self.drawCard = data.drawCard
	self.handCard[1] = data.abyCard[1]
	self.handCard[2] = data.abyCard[2]
	self.coinWon = data.coinWin
	self.coinBet = data.coin

	local point1 = self.handCard[1]%13
	if point1 == 0 then
		point1 = 13
	end

	local point2 = self.handCard[2]%13
	if point2 == 0 then
		point2 = 13
	end

	if point1 > point2 then
		self.handCard[1], self.handCard[2] = self.handCard[2], self.handCard[1]
	end

	self.cardGroup.cards[1]:setCardID(self.handCard[1])
	self.cardGroup.cards[2]:setCardID(self.handCard[2])

	self.coinBetView:setVisible(false)

	self:showHandCard()
	self.cardGroup:dealMiddleCardInstant(self.drawCard)
	
	if self.enResult == INTERIM_RESULT.Kain then
		self:showHit()
	elseif self.enResult == INTERIM_RESULT.Kain4 then
		self:showHit()
	elseif self.enResult == INTERIM_RESULT.Kain2 then
		self:showHit()
	elseif self.enResult == INTERIM_RESULT.Kain3 then
		self:showHit()
	elseif self.enResult == INTERIM_RESULT.Kainth2 then             --同花双卡
		self:showKainSametraight()
	elseif self.enResult == INTERIM_RESULT.Kainth3 then   			--同花三卡
		self:showKainSametraight()
	elseif self.enResult == INTERIM_RESULT.Kamid then               --普通卡当
		self:showKadang()
	elseif self.enResult == INTERIM_RESULT.Threesamestraight then   --同花顺卡当
		self:showKainSametraight()
	elseif self.enResult == INTERIM_RESULT.Kapillar then
		self:showHitPillar()
	elseif self.enResult == INTERIM_RESULT.Kasame then
		self:showKabz()
	elseif self.enResult == INTERIM_RESULT.Kaout then
		self:showMiss()
	end
	
	local gameData = GameDataContainer:getGameData(INTERIM_MATCH_ID)
	local playerInfo = gameData:getPlayerInfoBySeatIndex(self.seatIndex)
	playerInfo.tkInfo.score = playerInfo.tkInfo.score - self.coinBet + self.coinWon
	self.score = playerInfo.tkInfo.score
	if playerInfo.userid == UserInfo.userId_ then
		gameData.myCoin = playerInfo.tkInfo.score
	end
	self:refreshScore()
end

function SeatView:bottomBet(coinBet)
	self:resetCoinBetPos()
	self.coinBetView:setVisible(true)
	self.coinBetView:setCoin(coin)

	self.score = self.score - coinBet
	local gameData = GameDataContainer:getGameData(INTERIM_MATCH_ID)
	local playerInfo = gameData:getPlayerInfoBySeatIndex(self.seatIndex)
	playerInfo.tkInfo.score = self.score
	if playerInfo.tkInfo.userid == UserInfo.userId_ then
		gameData.myCoin = playerInfo.tkInfo.score
	end

	self:refreshScore()

	if gameData.enteringScene == false then
		local targetPos = self.positionConfig.chipPool
		targetPos = self:convertToNodeSpace(targetPos)
		local array = CCArray:create()
		local moveTo = CCMoveTo:create(0.2, targetPos)
		local easeAction = CCEaseSineOut:create(moveTo)
	    array:addObject(easeAction)
	    array:addObject(CCCallFunc:create(handler(self, self.bottomBetFinished)))
	    local seq = CCSequence:create(array)
	    self.coinBetView:stopAllActions()
		self.coinBetView:runAction(seq)
	else
		self.coinBetView:setVisible(false)
	
	end
end

function SeatView:bottomBetFinished()
	self.coinBetView:setVisible(false)
end

function SeatView:callBet(coin)

	self:resetCoinBetPos()
	self.coinBetView:setVisible(true)
	self.coinBetView:setCoin(coin)

	self.score = self.score - coin
	local gameData = GameDataContainer:getGameData(INTERIM_MATCH_ID)
	local playerInfo = gameData:getPlayerInfoBySeatIndex(self.seatIndex)
	playerInfo.tkInfo.score = self.score
	if playerInfo.userid == UserInfo.userId_ then
		gameData.myCoin = playerInfo.tkInfo.score
	end
	self:refreshScore()

	JJLog.i("播放下注，显示手牌")
	self:showHandCard()
	self:dealMiddleCard(self.drawCard)

	-- local targetPos = self.positionConfig.chipPool
	-- targetPos = self:convertToNodeSpace(targetPos)
	-- local array = CCArray:create()
	-- local moveTo = CCMoveTo:create(0.3, targetPos)
	-- local easeAction = CCEaseSineOut:create(moveTo)
 --    array:addObject(easeAction)
 --    array:addObject(CCCallFunc:create(handler(self, self.callBetFinished)))
 --    local seq = CCSequence:create(array)
 --    self.coinBetView:stopAllActions()
	-- self.coinBetView:runAction(seq)
end

function SeatView:showHandCard()
	self.cardGroup:showHandCard()
end

-- function SeatView:callBetFinished()
-- 	self.coinBetView:setVisible(false)
-- 	self.parentView:callBetFinished()
-- 	self:dealMiddleCard(self.drawCard)
-- end

function SeatView:dealMiddleCard(cardID)
	self.cardGroup:dealMiddleCard(cardID)
end

function SeatView:dealMiddleCardFinished()

	-- self.parentView:dealMiddleCardFinished(self)

	if self.enResult == INTERIM_RESULT.Kain then
		self:showHit()
	elseif self.enResult == INTERIM_RESULT.Kain4 then
		self:showHit()
	elseif self.enResult == INTERIM_RESULT.Kain2 then
		self:showHit()
	elseif self.enResult == INTERIM_RESULT.Kain3 then
		self:showHit()
	elseif self.enResult == INTERIM_RESULT.Kainth2 then             --同花双卡
		self:showKainSametraight()
	elseif self.enResult == INTERIM_RESULT.Kainth3 then   			--同花三卡
		self:showKainSametraight()
	elseif self.enResult == INTERIM_RESULT.Kamid then               --普通卡当
		self:showKadang()
	elseif self.enResult == INTERIM_RESULT.Threesamestraight then   --同花顺卡当
		self:showKainSametraight()
	elseif self.enResult == INTERIM_RESULT.Kapillar then
		self:showHitPillar()
	elseif self.enResult == INTERIM_RESULT.Kasame then
		self:showKabz()
	elseif self.enResult == INTERIM_RESULT.Kaout then
		self:showMiss()
	end

	if self.coinWon > 0 then
		self:gainCoin()
	else
		self:loseCoin()
	end
	self.parentView:seatPlayCardFinished(self)
end

function SeatView:loseCoin()
	local targetPos = self.positionConfig.chipPool
	targetPos = self:convertToNodeSpace(targetPos)
	local array = CCArray:create()
	local moveTo = CCMoveTo:create(COIN_MOVE_DURATION, targetPos)
	local easeAction = CCEaseSineOut:create(moveTo)
    array:addObject(easeAction)
    array:addObject(CCCallFunc:create(handler(self, self.loseCoinFinished)))
    local seq = CCSequence:create(array)
    self.coinBetView:stopAllActions()
	self.coinBetView:runAction(seq)
end

function SeatView:loseCoinFinished()
	self.parentView:playerLoseCoin(self.coinBet)

	self.coinBetView:stopAllActions()
	self.coinBetView:setVisible(false)

	self.parentView:seatPlayCardFinished(self)
end

function SeatView:gainCoin()
	self.parentView:playerGainCoin(self.coinBet, self.coinWon)

	self.coinWonView:setVisible(true)
	self.coinWonView:setCoin(self.coinWon)
	local startPos = self.positionConfig.chipPool
	startPos = self:convertToNodeSpace(startPos)
	self.coinWonView:setPosition(startPos)

	local targetPos = self:getCoinBetPos()
	local array = CCArray:create()
	local moveTo = CCMoveTo:create(COIN_MOVE_DURATION, targetPos)
	local easeAction = CCEaseSineOut:create(moveTo)
    array:addObject(easeAction)
    array:addObject(CCCallFunc:create(handler(self, self.gainCoinFinished)))
    local seq = CCSequence:create(array)
    self.coinWonView:stopAllActions()
	self.coinWonView:runAction(seq)
end

function SeatView:gainCoinFinished()
	self.coinWonView:setVisible(false)

	self.score = self.score + self.coinWon

	local gameData = GameDataContainer:getGameData(INTERIM_MATCH_ID)
	local playerInfo = gameData:getPlayerInfoBySeatIndex(self.seatIndex)
	playerInfo.tkInfo.score = self.score
	if playerInfo.userid == UserInfo.userId_ then
		gameData.myCoin = playerInfo.tkInfo.score
	end
	self:refreshScore()
	-- local newCoin = self.coinBetView.coin + self.coinWonView.coin
	-- JJLog.i("newcoin")
	-- JJLog.i(newCoin)
	self.coinBetView:setCoin(self.coinWon)
	local array = CCArray:create()
	local delay = CCDelayTime:create(2.0)
    array:addObject(delay)
    array:addObject(CCCallFunc:create(handler(self, self.hideGainCoin)))
    local seq = CCSequence:create(array)
    self.coinBetView:stopAllActions()
	self.coinBetView:runAction(seq)
	
	self.parentView:seatPlayCardFinished(self)
end

function SeatView:hideGainCoin()
	self.coinBetView:setVisible(false)
end

function SeatView:handCardFull()
	if self.cardGroup.cards[1]:isVisible() == true
		and self.cardGroup.cards[2]:isVisible() == true then
		return true
	end
	return false
end

function SeatView:setMyself(var)
	self.myself = var
	self.cardGroup:setMyself(var)
end

function SeatView:setCardConcealed(var)
	self.cardConcealed = var
	self.cardGroup:setCardConcealed(var)
end

function SeatView:onPlayerClicked()
	self.parentView:onPlayerClicked(self)
end

function SeatView:getCards()
	return self.cardGroup.cards[1], self.cardGroup.cards[2]
end

function SeatView:getCardBalance()
	local point1 = self.cardGroup.cards[1].cardID%13
	if point1 == 0 then
		point1 = 13
	end
    
    local point2 = self.cardGroup.cards[2].cardID%13
	if point2 == 0 then
		point2 = 13
	end

	local balance = point1 - point2
	if balance < 0 then
		balance = balance*(-1)
	end
	return balance
end

function SeatView:showCardTip()
	if self.myself == false then
		return
	end

	local gameData = GameDataContainer:getGameData(INTERIM_MATCH_ID)
	local playerInfo = gameData:getMyPlayerInfo()
	if playerInfo.status == INTERIM_PLAYER_STATUS_STANDBY then
		return
	end

	local balance = self:getCardBalance()

	if balance == 0 then
		self.cardGroup:setTipe("X25")
	elseif balance == 1 then
		-- self.parentView.parentScene:autoFold()
		-- self:showFoldCard()
	elseif balance == 2 then
		self.cardGroup:setTipe("X12")
	elseif balance == 3 then
		self.cardGroup:setTipe("X6")
	elseif balance == 4 then
		self.cardGroup:setTipe("X4")
	elseif balance == 5 then
		self.cardGroup:setTipe("X3")
	elseif balance >5 then
		self.cardGroup:setTipe("X1")
	end
end

function SeatView:onPortraitClicked(view)
	-- self.parentView:showPlayerInfo(self.seatIndex)
	local gameData = GameDataContainer:getGameData(INTERIM_MATCH_ID)

	if gameData.property.isTourny == true then
		local playerInfo = gameData:getPlayerInfoBySeatIndex(self.seatIndex)
		--发送下面的请求后可以显示玩家信息，
		HttpMsg:sendGetRankInMatchReq(JJGameDefine.GAME_ID_INTERIM, playerInfo.tkInfo.userid)  
		JJLog.i("发送玩家信息请求， id ***********1： ", playerInfo.tkInfo.userid)
	else
		JJLog.i("显示玩家信息*******************2")
		local playerInfo = gameData:getPlayerInfoBySeatIndex(self.seatIndex)
		self.parentView:showPlayerInfo(self.seatIndex, self.layoutIndex)
	end
end

function SeatView:getEmotePos()
	local playerPos = ccp(self.playerView:getPositionX(), self.playerView:getPositionY())
	local emotePos = nil
	local xSpace = self.dimens_:getDimens(40)
	if self.layoutIndex == 1 or self.layoutIndex == 4 or self.layoutIndex == 5 then
		emotePos = ccp(playerPos.x + xSpace, 
					playerPos.y - self.dimens_:getDimens(30))
	else
		emotePos = ccp(playerPos.x - xSpace, 
					playerPos.y - self.dimens_:getDimens(30))
	end

	return emotePos
end

function SeatView:showEmote(emoteID)
	JJLog.i("播放表情 " .. emoteID)
	self.emoteView:setVisible(true)
	local emotePos = self:getEmotePos()
	self.emoteView:setPosition(emotePos)
	-- self.emoteView:setText("表情" .. emoteID)
	local animation = EmoteFactory:createEmoteByID(emoteID)
	if animation == nil then
		--JJLog.i("animation is null for emote: " .. emoteID)
	end
	self.emoteView:stopAllActions()
	self.emoteView:setVisible(true)
	self.emoteView:playAnimationOnce(animation, false, nil)

	local array = CCArray:create()
    array:addObject(CCDelayTime:create(2))
    array:addObject(CCCallFunc:create(handler(self, self.hideEmote)))
    local seq = CCSequence:create(array)
    self.emoteView:runAction(seq) 
end

function SeatView:hideEmote()
	self.emoteView:setVisible(false)
end

function SeatView:countDownExpire()
	if self.myself == true then
		self.parentView:countDownExpire()
	end
end

function SeatView:playGainCoin(coin)
	self.coinWon = coin

	self.coinWonView:setVisible(true)
	self.coinWonView:setCoin(coin)
	local startPos = self.positionConfig.chipPool
	startPos = self:convertToNodeSpace(startPos)
	self.coinWonView:setPosition(startPos)

	local targetPos = self:getCoinBetPos()
	local array = CCArray:create()
	local moveTo = CCMoveTo:create(1, targetPos)
	local easeAction = CCEaseSineOut:create(moveTo)
    array:addObject(easeAction)
    array:addObject(CCDelayTime:create(2))
    array:addObject(CCCallFunc:create(handler(self, self.hideCoinWon)))
    local seq = CCSequence:create(array)
    self.coinWonView:stopAllActions()
	self.coinWonView:runAction(seq)
end

function SeatView:hideCoinWon()
	self.coinWonView:setVisible(false)

	self.score = self.score + self.coinWon
	local gameData = GameDataContainer:getGameData(INTERIM_MATCH_ID)
	local playerInfo = gameData:getPlayerInfoBySeatIndex(self.seatIndex)
	playerInfo.tkInfo.score = self.score
	if playerInfo.userid == UserInfo.userId_ then
		gameData.myCoin = playerInfo.tkInfo.score
	end
end

function SeatView:refreshCardCache()

	local gameData = GameDataContainer:getGameData(INTERIM_MATCH_ID)
	local playerInfo = gameData:getPlayerInfoBySeatIndex(self.seatIndex)

	if playerInfo.tkInfo.userid == 0 then 
		return
	end

	print("刷新牌数据refreshCardCache at index : " .. self.seatIndex)
	print(playerInfo.cardLeft)
	print(playerInfo.cardRight)
	print(playerInfo.cardMiddle)

	if playerInfo.cardLeft ~= nil then
		self.cardGroup.cards[1]:setVisible(true)
		self.cardGroup.cards[1]:setCardID(playerInfo.cardLeft)
		if playerInfo.cardLeft == 0 then
			self.cardGroup.cards[1]:concealed()
		else
			self.cardGroup.cards[1]:expose()
		end
	end

	if playerInfo.cardRight ~= nil then
		self.cardGroup.cards[2]:setVisible(true)
		self.cardGroup.cards[2]:setCardID(playerInfo.cardRight)
		if playerInfo.cardRight == 0 then
			self.cardGroup.cards[2]:concealed()
		else
			self.cardGroup.cards[2]:expose()
		end
	end

	if playerInfo.cardMiddle ~= nil then
		print("刷新牌数据，显示中间牌")
		print("playerInfo.cardMiddle: " .. playerInfo.cardMiddle)
		self.cardGroup.middleCard:setVisible(true)
		self.cardGroup.middleCard:setCardID(playerInfo.cardMiddle)
		if playerInfo.cardMiddle == 0 then
			self.cardGroup.middleCard:concealed()
		else
			self.cardGroup.middleCard:expose()
		end

	else
		print("刷新牌时，隐藏中间牌")
		self.cardGroup.middleCard:setVisible(false)
	end	

	if playerInfo.cardMiddle ~= nil or self.myself == true then
		self.cardGroup.cardConcealed = false
		local pos = self.cardGroup:getCardPosition(self.cardGroup.layoutIndex, "1")
		self.cardGroup.cards[1]:setPosition(pos)

		pos = self.cardGroup:getCardPosition(self.cardGroup.layoutIndex, "2")
		self.cardGroup.cards[2]:setPosition(pos)
		self:showCardTip()
		pos = self.cardGroup:getCardPosition(self.cardGroup.layoutIndex, "middle")
		self.cardGroup.middleCard:setPosition(pos)
	else--if conditions then
		--todo
		self.cardGroup.cardConcealed = true
		local pos = self.cardGroup:getCardPosition(self.cardGroup.layoutIndex, "hidden1")
		self.cardGroup.cards[1]:setPosition(pos)
		pos = self.cardGroup:getCardPosition(self.cardGroup.layoutIndex, "hidden2")
		self.cardGroup.cards[2]:setPosition(pos)
	end

end

return SeatView
