-- 奖状界面
local JJViewGroup = require("sdk.ui.JJViewGroup")
local AwardView = class("AwardView", JJViewGroup)

function AwardView:ctor(parentView)
	AwardView.super.ctor(self)
	self.parentView = parentView
    self.positionConfig = parentView.positionConfig
	self.dimens_ = parentView.dimens_

	local bg = jj.ui.JJImage.new({
		image = "img/diploma/diploma_view_bg.jpg"
		})
	bg:setPosition(self.dimens_.cx, self.dimens_.cy)
	bg:setScaleX(self.dimens_.wScale_)
	bg:setScaleY(self.dimens_.hScale_)
	self:addView(bg)

	local diplomaBg = jj.ui.JJImage.new({
		image = "img/diploma/diploma_bg.png"
		})
	diplomaBg:setAnchorPoint(CCPoint(0.5, 1))
	diplomaBg:setPosition(self.dimens_.cx,self.dimens_.top - self.dimens_:getDimens(10))
	diplomaBg:setScale(self.dimens_.scale_)
	self:addView(diplomaBg)

	self.exitBtn = jj.ui.JJButton.new({
			images = {
				normal = "img/diploma/diploma_btn_red_d.png",
				highlight = "img/diploma/diploma_btn_red_n.png"
			},
			fontSize = 28,
        	text = "返回大厅",
		})
    self.exitBtn.name = "back"
	self.exitBtn:setAnchorPoint(ccp(0.5,0.5))
	self.exitBtn:setPosition(self.dimens_.cx - self.dimens_:getDimens(0), self.dimens_:getDimens(50))
	self.exitBtn:setScale(self.dimens_.scale_)
	self.exitBtn:setOnClickListener(handler(self, self.onClickBtn))
	self:addView(self.exitBtn)

    self.playAgain = jj.ui.JJButton.new({
            images = {
                normal = "img/diploma/diploma_btn_red_d.png",
                highlight = "img/diploma/diploma_btn_red_n.png"
            },
            fontSize = 28,
            text = "再玩一次",
        })
    self.playAgain.name = "again"
    self.playAgain:setAnchorPoint(ccp(0.5,0.5))
    self.playAgain:setPosition(self.dimens_.cx + self.dimens_:getDimens(100), self.dimens_:getDimens(50))
    self.playAgain:setScale(self.dimens_.scale_)
    self.playAgain:setOnClickListener(handler(self, self.onClickBtn))
    --self:addView(self.playAgain)

    self.shareBtn = jj.ui.JJButton.new({
            images = {
                normal = "img/diploma/diploma_btn_red_d.png",
                highlight = "img/diploma/diploma_btn_red_n.png"
            },
            fontSize = 28,
            text = "分享好友",
        })
    self.shareBtn.name = "share"
    self.shareBtn:setAnchorPoint(ccp(0.5,0.5))
    self.shareBtn:setPosition(self.dimens_.cx + self.dimens_:getDimens(0), self.dimens_:getDimens(50))
    self.shareBtn:setScale(self.dimens_.scale_)
    self.shareBtn:setOnClickListener(handler(self, self.onClickBtn))
    --self:addView(self.shareBtn)
	
	self.contentLabel = jj.ui.JJLabel.new({
        fontSize = 20*self.dimens_.scale_,
        --color = ccc3(252, 217, 97),
        color = ccc3(109, 47, 14),
        text = "你在【卡当新手锦标赛】中获得了第8名(8/10)！再接再厉。\n奖品如下：\n金币：20\n卡子：30",
        singleLine=false,
        valign = ui.TEXT_VALIGN_TOP,
        align = ui.TEXT_ALIGN_LEFT, 
    	viewSize = CCSize(self.dimens_:getDimens(530), 0),
    })
	self.contentLabel:setAnchorPoint(ccp(0.5,1))
    self.contentLabel:setPosition(self.dimens_.cx + self.dimens_:getDimens(0),
    						self.dimens_.cy + self.dimens_:getDimens(100))
    self:addView(self.contentLabel)

    self.awardLabel = jj.ui.JJLabel.new({
        fontSize = 20*self.dimens_.scale_,
        --color = ccc3(252, 217, 97),
        color = ccc3(109, 47, 14),
        text = "\n ★ 1000金币 \n ★ 10大师分",
        viewSize = CCSize(self.dimens_:getDimens(530), 0),
    })
    self.awardLabel:setAnchorPoint(ccp(0.5,1))
    self.awardLabel:setPosition(self.dimens_.cx + self.dimens_:getDimens(20), self.dimens_.cy + self.dimens_:getDimens(30))
    self:addView(self.awardLabel)

    self.historyLabel = jj.ui.JJLabel.new({
        fontSize = 20*self.dimens_.scale_,
        --color = ccc3(252, 217, 97),
        color = ccc3(0, 0, 0),
        text = "恭喜！您在本赛事中曾荣获过次“冠军”，加油！(14-06-11 17:01)",
        singleLine=false,
        valign = ui.TEXT_VALIGN_TOP,
    	viewSize = CCSize(self.dimens_:getDimens(800), self.dimens_:getDimens(300)),
    })
	self.historyLabel:setAnchorPoint(ccp(0.5,1))
    self.historyLabel:setPosition(self.dimens_.cx + self.dimens_:getDimens(-10),
    						self.dimens_.cy + self.dimens_:getDimens(-80))
    --self:addView(self.historyLabel)
   
    self:setTouchEnable(true)

    self.onSharing = false
