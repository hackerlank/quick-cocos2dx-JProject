--[[
 这个文件相当于我们原来的GameMsgController,
 比如LordController, PKLordController，每个游戏对应一个
]]
-- XXX游戏消息处理
import("interim.pb.InterimMsg")
InterimMsgController = {}
local GameState = require("game.def.JJGameStateDefine")
local InterimUtilDefine = require("interim.util.InterimUtilDefine")
local INTERIM_PLAYER_STATUS_EMPTY = InterimUtilDefine.INTERIM_PLAYER_STATUS_EMPTY
local INTERIM_PLAYER_STATUS_ENGAGED = InterimUtilDefine.INTERIM_PLAYER_STATUS_ENGAGED
local INTERIM_PLAYER_STATUS_STANDBY = InterimUtilDefine.INTERIM_PLAYER_STATUS_STANDBY
local INTERIM_PLAYER_STATUS_FOLD = InterimUtilDefine.INTERIM_PLAYER_STATUS_FOLD
-- XXXmsg type

local InitCardAck = InterimUtilDefine.InitCardAck
local CoinAck = InterimUtilDefine.CoinAck
local OverAck = InterimUtilDefine.OverAck
local CurPrizePoolAck = InterimUtilDefine.CurPrizePoolAck
local ConGambAck = InterimUtilDefine.ConGambAck
local GambEndAck = InterimUtilDefine.GambEndAck                 -- 有人获得博彩消息
local CurPrizePoolNoteAck = InterimUtilDefine.CurPrizePoolNoteAck
local ChangeScoreAck = InterimUtilDefine.ChangeScoreAck
local DivideTableCoinAck = InterimUtilDefine.DivideTableCoinAck


function InterimMsgController:handleMsg(msg)   
  local InterimData, matchId

  local interimmsg = msg.interim_ack_msg  
  if interimmsg then 
    matchId = interimmsg.matchid    
    InterimData = GameDataContainer:getGameData(matchId)
    if not InterimData then return end
  end
  msg[MSG_CATEGORY] = INTERIM_ACK_MSG
  if #interimmsg.InitCard_ack_msg ~= 0 then
    self:handleInitCardAck(msg, InterimData)
    JJLog.i("handleInitCardAck")
  elseif #interimmsg.Coin_ack_msg ~= 0 then
    self:handleCoinAck(msg, InterimData)
  
  elseif #interimmsg.Over_ack_msg ~= 0 then
    self:handleOverAck(msg, InterimData)
  
  elseif #interimmsg.CurPrizePool_ack_msg ~= 0 then
    self:handleCurPrizePoolAck(msg, InterimData)
  
  elseif #interimmsg.ConGamb_ack_msg ~= 0 then
    self:handleConGambAck(msg, InterimData)
  
  elseif #interimmsg.GambEnd_ack_msg ~= 0 then
    self:handleGambEndAck(msg, InterimData)
  
  elseif #interimmsg.CurPrizePoolNote_ack_msg ~= 0 then
    self:handleCurPrizePoolNoteAck(msg, InterimData)
  
  elseif #interimmsg.ChangeScore_ack_msg ~= 0 then
    self:handleChangeScoreAck(msg, InterimData)
  
  elseif #interimmsg.DivideTableCoin_ack_msg ~= 0 then
    self:handleDivideTableCoinAck(msg, InterimData)

  else
      JJLog.i("InterimMsgController", "receive not unknown Interim msg ")
  end
end

