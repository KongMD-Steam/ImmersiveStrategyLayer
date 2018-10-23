class ISL_Settings_Listener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
    local ISL_Settings settings;

    if (MCM_API(Screen) != none || UIShell(Screen) != none)
    {
        settings = new class'ISL_Settings';
        settings.OnInit(Screen);
    }
}

defaultproperties
{
    ScreenClass = none;
}