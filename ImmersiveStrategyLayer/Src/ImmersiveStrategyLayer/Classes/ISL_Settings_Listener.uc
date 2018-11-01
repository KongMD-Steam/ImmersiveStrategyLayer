class ISL_Settings_Listener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
    local ISL_Settings settings;

    if (MCM_API(Screen) != none || UIShell(Screen) != none)
    {
        settings = new class'ISL_Settings';
        settings.OnInit(Screen);
    }
    else if(UIFacilityGrid(screen) != none)
	{
        settings = new class'ISL_Settings';
        if(settings.InstantRoomTransitions)
        {
		    UIFacilityGrid(screen).bInstantInterp = true;
        }
	}
}

function OnLoseFocus(UIScreen screen)
{
    local ISL_Settings settings;

	if(UIFacilityGrid(screen) != none)
	{
        settings = new class'ISL_Settings';

		if(settings.InstantRoomTransitions)
        {
		    UIFacilityGrid(screen).bInstantInterp = true;
        }
	}
}

// Fix for never-ending skyranger noise
// Credit to Robojumper: http://steamcommunity.com/sharedfiles/filedetails/?id=868937841
event OnRemoved(UIScreen screen)
{
	if (UIInventory_LootRecovered(screen) != none)	
	{
		class'WorldInfo'.static.GetWorldInfo().PostAkEvent(AkEvent'SoundSkyranger.Stop_Skyranger_Lower_Interior_LP');
	}
}

defaultproperties
{
    ScreenClass = none;
}