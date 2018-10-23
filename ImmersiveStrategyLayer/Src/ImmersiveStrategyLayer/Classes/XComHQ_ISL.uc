class XComHQ_ISL extends XComHQPresentationLayer;

/* 	All changes in this class override are optional and controlled via INI or MCM settings. 
	Vanilla function changes are at the top and helper functions are at the bottom.
	Portions of this code were copied from Blue Raja's excellent Instant Avenger Menus mod.
*/

var private Vector2D DoomEntityLoc; // for doom panning
var protected int TicksTillMap;

//------------------------------begin vanilla function overrides------------------------------

//----------------------------------------------------
// INSTANT ROOM TRANSITIONS
//----------------------------------------------------

//Modified to support instant room transitions
simulated function XComHeadquartersCamera GetCamera()
{
	local XComHeadquartersCamera cam;
	local ISL_Settings settings;
	
	cam = XComHeadquartersCamera(XComHeadquartersController(Owner).PlayerCamera);
    settings = new class'ISL_Settings';
	if(settings.InstantRoomTransitions)
	{
		//[HIGHLANDER] set the free movement interpolation variable
		cam.fFreeMovementInterpTime = 0.01f;
	}
	return cam;
}

//Modified to support InstantRoomTransitions
function UIArmory_MainMenu(StateObjectReference UnitRef, optional name DispEvent, optional name SoldSpawnEvent, optional name NavBackEvent, optional name HideEvent, optional name RemoveEvent, optional bool bInstant = false)
{
    local ISL_Settings settings;
    settings = new class'ISL_Settings';
	if(ScreenStack.IsNotInStack(class'UIArmory_MainMenu'))
		UIArmory_MainMenu(ScreenStack.Push(Spawn(class'UIArmory_MainMenu', self), Get3DMovie())).InitArmory(UnitRef, , SoldSpawnEvent, , HideEvent, RemoveEvent, bInstant || settings.InstantRoomTransitions);
}

//Modified to support InstantRoomTransitions
reliable client function CAMLookAtNamedLocation( string strLocation, optional float fInterpTime = 2, optional bool bSkipBaseViewTransition, optional Vector ForceLocation, optional Rotator ForceRotation )
{
    local ISL_Settings settings;
    settings = new class'ISL_Settings';
	
	//DEBUGGING ONLY. Very verbose. Use with caution
	//`log("CAMLookAtNamedLocation" @ strLocation @ fInterpTime,,'ISL');

	if(settings.InstantRoomTransitions)
	{
		fInterpTime *= 0.001f;
	}
	super.CAMLookAtNamedLocation (strLocation, fInterpTime, bSkipBaseViewTransition, ForceLocation, ForceRotation);
}

//Modified to support InstantRoomTransitions
reliable client function CAMLookAtHQTile( int x, int y, optional float fInterpTime = 2, optional Vector ForceLocation, optional Rotator ForceRotation )
{
    local ISL_Settings settings;
    settings = new class'ISL_Settings';

	if(settings.InstantRoomTransitions)
	{
		fInterpTime *= 0.001f;
	}
	super.CAMLookAtHQTile (x, y, fInterpTime, ForceLocation, ForceRotation);
}


