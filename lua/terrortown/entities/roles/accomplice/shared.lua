if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_accom.vmt")

	-- if there is TTTC installed: sync classes
	util.AddNetworkString("TTT2AccompliceSyncClasses")
end

function ROLE:PreInitialize()
	self.color = Color(130, 30, 45, 255)

	self.abbr = "accom" -- abbreviation
	self.visibleForTeam = {TEAM_TRAITOR}
	self.surviveBonus = 0.5 -- bonus multiplier for every survive while another player was killed
	self.scoreKillsMultiplier = 16 -- multiplier for kill of player of another team
	self.scoreTeamKillsMultiplier = -5 -- multiplier for teamkill
	self.preventFindCredits = true
	self.preventKillCredits = true
	self.preventTraitorAloneCredits = true
	self.unknownTeam = true -- player does not know their teammates
	self.preventWin = not GetConVar('ttt2_accomplice_win_alone'):GetBool()

	self.defaultEquipment = INNO_EQUIPMENT -- here you can set up your own default equipment
	self.defaultTeam = TEAM_TRAITOR

	self.conVarData = {
		pct = 0.17, -- necessary: percentage of getting this role selected (per player)
		maximum = 1, -- maximum amount of roles in a round
		minPlayers = 8, -- minimum amount of players until this role is able to get selected
		togglable = true, -- option to toggle a role for a client if possible (F1 menu)
		random = 50,
		traitorButton = 1, -- can use traitor buttons
	}
end

local h_TTTCPostReceiveCustomClasses = "TTT2AccompliceCanSeeClasses"

if SERVER then
	local function SendClassesToAccomplice(accomplice)
		if not TTTC then return end

		for _, ply in ipairs(player.GetAll()) do
			if ply ~= accomplice then
				net.Start("TTT2AccompliceSyncClasses")
				net.WriteEntity(ply)
				net.WriteUInt(ply:GetCustomClass() or 0, CLASS_BITS)
				net.Send(accomplice)
			end
		end)

		hook.Add('TTT2TellTraitors', 'TTT2HideTraitorMessageAccomplice', function(tmp, ply)
			if ply:GetSubRole() ~= ROLE_ACCOMPLICE then return end
			return false
		end)

		hook.Add('TTT2AvoidTeamChat', 'TTT2AvoidAccompliceChat', function(sender, team, msg)
			if sender:GetSubRole() ~= ROLE_ACCOMPLICE or GetRoundState() ~= ROUND_ACTIVE then return end
			return false
		end)

if CLIENT then
	net.Receive("TTT2AccompliceSyncClasses", function(len)
		local target = net.ReadEntity()
		local class = net.ReadUInt(CLASS_BITS)

		if class == 0 then
			class = nil
		end

		target:SetClass(class)

		end)
end		
