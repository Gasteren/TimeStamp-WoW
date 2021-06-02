local frame = CreateFrame('Frame', 'TimeStampFrame')
frame:Hide()

-- Making sure to pull the frame in.
local framePaddingTop = 8
local framePaddingSides = 10
frame:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', framePaddingSides, -framePaddingTop)
frame:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', -framePaddingSides, framePaddingTop)

function createFrameText(inherits)
    local text = frame:CreateFontString(nil, nil, inherits)
    text:SetTextColor(1, 0.8, 0, 1)
    text:SetText('')
    return text
end

-- For additional refresh functions, return true if there was something useful
-- to display. this is used so it doesnt add any gabs if someones NOT in a guild.

function refreshName(text)
    text:SetText(UnitName('player') .. ' - ' .. GetRealmName())
    return true
end

function refreshClass(text)
	text:SetText('The ' .. UnitClass('player'))
	return true
end
-- added a dash instead of "of" because it looked better with crossrealms etc.
function refreshGuild(text)
    local currentGuildName, currentRankName = GetGuildInfo('player')
    if currentGuildName ~= nil then
        text:SetText(currentRankName .. ' of <' .. currentGuildName .. '>')
        return true
    end
    return false
end

function refreshLevel(text)
    local currentPercentXP = floor(UnitXP('player') / UnitXPMax('player') * 100)
    text:SetText('Level: ' .. UnitLevel('player') .. (currentPercentXP > 0 and ' XP: ' .. currentPercentXP .. '%' or ''))
    return true
end

function refreshZone(text)
    local currentZone = GetRealZoneText()
    local _, _, currentInstanceDifficulty = GetInstanceInfo()
    text:SetText(currentZone .. (currentInstanceDifficulty > 0 and ' ' .. GetDifficultyInfo(currentInstanceDifficulty) or ''))
    return true
end

function refreshSubzone(text)
    local currentZone = GetRealZoneText()
    local currentSubzone = GetSubZoneText()
    if currentZone ~= currentSubzone then
        text:SetText(currentSubzone)
        return true
    end
    return false
end

function refreshTimestamp(text)
    text:SetText(date('%B %d, %Y %I:%M%p'))
    return true
end

function refreshXpack(text)
    text:SetText('Legion')
    return true
end

function refreshItemlvl(text)
	text:SetText('Item level: ' .. GetAverageItemLevel('player'))
	return true
end

local textParts = {
    {name="name", text=createFrameText('QuestTitleFont'), refresh=refreshName},
	{name="class", text=createFrameText('QuestFont'), refresh=refreshClass},
    {name="guild", text=createFrameText('QuestFont'), refresh=refreshGuild},
    {name="level", text=createFrameText('QuestFont'), refresh=refreshLevel},
	{name="itemlvl", text=createFrameText('QuestFont'), refresh=refreshItemlvl},
    {name="zone", text=createFrameText('QuestTitleFont'), refresh=refreshZone},
    {name="subzone", text=createFrameText('QuestFont'), refresh=refreshSubzone},
    {name="timestamp", text=createFrameText('QuestFont'), refresh=refreshTimestamp},
	{name="xpack", text=createFrameText('QuestFont'), refresh=refreshXpack}
}

SLASH_TimeStamp1 = '/TimeStamp'
SLASH_TimeStamp2 = '/ts'
SlashCmdList['TimeStamp'] = function()
    UIParent:Hide()

    textParts[1].text:SetPoint('TOPLEFT', frame, 'TOPLEFT', 0, 0)
    textParts[1].refresh(textParts[1].text)
    local lastText = textParts[1].text
    for i = 2, 9 do
        local text = textParts[i].text
        local refresh = textParts[i].refresh
        if refresh(text) then
            -- add a small vertical gap between level and zone to make it look clean enough
            yOffset = 0
            if textParts[i].name == "zone" then
                yOffset = -framePaddingTop
            end
            text:SetPoint('TOPLEFT', lastText, 'BOTTOMLEFT', 0, yOffset)
            lastText = text
        else
            -- End of the alt switching.
            text:SetText(' ')
        end
    end

    frame:Show()
    Screenshot()
end

frame:RegisterEvent('SCREENSHOT_SUCCEEDED')
frame:RegisterEvent('SCREENSHOT_FAILED')
frame:SetScript('OnEvent', function(self, event, ...)
    if event == 'SCREENSHOT_SUCCEEDED' or event == 'SCREENSHOT_FAILED' then
        frame:Hide()
        UIParent:Show()
    end
end)