//this is called from X2StrategyElement_DefaultFacilities:SelectFacilityBridge()
//Modified to support InstantRoomTransitions setting
simulated function ClearToFacilityMainMenu(optional bool bInstant = false)
{
	local UIFacilityGrid kScreen;
	local string theTrace;
	local ISL_Settings settings;
	local UIScreen Screen;
	
	settings = new class'ISL_Settings';

	//when transitioning to Geoscape, pop directly to the strategy map, instead of going to the bridge first
	if(settings.InstantRoomTransitions)
	{
		kScreen = UIFacilityGrid(ScreenStack.GetScreen(class'UIFacilityGrid'));
		theTrace = GetScriptTrace();

		m_kFacilityGrid.DeactivateGrid();
		m_kAvengerHUD.FacilityHeader.Hide();
		kScreen.bInstantInterp = true;
			
		//`log("StringIndex of SelectFacilityBridge"@InStr(theTrace, "SelectFacilityBridge"));

		//pop to UIFacilityGrid if we're not going to Geoscape
		if(InStr(theTrace, "SelectFacilityBridge") == INDEX_NONE)
		{
			//`log("Popping to UIFacilityGrid...");
			ScreenStack.PopUntilClass(class'UIFacilityGrid', true);
		}
		else
		{
			Screen = `SCREENSTACK.Screens[0];

			if(!Screen.isA('UIFacilityGrid') && !Screen.bIsPermanent)
			{
				//`log("Non-UIFacilityGrid screen detected! Removing screen...");
				
				//remove the screen instead of popping. Cleaner transition when there are no transition animations
				`SCREENSTACK.Screens.RemoveItem(Screen);
				Screen.Movie.RemoveScreen(Screen);
			}
		}
	}
	else 
	{
		//`log("NO INSTANT TRANSITIONS. Popping to UIFacilityGrid...");
		super.ClearToFacilityMainMenu(bInstant);
	}
}

//----------------------------------------------------
// HOLOGLOBE DISSOLVE ANIMATION
//----------------------------------------------------

simulated function Tick( float DeltaTime )
{
	super.Tick (DeltaTime);
	
	if (TicksTillMap > 0)
	{
		TicksTillMap --;
		if (TicksTillMap <= 1)
		{
			//`log("--------------------------------------------------------------------------------------");
			// -- Put the test `log functions here,
			// if we ever want to figure out why we need to wait 5 ticks before instantly transitioning to the globe
			//`log("--------------------------------------------------------------------------------------");
		}
		if (TicksTillMap == 0)
		{
			OnRemoteEvent ('FinishedTransitionIntoMap');

			// Display event messages next-tick instead of waiting ~1s
			if(!IsTimerActive(nameof(StrategyMap_TriggerGeoscapeEntryEvent)))
			{
				SetTimer(0.01, false, nameof(StrategyMap_TriggerGeoscapeEntryEvent));
			}
		}
	}
}

//Modified to support SkipHologlobeDissolveAnimation setting
function UIEnterStrategyMap(bool bSmoothTransitionFromSideView = false)
{
    local ISL_Settings settings;
    settings = new class'ISL_Settings';

	if(settings.DebugLogging)
	{
		`log("UIEnterStrategyMap SmoothTransition="$bSmoothTransitionFromSideView$" SkipHoloAnimation="$settings.SkipHologlobeDissolveAnimation,,'ISL');
	}
	
	m_bCanPause = false;
	if(!settings.SkipHologlobeDissolveAnimation || !bSmoothTransitionFromSideView)
	{
		if(settings.DebugLogging)
		{
			`log("super.UIEnterStrategyMap() called",,'ISL');
		}
		super.UIEnterStrategyMap(bSmoothTransitionFromSideView);
		return;
	}

	WorldInfo.RemoteEventListeners.AddItem(self);

	// We need at least 5 ticks for it to not break when instantly transitioning
	// Anything less than 5 will cause the issue
	TicksTillMap = 5;
	
	m_kAvengerHUD.ClearResources();
	m_kAvengerHUD.HideEventQueue();
	m_kFacilityGrid.Hide();
	m_kAvengerHUD.Shortcuts.Hide();
	m_kAvengerHUD.ToDoWidget.Hide();
}

//Modified to support SkipHologlobeDissolveAnimation setting
function ExitStrategyMap(bool bSmoothTransitionFromSideView = false)
{
    local ISL_Settings settings;
	settings = new class'ISL_Settings';
	
	if(settings.DebugLogging == true)
	{
		`log("ExitStrategyMap smooth="$bSmoothTransitionFromSideView,,'ISL');
	}

	//if we're not skipping the Hologlobe animation, or if the game is sending the player to a specific room,
	//handle this like vanilla
	if( !settings.SkipHologlobeDissolveAnimation || !bSmoothTransitionFromSideView)
	{
		if(settings.DebugLogging == true)
		{
			`log("super.ExitStrategyMap() called",,'ISL');
		}

		super.ExitStrategyMap(bSmoothTransitionFromSideView);
		return;
	}

	m_kXComStrategyMap.ExitStrategyMap();
	m_bCanPause = false;

	//Normally we'd call OnRemoteEvent('FinishedTransitionFromMap') here
	//However 'FinishedTransitionFromMap' event is wonky, hiding the UI and then showing it again on a timer, 
	//causing all sorts of issues. Avoid that entirely by handling the outcome ourselves
	if (StrategyMap2D != none)
	{
		StrategyMap2D.Hide();
	}

	CAMLookAtNamedLocation("Base", 0.0);

	SetTimer(0.01, false, nameof(StrategyMap_FinishTransitionExit)); //Trick to call private function!  hehehe
}

