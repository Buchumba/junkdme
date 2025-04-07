
local START_MONEY = GetMoney()
local CLOSED_MONEY = 0
local JDME_OPENBAG = nil
local prefix = "|cfffcaa52[Junk DME]:|r"
local color_after_prefix = "e1e68a"
local text_help_command = "/jdme [ссылка на предмет]"
local WAIT_ITERATIONS = 700000 --(кол-во итераций) замедление перед каждой продажи итема
local MAIL_IS_OPENER = nil
local JDME_VERSION = "1.0.3"

JDME_GLOBALS = CreateFrame("Frame")
JDME_GLOBALS:RegisterEvent("ADDON_LOADED")
JDME_GLOBALS:SetScript("OnEvent", function()
    if event then        
        if event == 'ADDON_LOADED' and arg1 == 'junkdme' then            
            return JDME_GLOBALS.init()
        end
    end    
end)

function JDME_GLOBALS.init()
  JDME_GeneralTitle:SetText("J|cff54ff00u|r|cff52d014nk|r |cffc4ff53D|r|cffffec95m|re|r v"..JDME_VERSION);
end

SLASH_JDME1 = "/jdme"
function SlashCmdList.JDME(msg, editbox)
  if msg == "" then
    JunkDme:Show()
    JDME_ShowAllSaveValues()    
  elseif msg == "help" then
    JDME_Help()
  else 
    local _, _, item_name = strfind(msg, "|h(.+)|h")
    if item_name then      
      JDME_AddListItem(msg)       
      SaleListXml:Show()
      JDME_SaleListBuild(ScrollChildFrame)
    else       
      DEFAULT_CHAT_FRAME:AddMessage(prefix.." |cff" .. color_after_prefix .. "Нужно указать вещь для добавления в список через Shift. Пример: '"..text_help_command.."'|r")
    end  
  end  
end

SLASH_JUNKDME1 = "/junkdme"
function SlashCmdList.JUNKDME(msg, editbox)
  if msg == "" then
    JunkDme:Show()
    JDME_ShowAllSaveValues()    
  end
end

function JDME_AnounceEmptyList()
  DEFAULT_CHAT_FRAME:AddMessage(prefix.." |cff" .. color_after_prefix .. "Ваш список пуст но вы можете в него добавить первую вещь. Пример: '"..text_help_command.."'|r")
end

function JDME_AddListItem(itemLink)
  if not JDME_SALE_LIST then
    JDME_SALE_LIST = {}
  end
  if not JDME_IsDoubleItemList(JDME_SALE_LIST, itemLink) then
    table.insert(JDME_SALE_LIST, itemLink)
  else
    DEFAULT_CHAT_FRAME:AddMessage(prefix .. " "..itemLink.." |cff".. color_after_prefix.. "уже есть в вашем списке.|r")
  end
end

function JDME_Help()
  DEFAULT_CHAT_FRAME:AddMessage("Аддон `Junk DME` предназначен для автопродажи разных вещей внесенных в 5личный список.",1,1,0);
  DEFAULT_CHAT_FRAME:AddMessage("Список команд:",0,1,0);
  DEFAULT_CHAT_FRAME:AddMessage("/jdme, /junkdme - открытие окна аддона.",1,1,1);
  DEFAULT_CHAT_FRAME:AddMessage("/jdme help - вызов справки.",1,1,1);
  DEFAULT_CHAT_FRAME:AddMessage(text_help_command .. " - внесение предмета в личный список вашего персонажа для автопродажи.",1,1,1);
  DEFAULT_CHAT_FRAME:AddMessage("Об ошибка этого аддона, пожалуйста, сообщите Casta (Going to Death. Turtle-WOW).",1,1,0);
end

function JDME_SetGreySell()  
  local v = this:GetText()    
  if not JDME_CheckValue(v) then    
    JDME_GREY_AUTOSELL = 1   
  else    
    JDME_GREY_AUTOSELL = 0   
  end
  this:SetText(JDME_GetTitleValue(JDME_GREY_AUTOSELL)) 
