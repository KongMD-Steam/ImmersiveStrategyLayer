class ISL_Timer_Helper extends Actor;

/*
Thanks a ton to Musashi and Mr. Nice for help implementing this SetTimer hack! This dummy actor allows SetTimer to function when called from a static function.
*/

//static function ResumeGameAfterPopup()
event Timer()
{
	local XComGameState NewGameState;
    local XGGeoscape geo;
    local UIStrategyMap stratMap;
    local XComGameState_HeadquartersXCom hqstate;
	local XComHQPresentationLayer hq;
	local ISL_Settings settings;
	
	settings = new class'ISL_Settings';
	hq = `HQPRES;
	
	//Resume the game if we're on the Geoscape
	if(hq.ScreenStack.IsCurrentClass(class'UIStrategyMap') )
	{
		geo = `GAME.GetGeoscape();
		stratMap = hq.StrategyMap2D;
		hqstate = stratMap.XCOMHQ();
	
		geo.Resume();

		if(settings.DebugLogging == true)
		{
			`log("*************Resuming Game After Popup**************",,'ISL');
		}
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Resuming game...");
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

		//Restart scanning if it was stopped
		if(!geo.IsScanning() && hqstate.IsScanningAllowedAtCurrentLocation())
		{
			if(settings.DebugLogging == true)
			{
				`log("Toggling site scanning...",,'ISL');
			}
			
			//StrategyMap2D.ToggleScan() kludge to avoid the 'scan' sound effect triggering after each blocked UIAlert. A Highlander hook into 
			//ToggleScan() would be a cleaner alternative, but that's overkill.
			
			hqstate.ToggleSiteScanning(true);
			geo.m_fTimeScale = geo.TWELVE_HOURS;
			stratMap.UpdateButtonHelp();
		}
	}

    Destroy();
}
