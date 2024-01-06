local PLUGIN = PLUGIN

function PLUGIN:ShouldDrawCombineHUD()
    if not ( IsValid(localPlayer) ) then
        return false
    end

    local char = localPlayer:GetCharacter()

    if not ( char ) then
        return false
    end

    if not ( localPlayer:Alive() ) then
        return false
    end

    if not ( Schema:IsCombine(localPlayer) ) then
        return false
    end

    if ( localPlayer.CanOverrideView ) then // Helix Thirdperson Plugin Function
        if ( localPlayer:CanOverrideView() ) then
            return false
        end
    end

    return true
end

function PLUGIN:DrawBox(drawData)
    drawData.x = drawData.x or 0
    drawData.y = drawData.y or 0
    drawData.w = drawData.w or 0
    drawData.h = drawData.h or 0
    drawData.rectWidth = drawData.rectWidth or 10
    drawData.rectHeight = drawData.rectHeight or 1

    drawData.rectColor = drawData.rectColor or Color(255, 255, 255)
    drawData.backColor = drawData.backColor or Color(0, 0, 0)

    surface.SetDrawColor(drawData.backColor)
    surface.DrawRect(drawData.x, drawData.y, drawData.w, drawData.h)

    surface.SetDrawColor(drawData.rectColor)
    surface.DrawRect(drawData.x, drawData.y, drawData.rectWidth, drawData.rectHeight)
    surface.DrawRect((drawData.x + drawData.w) - drawData.rectWidth, drawData.y, drawData.rectWidth, drawData.rectHeight)
    surface.DrawRect((drawData.x + drawData.w) - drawData.rectHeight, drawData.y, drawData.rectHeight, drawData.rectHeight)
    surface.DrawRect(drawData.x + drawData.w - drawData.rectHeight, drawData.y, drawData.rectHeight, drawData.rectWidth)
    
    surface.DrawRect(drawData.x, drawData.y, drawData.rectHeight, drawData.rectWidth)
    surface.DrawRect(drawData.x, (drawData.y + drawData.h) - drawData.rectWidth, drawData.rectHeight, drawData.rectWidth)
    surface.DrawRect(drawData.x, (drawData.y + drawData.h) - drawData.rectHeight, drawData.rectWidth, drawData.rectHeight)

    surface.DrawRect(drawData.x + drawData.w - drawData.rectWidth, (drawData.y + drawData.h) - drawData.rectHeight, drawData.rectWidth, drawData.rectHeight)
    surface.DrawRect(drawData.x + drawData.w - drawData.rectHeight, (drawData.y + drawData.h) - drawData.rectWidth, drawData.rectHeight, drawData.rectWidth)
end

