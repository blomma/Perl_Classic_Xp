
Perl_Xp_Config = {};
local Perl_Xp_PlayerName = nil;

-- Accessor functions
function Perl_Xp_SetVar( var, val ) Perl_Xp_Config[Perl_Xp_PlayerName][var] = val end
function Perl_Xp_GetVar( var ) return Perl_Xp_Config[Perl_Xp_PlayerName][var] end

-- Default local variables
local Initialized = nil;

-- Loading Function --
function Perl_Xp_OnLoad()
	-- Events
	this:RegisterEvent("PLAYER_XP_UPDATE");
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("UPDATE_EXHAUSTION");

	-- Slash Commands
	SlashCmdList["PERL_XP"] = Perl_Xp_SlashHandler;
	SLASH_PERL_XP1 = "/perlxp";

	if( DEFAULT_CHAT_FRAME ) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Perl Classic Xp Frame loaded successfully.");
	end
end

-- Event Handler Function--
function Perl_Xp_OnEvent( event )
	if( event == "PLAYER_XP_UPDATE" or event == "UPDATE_EXHAUSTION" ) then
		if( Perl_Xp_GetVar( "Visible" ) == 1 ) then
			Perl_Xp_UpdateDisplay();
		end
	elseif( event == "VARIABLES_LOADED" ) then
		Perl_Xp_Initialize();
	elseif( event=="PLAYER_ENTERING_WORLD" ) then
		Perl_Xp_Update_Once();
	end
end

-- Slash Handler Functions --
function Perl_Xp_Get_Cmd_Arg( msg )
    local _, _, cmd, arg = strfind( msg, "(%w+)%s*(%w*)" );
    return cmd, arg;
end

function Perl_Xp_Cmd_Help()
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00   --- Classic Perl Xp Frame ---");
	DEFAULT_CHAT_FRAME:AddMessage("|cffffffff lock |cffffff00- Lock the frame in place.");
	DEFAULT_CHAT_FRAME:AddMessage("|cffffffff unlock |cffffff00- Unlock the frame so it can be moved.");
	DEFAULT_CHAT_FRAME:AddMessage("|cffffffff hide |cffffff00- Hide the frame.");
	DEFAULT_CHAT_FRAME:AddMessage("|cffffffff show |cffffff00- Show the frame.");
	DEFAULT_CHAT_FRAME:AddMessage("|cffffffff scale |cffffff00- Set the scale of the frame.");
	DEFAULT_CHAT_FRAME:AddMessage("|cffffffff transparency |cffffff00- Set the transparency of the frame.");
	DEFAULT_CHAT_FRAME:AddMessage("|cffffffff status |cffffff00- Show the current settings.");
end

function Perl_Xp_Cmd_Transparency( arg )
	local number = tonumber( arg );
	if( number > 0 and number < 101 ) then
		Perl_Xp_Set_Transparency( number );
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Xp Frame transparency is now |cffffffff" .. number  .. "%|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("You need to specify a valid number. (1-100).");
	end
end

function Perl_Xp_Cmd_Scale( arg )
	local number;    
	if( arg == "ui" ) then
        number = floor( UIParent:GetEffectiveScale() * 100 + 0.5 )
	else
		number = tonumber( arg );
    end
    
    if( number > 0 and number < 150 ) then
        Perl_Xp_Set_Scale( number );
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Xp Frame scale is now |cffffffff" .. number  .. "%|cffffff00.");
    else
        DEFAULT_CHAT_FRAME:AddMessage("You need to specify a valid number. (1-149)  You may also do '/perlxp scale ui' to set to the current UI scale.");
	end
end

function Perl_Xp_SlashHandler( msg )
	local cmd, arg = Perl_Xp_Get_Cmd_Arg( msg );
	if( cmd == "unlock" ) then
		Perl_Xp_Toggle_Lock( 0 );
	elseif( cmd == "lock" ) then
		Perl_Xp_Toggle_Lock( 1 );
	elseif( cmd == "hide" ) then
		Perl_Xp_Toggle_Frame( 0 );
	elseif( cmd == "show" ) then
		Perl_Xp_Toggle_Frame( 1 );
	elseif( cmd == "transparency" ) then
		Perl_Xp_Cmd_Transparency( arg );
	elseif( cmd == "scale" ) then
		Perl_Xp_Cmd_Scale( arg );
	elseif( cmd == "status" ) then
		Perl_Xp_Status();
	else
		Perl_Xp_Cmd_Help();
	end		
end