end

function JDME_RecipesAutoSell()  
  local v = this:GetText()    
  if not JDME_CheckValue(v) then    
    JDME_RECIPES_AUTOSELL = 1   
  else    
    JDME_RECIPES_AUTOSELL = 0   
  end
  this:SetText(JDME_GetTitleValue(JDME_RECIPES_AUTOSELL)) 
end

function JDME_GetTitleValue(value)
  if value == 1 then
    return "on"
  else
    return "off"
  end
end

function JDME_CheckValue(value)  
  if not value or value == "off" then   
    return nil 
  end 
  return true
end

function JDME_FormatMoney(value)
  if value == 0 then
    return "0"
  elseif value > 0 then
    local gold = floor(value / 1e4)
    local silver = floor(mod((value / 100), 100))
    local copper = floor(mod(value, 100))
    return string.format("|cfffff600%d gold|r, |cffbfbfbf%d silver|r, |cffcc9966%d copper|r", gold, silver, copper)
  end
end

function JDME_IsDoubleItemList(Table, item)
  for k, v in ipairs(Table) do 
    if v == item then
      return true 
    end     
  end
  return false
end

---некое подобие sleep & wait функций, которых тут нет.
function JDME_Wait(millisecond)  
  local count = 1
  for x=1, millisecond do    
    if count == millisecond then
      return true;
    end 
    count = count + 1   
  end  
  return nil
end

local function GreySell()  
  for bag=0,4 do
    for slot=0,GetContainerNumSlots(bag) do
      local link = GetContainerItemLink(bag, slot)
      if link and string.find(link, "ff9d9d9d") and JDME_Wait(WAIT_ITERATIONS) then        
        ShowMerchantSellCursor(1)
        UseContainerItem(bag, slot)  
        annoTextOfSelling(link)                
      end
    end
  end  
end

function JunkDme_OnLoad()
  this:RegisterEvent("VARIABLES_LOADED")         
end

local function annoTextOfSelling(link)
  DEFAULT_CHAT_FRAME:AddMessage(prefix .. " |cff"..color_after_prefix.."Ваш|r " .. link .. " |cff"..color_after_prefix.."был продан.|r")                       
end

local f = CreateFrame("Frame")
f:RegisterEvent("MERCHANT_SHOW")
f:RegisterEvent("MERCHANT_CLOSED")
f:RegisterEvent("BAG_UPDATE")
f:RegisterEvent("MERCHANT_CLOSED")
f:SetScript("OnEvent", function()
  if event  == "MERCHANT_SHOW" and not JDME_OPENBAG then
    JDME_OPENBAG = true
    START_MONEY = GetMoney()
    local _countForSale = 0
    if JDME_SALE_LIST then
      _countForSale = table.getn(JDME_SALE_LIST)
    end 
    local _sales = {}
    for bag=0, 4 do
      for slot = 0, GetContainerNumSlots(bag) do
        local link = GetContainerItemLink(bag, slot)        
        if link then
          --продаем серую вещь. если такая опция включена через JDME_GREY_AUTOSELL          
          if JDME_GREY_AUTOSELL == 1 and string.find(link, "ff9d9d9d") and JDME_Wait(WAIT_ITERATIONS) then 
            ShowMerchantSellCursor(1)
            UseContainerItem(bag, slot)  
            annoTextOfSelling(link)            
          --зеленые рецепты, патерны и тд
          elseif JDME_RECIPES_AUTOSELL == 1 and string.find(link, "ff1eff00") and string.find(link, "^.[RecipePatternPlansFormula].+:%s") and JDME_Wait(WAIT_ITERATIONS) then 
            ShowMerchantSellCursor(1)
            UseContainerItem(bag, slot)  
            annoTextOfSelling(link)
          else 
            --далее, продаем вещь из списка, если находим в нем                     
            for x = 1, _countForSale do
              if link == JDME_SALE_LIST[x] and JDME_Wait(WAIT_ITERATIONS) then --проверка из списка
                ShowMerchantSellCursor(1)
                UseContainerItem(bag, slot)                  
                annoTextOfSelling(link)                                       
              end            
            end 
          end       
        end
      end
    end
    CLOSED_MONEY = 0
  end   
  
  if event == "MERCHANT_CLOSED" and JDME_OPENBAG then
    JDME_OPENBAG = nil
    CLOSED_MONEY = GetMoney()
    if CLOSED_MONEY > 0 and START_MONEY > 0 and CLOSED_MONEY > START_MONEY then    
      DEFAULT_CHAT_FRAME:AddMessage(prefix .. " Вы получили " .. JDME_FormatMoney((CLOSED_MONEY - START_MONEY)))
    end    
  end
end)

