#include <movementhud>

public Plugin myinfo =
{
	name = "MovementHUD-Module-KZTimer",
	author = "Sikari",
	description = "Provides MovementHUD integration for KZTimer",
	version = "1.0.0",
	url = "https://github.com/Sikarii/MovementHUD-Misc",
};

float gF_TakeoffSpeed[MAXPLAYERS + 1];

public void OnPluginStart()
{
    HookEvent("player_jump", Event_Jump, EventHookMode_Pre);
}

public void OnClientPutInServer(int client)
{
    gF_TakeoffSpeed[client] = 0.0;
}

public void Event_Jump(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));

    gF_TakeoffSpeed[client] = GetSpeed(client);
}

public void MHud_Movement_OnTakeoff(int client, bool didJump, bool &didPerf, float &takeoffSpeed)
{
	if (didJump)
	{
		takeoffSpeed = gF_TakeoffSpeed[client];
	}
}

static float GetSpeed(int client)
{
    float vec[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vec);

    float x = Pow(vec[0], 2.0);
    float y = Pow(vec[1], 2.0);

    return SquareRoot(x + y);
}