//----------------------------------------------------
// DOOM EFFECT
//----------------------------------------------------

//Modified to support AvatarPauseMultiplier. Unused if SkipAvatarCameraPan = true
function NonPanClearDoom(bool bPositive)
{
    local ISL_Settings settings;
	local float interpTime;
    settings = new class'ISL_Settings';
	StrategyMap2D.SetUIState(eSMS_Flight);

	if(bPositive)
	{
		StrategyMap2D.StrategyMapHUD.StartDoomRemovedEffect();
		`XSTRATEGYSOUNDMGR.PlaySoundEvent("Doom_DecreaseScreenTear_ON");
	}
	else
	{
		StrategyMap2D.StrategyMapHUD.StartDoomAddedEffect();
		`XSTRATEGYSOUNDMGR.PlaySoundEvent("Doom_IncreasedScreenTear_ON");
	}

	interpTime = 3.0f * GetDoomTimerVisModifiers() * settings.AvatarPauseMultiplier;
	if(settings.DebugLogging)
	{
		`log("NonPanClearDoom() interp time:"@interpTime@"seconds",,'ISL');
	}
	
	SetTimer(interpTime, false, nameof(NoPanClearDoomPt2));
}

//Modified to support AvatarPauseMultiplier. Unused if SkipAvatarCameraPan = true
function NoPanClearDoomPt2()
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersAlien AlienHQ;
	local float interpTime;
    local ISL_Settings settings;

    settings = new class'ISL_Settings';
	History = `XCOMHISTORY;
	AlienHQ = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
	AlienHQ.ClearPendingDoom();

	History = `XCOMHISTORY;
	AlienHQ = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));

	interpTime = 4.0f * settings.AvatarPauseMultiplier * GetDoomTimerVisModifiers();
	if(settings.DebugLogging)
	{
		`log("NoPanClearDoomPt2() interp time:"@interpTime@"seconds",,'ISL');
	}

	if(AlienHQ.PendingDoomData.Length > 0)
	{
		SetTimer(interpTime, false, nameof(NoPanClearDoomPt2));
	}
	else
	{
		SetTimer(interpTime, false, nameof(UnPanDoomFinished));
	}
}

//Removes the camera pan & game pause when the avatar project makes progress
//Fixed bug in Instant Avenger Menus code with interpolation time being too long
function DoomCameraPan(XComGameState_GeoscapeEntity EntityState, bool bPositive, optional bool bFirstFacility = false)
{
    local ISL_Settings settings;
	local float interpTime;
    settings = new class'ISL_Settings';
	
	
	//trigger the doom added/decreased sound effect and animation
	if(bPositive == true)
	{
		StrategyMap2D.StrategyMapHUD.StartDoomRemovedEffect();
		`XSTRATEGYSOUNDMGR.PlaySoundEvent("Doom_DecreaseScreenTear_ON");
	}
	else
	{
		StrategyMap2D.StrategyMapHUD.StartDoomAddedEffect();
		`XSTRATEGYSOUNDMGR.PlaySoundEvent("Doom_IncreasedScreenTear_ON");
	}

	
	if(settings.SkipAvatarCameraPan == true)
	{	
		DoomCameraPanComplete();
	}
	else
	{
		CAMSaveCurrentLocation();
		StrategyMap2D.SetUIState(eSMS_Flight);

		// Stop Scanning
		if(`GAME.GetGeoscape().IsScanning())
		{
			StrategyMap2D.ToggleScan();
		}

		DoomEntityLoc = EntityState.Get2DLocation();

		interpTime = 3.0f * GetDoomTimerVisModifiers() * settings.AvatarPauseMultiplier;
		if(settings.DebugLogging)
		{
			`log("GetDoomTimerVisModifiers: "$GetDoomTimerVisModifiers(),,'ISL');
			`log("DoomCameraPan() interp time:"@interpTime@"seconds",,'ISL');
		}

		if(bFirstFacility == true)
		{
			SetTimer(interpTime, false, nameof(StartFirstFacilityCameraPan));
		}
		else
		{
			SetTimer(interpTime, false, nameof(StartDoomCameraPan));
		}
	}
}

//Modified to support AvatarPauseMultiplier & SkipAvatarCameraPan settings
function StartDoomCameraPan()
{
    local ISL_Settings settings;
	local float interpTime;
    settings = new class'ISL_Settings';
	
	if(settings.SkipAvatarCameraPan == false)
	{
		interpTime = (`HQINTERPTIME + 3.0f * GetDoomTimerVisModifiers()) * settings.AvatarPauseMultiplier;
		if(settings.DebugLogging)
		{
			`log("StartDoomCameraPan() interp time:"@interpTime@"seconds",,'ISL');
		}

		// Pan to the location
		CAMLookAtEarth(DoomEntityLoc, 0.5f, `HQINTERPTIME);
		`XSTRATEGYSOUNDMGR.PlaySoundEvent("Doom_Camera_Whoosh");
		//SetTimer((`HQINTERPTIME + 3.0f*settings.AvatarPauseMultiplier), false, nameof(DoomCameraPanComplete));
		SetTimer((interpTime), false, nameof(DoomCameraPanComplete));
	}
}