-- 一局游戏开始
function InterimMsgController:handleInitCardAck(msg, gameData)
  JJLog.i("InterimMsgController:handleInitCardAck")

  local function getCards(cards)
    local cardsArr = {}
    cardsArr[1], cardsArr[2] = 256, 256
    if cards ~= nil then
      for i = 1, string.len(cards) do
        cardsArr[i] = tonumber(string.byte(cards, i, i)) + 1
      end
      JJLog.i("getCards, cardsArr = "..table.concat(cardsArr,","))
    end
    if #cardsArr == 2 and cardsArr[1] ~= 256 and cardsArr[2] ~= 256 then
      local point1 = cardsArr[1]%13
      if point1 == 0 then
        point1 = 13
      end
      local point2 = cardsArr[2]%13
      if point2 == 0 then
        point2 = 13
      end
      if point1 > point2 then
        cardsArr[1], cardsArr[2] = cardsArr[2], cardsArr[1]
      end
    end

    return cardsArr[1], cardsArr[2]
  end

  msg[MSG_TYPE] = InitCardAck
  local ack = msg.interim_ack_msg.InitCard_ack_msg

  -- 历史记录
  if gameData.enteringHistory == true and gameData.property.isTourny == true then
    JJLog.i("记录initcard历史记录")
    gameData.historyData = {}
    gameData.historyData.bankSeat = ack.bankSeat + 1
    gameData.historyData.firstSeat = ack.firstSeat + 1
    gameData.historyData.cardCount = ack.cardCount
    gameData.historyData.playerCount = ack.playerCount
    gameData.historyData.nBaseScore = ack.nBaseScore
    gameData.historyData.tableCoin = ack.tableCoin
    
    gameData.historyData.playerCards = {}
    gameData.historyData.playerCards[1], gameData.historyData.playerCards[2] = getCards(ack.cards)
    
    gameData.historyData.anBottomCoin = {}
    for i,v in ipairs(ack.anBottomCoin) do
      local coin = ack.anBottomCoin[i]
      gameData.historyData.anBottomCoin[#gameData.historyData.anBottomCoin + 1] = coin
    end

    gameData.historyData.coinData = {}

    -- gameData.historyData.anTax = {}
    -- for i,v in ipairs(ack.anTax) do
    --   gameData.historyData.anTax[#gameData.historyData.anTax + 1] = ack.anTax[i]
    -- end
    
    -- gameData.historyData.anNewBlind = {}
    -- for i,v in ipairs(ack.anNewBlind) do
    --   gameData.historyData.anNewBlind[#gameData.historyData.anNewBlind + 1] = ack.anNewBlind[i]
    -- end

    -- gameData.historyData.anBalanceTax = {}
    -- for i,v in ipairs(ack.anBalanceTax) do
    --   gameData.historyData.anBalanceTax[#gameData.historyData.anBalanceTax + 1] = ack.anBalanceTax[i]
    -- end

  else
    --正常数据
    gameData.bankSeat = ack.bankSeat + 1
    gameData.firstSeat = ack.firstSeat + 1
    JJLog.i("setting first seata " .. gameData.firstSeat)
    gameData.cardCount = ack.cardCount
    gameData.playerCount = ack.playerCount
    gameData.nBaseScore = ack.nBaseScore
    gameData.tableCoin = ack.tableCoin
    gameData.enProba = ack.enProba
    
    JJLog.i("playerCards")
    gameData.playerCards[1], gameData.playerCards[2] = getCards(ack.cards)
    for i,v in ipairs(gameData.playerCards) do
      JJLog.i(v)
    end

     for i=1,5 do
       gameData.allPlayerInfo[i]:resetCard()
     end
    -- for i,v in ipairs(gameData.allPlayerInfo) do
    --   if v then
    --     gameData.allPlayerInfo[i]:resetCard()
    --   end
    -- end
    
    JJLog.i("cardCount: " .. gameData.cardCount .. " playerCount: "  .. gameData.playerCount)
    JJLog.i("nBaseScore: " .. gameData.nBaseScore .. " enProba: "  .. gameData.enProba)
    JJLog.i("anBottomCoin: ")
    gameData.anBottomCoin = {}
    for i,v in ipairs(ack.anBottomCoin) do
      local coin = ack.anBottomCoin[i]
      if coin > 0 and gameData.minCoin == nil then
        gameData.minCoin = coin * 6
      end

      gameData.anBottomCoin[#gameData.anBottomCoin + 1] = coin
      JJLog.i(ack.anBottomCoin[i])
      -- 参与发牌的玩家，下注玩家才会发牌
      if coin > 0 then
        gameData.allPlayerInfo[i].status = INTERIM_PLAYER_STATUS_ENGAGED
        gameData.allPlayerInfo[i].enResult = nil
        if gameData.allPlayerInfo[i].tkInfo.userid == UserInfo.userId_ then
          gameData.allPlayerInfo[i].cardLeft = gameData.playerCards[1]
          gameData.allPlayerInfo[i].cardRight = gameData.playerCards[2]
          JJLog.i("设置玩家左右卡：" .. gameData.allPlayerInfo[i].cardLeft .. 
              " " .. gameData.allPlayerInfo[i].cardRight)
          gameData.allPlayerInfo[i].cardMiddle = nil
        else
          gameData.allPlayerInfo[i].cardLeft = 0
          gameData.allPlayerInfo[i].cardRight = 0
          gameData.allPlayerInfo[i].cardMiddle = nil
        end

      else
        if gameData.allPlayerInfo[i].tkInfo.userid ~= 0 then
          gameData.allPlayerInfo[i].status = INTERIM_PLAYER_STATUS_STANDBY
        end
      end
    end

    JJLog.i("anTax: ")
    gameData.anTax = {}
    for i,v in ipairs(ack.anTax) do
      gameData.anTax[#gameData.anTax + 1] = ack.anTax[i]
      JJLog.i(ack.anTax[i])
    end
    
    JJLog.i("anNewBlind: ")
    gameData.anNewBlind = {}
    for i,v in ipairs(ack.anNewBlind) do
      gameData.anNewBlind[#gameData.anNewBlind + 1] = ack.anNewBlind[i]
      JJLog.i(ack.anNewBlind[i])
    end

    JJLog.i("anBalanceTax: ")
    gameData.anBalanceTax = {}
    for i,v in ipairs(ack.anBalanceTax) do
      gameData.anBalanceTax[#gameData.anBalanceTax + 1] = ack.anBalanceTax[i]
      JJLog.i(ack.anBalanceTax[i])
    end

    if gameData.property.isTourny == true then
      gameData.roundInfo.roundId = gameData.roundInfo.roundId + 1
    end

    gameData.coinData = {}
    gameData:roundStarting()
    gameData.isAction = false
  end
end

function InterimMsgController:handleCoinAck(msg, gameData)
  msg[MSG_TYPE] = CoinAck
  local ack = msg.interim_ack_msg.Coin_ack_msg

  -- 历史记录
  if gameData.enteringHistory == true and gameData.property.isTourny == true then
    if gameData.historyData.coinData then
      local coinData = {}
      coinData.enResult = ack.enResult
      coinData.coin = ack.coin
      coinData.coinWin = ack.coinWin
      coinData.seat = ack.seat + 1
      coinData.nextSeat = ack.nextSeat + 1
      
      coinData.abyCard = {}
      for i,v in ipairs(ack.abyCard) do
        coinData.abyCard[i] = ack.abyCard[i] + 1
      end
      coinData.drawCard = ack.drawCard + 1
      coinData.enProbaPre = ack.enProbaPre
      coinData.enProbaCur = ack.enProbaCur

      gameData.historyData.coinData[#gameData.historyData.coinData + 1] = coinData
    end
  else
     -- 正常叫牌
    gameData.coinData.enResult = ack.enResult
    gameData.coinData.coin = ack.coin
    JJLog.i("*****************ack.coin" .. ack.coin)
    gameData.coinData.coinWin = ack.coinWin
    gameData.coinData.seat = ack.seat + 1
    gameData.coinData.nextSeat = ack.nextSeat + 1
     JJLog.i("*****************ack.nextSeat" .. ack.nextSeat)
    gameData.coinData.abyCard = {}
    for i,v in ipairs(ack.abyCard) do
      gameData.coinData.abyCard[i] = ack.abyCard[i] + 1
    end
    gameData.coinData.drawCard = ack.drawCard + 1
    gameData.coinData.enProbaPre = ack.enProbaPre
    gameData.coinData.enProbaCur = ack.enProbaCur
    gameData.coinData.coinWinPrize = ack.coinWinPrize
    gameData.coinData.wallCardCount = ack. wallCardCount

    JJLog.i("coin: " .. gameData.coinData.coin .. " coinWin: " .. gameData.coinData.coinWin)
    JJLog.i("enResult: " .. gameData.coinData.enResult .. " seat: "  .. gameData.coinData.seat)
    JJLog.i("nextSeat: " .. gameData.coinData.nextSeat .. " drawCard: "  .. gameData.coinData.drawCard)
    JJLog.i("enProbaPre: " .. gameData.coinData.enProbaPre .. " enProbaCur: "  .. gameData.coinData.enProbaCur)
    JJLog.i("coinWinPrize: " .. gameData.coinData.coinWinPrize .. " wallCardCount: "  .. gameData.coinData.wallCardCount)
    JJLog.i("abyCard : ")
    for i,v in ipairs(gameData.coinData.abyCard) do
      if gameData.coinData.abyCard[i] >52 then
         JJLog.i(gameData.coinData.abyCard[i])
      else
        local point = gameData.coinData.abyCard[i]%13
        if point == 0 then
          point = 13
        end
        JJLog.i(point .. " from " .. gameData.coinData.abyCard[i])
      end
    end

    local playerInfo = gameData:getPlayerInfoBySeatIndex(gameData.coinData.seat)
    if gameData.coinData.abyCard[1] and gameData.coinData.abyCard[1] ~= 256 then
      playerInfo.cardLeft = gameData.coinData.abyCard[1]
    end
    if gameData.coinData.abyCard[2] and gameData.coinData.abyCard[2] ~= 256 then
      playerInfo.cardRight = gameData.coinData.abyCard[2]
    end
    if gameData.coinData.drawCard and gameData.coinData.drawCard ~= 256 then
      playerInfo.cardMiddle = gameData.coinData.drawCard
    end
      playerInfo.enResult = gameData.coinData.enResult  --前后台切换时不显示玩家牌型结果
    JJLog.i("playerInfo card: ")
    JJLog.i(playerInfo.cardLeft)
    JJLog.i(playerInfo.cardRight)
    JJLog.i(playerInfo.cardMiddle)
  end
end

-- function InterimMsgController:checkRoundShouldEnd(ack)
--   if ack.coin == 0 and ack.coinWin == 0 and ack.seat == 0
--   and ack.nextSeat == 0 and ack.drawCard == 0 then
--     return true;
--   end
--   return false
-- end

function InterimMsgController:handleOverAck(msg, gameData)
  msg[MSG_TYPE] = OverAck

  local ack = msg.interim_ack_msg.Over_ack_msg
  
  local playerInfo = gameData:getMyPlayerInfo()
  if playerInfo == nil then
     JJLog.i("*********************handleOverAck*********playerInfo == nil*")
    return
  end

  if not gameData.isAction and playerInfo.status == INTERIM_PLAYER_STATUS_ENGAGED 
    and gameData.standFlag == false and  Util:isAppActive() == false then
    MatchMsg:sendMarkPlayerIdleReq(INTERIM_MATCH_ID, true) 
    JJLog.i("*********************handleOverAck*******************MatchMsg:sendMarkPlayerIdleReq")
  end
end

function InterimMsgController:handleCurPrizePoolAck(msg, gameData)
  msg[MSG_TYPE] = CurPrizePoolAck
  local ack = msg.interim_ack_msg.CurPrizePool_ack_msg

  gameData.curPrizePool = ack.curPrizePool
end

function InterimMsgController:handleConGambAck(msg, gameData)
  msg[MSG_TYPE] = ConGambAck
  local ack = msg.interim_ack_msg.ConGamb_ack_msg

  gameData.conGamb.seat = ack.seat + 1
  gameData.conGamb.card = ack.card + 1
  gameData.conGamb.winCoin = ack.winCoin
  gameData.conGamb.everyWin = ack.everyWin
  gameData.conGamb.enResult = ack.enResult
  gameData.conGamb.cardCount = ack.cardCount
  gameData.conGamb.click = ack.click + 1

end

function InterimMsgController:handleGambEndAck(msg, gameData)
  msg[MSG_TYPE] = GambEndAck
  local ack = msg.interim_ack_msg.GambEnd_ack_msg

  gameData.gambData.seat = ack.seat + 1
  gameData.gambData.card = ack.card + 1
  gameData.gambData.winCoin = ack.winCoin
  gameData.gambData.everyWin = ack.everyWin
  gameData.gambData.enResult = ack.enResult
  gameData.gambData.nextSeat = ack.nextSeat + 1
  gameData.gambData.enProbaCur = ack.enProbaCur
  gameData.gambData.click = ack.click + 1

  JJLog.i("gambData.winCoin : " .. gameData.gambData.winCoin)
  JJLog.i("gambData.card : " .. gameData.gambData.card)
  JJLog.i("gambData.click : " .. gameData.gambData.click)

  gameData.coinData.nextSeat = gameData.gambData.nextSeat
end

function InterimMsgController:handleCurPrizePoolNoteAck(msg, gameData)
  msg[MSG_TYPE] = CurPrizePoolNoteAck
  local ack = msg.interim_ack_msg.CurPrizePoolNote_ack_msg
  gameData.poolNote = ack.note

end

function InterimMsgController:handleChangeScoreAck(msg, gameData)
  msg[MSG_TYPE] = ChangeScoreAck
  local ack = msg.interim_ack_msg.ChangeScore_ack_msg

  for i,v in ipairs(ack.score) do
    gameData.changeScoreData.score[i] = v
  end
  --  = ack.score
  -- gameData.changeScoreData.seat = {}

  --  ack.seat + 1
end

function InterimMsgController:handleDivideTableCoinAck(msg, gameData)
  msg[MSG_TYPE] = DivideTableCoinAck
  local ack = msg.interim_ack_msg.DivideTableCoin_ack_msg
  
  JJLog.i("divideTableCoin:")
  local hasPlayerOut = false
  local playerLeftCount = 0
  for i,v in ipairs(ack.score) do
      gameData.divideTableCoin[i] = v
      JJLog.i("coin: " .. gameData.divideTableCoin[i])
      if v > 0 then
        gameData.divideTableCoinSingle = v
        playerLeftCount = playerLeftCount + 1
      end

      local playerInfo = gameData:getPlayerInfoBySeatIndex(i)
      if playerInfo and playerInfo.tkInfo.userid ~= 0 then
        if v == 0 then
          playerInfo.tkInfo.userid = 0
          hasPlayerOut = true
        else 
          playerInfo.tkInfo.score = playerInfo.tkInfo.score + v
        end
      end
  end
  gameData.hasPlayerOut = hasPlayerOut
  gameData.tableCoin = 0
  if playerLeftCount == 1 then
    gameData.lastPlayer = true
  else
    gameData.lastPlayer = false
  end

end

return InterimMsgController