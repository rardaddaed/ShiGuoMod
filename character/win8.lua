win8_module = {}

win8_module.win8 = {
    DAMAGE = 0,
    SPEED = 0.1,
    SHOTSPEED = 0,
    TEARHEIGHT = 0,
    MaxFireDelay = 1.1, --1 is defaut
    TEARRANGE = 1, --1 is defaut
    TEARFALLINGSPEED = 0,
    LUCK = 0,
    FLYING = false,
    TEARFLAG = 0, -- 0 is default
    TEARCOLOR = Color(1.0, 1.0, 1.0, 1.0, 0, 0, 0)
}

local cardList = {}
local cardMatrix = {}
local game = Game()

----Win8 Stats----
function win8_module.win8:onCache(player, cacheFlag) -- I do mean everywhere!
    if player:GetName() == "Win8" then -- Especially here!
        if cacheFlag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + win8_module.win8.DAMAGE
        end
        if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed + win8_module.win8.SHOTSPEED
        end
        if cacheFlag == CacheFlag.CACHE_RANGE then
            player.TearHeight = player.TearHeight - win8_module.win8.TEARHEIGHT
            player.TearFallingSpeed = player.TearFallingSpeed + win8_module.win8.TEARFALLINGSPEED
            player.TearRange = player.TearRange * win8_module.win8.TEARRANGE
        end
        if (cacheFlag == CacheFlag.CACHE_FIREDELAY) then
            player.MaxFireDelay = player.MaxFireDelay * win8_module.win8.MaxFireDelay
        end
        if cacheFlag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed + win8_module.win8.SPEED
        end
        if cacheFlag == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck + win8_module.win8.LUCK
        end
        if cacheFlag == CacheFlag.CACHE_FLYING and win8_module.win8.FLYING then
            player.CanFly = true
        end
        if cacheFlag == CacheFlag.CACHE_TEARFLAG then
            player.TearFlags = player.TearFlags | win8_module.win8.TEARFLAG
        end
        if cacheFlag == CacheFlag.CACHE_TEARCOLOR then
            player.TearColor = win8_module.win8.TEARCOLOR
        end
    end
end