//Modified to support AvatarPauseMultiplier setting
function DoomCameraPanComplete()
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersAlien AlienHQ;
    local ISL_Settings settings;
	local float interpTime;
    settings = new class'ISL_Settings';

	History = `XCOMHISTORY;
	AlienHQ = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
	AlienHQ.ClearPendingDoom();

	History = `XCOMHISTORY;
	AlienHQ = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));

	interpTime = 4.0f * GetDoomTimerVisModifiers() * settings.AvatarPauseMultiplier;
	if(settings.DebugLogging)
	{
		`log("DoomCameraPanComplete() interp time:"@interpTime@"seconds",,'ISL');
	}

	if(AlienHQ.PendingDoomData.Length > 0)
	{
		SetTimer(interpTime, false, nameof(DoomCameraPanComplete));
	}
	else
	{
		SetTimer(interpTime, false, nameof(UnpanDoomCamera));
	}
}

//Modified to support AvatarPauseMultiplier and SkipAvatarCameraPan settings
function UnpanDoomCamera()
{
    local ISL_Settings settings;
	local float interpTime;
    settings = new class'ISL_Settings';

	if(settings.SkipAvatarCameraPan == true)
	{
		UnPanDoomFinished();
	}
	else
	{
		interpTime = (`HQINTERPTIME + 3.0f * GetDoomTimerVisModifiers()) * settings.AvatarPauseMultiplier;
		if(settings.DebugLogging)
		{
			`log("UnpanDoomCamera() interp time:"@interpTime@"seconds",,'ISL');
		}

		CAMRestoreSavedLocation();
		`XSTRATEGYSOUNDMGR.PlaySoundEvent("Doom_Camera_Whoosh");
		SetTimer((interpTime), false, nameof(UnPanDoomFinished));
	}
}


//----------------------------------------------------
// POPUP EVENTS REMOVED
//----------------------------------------------------

/*Override the popup handler function from parent XComPresentationLayerBase class to skip user-defined popup alerts
	DynamicPropertySet is a struct defined in X2StrategyGameRulesetDataStructures 
	X2StrategyGameRulesetDataStructures.BuildDynamicPropertySet() is always called before this to assemble the info about the alert
*/

