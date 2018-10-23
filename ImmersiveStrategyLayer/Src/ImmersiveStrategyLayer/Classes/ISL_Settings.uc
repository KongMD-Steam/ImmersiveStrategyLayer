class ISL_Settings extends Object config(ISL_Settings)
	dependsOn(ISL_Settings_Defaults);

var config int ConfigVersion;

var config float AvatarPauseMultiplier;
var localized string strAvatarPauseMultiplier;
var localized string strAvatarPauseMultiplierTooltip;
var MCM_API_Slider AvatarPauseMultiplier_Slider;

var config bool InstantRoomTransitions;
var localized string strInstantRoomTransitions;
var localized string strInstantRoomTransitionsTooltip;
var MCM_API_Checkbox InstantRoomTransitions_Checkbox;

var config bool SkipHologlobeDissolveAnimation;
var localized string strSkipHologlobeDissolveAnimation;
var localized string strSkipHologlobeDissolveAnimationTooltip;
var MCM_API_Checkbox SkipHologlobeDissolveAnimation_Checkbox;

var config bool SkipAvatarCameraPan;
var localized string strSkipAvatarCameraPan;
var localized string strSkipAvatarCameraPanTooltip;
var MCM_API_Checkbox SkipAvatarCameraPan_Checkbox;

var config bool SkipClassIntroMovies;
var localized string strSkipClassIntroMovies;
var localized string strSkipClassIntroMoviesTooltip;
var MCM_API_Checkbox SkipClassIntroMovies_Checkbox;

var config bool SkipArmorIntroMovies;
var localized string strSkipArmorIntroMovies;
var localized string strSkipArmorIntroMoviesTooltip;
var MCM_API_Checkbox SkipArmorIntroMovies_Checkbox;

var config bool SkipGeoscapeAnimationOnEnter;
var localized string strSkipGeoscapeAnimationOnEnter;
var localized string strSkipGeoscapeAnimationOnEnterTooltip;
var MCM_API_Checkbox SkipGeoscapeAnimationOnEnter_Checkbox;

var config bool SkipInfoPopups;
var localized string strSkipInfoPopups;
var localized string strSkipInfoPopupsTooltip;
var MCM_API_Checkbox SkipInfoPopups_Checkbox;

var config bool DebugLogging;
var localized string strDebugLogging;
var localized string strDebugLoggingTooltip;
var MCM_API_Checkbox DebugLogging_Checkbox;


//settings retrieved only via the ISL_Settings_Defaults.ini. Can't manage arrays in MCM!
var config array<string> InfoPopupsToSkip;


`include(ImmersiveStrategyLayer/Src/ModConfigMenuAPI/MCM_API_Includes.uci)
`include(ImmersiveStrategyLayer/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)
`MCM_CH_VersionChecker(class'ISL_Settings_Defaults'.default.ConfigVersion, ConfigVersion)

event OnInit(UIScreen Screen)
{
    `MCM_API_Register(Screen, ClientModCallback);
	
	// Ensure that the default config is loaded, if necessary
	EnsureConfigExists();
}