--- replaces all bombs to card High Priestess for win8, then replaces all non-normal tarot cards to normal tarot cards ---
function win8_module.winPickupReplace()
    local player = Isaac.GetPlayer(0)
    local itemPool = game:GetItemPool()
    local roomEntities = Isaac.GetRoomEntities()
    local room = Game():GetRoom()
    if player:GetName() == "Win8" then
        for i, entity in pairs(roomEntities) do
            local entityPosition = entity.Position
            if entity.Type == EntityType.ENTITY_PICKUP --- Remove bomb collectibles
                and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE
                and entity.SubType == itemPool:GetCollectible(ItemPoolType.POOL_BOMB_BUM, false, Random(), entity.SubType) then
                entity:Remove()
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE,
                    itemPool:GetCollectible(ItemPoolType.POOL_TREASURE), entityPosition, Vector(0, 0), nil)
            end
            randomNumber = Random()
            if room:GetType() ~= RoomType.ROOM_SHOP and randomNumber / (4294967296) <= 0.85 then
                if entity.Type == EntityType.ENTITY_PICKUP
                    and entity.Variant == PickupVariant.PICKUP_BOMB
                    and entity.SubType == BombSubType.BOMB_NORMAL then
                    entity:Remove()
                end
                if entity.Type == EntityType.ENTITY_PICKUP
                    and entity.Variant == PickupVariant.PICKUP_BOMB
                    and entity.SubType == BombSubType.BOMB_DOUBLEPACK then
                    entity:Remove()
                end
                if entity.Type == EntityType.ENTITY_PICKUP
                    and entity.Variant == PickupVariant.PICKUP_BOMB
                    and entity.SubType == BombSubType.BOMB_GOLDEN then
                    entity:Remove()
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MEGA,
                        entityPosition, Vector(0, 0), nil)
                end
                if entity.Type == EntityType.ENTITY_PICKUP --- Replace non-normal tarot cards with normal tarot cards
                    and entity.Variant == PickupVariant.PICKUP_TAROTCARD
                    and entity.SubType > 22 
                    and entity.SpawnerType == 0 then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, math.ceil(math.random(1, 22)), entityPosition, Vector(0,0), nil)
                    entity:Remove() 
                end
            end
            if room:GetType() ~= RoomType.ROOM_SHOP and randomNumber / (4294967296) > 0.85 then
                if entity.Type == EntityType.ENTITY_PICKUP
                    and entity.Variant == PickupVariant.PICKUP_BOMB
                    and entity.SubType == BombSubType.BOMB_NORMAL then
                    entity:Remove()
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_HIGH_PRIESTESS,
                        entityPosition, Vector(0, 0), nil)
                end
                if entity.Type == EntityType.ENTITY_PICKUP
                    and entity.Variant == PickupVariant.PICKUP_BOMB
                    and entity.SubType == BombSubType.BOMB_DOUBLEPACK then
                    entity:Remove()
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_HIGH_PRIESTESS,
                        entityPosition, Vector(0, 0), nil)
                end
                if entity.Type == EntityType.ENTITY_PICKUP --- Replace non-normal tarot cards with normal tarot cards
                    and entity.Variant == PickupVariant.PICKUP_TAROTCARD
                    and entity.SubType > 22 
                    and entity.SpawnerType == 0 then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, math.ceil(math.random(1, 22)), entityPosition, Vector(0,0), nil)
                    entity:Remove() 
                end
            end
        end
        if player:GetNumBombs() > 0 then
            player:AddBombs(-99)
            player:AnimateSad()
            SFXManager():Play(Isaac.GetSoundIdByName("oof"))
        end
    end
end



--- Win8 merges two cards in the slot together when pressed bomb button, if mergable ---
function win8_module.winCardForge()
    local player = Isaac.GetPlayer(0)
    if player:GetName() == "Win8"
        and player:GetCard(0) * player:GetCard(1) ~= 0
        and player:GetCard(0) < 23
        and player:GetCard(1) < 23
        and Input.IsActionPressed(ButtonAction.ACTION_BOMB, 0) then
        local row = player:GetCard(0)
        local col = player:GetCard(1)
        if cardMatrix[player:GetCard(0)][player:GetCard(1)] ~= 0 then
            player:SetCard(1, 0)
            player:SetCard(0, cardMatrix[row][col])
            player:AnimateCard(player:GetCard(0))
            SFXManager():Play(Isaac.GetSoundIdByName("card_merge"))
        elseif cardMatrix[player:GetCard(1)][player:GetCard(0)] ~= 0 then
            player:SetCard(1, 0)
            player:SetCard(0, cardMatrix[col][row])
            player:AnimateCard(player:GetCard(0))
            SFXManager():Play(Isaac.GetSoundIdByName("card_merge"))
        end
    end
end

--- Win8 only gets a normal tarot card when using card deck ---
function win8_module.winUseCardDeck()
    local player = Isaac.GetPlayer(0)
    if player:GetName() == "Win8" then
        player:SetCard(0, math.ceil(math.random(1, 22)))
    end
end

--- Win8's initial charge for card deck will always be 3 ---
function win8_module.winChargeCardDeck()
    local player = Isaac.GetPlayer(0)
    if player:GetName() == "Win8"
        and player:HasCollectible(85) then
        for i = 0, 1 do
            if player:GetActiveItem(i) == CollectibleType.COLLECTIBLE_DECK_OF_CARDS
                and player:GetActiveCharge(i) == 0 then
                player:SetActiveCharge(3)
            elseif player:GetActiveItem(i) == CollectibleType.COLLECTIBLE_DECK_OF_CARDS  --- If Win8 has 9 volt, charge will be 4
            and player:HasCollectible(116) == true then
                player:SetActiveCharge(4)
            end
        end
    end