local m = CreateFrame("Frame")
m:RegisterEvent("MAIL_SHOW")
m:RegisterEvent("MAIL_CLOSED")
m:RegisterEvent("MAIL_FAILED")
m:SetScript("OnEvent", function()   
  if event == "MAIL_SHOW" then
    MAIL_IS_OPENER = true
  end
  if event == "MAIL_CLOSED" then
    MAIL_IS_OPENER = nil
  end
end)

function JDME_ShowAllSaveValues()
  GreySellXml:SetText(JDME_GetTitleValue(JDME_GREY_AUTOSELL))
  RecipeSellXml:SetText(JDME_GetTitleValue(JDME_RECIPES_AUTOSELL))
end

function JDME_Hundler() 
  message(tostring(self) .. ", " .. tostring(motion))
end

function JDME_SaleListBuild(self) 
  f, _, _ = GameFontNormal:GetFont() 
  local countForSale = table.getn(JDME_SALE_LIST)  
  for x=0, countForSale do 
    if JDME_SALE_LIST[x+1] then
      local rowItemFrame = "ItemFrame" .. (x + 1)
      local iframe = CreateFrame("Frame", rowItemFrame, self)
      iframe:SetWidth(200)
      iframe:SetHeight(20)
      iframe:SetPoint("TOPLEFT", self, 50, x*-15)
      iframe:EnableMouse(true) 
      iframe:SetID(x+1)  
      iframe:SetScript("OnEnter", function() 
        JDME_SaleListToolTip(JDME_SALE_LIST[this:GetID()], this)  
      end)  
      
      iframe:SetScript("OnLeave", function() 
        GameTooltip:Hide()
      end)  
      
      iframe:SetScript("OnMouseDown", function()         
          JDME_HandlerDelete(this:GetID(), self)
          JDME_SaleListBuild(ScrollChildFrame) 
      end) 
            
      local rowItem = iframe:CreateFontString("fontStr"..(x+1), "OVERLAY")
      rowItem:SetFont(f, 12)      
      rowItem:SetWidth(0)
      rowItem:SetHeight(20)      
      rowItem:SetText((x+1)  .. ". ".. JDME_SALE_LIST[x+1])
      rowItem:SetTextColor(1, .8, 0)
      rowItem:ClearAllPoints()    
      rowItem:SetPoint("TOPLEFT", self, 50, x*-15) 
    end
  end  
end

function JDME_SaleListToolTip(link, this)   
  local _,_, item = string.find(link, "(item:%d+)")
  GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
  GameTooltip:SetHyperlink(item)
  GameTooltip:Show()
end

function JDME_HandlerDelete(rowId, self)
  local linkItemForDelete = JDME_SALE_LIST[rowId]
  if table.remove(JDME_SALE_LIST, rowId) then
    local iframes = { self:GetChildren() };
    for _, linkItemFrame in ipairs(iframes) do
      linkItemFrame:Hide()      
    end
    DEFAULT_CHAT_FRAME:AddMessage(prefix .. " |cff"..color_after_prefix.."Вы удалили из списка|r ".. linkItemForDelete)
    DEFAULT_CHAT_FRAME:AddMessage(prefix .. " |cff"..color_after_prefix.."Для внесения нового предмета используйте команду: '"..text_help_command.."'|r")
  end  
end

function JDME_HelpButton_OnClick()
  JDME_Help()
end