function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
    // Build the settings UI
    local MCM_API_SettingsPage page;
    local MCM_API_SettingsGroup group, cinematicsGroup;

    LoadSavedSettings();

    page = ConfigAPI.NewSettingsPage("Immersive Strategy Layer");
    page.SetPageTitle("Immersive Strategy Layer");
    page.SetSaveHandler(SaveButtonClicked);
	Page.EnableResetButton(ResetButtonClicked);

    group = Page.AddGroup('General Changes', "General Changes");
	cinematicsGroup = Page.AddGroup('Cinematic Changes', "Cinematic Changes");
	
	//These slider values fix a bug in Instant Avenger Menus where game would soft lock after takeoff, if value = 0
    AvatarPauseMultiplier_Slider = group.AddSlider('AvatarPauseMultiplier', // Name
      strAvatarPauseMultiplier, // Text
      strAvatarPauseMultiplierTooltip, // Tooltip
      0.01, 1, 0.01, // Min, Max, Step. 
      AvatarPauseMultiplier, // Initial value
      SaveAvatarPauseMultiplier // Save handler
    );
    InstantRoomTransitions_Checkbox = group.AddCheckbox('InstantRoomTransitions', // Name
      strInstantRoomTransitions, // Text
      strInstantRoomTransitionsTooltip, // Tooltip
      InstantRoomTransitions, // Initial value
      SaveInstantRoomTransitions // Save handler
    );
    SkipHologlobeDissolveAnimation_Checkbox = cinematicsGroup.AddCheckbox('SkipHologlobeDissolveAnimation', // Name
      strSkipHologlobeDissolveAnimation, // Text
      strSkipHologlobeDissolveAnimationTooltip, // Tooltip
      SkipHologlobeDissolveAnimation, // Initial value
      SaveSkipHologlobeDissolveAnimation // Save handler
    );
	SkipAvatarCameraPan_Checkbox = group.AddCheckbox('SkipAvatarCameraPan', // Name
      strSkipAvatarCameraPan, // Text
      strSkipAvatarCameraPanTooltip, // Tooltip
      SkipAvatarCameraPan, // Initial value
      SaveSkipAvatarCameraPan // Save handler
    );
	SkipClassIntroMovies_Checkbox = cinematicsGroup.AddCheckbox('SkipClassIntroMovies', // Name
      strSkipClassIntroMovies, // Text
      strSkipClassIntroMoviesTooltip, // Tooltip
      SkipClassIntroMovies, // Initial value
      SaveSkipClassIntroMovies // Save handler
    );
	SkipArmorIntroMovies_Checkbox = cinematicsGroup.AddCheckbox('SkipArmorIntroMovies', // Name
      strSkipArmorIntroMovies, // Text
      strSkipArmorIntroMoviesTooltip, // Tooltip
      SkipArmorIntroMovies, // Initial value
      SaveSkipArmorIntroMovies // Save handler
	);
	SkipGeoscapeAnimationOnEnter_Checkbox = cinematicsGroup.AddCheckbox('SkipGeoscapeAnimationOnEnter', // Name
      strSkipGeoscapeAnimationOnEnter, // Text
      strSkipGeoscapeAnimationOnEnterTooltip, // Tooltip
      SkipGeoscapeAnimationOnEnter, // Initial value
      SaveSkipGeoscapeAnimationOnEnter // Save handler
	);
	SkipInfoPopups_Checkbox = group.AddCheckbox('SkipInfoPopups', // Name
      strSkipInfoPopups, // Text
      strSkipInfoPopupsTooltip, // Tooltip
      SkipInfoPopups, // Initial value
      SaveSkipInfoPopups // Save handler
	);
	DebugLogging_Checkbox = group.AddCheckbox('DebugLogging', // Name
      strDebugLogging, // Text
      strDebugLoggingTooltip, // Tooltip
      DebugLogging, // Initial value
      SaveDebugLogging // Save handler
	);
    page.ShowSettings();
}

