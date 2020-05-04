local AddOn = ...
local vUI, GUI, Language, Assets, Settings = vUIGlobal:get()

local Outlaw = vUI:NewPlugin(AddOn)

if (vUI.UserClass ~= "ROGUE") then
	return
end

local GetTime = GetTime
local FindAuraByName = AuraUtil.FindAuraByName

local Name, Count, Duration, Expiration, _

function Outlaw:OnUpdate(elapsed)
	self.Remaining = self.Remaining - elapsed
	
	self.BuffBar:SetValue(self.Remaining)
	
	if (self.Remaining < 0) then
		self:SetScript("OnUpdate", nil)
	end
end

Outlaw.BuffNames = {
	[1] = GetSpellInfo(193357), -- Ruthless Precision
	[2] = GetSpellInfo(193358), -- Grand Melee
	[3] = GetSpellInfo(193356), -- Broadside
	[4] = GetSpellInfo(199603), -- Skull and Crossbones
	[5] = GetSpellInfo(199600), -- Buried Treasure
	[6] = GetSpellInfo(193359), -- True Bearing
}

Outlaw.TextureMap = {
	[1] = GetSpellTexture(193357),
	[2] = GetSpellTexture(193358),
	[3] = GetSpellTexture(193356),
	[4] = GetSpellTexture(199603),
	[5] = GetSpellTexture(199600),
	[6] = GetSpellTexture(193359),
}

function Outlaw:OnEvent()
	for i = 1, 6 do
		Name, _, Count, _, Duration, Expiration = UnitAuraByName("player", self.BuffNames[i])
		
		if (Name and Expiration) then
			self.RollTheBones[i].Icon:SetDesaturated(false)
			self.RollTheBones[i].Icon:SetAlpha(1)
			
			self.Remaining = Expiration - GetTime()
			self.BuffBar:SetMinMaxValues(0, Duration)
			self.BuffBar:SetValue(self.Remaining)
			self:SetScript("OnUpdate", self.OnUpdate)
		else
			self.RollTheBones[i].Icon:SetDesaturated(true)
			self.RollTheBones[i].Icon:SetAlpha(0.3)
		end
	end
end

local FrameWidth = 236

function Outlaw:CreateBars()
	-- Roll the Bones timer bar
	self.BuffBar = CreateFrame("StatusBar", nil, UIParent)
	self.BuffBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	self.BuffBar:SetStatusBarColor(vUI:HexToRGB("E0392B"))
	self.BuffBar:SetSize(FrameWidth, 10)
	--vUI:SetPoint(self.BuffBar, "CENTER", UIParent, 0, -200)
	self.BuffBar:SetPoint("BOTTOM", vUI.UnitFrames["player"], "TOP", 0, 11)
	self.BuffBar:SetMinMaxValues(0, 1)
	self.BuffBar:SetValue(0)
	
	self.BuffBar.BG = self.BuffBar:CreateTexture(nil, "ARTWORK")
	self.BuffBar.BG:SetAllPoints(self.BuffBar)
	self.BuffBar.BG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	self.BuffBar.BG:SetVertexColor(vUI:HexToRGB("E0392B"))
	self.BuffBar.BG:SetAlpha(0.2)
	
	self.BuffBar.BG2 = self.BuffBar:CreateTexture(nil, "BORDER")
	self.BuffBar.BG2:SetPoint("TOPLEFT", self.BuffBar, -1, 1)
	self.BuffBar.BG2:SetPoint("BOTTOMRIGHT", self.BuffBar, 1, -1)
	self.BuffBar.BG2:SetTexture(Assets:GetTexture("Blank"))
	self.BuffBar.BG2:SetVertexColor(0, 0, 0)
	
	-- Roll the bones icons
	local IconSize = ((FrameWidth - 2) / 6) - 1
	
	self.RollTheBones = CreateFrame("Frame", nil, self)
	self.RollTheBones:SetPoint("BOTTOMLEFT", self.BuffBar, "TOPLEFT", -1, 0)
	self.RollTheBones:SetSize(FrameWidth + 3, IconSize + 2)
	self.RollTheBones:SetBackdrop(vUI.Backdrop)
	self.RollTheBones:SetBackdropColor(0, 0, 0)
	self.RollTheBones:SetBackdropBorderColor(0, 0, 0)
	
	for i = 1, 6 do
		self.RollTheBones[i] = CreateFrame("Frame", nil, self.RollTheBones)
		self.RollTheBones[i]:SetSize(IconSize, IconSize)
		
		self.RollTheBones[i].Icon = self.RollTheBones:CreateTexture(nil, "ARTWORK")
		self.RollTheBones[i].Icon:SetAllPoints(self.RollTheBones[i])
		self.RollTheBones[i].Icon:SetTexture(self.TextureMap[i])
		self.RollTheBones[i].Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		self.RollTheBones[i].Icon:SetDesaturated(true)
		self.RollTheBones[i].Icon:SetAlpha(0.3)
		
		self.RollTheBones[i].BG = self.RollTheBones:CreateTexture(nil, "BORDER")
		self.RollTheBones[i].BG:SetAllPoints(self.RollTheBones[i])
		self.RollTheBones[i].BG:SetTexture(Assets:GetTexture("Blank"))
		self.RollTheBones[i].BG:SetVertexColor(0, 0, 0)
		
		if (i == 1) then
			self.RollTheBones[i]:SetPoint("LEFT", self.RollTheBones, 1, 0)
		else
			self.RollTheBones[i]:SetPoint("TOPLEFT", self.RollTheBones[i-1], "TOPRIGHT", 1, 0)
		end
	end
end

function Outlaw:Load()
	self:CreateBars()
	self:RegisterUnitEvent("UNIT_AURA", "player")
	self:SetScript("OnEvent", self.OnEvent)
end

function Outlaw:Unload()
	self.EnrageBar:Hide()
	self:UnregisterEvent("UNIT_AURA")
end