end

function AwardView:onClickBtn(target)
	if target == self.exitBtn then
		self.parentView:exitGame()
    elseif target == self.playAgain then
        self:resignUp()
    elseif target == self.share then
        --todo
	end
end

function AwardView:resignUp()

    local gameData = GameDataContainer:getGameData(INTERIM_MATCH_ID)
    local tourneyId = gameData.tourneyID
    local tourneyInfo = LobbyDataController:getTourneyInfoByTourneyId(tourneyId)
    if tourneyInfo == nil then
        return
    end
    local matchPoint = tourneyInfo:getSignupTime()
    local matchType = tourneyInfo.matchconfig_.matchType_
    local matchpoint = MatchPointManager:getLastMatchPoint(tourneyId)
    -- self.viewController_:exitMatch(true)

    local tm = tourneyInfo:getSignupTime()

    local signupType = 0
    local singupFee = tourneyInfo:getEntryFee()
    if singupFee and #singupFee > 0 then
        for i = 1, #singupFee do
            if singupFee[i].useable_ then
                signupType = singupFee[i].type_
                break
            end
        end
    end
    LobbyDataController:signupMatch(JJGameDefine.GAME_ID_INTERIM, tourneyId, tm, signupType, 0, 0)
end

function AwardView:setResult(matchAward)
	--local nameText = "亲爱的" .. matchAward.nickName_
    --self.awardLabel:setText(nameText)
    --self.awardLabel:setVisible(false)

    local contentText = matchAward.nickName_ .."你在【" .. matchAward.matchName_ .. "】中获得了第" 
    .. matchAward.rank_ .. "名(" .. matchAward.rank_ .. "/" .. matchAward.totalPlayer_ .. ")！"

   

    --contentText = contentText .. exText    
    
    local awardText = ""
    if #matchAward.awards_ ~= 0 then
		for i,v in ipairs(matchAward.awards_) do
            awardText = awardText .. "\n ★ "
			awardText = awardText .. tostring(v.amount).."  " .. v.type .. " "
		end
    end

    self.awardLabel:setText(awardText)
   
    --self.contentLabel:setText(contentText)

    if matchAward.historyNote_ ~= nil then
    	self.contentLabel:setText(contentText .. matchAward.historyNote_)
    end



end


return AwardView