static function QueueDynamicPopup(const out DynamicPropertySet PopupInfo, optional XComGameState NewGameState)
{
	local ISL_Settings settings;
	local bool shouldSkip;
	local int  idx;					//used in for loop below
	local ISL_Timer_Helper timerHelper;
	local XGGeoscape geo;
	
	settings = new class'ISL_Settings';
	geo = `GAME.GetGeoscape();

	if(settings.DebugLogging == true)
	{
		`log("Alert name:"@PopupInfo.SecondaryRoutingKey,,'ISL');
	}

	if(settings.SkipInfoPopups == true)
	{
		shouldSkip = false;
		//Loop through our array of custom UIAlert events to skip.
		for(idx = 0; idx < settings.InfoPopupsToSkip.length; ++idx )
		{
			//Check if the current alert name matches the eAlertName in the popup event
			if(InStr(PopupInfo.SecondaryRoutingKey,settings.InfoPopupsToSkip[idx]) != INDEX_NONE)
			{
				shouldSkip = true;
				break;
			}
		}

		//`log("bDisplayOnGeoscapeIdle="@PopupInfo.bDisplayOnGeoscapeIdle,,'ISL');
		
		if(shouldSkip == true)
		{	
			if(settings.DebugLogging == true)
			{
				`log("Blocked UIAlert: "@PopupInfo.SecondaryRoutingKey,,'ISL');
			}

			//Resume the game by calling the Timer event of a dummy actor. Hack to make SetTimer work in a static function.
			timerHelper = geo.Spawn( class'ISL_Timer_Helper');
			timerHelper.SetTimer(0.2f);	
		}
		else
		{
			super.QueueDynamicPopup(PopupInfo, NewGameState);
		}
	}
	else
	{
		super.QueueDynamicPopup(PopupInfo, NewGameState);
	}
}


//----------------------------------------------------
// SKIP INTRO CINEMATICS
//----------------------------------------------------

function UISoldierIntroCinematic(name SoldierClassName, StateObjectReference SoldierRef, optional bool bNoCallback)
{
	local ISL_Settings settings;
	local string theTrace;
	
	settings = new class'ISL_Settings';
	
	if (settings.SkipClassIntroMovies)
	{
		theTrace = GetScriptTrace();
		//Can't access bFactionRevealSequence (private), so check if stack contains 'BeginFactionRevealSequence'
		if(InStr(theTrace, "FactionReveal") != INDEX_NONE)
		{
			//UISoldierIntroCinematic(ScreenStack.Push(Spawn(class'UISoldierIntroCinematic', self), Get3DMovie())).InitCinematic(SoldierClassName, SoldierRef, UIFactionRevealComplete);
			
			if(settings.DebugLogging == true)
			{
				`log("Skipping Faction class intro cinematic...",,'ISL');
			}
			UIFactionRevealComplete(SoldierRef);
		}
		else if (!bNoCallback)
		{
			//UISoldierIntroCinematic(ScreenStack.Push(Spawn(class'UISoldierIntroCinematic', self), Get3DMovie())).InitCinematic(SoldierClassName, SoldierRef, ShowPromotionUI);
			if(settings.DebugLogging == true)
			{
				`log("Skipping Soldier class intro cinematic...",,'ISL');
			}
			ShowPromotionUI(SoldierRef);
		}
	}
	else
	{
		super.UISoldierIntroCinematic(SoldierClassName, SoldierRef, bNoCallback);
	}
}

function UIArmorIntroCinematic(name StartEventName, name StopEventName, StateObjectReference SoldierRef)
{
	local ISL_Settings settings;
	settings = new class'ISL_Settings';

	if (!settings.SkipArmorIntroMovies)
	{
		super.UIArmorIntroCinematic(StartEventName, StopEventName, SoldierRef);
	}
}


//------------------------------end vanilla function overrides------------------------------

//DEBUGGING ONLY!!!!!!
function HandleDebuggingDelegates()
{
	local delegate<UIScreenStack.CHOnInputDelegate> inputDelegate;
	inputDelegate = DebuggingHotkeys;

	`SCREENSTACK.SubscribeToOnInput(inputDelegate);

}

//DEBUGGING ONLY!!!!!!
function bool DebuggingHotkeys(int iInput, int ActionMask)
{
	if(ActionMask == class'UIUtilities_Input'.const.FXS_ACTION_RELEASE)
	{
		switch(iInput)
		{	
			case class'UIUtilities_Input'.const.FXS_KEY_8:
				class'ISL_Helpers'.static.PrintScreenStack();
				return true;
			default:
				break;
		}
	}

	return false;
}


DefaultProperties
{
	TicksTillMap=0;
}