`MCM_API_BasicSliderSaveHandler(SaveAvatarPauseMultiplier, AvatarPauseMultiplier)
`MCM_API_BasicCheckboxSaveHandler(SaveInstantRoomTransitions, InstantRoomTransitions)
`MCM_API_BasicCheckboxSaveHandler(SaveSkipHologlobeDissolveAnimation, SkipHologlobeDissolveAnimation)
`MCM_API_BasicCheckboxSaveHandler(SaveSkipAvatarCameraPan, SkipAvatarCameraPan)
`MCM_API_BasicCheckboxSaveHandler(SaveSkipClassIntroMovies, SkipClassIntroMovies)
`MCM_API_BasicCheckboxSaveHandler(SaveSkipArmorIntroMovies, SkipArmorIntroMovies)
`MCM_API_BasicCheckboxSaveHandler(SaveSkipGeoscapeAnimationOnEnter, SkipGeoscapeAnimationOnEnter)
`MCM_API_BasicCheckboxSaveHandler(SaveSkipInfoPopups, SkipInfoPopups)
`MCM_API_BasicCheckboxSaveHandler(SaveDebugLogging, DebugLogging)




function LoadSavedSettings()
{
    AvatarPauseMultiplier = `MCM_CH_GetValue(class'ISL_Settings_Defaults'.default.AvatarPauseMultiplier, AvatarPauseMultiplier);
    InstantRoomTransitions = `MCM_CH_GetValue(class'ISL_Settings_Defaults'.default.InstantRoomTransitions, InstantRoomTransitions);
    SkipHologlobeDissolveAnimation = `MCM_CH_GetValue(class'ISL_Settings_Defaults'.default.SkipHologlobeDissolveAnimation, SkipHologlobeDissolveAnimation);
	SkipAvatarCameraPan = `MCM_CH_GetValue(class'ISL_Settings_Defaults'.default.SkipAvatarCameraPan, SkipAvatarCameraPan);
	SkipClassIntroMovies = `MCM_CH_GetValue(class'ISL_Settings_Defaults'.default.SkipClassIntroMovies, SkipClassIntroMovies);
	SkipArmorIntroMovies = `MCM_CH_GetValue(class'ISL_Settings_Defaults'.default.SkipArmorIntroMovies, SkipArmorIntroMovies);
	SkipGeoscapeAnimationOnEnter = `MCM_CH_GetValue(class'ISL_Settings_Defaults'.default.SkipGeoscapeAnimationOnEnter, SkipGeoscapeAnimationOnEnter);
	SkipInfoPopups = `MCM_CH_GetValue(class'ISL_Settings_Defaults'.default.SkipInfoPopups, SkipInfoPopups);
	DebugLogging = `MCM_CH_GetValue(class'ISL_Settings_Defaults'.default.DebugLogging, DebugLogging);
	
	//get the values not exposed to MCM from the default INI
	InfoPopupsToSkip = class'ISL_Settings_Defaults'.default.InfoPopupsToSkip;
}

function LoadNonMCMSettings()
{
	InfoPopupsToSkip = class'ISL_Settings'.default.InfoPopupsToSkip;

    if(DebugLogging == true)
    {
	    `log("Number of UIAlerts to Skip:"@InfoPopupsToSkip.length,,'ISL');
    }
}

simulated function ResetButtonClicked(MCM_API_SettingsPage Page)
{
	AvatarPauseMultiplier_Slider.SetValue(class'ISL_Settings_Defaults'.default.AvatarPauseMultiplier, true);
	InstantRoomTransitions_Checkbox.SetValue(class'ISL_Settings_Defaults'.default.InstantRoomTransitions, true);
	SkipHologlobeDissolveAnimation_Checkbox.SetValue(class'ISL_Settings_Defaults'.default.SkipHologlobeDissolveAnimation, true);
	SkipAvatarCameraPan_Checkbox.SetValue(class'ISL_Settings_Defaults'.default.SkipAvatarCameraPan, true);
	SkipClassIntroMovies_Checkbox.SetValue(class'ISL_Settings_Defaults'.default.SkipClassIntroMovies, true);
	SkipArmorIntroMovies_Checkbox.SetValue(class'ISL_Settings_Defaults'.default.SkipArmorIntroMovies, true);
	SkipGeoscapeAnimationOnEnter_Checkbox.SetValue(class'ISL_Settings_Defaults'.default.SkipGeoscapeAnimationOnEnter, true);
	SkipInfoPopups_Checkbox.SetValue(class'ISL_Settings_Defaults'.default.SkipInfoPopups, true);
	DebugLogging_Checkbox.SetValue(class'ISL_Settings_Defaults'.default.DebugLogging, true);
}

function SaveButtonClicked(MCM_API_SettingsPage Page)
{
    self.ConfigVersion = `MCM_CH_GetCompositeVersion();
    self.SaveConfig();
}

function EnsureConfigExists()
{
    if(ConfigVersion == 0)
    {
        LoadSavedSettings();
        SaveButtonClicked(none);
    }
	else
	{
		LoadNonMCMSettings();
	}
}
