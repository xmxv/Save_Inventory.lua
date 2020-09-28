--[[
Name: return-weapon.lua
By: Kamanoo
///////////////////////////////////////////////////////////////////////////
]]--  

print("+++++++++++++++++++++++++++++")
print("| Return Weapon initialized |")
print("+++++++++++++++++++++++++++++")

kstat = {}
function debugrs(test)
table.insert(kstat, tostring(test))
print("Inserted \"" .. tostring(test) .. "\"")
PrintTable(kstat)
end

hook.Add("PlayerLeft", function (ply)
local psteamid = ply:SteamID64()
local newvalues = {
  [psteamid] = {pos = ply:GetPos(), alive = ply:Alive(), job = ply:Team(), health = ply:Health(), distime = CurTime(), items = {}, valid = ply:IsValid()}
}

for k, v in pairs(ply:GetWeapons()) do
  newvalues[psteamid].items[k] = {v:GetClass(), ply:GetAmmoCount(v:GetPrimaryAmmoType()),
  v:GetPrimaryAmmoType(), ply:GetAmmoCount(v:GetSecondaryAmmoType()), v:GetSecondaryAmmoType(),
  v:Clip1(), v:Clip2()}
end

table.Merge( kstat, newvalues )
print("[Return Weapon] Saved Input for " .. psteamid)
timer.Create( tostring(psteamid .. "_return"), 900, 1, function() 
if checkval(psteamid) then 
 kstat[psteamid] = nil end
end )
end)

hook.Add( "PlayerFirstSpawn", function(ply)
  local psteamid = ply:SteamID64()
  if checkval(psteamid) ~= true then return print("[Return Weapon] Input for " .. psteamid .. " does not exist.") end
  if timer.Exists( psteamid .. "_return") then timer.Remove(psteamid .. "_return") end
  
--[[
Use this to change player's team for example from Citizen on DarkRP to Police officer and then execute the rest of the script.
If your server does not use different jobs but instead uses one base job with different ranks, this may need tweaking to include your rank system.
But you won't need to add the line below in. 
ply:changeTeam(kstat[psteamid].job, true, true)
]]-- 
  timer.Simple(8, function()
  ply:SetPos(kstat[psteamid].pos)

  if kstat[psteamid].alive then 
  ply:SetHealth(kstat[psteamid].health)
  ply.Babygod = nil
  ply:GodDisable()

  for _, v in pairs(kstat[psteamid].items) do
    local wep = ply:Give(v[1])
    ply:RemoveAllAmmo()
    ply:SetAmmo(v[2], v[3], false)
    ply:SetAmmo(v[4], v[5], false)
    if IsValid(wep) then
      wep:SetClip1(v[6])
      wep:SetClip2(v[7])
    end
  end
else
  ply:Kill()
  print("Not Alive")
  end
print("[Return Weapon] Loaded Input for " .. psteamid)
kstat[psteamid] = nil 
  end)
  end)

function checkval (val)
  if kstat[val] then return true
else
  return false
end
end