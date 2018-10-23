class UISquadSelect_Listener_ISL extends UIScreenListener;

function OnInit(UIScreen screen)
{
	local ISL_Settings settings;
	
	settings = new class'ISL_Settings';

	if(settings.InstantRoomTransitions)
	{
		class'ISL_Helpers'.static.RemoveRemoteEvent('PreM_GoToSoldier', settings.DebugLogging);
	}
}


defaultproperties
{
	ScreenClass = UISquadSelect
}
