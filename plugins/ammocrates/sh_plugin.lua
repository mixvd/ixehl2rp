local PLUGIN = PLUGIN

PLUGIN.name = "Ammo Crates"
PLUGIN.author = "eon"
PLUGIN.description = "Adds ammo crates that can be used to refill ammo."

ix.config.Add("ammoCrateInfinite", false, "Whether or not ammo crates should be infinite.", nil, {
    category = "Ammo Crates"
})

ix.config.Add("ammoCrateCooldown", (60 * 10), "On how much time should the ammo crates be refilled.", nil, {
    data = {min = 1, max = 3600},
    category = "Ammo Crates"
})

PLUGIN.ammoTypes = {
    // AMMO TYPE = {"CRATE MODEL", "MAX AMMO FROM CRATE", "AMOUNT OF AMMO TO GIVE TO THE PLAYER PER USE", "ITEM AMMO (OPTIONAL)"}

    ["AR2"] = {"models/items/ammocrate_ar2.mdl", 1000, 30, "ammo_ar2"},
    ["SMG1"] = {"models/items/ammocrate_smg1.mdl", 1000, 90, "ammo_smg1"},
    ["Buckshot"] = {"models/items/ammocrate_buckshot.mdl", 90, 8, "ammo_buckshot"},
    ["Pistol"] = {"models/items/ammocrate_pistol.mdl", 400, 80, "ammo_pistol"},
    ["357"] = {"models/items/ammocrate_pistol.mdl", 400, 6, "ammo_357"},
}

function PLUGIN:CreateCrates()
    for k, v in pairs(PLUGIN.ammoTypes) do
        local ENT = {}

        ENT.Type = "anim"
        ENT.PrintName = k .. " Ammo Crate"
        ENT.Category = "ix: HL2RP - Ammo Crates"
        ENT.Spawnable = true
        ENT.AdminOnly = true
        ENT.PhysgunDisable = true
        ENT.bNoPersist = true

        function ENT:SetupDataTables()
            self:NetworkVar("String", 0, "AmmoType")
            self:NetworkVar("Int", 0, "RemainingAmmo")
        end

        if ( SERVER ) then
            function ENT:Initialize()
                self:SetModel(v[1])
                self:PhysicsInit(SOLID_VPHYSICS)
                self:SetSolid(SOLID_VPHYSICS)
                self:SetUseType(SIMPLE_USE)

                local physObj = self:GetPhysicsObject()

                if ( IsValid(physObj) ) then
                    physObj:Wake()
                end

                self:SetAmmoType(k)
                self:SetRemainingAmmo(v[2])

                local uID = "ix_ammo_crate_" .. string.lower(k) .. "_" .. self:EntIndex() .. "_refill_timer"

                if not ( timer.Exists(uID) ) then
                    timer.Create(uID, ix.config.Get("ammoCrateCooldown", (60 * 10)), 1, function()
                        if not ( IsValid(self) ) then
                            timer.Remove(uID)

                            return
                        end

                        self:SetRemainingAmmo(v[2])
                    end)
                end
            end

            function ENT:Use(ply)
                if not ( ply:GetEyeTrace().Entity == self ) then
                    return 
                end

                local char = ply:GetCharacter()

                if not ( char ) then
                    return
                end

                ply:SetAction("Refilling...", 1)
                ply:DoStaredAction(self, function()
                    if ( ix.config.Get("ammoCrateInfinite", false) ) then
                        if ( v[4] ) then
                            char:GetInventory():Add(v[4])
                        else
                            ply:GiveAmmo(v[3], k, true)
                        end
                    else
                        if ( self:GetRemainingAmmo() <= 0 ) then
                            ply:Notify("This ammo crate doesn't have any remaining ammo!")
                            return
                        end

                        char:GetInventory():Add(v[4])
                        self:SetRemainingAmmo(self:GetRemainingAmmo() - v[3])
                    end
                end, 1, function()
                    ply:SetAction()
                end)
            end
        else
            ENT.PopulateEntityInfo = true

            function ENT:OnPopulateEntityInfo(container)
                local text = container:AddRow("name")
                text:SetImportant()
                text:SetText(self.PrintName)
                text:SizeToContents()

                local desc = container:AddRow("description")
                desc:SetText("An ammunition crate containing " .. k .. " ammo.")
                desc:SizeToContents()

                if not ( ix.config.Get("ammoCrateInfinite", false) ) then
                    local ammo = container:AddRow("ammo")
                    ammo:SetText("Remaining Ammo: " .. self:GetRemainingAmmo())
                    ammo:SetBackgroundColor(Color(175, 130, 0))
                    ammo:SizeToContents()
                end
            end
        end

        scripted_ents.Register(ENT, "ix_ammo_crate_" .. string.lower(k))
    end
end

PLUGIN:CreateCrates()

function PLUGIN:OnReloaded()
    self:CreateCrates()
end

if ( SERVER ) then
    function PLUGIN:CanPlayerSpawnContainer(ply, model, entity)
        if ( entity:GetClass():find("ix_ammo_crate_*") ) then
            return false
        end
    end
end