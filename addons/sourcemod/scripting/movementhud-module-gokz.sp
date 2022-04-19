#include <gokz/hud>
#include <gokz/core>
#include <movementhud>

TopMenu gTM_Options;
TopMenuObject gTMO_MovementHUD;

public Plugin myinfo =
{
	name = "MovementHUD-Module-GOKZ",
	author = "Sikari",
	description = "Provides MovementHUD integration for GOKZ",
	version = "1.0.0",
	url = "https://github.com/Sikarii/MovementHUD-Misc",
};

public void OnAllPluginsLoaded()
{
    TopMenu gokzTopMenu = GOKZ_GetOptionsTopMenu();
    if (gokzTopMenu != null)
    {
        GOKZ_OnOptionsMenuReady(gokzTopMenu);
    }
}

public void GOKZ_OnOptionsMenuCreated(TopMenu topMenu)
{
    if (gTM_Options == topMenu && gTMO_MovementHUD != INVALID_TOPMENUOBJECT)
	{
		return;
	}

    gTMO_MovementHUD = topMenu.AddCategory("movementhud", TopMenuHandler_MovementHUD);
}

public void GOKZ_OnOptionsMenuReady(TopMenu topMenu)
{
    if (gTMO_MovementHUD == INVALID_TOPMENUOBJECT)
    {
        GOKZ_OnOptionsMenuCreated(topMenu);
    }

    if (gTM_Options == topMenu)
    {
        return;
    }

    gTM_Options = topMenu;
    gTM_Options.AddItem("movementhud_simple", TopMenuHandler_Preferences, gTMO_MovementHUD);
    gTM_Options.AddItem("movementhud_advanced", TopMenuHandler_Preferences, gTMO_MovementHUD);
}

public void TopMenuHandler_MovementHUD(TopMenu topmenu, TopMenuAction action, TopMenuObject topobj_id, int param, char[] buffer, int maxlength)
{
    if (action == TopMenuAction_DisplayOption)
    {
        Format(buffer, maxlength, "MovementHUD");
    }

    if (action == TopMenuAction_DisplayTitle)
    {
        Format(buffer, maxlength, "MovementHUD (!mhud)");
    }
}

public void TopMenuHandler_Preferences(TopMenu topmenu, TopMenuAction action, TopMenuObject topobj_id, int param, char[] buffer, int maxlength)
{
    if (action == TopMenuAction_DisplayOption)
    {
        char name[64];
        topmenu.GetObjName(topobj_id, name, sizeof(name));

        // Skip "movementhud_"
        switch (name[12])
        {
            case 's': Format(buffer, maxlength, "* Simple preferences");
            case 'a': Format(buffer, maxlength, "** Advanced preferences");
        }
    }

    if (action == TopMenuAction_SelectOption)
    {
        char name[64];
        topmenu.GetObjName(topobj_id, name, sizeof(name));

        // Skip "movementhud_"
        switch (name[12])
        {
            case 's': FakeClientCommand(param, "sm_mhud simple");
            case 'a': FakeClientCommand(param, "sm_mhud advanced");
        }
    }
}

public void MHud_Movement_OnTakeoff(int client, bool didJump, bool &didPerf, float &takeoffSpeed)
{
    if (!IsFakeClient(client))
    {
        didPerf = GOKZ_GetHitPerf(client);
        takeoffSpeed = GOKZ_GetTakeoffSpeed(client);
    }
}

public void MHud_OnPreferenceValueSet(int client, char id[MHUD_MAX_ID], char value[MHUD_MAX_VALUE])
{
    if (StrEqual(id, "keys_mode"))
    {
        MHudEnumPreference preference = MHudEnumPreference.Find(id);

        int mode = preference.GetInt(client);
        if (mode != KeysMode_None)
        {
            GOKZ_SetOption(client, gC_HUDOptionNames[HUDOption_ShowKeys], ShowKeys_Disabled);
            PotentiallyDisableInfoPanel(client);
        }
    }

    if (StrEqual(id, "speed_mode"))
    {
        MHudEnumPreference preference = MHudEnumPreference.Find(id);

        int mode = preference.GetInt(client);
        if (mode != SpeedMode_None)
        {
            GOKZ_SetOption(client, gC_HUDOptionNames[HUDOption_SpeedText], SpeedText_Disabled);
            PotentiallyDisableInfoPanel(client);
        }
    }
}

static void PotentiallyDisableInfoPanel(int client)
{
    MHudEnumPreference keysMode = MHudEnumPreference.Find("keys_mode");
    MHudEnumPreference speedMode = MHudEnumPreference.Find("speed_mode");

    int keysModeVal = keysMode.GetInt(client);
    int speedModeVal = speedMode.GetInt(client);

    if (keysModeVal != KeysMode_None && speedModeVal != SpeedMode_None)
    {
        GOKZ_SetOption(client, gC_HUDOptionNames[HUDOption_TimerText], TimerText_TPMenu);
        GOKZ_SetOption(client, gC_HUDOptionNames[HUDOption_InfoPanel], InfoPanel_Disabled);
    }
}