function PLUGIN:HUDPaint()
    if not ( self:ShouldDrawCombineHUD() ) then
        return
    end

    local padding = ScreenScale(10)
    local x, y = padding, padding
    local code = ix.cmbSystems.cityCodes[ix.cmbSystems:GetCityCode()]

    if ( code ) then
        surface.SetFont("ixCombineFont08")
        local textWidth, textHeight = surface.GetTextSize("<:: City Code : " .. code.name)

        draw.RoundedBox(5, x - 2, y, textWidth + 6, padding * 0.9, Color(30, 20, 25, 225))
        
        self:DrawBox({
            x = x - 2,
            y = y,
            w = textWidth + 6,
            h = padding * 0.9,
            rectColor = Color(255, 255, 255),
            backColor = Color(30, 20, 25, 225)
        })

        draw.SimpleText("<:: City Code : " .. code.name, "ixCombineFont08", x, y, code.color or color_white, TEXT_ALIGN_LEFT)
    end

    for k, v in pairs(ix.cmbSystems.waypoints) do
        local wayPos = v.pos:ToScreen()
        local dist = math.Round(v.pos:Distance(localPlayer:GetPos()) / 16, 1)

        local diff = v.pos - localPlayer:GetShootPos()
        
        if not ( v.drawAlpha ) then
            v.drawAlpha = 255
        end

        if ( localPlayer:GetAimVector():Dot(diff) / diff:Length() >= 0.995 ) then
            v.drawAlpha = Lerp(FrameTime() * 2, v.drawAlpha, 25)
        elseif ( dist <= 40 ) then
            v.drawAlpha = Lerp(FrameTime() * 2, v.drawAlpha, 100)
        else
            v.drawAlpha = Lerp(FrameTime() * 2, v.drawAlpha, 255)
        end

        surface.SetFont("ixCombineFont08")
        textWidth, textHeight = surface.GetTextSize(v.text .. " (" .. dist .. "m)")

        surface.SetDrawColor(ColorAlpha(v.backColor or Color(0, 0, 0), v.drawAlpha))
        surface.DrawRect(wayPos.x - (textWidth / 2), wayPos.y, textWidth, 30)

        surface.SetDrawColor(v.rectColor or Color(0, 100, 255))
        surface.DrawRect(wayPos.x - (textWidth / 2), wayPos.y, textWidth, 1)

        draw.SimpleText(v.text .. " (" .. dist .. "m)", "ixCombineFont08", wayPos.x, wayPos.y, ColorAlpha(v.textColor or color_white, v.drawAlpha), TEXT_ALIGN_CENTER)
        
        // Uncomment this if you want to use sentBy value on the waypoint
        --[[
        surface.SetFont("ixCombineHUDWaypointText")
        textWidth, textHeight = surface.GetTextSize(v.sentBy)

        draw.SimpleText(v.sentBy, "ixCombineHUDWaypointText", wayPos.x, wayPos.y - ScreenScale(9), ColorAlpha(v.textColor or color_white, v.drawAlpha), TEXT_ALIGN_CENTER)
        ]]
    end

    if ( ix.option.Get("combineOverlayAssets", true) ) then
        for k, v in ipairs(player.GetAll()) do
            if not ( IsValid(v) ) then
                continue
            end

            local char = v:GetCharacter()

            if not ( char ) then
                continue
            end

            if not ( v:Alive() ) then
                continue
            end

            if not ( Schema:IsCombine(v) ) then
                continue
            end

            if ( v:GetPos():Distance(localPlayer:GetPos()) > 300 ) then
                continue
            end

            if ( v == localPlayer ) then
                continue
            end

            local vPos = v:GetPos()
            vPos = vPos - v:GetUp() * -50

            if not ( v.displayAlpha ) then
                v.displayAlpha = 255
            end

            local dist = math.Round(vPos:Distance(localPlayer:GetPos()) / 16, 1)

            local diff = vPos - localPlayer:GetShootPos()

            vPos = vPos:ToScreen()


            if ( localPlayer:GetAimVector():Dot(diff) / diff:Length() >= 0.985 ) then
                v.displayAlpha = Lerp(FrameTime() * 2, v.displayAlpha, 125)
            else
                v.displayAlpha = Lerp(FrameTime() * 2, v.displayAlpha, 255)
            end

            surface.SetFont("ixCombineFont08")
            local textWidth, textHeight = surface.GetTextSize(string.upper("<:: " .. v:Name() .. " ::>"))

            surface.SetDrawColor(Color(10, 10, 10, v.displayAlpha))
            surface.DrawRect(vPos.x - (textWidth / 2) - 2, vPos.y, textWidth + 6, padding * 0.9)

            surface.SetDrawColor(ColorAlpha(team.GetColor(v:Team()), v.displayAlpha))
            surface.DrawRect(vPos.x - (textWidth / 2) - 2, vPos.y, 2, padding * 0.9)

            draw.SimpleText(string.upper("<:: " .. v:Name() .. " ::>"), "ixCombineFont08", vPos.x, vPos.y, ColorAlpha(team.GetColor(v:Team()), v.displayAlpha), TEXT_ALIGN_CENTER)

            if not ( Schema:IsCP(v) ) then // Remove this line and the end at line 162 if you want to use classes for CPs
                if ( char:GetClass() ) then
                    surface.SetFont("ixCombineFont08")
                    textWidth, textHeight = surface.GetTextSize("<:: " .. ix.class.list[char:GetClass()].name .. " ::>")

                    vPos.y = vPos.y + padding

                    surface.SetDrawColor(Color(10, 10, 10, v.displayAlpha))
                    surface.DrawRect(vPos.x - (textWidth / 2) - 2, vPos.y, textWidth + 6, padding * 0.9)

                    surface.SetDrawColor(ColorAlpha(team.GetColor(v:Team()), v.displayAlpha))
                    surface.DrawRect(vPos.x - (textWidth / 2) - 2, vPos.y, textWidth + 6, 2)

                    draw.SimpleText("<:: " .. ix.class.list[char:GetClass()].name .. " ::>", "ixCombineFont08", vPos.x, vPos.y, ColorAlpha(team.GetColor(v:Team()), v.displayAlpha), TEXT_ALIGN_CENTER)
                end
            end

            if ( char:GetRank() ) then
                surface.SetFont("ixCombineFont08")
                textWidth, textHeight = surface.GetTextSize("<:: " .. ix.rank.list[char:GetRank()].name .. " ::>")

                vPos.y = vPos.y + padding

                surface.SetDrawColor(Color(10, 10, 10, v.displayAlpha))
                surface.DrawRect(vPos.x - (textWidth / 2) - 2, vPos.y, textWidth + 6, padding * 0.9)

                surface.SetDrawColor(ColorAlpha(team.GetColor(v:Team()), v.displayAlpha))
                surface.DrawRect(vPos.x - (textWidth / 2) - 2, vPos.y, textWidth + 6, 2)

                draw.SimpleText("<:: " .. ix.rank.list[char:GetRank()].name .. " ::>", "ixCombineFont08", vPos.x, vPos.y, ColorAlpha(team.GetColor(v:Team()), v.displayAlpha), TEXT_ALIGN_CENTER)
            end
        end
    end

    local wep = localPlayer:GetActiveWeapon()

    if ( IsValid(wep) ) then
        if ( wep:Clip1() != -1 ) then
            surface.SetFont("ixCombineFont14")
            draw.RoundedBox(5, scrW - padding * 7.5, scrH - padding * 3, padding * 5.4, padding * 2, Color(30, 20, 25, 225))
            
            draw.SimpleText(wep:Clip1(), "ixCombineFont18", scrW - padding * 5.5, scrH - padding * 2.9, color_white, TEXT_ALIGN_RIGHT)

            surface.SetDrawColor(Color(255, 255, 255))
            surface.DrawRect(scrW - padding * 4.5, scrH - padding - 50, 3, padding * 1.6)

            draw.SimpleText(localPlayer:GetAmmoCount(wep:GetPrimaryAmmoType()), "ixCombineFont14", scrW - padding * 4.2, scrH - padding * 2.55, color_white, TEXT_ALIGN_LEFT)
        end
    end
