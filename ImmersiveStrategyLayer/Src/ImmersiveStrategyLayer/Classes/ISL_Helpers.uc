class ISL_Helpers extends Object config(Game);
	

// Modified from original function PlayerController:InternalRemoteEvent()
static function RemoveRemoteEvent(name EventName, bool sendToLog)
{
	local array<SequenceObject> AllRemoteEvents;
	local SeqEvent_RemoteEvent RemoteEvt;
	local Sequence GameSeq;
	local int Idx;

	if (EventName != '')
	{
		// Get the gameplay sequence.
		GameSeq = class'WorldInfo'.static.GetWorldInfo().GetGameSequence();
		if (GameSeq != None)
		{
			// Find all SeqEvent_Console objects anywhere.
			GameSeq.FindSeqObjectsByClass(class'SeqEvent_RemoteEvent', true, AllRemoteEvents);

			if(sendToLog == true)
			{
				`log("Total RemoteEvents:"@AllRemoteEvents.length,,'ISL');
			}

				// Iterate over them, seeing if the name is the one we typed in.
				for (Idx = 0; Idx < AllRemoteEvents.length; Idx++)
				{
					RemoteEvt = SeqEvent_RemoteEvent(AllRemoteEvents[Idx]);

					//true if the event being triggered matches the current event in the array
					if (RemoteEvt != None && EventName == RemoteEvt.EventName)
					{
						if(sendToLog == true)
						{
							`log("RemoteEvent"@RemoteEvt.EventName@"REMOVED",,'ISL');
						}

						// assign the event a blank event name, which will cause it to not trigger
						RemoteEvt.EventName = '';
					}
				}

		}
		else if(sendToLog == true)
		{
			`log("NO SEQUENCE");
		}
	}

}


static simulated function PrintScreenStack()
{
//`if (`notdefined(FINAL_RELEASE))
	local int i;
	local UIScreen Screen;
	local string inputType;
	local string prefix;
	local UIScreenStack stack;
	
	stack = `SCREENSTACK;

	`log("============================================================");
	`log("---- BEGIN UIScreenStack.PrintScreenStack() -------------");

	`log("");
	
	`log("---- Stack: General Information ----------------");
	`log("Stack.GetCurrentScreen() = " $stack.GetCurrentScreen());
	`log("Stack.IsInputBlocked = " $stack.IsInputBlocked);

	`log("");
	`log("---- stack.Screens[]:  Classes and Instance Names ---");
	for( i = 0; i < stack.Screens.Length; i++)
	{
		Screen = stack.Screens[i];
		if ( Screen == none )
		{
			`log(i $": NONE ");
			continue;
		}
		`log(i $": " $Screen.Class $", " $ Screen);
	}	
	if( stack.Screens.Length == 0)
		`log("Nothing to show because stack.Screens.Length = 0,");
	`log("");
	
	`log("---- Unreal Visibility -----------------------");
	for( i = 0; i < stack.Screens.Length; i++)
	{
		Screen = stack.Screens[i];
		if ( Screen == none )
		{
			`log(i $": NONE ");
			continue;
		}
		`log(i $": " $"bIsVisible = " $Screen.bIsVisible @ Screen);
	}	
	if( stack.Screens.Length == 0)
		`log("Nothing to show because stack.Screens.Length = 0,");
	`log("");

	`log("---- UI Input information --------------------");
	
	prefix = stack.IsInputBlocked ? "INPUT GATED " : "      ";
	for( i = 0; i < stack.Screens.Length; i++)
	{
		Screen = stack.Screens[i];
		if ( Screen == none )
		{
			`log("      " $ "        " $ " " $ i $ ": ?none?");
			continue;
		}

		if( Screen.ConsumesInput() )
		{
			inputType = "CONSUME ";
			prefix = "XXX   ";
		}
		else if( Screen.EvaluatesInput() )
			inputType = "eval    ";
		else
			inputType = "-       ";

		`log(prefix $ inputType $ " " $ i $ ": '" @ Screen.class $ "'");
	}
	if( stack.Screens.Length == 0)
		`log("Nothing to show because stack.Screens.Length = 0,");
	`log("");

	//`log("*** Movie.stack.Screens are what the movie has loaded: **");	
	//stack.Pres.Get2DMovie().PrintCurrentstack.Screens();
	`log("****************************************************");	
	`log("");

	`log("---- END PrintScreenStack --------------------");

	`log("========================================================");
//`endif
}