-- Display Update Function --
function Perl_Xp_UpdateDisplay()
	-- set common variables
	local playerxp = UnitXP("player");
	local playerxpmax = UnitXPMax("player");
	local playerxprest = GetXPExhaustion();

	-- Set Statistics
	Perl_Classic_Xp_Frame_Bar:SetMinMaxValues( 0, playerxpmax );
	Perl_Classic_Xp_Frame_Bar_Rest:SetMinMaxValues( 0, playerxpmax );
	Perl_Classic_Xp_Frame_Bar:SetValue( playerxp );

	-- Set xp text
	local xptext = playerxp .. " / " .. playerxpmax;

	if( playerxprest ) then
		xptext = xptext .. " (+" .. (playerxprest) .. ")";
		Perl_Classic_Xp_Frame_Bar:SetStatusBarColor( 0.3, 0.3, 1, 1 );
		Perl_Classic_Xp_Frame_Bar_Rest:SetStatusBarColor( 0.3, 0.3, 1, 0.5 );
		Perl_Classic_Xp_Frame_Bar_Bg:SetStatusBarColor( 0.3, 0.3, 1, 0.25 );
		Perl_Classic_Xp_Frame_Bar_Rest:SetValue( playerxp + playerxprest );
	else
		Perl_Classic_Xp_Frame_Bar:SetStatusBarColor( 0.6, 0, 0.6, 1 );
		Perl_Classic_Xp_Frame_Bar_Rest:SetStatusBarColor( 0.6, 0, 0.6, 0.5 );
		Perl_Classic_Xp_Frame_Bar_Bg:SetStatusBarColor( 0.6, 0, 0.6, 0.25 );
		Perl_Classic_Xp_Frame_Bar_Rest:SetValue( playerxp );
	end

	Perl_Classic_Xp_Frame_Bar_Text:SetText( xptext );
end

-- Config Functions --
function Perl_Xp_Toggle_Lock( value )
	Perl_Xp_SetVar( "Locked", value );
	if( value == 1 ) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Xp frame is now |cfffffffflocked|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Xp frame is now |cffffffffunlocked|cffffff00.");
	end
end

function Perl_Xp_Toggle_Frame( value )
	Perl_Xp_SetVar( "Visible", value );
	if( value == 0 ) then
		Perl_Classic_Xp_Frame:Hide();
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Xp frame is now |cffffffffhidden|cffffff00."); 
	else
		Perl_Xp_Update_Once();
		Perl_Classic_Xp_Frame:Show();
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Xp frame is now |cffffffffshown|cffffff00.");
	end
end

function Perl_Xp_Set_Transparency( number )
	if( number ~= nil ) then
		Perl_Xp_SetVar( "Transparency", ( number / 100 ));
	end
	Perl_Classic_Xp_Frame:SetAlpha( Perl_Xp_GetVar( "Transparency" ));
end

function Perl_Xp_Set_Scale( number )
	local unsavedscale;
	if( number ~= nil ) then
		Perl_Xp_SetVar( "Scale", ( number / 100 ));
	end
	unsavedscale = 1 - UIParent:GetEffectiveScale() + Perl_Xp_GetVar( "Scale" );
	Perl_Classic_Xp_Frame:SetScale( unsavedscale );
end

function Perl_Xp_Status()
	if( Perl_Xp_GetVar( "Locked" ) == 1 ) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Xp Frame is |cfffffffflocked|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Xp Frame is |cffffffffunlocked|cffffff00.");
	end
	
	if( Perl_Xp_GetVar( "Visible" ) == 1 ) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Xp Frame is |cffffffffvisible|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Xp Frame is |cffffffffhidden|cffffff00.");
	end

    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Xp Frame transparency is |cffffffff" .. Perl_Xp_GetVar( "Transparency" ) * 100 .. "%|cffffff00.");
    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Xp Frame scale is |cffffffff" .. floor( Perl_Xp_GetVar( "Scale" ) * 100 + 0.5 ) .. "%|cffffff00.");
end

-- Loading Settings Functions --
function Perl_Xp_New_Config()
	Perl_Xp_Config[Perl_Xp_PlayerName] = {
		["Locked"] = 0,
		["Transparency"] = 1,
		["Scale"] = 1,
		["Visible"] = 1
	};
end

function Perl_Xp_Initialize()
	if( Initialized ) then
		Perl_Xp_Set_Scale();
		return;
	end
    
    Perl_Classic_Xp_Frame:SetBackdropColor( 0, 0, 0, Transparency );
	Perl_Classic_Xp_Frame:SetBackdropBorderColor( 0.5, 0.5, 0.5, 1 );
	Perl_Classic_Xp_Frame:Hide();

	-- Set Player Name
	Perl_Xp_PlayerName = UnitName("player").." of "..GetCVar("realmName");

	if( Perl_Xp_Config[Perl_Xp_PlayerName] == nil ) then
		Perl_Xp_New_Config();
	end

    if( Perl_Xp_GetVar( "Visible" ) == 1 ) then
        Perl_Classic_Xp_Frame:Show();
    end

	Initialized = 1;
end

function Perl_Xp_Update_Once()
	Perl_Xp_Set_Scale();
	Perl_Xp_Set_Transparency();
	Perl_Xp_UpdateDisplay();
end