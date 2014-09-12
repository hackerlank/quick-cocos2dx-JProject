local JJViewGroup = require("sdk.ui.JJViewGroup")
local MaskView = class("MaskView", jj.ui.JJViewGroup)
local InterimUtilDefine = require("interim.util.InterimUtilDefine")
local INTERIM_SOUND = InterimUtilDefine.INTERIM_SOUND

function MaskView:ctor(parentView)
	MaskView.super.ctor(self, parentView)
	self.parentView = parentView
	self.dimens_ = parentView.dimens_
	self:initView()
end

function MaskView:initView()
	self.background = jj.ui.JJImage.new({
		 image = "img/interim/ui/mask.png",
      })
    self.background:setAnchorPoint(ccp(0.5, 0.5))
    self.background:setPosition(0, 0)
    self.background:setScaleX(self.dimens_.wScale_)
    self.background:setScaleY(self.dimens_.hScale_)  
	self:addView(self.background)
	self.background:setPosition(self.dimens_.right/2,self.dimens_.top/2)
    
	self:setTouchEnable(true)
	self:setAnchorPoint(ccp(0,0))
	self:setViewSize(self.dimens_.right, self.dimens_.top)
end

function MaskView:onTouchBegan(x, y)
	if self:isTouchInside(x, y) == true and self.bTouchEnable_ then
		self:setTouchedIn(true)
		self.parentView:maskViewTouched()
		SoundManager:playEffect(INTERIM_SOUND.BUTTON)
		return true
	end
	return false
end

function MaskView:show(shadow)
	self:setVisible(true)
	if shadow == true then
		self.background:setVisible(true)
	else
		self.background:setVisible(false)
	end
end

return MaskView