end

--- Renders text on screen to show what cards can be merged into for Win8, if possible ---
function win8_module.winShowCard()
    local player = Isaac.GetPlayer(0)
    if player:GetName() == "Win8"
        and player:GetCard(0) * player:GetCard(1) ~= 0
        and player:GetCard(0) < 23
        and player:GetCard(1) < 23 then
        local f = Font()
        f:Load("font/teammeatfont10.fnt")
        local row = player:GetCard(0)
        local col = player:GetCard(1)
        local textVector = Vector(10, 470)
        local screenpos = Isaac.WorldToScreen(textVector)
        if cardMatrix[player:GetCard(0)][player:GetCard(1)] ~= 0 then
            f:DrawString(cardList[cardMatrix[row][col]], screenpos.X, screenpos.Y, KColor(1, 1, 1, 1, 0, 0, 0), 0, true)
        elseif cardMatrix[player:GetCard(1)][player:GetCard(0)] ~= 0 then
            f:DrawString(cardList[cardMatrix[col][row]], screenpos.X, screenpos.Y, KColor(1, 1, 1, 1, 0, 0, 0), 0, true)
        end
    end
end

function win8_module.unNameFunction1(_, mpgsc)
    local player = Isaac.GetPlayer(0)
    local roomEntities = Isaac.GetRoomEntities()
    if player:GetName() == "Win8" then
        if (not mpgsc) then
            player:SetCard(0, 0)
            for i, entity in pairs(roomEntities) do
                if entity.Type == EntityType.ENTITY_PICKUP
                    and entity.Variant == PickupVariant.PICKUP_TAROTCARD then
                    entity:Remove()
                end
            end
        end
    end
end

function win8_module.unNameFunction2(_, mpgsc)
    local player = Isaac.GetPlayer(0)
    if player:GetName() == "Win8" then
        if (not mpgsc) then
            for i = 1, 22 do --- Initialise matrix
                cardMatrix[i] = {} -- create a new row
                for j = 1, 22 do
                    cardMatrix[i][j] = 0
                end
            end
            for i = 1, 22 do
                cardMatrix[i][i] = 55 + i
            end
            cardMatrix[17][17] = 42
            cardMatrix[1][6] = 35
            cardMatrix[1][14] = 91
            cardMatrix[1][17] = 72
            cardMatrix[1][22] = 53
            cardMatrix[2][3] = 50
            cardMatrix[2][10] = 93
            cardMatrix[2][13] = 80
            cardMatrix[2][17] = 23
            cardMatrix[3][10] = 38
            cardMatrix[3][14] = 41
            cardMatrix[4][7] = 30
            cardMatrix[5][16] = 88
            cardMatrix[5][19] = 78
            cardMatrix[5][20] = 51
            cardMatrix[6][3] = 96
            cardMatrix[7][6] = 26
            cardMatrix[8][12] = 52
            cardMatrix[8][14] = 39
            cardMatrix[8][17] = 32
            cardMatrix[9][2] = 55
            cardMatrix[9][10] = 28
            cardMatrix[9][18] = 49
            cardMatrix[10][18] = 25
            cardMatrix[11][2] = 40
            cardMatrix[11][10] = 24
            cardMatrix[11][14] = 89
            cardMatrix[11][17] = 27
            cardMatrix[12][3] = 86
            cardMatrix[12][7] = 82
            cardMatrix[12][17] = 84
            cardMatrix[12][21] = 87
            cardMatrix[13][3] = 92
            cardMatrix[13][5] = 97
            cardMatrix[13][19] = 47
            cardMatrix[13][22] = 36
            cardMatrix[13][23] = 54
            cardMatrix[14][13] = 95
            cardMatrix[15][2] = 44
            cardMatrix[15][4] = 85
            cardMatrix[16][14] = 46
            cardMatrix[18][3] = 94
            cardMatrix[18][16] = 31
            cardMatrix[19][15] = 34
            cardMatrix[20][7] = 79
            cardMatrix[20][10] = 43
            cardMatrix[20][18] = 29
            cardMatrix[21][11] = 48
            cardMatrix[21][18] = 37
            cardMatrix[21][19] = 83
            cardMatrix[22][9] = 33
            cardMatrix[22][11] = 90
            cardMatrix[22][17] = 45
            cardMatrix[22][18] = 81
        end
    end