end

local combineOverlayMat = ix.util.GetMaterial("effects/combine_binocoverlay")

function PLUGIN:RenderScreenspaceEffects()
    if not ( IsValid(localPlayer) ) then
        return
    end

    local char = localPlayer:GetCharacter()

    if not ( char ) then
        return
    end

    if not ( Schema:IsCombine(localPlayer) ) then
        return
    end

    if not ( ix.option.Get("combineOverlay", true) ) then
        return
    end

    if ( localPlayer.CanOverrideView ) then // Helix Thirdperson Plugin Function
        if ( localPlayer:CanOverrideView() ) then
            return
        end
    end

    render.UpdateScreenEffectTexture()

    combineOverlayMat:SetFloat("$alpha", 0.4)
    combineOverlayMat:SetInt("$ignorez", 1)

    render.SetMaterial(combineOverlayMat)
    render.DrawScreenQuad()
end

function PLUGIN:SetupOutlines()
    if not ( IsValid(localPlayer) ) then
        return
    end
    
    local char = localPlayer:GetCharacter()

    if not ( char ) then
        return
    end

    if not ( Schema:IsCombine(localPlayer) ) then
        return
    end

    if not ( localPlayer:Alive() ) then
        return
    end

    if ( localPlayer.CanOverrideView ) then // Helix Thirdperson Plugin Function
        if ( localPlayer:CanOverrideView() ) then
            return
        end
    end

    for k, v in ipairs(ents.GetAll()) do
        if not ( IsValid(v) ) then
            continue
        end

        if not ( v:IsNPC() ) then
            continue
        end

        if not ( v:Health() > 0 ) then
            continue
        end

        if not ( Schema:CanSeeEntity(localPlayer, v) ) then
            continue
        end

        if ( ix.relationships.CombineNPCs[v:GetClass()] ) then
            continue
        end

        local outlineColor = hook.Run("GetEntityOutlineColor", v)

        if ( outlineColor == nil ) then
            outlineColor = Color(255, 0, 0)
        end

        ix.outline.Add(v, outlineColor)
    end

    if ( ix.option.Get("combineOutlineAssets", true) ) then
        for k, v in ipairs(player.GetAll()) do
            if not ( IsValid(v) ) then
                continue
            end

            local char = v:GetCharacter()

            if not ( char ) then
                continue
            end

            if not ( v:Alive() ) then
                continue
            end

            if ( ix.option.Get("combineOutlineAssetsTeamOnly", false) ) then
                if not ( v:Team() == localPlayer:Team() ) then
                    continue
                end
            else
                if not ( Schema:IsCombine(v) ) then
                    continue
                end
            end

            if ( v == localPlayer ) then
                continue
            end

            local outlineColor = hook.Run("GetPlayerOutlineColor", v)

            if ( outlineColor == nil ) then
                outlineColor = team.GetColor(v:Team())
            end

            ix.outline.Add(v, outlineColor)
        end
    end

    if ( ix.option.Get("combineOutlineDeployables", true) ) then
        if ( #char:GetData("deployedEntities", {}) > 0 ) then
            for k, v in pairs(char:GetData("deployedEntities", {})) do
                local ent = Entity(v)

                if not ( IsValid(ent) ) then
                    continue
                end

                if not ( ent:IsNPC() or ent:GetClass() == "npc_grenade_frag" ) then
                    continue
                end

                if not ( ent:Health() > 0 or ent:GetClass() == "npc_grenade_frag" ) then
                    continue
                end

                local outlineColor = hook.Run("GetEntityOutlineColor", ent)

                if ( outlineColor == nil ) then
                    outlineColor = ix.faction.Get(localPlayer:Team()).color or Color(200, 200, 200, 200)
                end

                if ( ent:GetClass() == "npc_grenade_frag" ) then
                    outlineColor = Color(255, 0, 0)
                end

                ix.outline.Add(ent, outlineColor, mode, customCheck)
            end
        end
    end
end

net.Receive("ix.MakeWaypoint", function()
    local data = net.ReadTable() or {}

    ix.cmbSystems:MakeWaypoint(data)
end)

net.Receive("ix.cmbSystems.SyncSquads", function()
    local data = net.ReadTable() or {}

    ix.cmbSystems.squads = data
end)