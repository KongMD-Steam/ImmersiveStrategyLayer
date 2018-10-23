class UIAvengerHUD_Listener_ISL extends UIScreenListener;

function OnInit(UIScreen screen)
{
	local ISL_Settings settings;
	
	settings = new class'ISL_Settings';
	if(settings.SkipGeoscapeAnimationOnEnter)
	{
		class'ISL_Helpers'.static.RemoveRemoteEvent('CIN_PostGeoscapeLoaded', settings.DebugLogging);
	}
}


defaultproperties
{
	ScreenClass = UIAvengerHUD
}