end

function win8_module.unNameFunction3(_, mpgsc)
    local player = Isaac.GetPlayer(0)
    if player:GetName() == "Win8" then
        if (not mpgsc) then
            for i = 23, 98 do
                cardList[i] = ""
            end
            cardList[23] = "2 of Clubs"
            cardList[24] = "2 of Diamonds"
            cardList[25] = "2 of Spades"
            cardList[26] = "2 of Hearts"
            cardList[27] = "Ace of Clubs"
            cardList[28] = "Ace of Diamonds"
            cardList[29] = "Ace of Spades"
            cardList[30] = "Ace of Hearts"
            cardList[31] = "Joker"
            cardList[32] = "Hagalaz"
            cardList[33] = "Jera"
            cardList[34] = "Ehwaz"
            cardList[35] = "Dagaz"
            cardList[36] = "Ansuz"
            cardList[37] = "Perthro"
            cardList[38] = "Berkano"
            cardList[39] = "Algiz"
            cardList[40] = "Blank Rune"
            cardList[41] = "Black Rune"
            cardList[42] = "Chaos Card"
            cardList[43] = "Credit Card"
            cardList[44] = "Rules Card"
            cardList[45] = "A Card Against Humanity"
            cardList[46] = "Suicide King"
            cardList[47] = "Get Out of Jail Free Card"
            cardList[48] = "? Card"
            cardList[49] = "Dice Shard"
            cardList[50] = "Emergency Contact"
            cardList[51] = "Holy Card"
            cardList[52] = "Huge Growth"
            cardList[53] = "Ancient Recall"
            cardList[54] = "Sonic"
            cardList[55] = "Rune Shard"
            cardList[56] = "The Fool?"
            cardList[57] = "The Magician?"
            cardList[58] = "Dave's Pan?"
            cardList[59] = "The Empress?"
            cardList[60] = "The Emperor?"
            cardList[61] = "The Hierophant?"
            cardList[62] = "The Lovers?"
            cardList[63] = "The Chariot?"
            cardList[64] = "The Justice?"
            cardList[65] = "The Hermit?"
            cardList[66] = "Wheel of Fortune?"
            cardList[67] = "Strength?"
            cardList[68] = "The Hanged Man?"
            cardList[69] = "Death?"
            cardList[70] = "Temperance?"
            cardList[71] = "The Devil?"
            cardList[72] = "The Tower?"
            cardList[73] = "The Stars?"
            cardList[74] = "The Moon?"
            cardList[75] = "The Sun?"
            cardList[76] = "Judgement?"
            cardList[77] = "The World?"
            cardList[78] = "Cracked Key"
            cardList[79] = "Queen of Hearts"
            cardList[80] = "Wild Card"
            cardList[81] = "Soul of Isaac"
            cardList[82] = "Soul of Magdalene"
            cardList[83] = "Soul of Cain"
            cardList[84] = "Soul of Judas"
            cardList[85] = "Soul of ???"
            cardList[86] = "Soul of Eve"
            cardList[87] = "Soul of Samson"
            cardList[88] = "Soul of Azazel"
            cardList[89] = "Soul of Lazarus"
            cardList[90] = "Soul of Eden"
            cardList[91] = "Soul of the Lost"
            cardList[92] = "Soul of Lilith"
            cardList[93] = "Soul of the Keeper"
            cardList[94] = "Soul of Apollyon"
            cardList[95] = "Soul of Forgotten"
            cardList[96] = "Soul of Bethany"
            cardList[97] = "Soul of Jacob and Esau"
        end
    end
end

--- Defeat BOSS 80% chance to drop Emperor card
function win8_module.winDropCardEmperor()
    local player = Isaac.GetPlayer(0)
    local roomEntities = Isaac.GetRoomEntities()
    if player:GetName() == "Win8" then
        for i, entity in pairs(roomEntities) do
            if entity:IsBoss() == true and entity:IsDead() == true and entity.Type ~= EntityType.ENTITY_LARRYJR then
                randomNumber = Random()
                local sprite = entity:GetSprite()
                if sprite:IsFinished("Death") and randomNumber / (4294967296) <= 0.5 then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_EMPEROR,
                        entity.Position,
                        Vector(0, 0), nil)
                end
            end
        end
    end
end

--- Open the red chest with a 60% chance of dropping a death card
function win8_module.winDropCardDeath(chest, player, low)
    local player = Isaac.GetPlayer(0)
    local roomEntities = Isaac.GetRoomEntities()
    if player:GetName() == "Win8" then
        for i, entity in pairs(roomEntities) do
            if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == 360 then
                randomNumber = Random()
                local sprite = entity:GetSprite()
                if sprite:GetAnimation() == "Open" and sprite:GetFrame() == 1 and randomNumber / (4294967296) <= 0.6 then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_DEATH,
                        player.Position,
                        Vector(0, 0), nil)
                end
            end
        end
    end
end

--- Open the gold chest with a 60% chance of dropping a star card
function win8_module.winDropCardStar(chest, player, low)
    local player = Isaac.GetPlayer(0)
    local roomEntities = Isaac.GetRoomEntities()
    if player:GetName() == "Win8" then
        for i, entity in pairs(roomEntities) do
            if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == 60 then
                randomNumber = Random()
                local sprite = entity:GetSprite()
                if sprite:GetAnimation() == "Open" and sprite:GetFrame() == 1 and randomNumber / (4294967296) <= 0.6 then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_STARS,
                        player.Position,
                        Vector(0, 0), nil)
                end
            end
        end
    end
end

--- 80% chance to get Fool card at the beginning of each level
function win8_module.winDropCardFool()
    local player = Isaac.GetPlayer(0)
    if player:GetName() == "Win8" then
        randomNumber = Random()
        if randomNumber / (4294967296) <= 0.8 then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_FOOL,
                player.Position,
                Vector(0, 0), nil)
        end
    end
end

function win8_module.winDropCardTower() --- and hanged man
    local player = Isaac.GetPlayer(0)
    local roomEntities = Isaac.GetRoomEntities()
    if player:GetName() == "Win8" then
        for i, entity in pairs(roomEntities) do
            if entity.Type == EntityType.ENTITY_FIREPLACE then
                randomNumber = Random()
                local sprite = entity:GetSprite()
                if sprite:GetAnimation() == "Dissapear" or sprite:GetAnimation() == "Dissapear2" or sprite:GetAnimation() == "Dissapear3" then
                    if sprite:GetFrame() == 1 and randomNumber / (4294967296) <= 0.15 then
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_TOWER,
                        entity.Position,
                        Vector(0, 0), nil)
                    elseif sprite:GetFrame() == 1 and randomNumber / (4294967296) >= 0.85 then
                            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_HANGED_MAN,
                            entity.Position,
                            Vector(0, 0), nil)
                    end
                end
            end
        end
    end
end

local shopCount = 0
local angelCount = 0
local win8Heart = 0
function win8_module.winDropCardShop() --- Also gives a Tower card in angel room, for blowing angel statue and moon/hermit for shop
    local player = Isaac.GetPlayer(0)
    local room = Game():GetRoom()
    if player:GetName() == "Win8" then
        if room:GetType() == RoomType.ROOM_ANGEL and angelCount == 0  then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_TOWER,
            player.Position,
            Vector(0, 0), nil)
            angelCount = 1
        end
        if room:GetType() == RoomType.ROOM_DEVIL then
            win8Heart = player:GetMaxHearts()
        end
        if room:GetType() == RoomType.ROOM_SHOP then
            randomNumber = Random()
            if randomNumber / (4294967296) <= 0.2 and shopCount == 0 then 
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_MOON,
                player.Position,
                Vector(0, 0), nil)
            end
            if randomNumber / (4294967296) >= 0.7 and shopCount == 0  then 
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_HERMIT,
                player.Position,
                Vector(0, 0), nil)
            end
            shopCount = 1
        end
    end
end

local devilCount = 0
function win8_module.winDropCardDevil()
    local player = Isaac.GetPlayer(0)
    local room = Game():GetRoom()
    if player:GetName() == "Win8" and room:GetType() == RoomType.ROOM_DEVIL 
    and win8Heart ~= player:GetMaxHearts() and devilCount == 0 then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_DEVIL,
        player.Position,
        Vector(0, 0), nil)
        devilCount = 1
    end
end

function win8_module.resetRoomCount()
    shopCount = 0
    devilCount = 0
    angelCount = 0
end

function win8_module.winDropCardMagician()
    local player = Isaac.GetPlayer(0)
    local roomEntities = Isaac.GetRoomEntities()
    if player:GetName() == "Win8" then
        for i, entity in pairs(roomEntities) do
            if entity.Type == EntityType.ENTITY_PICKUP 
            and entity.Variant == PickupVariant.PICKUP_HEART then
                if entity.SubType ==  HeartSubType.HEART_FULL 
                or entity.SubType ==  HeartSubType.HEART_SOUL
                or entity.SubType ==  HeartSubType.HEART_BLACK then
                    randomNumber = Random()
                    local sprite = entity:GetSprite()
                    if sprite:GetAnimation() == "Collect" 
                    and sprite:GetFrame() == 1 and randomNumber / (4294967296) <= 0.2 then
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_MAGICIAN,
                        entity.Position,
                        Vector(0, 0), nil)
                    end
                end
            end
        end
    end
end

function win8_module.resetCardMatrix()
    local player = Isaac.GetPlayer(0)
    if player:GetName() == "Win8" then
            for i = 1, 22 do --- Initialise matrix
                cardMatrix[i] = {} -- create a new row
                for j = 1, 22 do
                    cardMatrix[i][j] = 0
                end
            end
            for i = 1, 22 do
                cardMatrix[i][i] = 55 + i
            end
            cardMatrix[17][17] = 42
            cardMatrix[1][6] = 35
            cardMatrix[1][14] = 91
            cardMatrix[1][17] = 72
            cardMatrix[1][22] = 53
            cardMatrix[2][3] = 50
            cardMatrix[2][10] = 93
            cardMatrix[2][13] = 80
            cardMatrix[2][17] = 23
            cardMatrix[3][10] = 38
            cardMatrix[3][14] = 41
            cardMatrix[4][7] = 30
            cardMatrix[5][16] = 88
            cardMatrix[5][19] = 78
            cardMatrix[5][20] = 51
            cardMatrix[6][3] = 96
            cardMatrix[7][6] = 26
            cardMatrix[8][12] = 52
            cardMatrix[8][14] = 39
            cardMatrix[8][17] = 32
            cardMatrix[9][2] = 55
            cardMatrix[9][10] = 28
            cardMatrix[9][18] = 49
            cardMatrix[10][18] = 25
            cardMatrix[11][2] = 40
            cardMatrix[11][10] = 24
            cardMatrix[11][14] = 89
            cardMatrix[11][17] = 27
            cardMatrix[12][3] = 86
            cardMatrix[12][7] = 82
            cardMatrix[12][17] = 84
            cardMatrix[12][21] = 87
            cardMatrix[13][3] = 92
            cardMatrix[13][5] = 97
            cardMatrix[13][19] = 47
            cardMatrix[13][22] = 36
            cardMatrix[13][23] = 54
            cardMatrix[14][13] = 95
            cardMatrix[15][2] = 44
            cardMatrix[15][4] = 85
            cardMatrix[16][14] = 46
            cardMatrix[18][3] = 94
            cardMatrix[18][16] = 31
            cardMatrix[19][15] = 34
            cardMatrix[20][7] = 79
            cardMatrix[20][10] = 43
            cardMatrix[20][18] = 29
            cardMatrix[21][11] = 48
            cardMatrix[21][18] = 37
            cardMatrix[21][19] = 83
            cardMatrix[22][9] = 33
            cardMatrix[22][11] = 90
            cardMatrix[22][17] = 45
            cardMatrix[22][18] = 81
            for i = 23, 98 do
                cardList[i] = ""
            end
            cardList[23] = "2 of Clubs"
            cardList[24] = "2 of Diamonds"
            cardList[25] = "2 of Spades"
            cardList[26] = "2 of Hearts"
            cardList[27] = "Ace of Clubs"
            cardList[28] = "Ace of Diamonds"
            cardList[29] = "Ace of Spades"
            cardList[30] = "Ace of Hearts"
            cardList[31] = "Joker"
            cardList[32] = "Hagalaz"
            cardList[33] = "Jera"
            cardList[34] = "Ehwaz"
            cardList[35] = "Dagaz"
            cardList[36] = "Ansuz"
            cardList[37] = "Perthro"
            cardList[38] = "Berkano"
            cardList[39] = "Algiz"
            cardList[40] = "Blank Rune"
            cardList[41] = "Black Rune"
            cardList[42] = "Chaos Card"
            cardList[43] = "Credit Card"
            cardList[44] = "Rules Card"
            cardList[45] = "A Card Against Humanity"
            cardList[46] = "Suicide King"
            cardList[47] = "Get Out of Jail Free Card"
            cardList[48] = "? Card"
            cardList[49] = "Dice Shard"
            cardList[50] = "Emergency Contact"
            cardList[51] = "Holy Card"
            cardList[52] = "Huge Growth"
            cardList[53] = "Ancient Recall"
            cardList[54] = "Sonic"
            cardList[55] = "Rune Shard"
            cardList[56] = "The Fool?"
            cardList[57] = "The Magician?"
            cardList[58] = "Dave's Pan?"
            cardList[59] = "The Empress?"
            cardList[60] = "The Emperor?"
            cardList[61] = "The Hierophant?"
            cardList[62] = "The Lovers?"
            cardList[63] = "The Chariot?"
            cardList[64] = "The Justice?"
            cardList[65] = "The Hermit?"
            cardList[66] = "Wheel of Fortune?"
            cardList[67] = "Strength?"
            cardList[68] = "The Hanged Man?"
            cardList[69] = "Death?"
            cardList[70] = "Temperance?"
            cardList[71] = "The Devil?"
            cardList[72] = "The Tower?"
            cardList[73] = "The Stars?"
            cardList[74] = "The Moon?"
            cardList[75] = "The Sun?"
            cardList[76] = "Judgement?"
            cardList[77] = "The World?"
            cardList[78] = "Cracked Key"
            cardList[79] = "Queen of Hearts"
            cardList[80] = "Wild Card"
            cardList[81] = "Soul of Isaac"
            cardList[82] = "Soul of Magdalene"
            cardList[83] = "Soul of Cain"
            cardList[84] = "Soul of Judas"
            cardList[85] = "Soul of ???"
            cardList[86] = "Soul of Eve"
            cardList[87] = "Soul of Samson"
            cardList[88] = "Soul of Azazel"
            cardList[89] = "Soul of Lazarus"
            cardList[90] = "Soul of Eden"
            cardList[91] = "Soul of the Lost"
            cardList[92] = "Soul of Lilith"
            cardList[93] = "Soul of the Keeper"
            cardList[94] = "Soul of Apollyon"
            cardList[95] = "Soul of Forgotten"
            cardList[96] = "Soul of Bethany"
            cardList[97] = "Soul of Jacob and Esau"
    end
end

return win8_module
