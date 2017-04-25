/*
		Qualidade de conexão
	www.brasilmegatrucker.com
	
	Script criado em 11/04/2017
*/

#include <a_samp>
// KB -> MB -> GB
#define KB  1024        // 2 ^ 10
#define MB  1048576     // 2 ^ 20
#define GB  1073741824  // 2 ^ 30

enum pe {
	conPing[4],         // armazena 4 pings
	conPingCount,
	///////////////
	conTimeCheck,
	conProgress
};
new pD[MAX_PLAYERS][pe];


public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print("Qualidade de conexão - V0.1");
	print("Ultima atualização: 11/04/2017");
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}


public OnPlayerConnect(playerid)
{
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	pD[playerid][conProgress]=pD[playerid][conPingCount]=0;
	for(new i; i < 4; i++) {
	    pD[playerid][conPing][i] = 0;
	}
	return 1;
}


public OnPlayerCommandText(playerid, cmdtext[])
{
	if (strcmp("/minhaconexao", cmdtext, true, 10) == 0)
	{
		if(pD[playerid][conProgress] != 0) return SendClientMessage(playerid, 0xFF0000FF, "Por favor aguarde, estamos obtendo informações sobre sua conexão.");
		SendClientMessage(playerid, 0xFFFF00FF, "Estamos obtendo dados de sua conexão. Aguarde alguns segundos.");
		pD[playerid][conTimeCheck] = SetTimerEx("ChecarConexao", 5000, true, "d", playerid);
		pD[playerid][conProgress]++;
		return 1;
	}
	return 0;
}


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 1;
}

forward ChecarConexao(playerid);
public ChecarConexao(playerid) {
	if(pD[playerid][conProgress] == 0) return KillTimer(pD[playerid][conTimeCheck]);
	if(pD[playerid][conPingCount] < 4) {
		pD[playerid][conPing][pD[playerid][conPingCount]] = GetPlayerPing(playerid);
		pD[playerid][conPingCount]++;
		//printf("[%i] PING %i/%i", playerid, GetPlayerPing(playerid),pD[playerid][conPingCount]);
	}

	if(pD[playerid][conPingCount] >= 4) {
		static connstring[320], IP[16], PingMedio=0, Float:BytesEnviados, Float:BytesRecebidos, TempoConectado[3];
		/////////////////////////////////////////////
		GetPlayerIp(playerid, IP, 16);
		TempoConectado[2] = NetStats_GetConnectedTime(playerid)/1000;
		for(new i; i < 4; i++) {
			PingMedio += pD[playerid][conPing][i];
		}
		// Bytes Enviados
		if(NetStats_BytesSent(playerid) >= GB)
		    BytesEnviados = floatdiv(NetStats_BytesSent(playerid), GB);
		else if(NetStats_BytesSent(playerid) >= MB)
		    BytesEnviados = floatdiv(NetStats_BytesSent(playerid), MB);
		else if(NetStats_BytesSent(playerid) >= KB)
		    BytesEnviados = floatdiv(NetStats_BytesSent(playerid), KB);
		else
		    BytesEnviados = float(NetStats_BytesSent(playerid));

		// Bytes Recebidos
		if(NetStats_BytesReceived(playerid) >= GB)
		    BytesRecebidos = floatdiv(NetStats_BytesReceived(playerid), GB);
		else if(NetStats_BytesReceived(playerid) >= MB)
		    BytesRecebidos = floatdiv(NetStats_BytesReceived(playerid), MB);
		else if(NetStats_BytesReceived(playerid) >= KB)
		    BytesRecebidos = floatdiv(NetStats_BytesReceived(playerid), KB);
		else
		    BytesRecebidos = float(NetStats_BytesReceived(playerid));

		// Tempo conectado
		if(TempoConectado[2] >= 3600) {
			TempoConectado[0] = (TempoConectado[2] / 3600);
			TempoConectado[2] -= (TempoConectado[0] * 3600);
		}
		if(TempoConectado[2] >= 60) {
			TempoConectado[1] = (TempoConectado[2] / 60);
			TempoConectado[2] -= (TempoConectado[1] * 60);
		}
		////////////////////////////////////////////////////////
		format(connstring, sizeof(connstring), "Seu IP:\t%s\nTempo Conectado:\t%ih,%imin,%isec\nPing Atual:\t%ims\nPing Médio:\t%ims\nPing's Obtidos:\t%ims - %ims - %ims - %ims\nPacket Loss:\t%0.0f%%\n\nBytes enviados:\t%0.2f %s\nBytes recebidos:\t%0.2f %s\n",
		    IP, TempoConectado[0], TempoConectado[1], TempoConectado[2], GetPlayerPing(playerid), (PingMedio/4), pD[playerid][conPing][0], pD[playerid][conPing][1], pD[playerid][conPing][2], pD[playerid][conPing][3],NetStats_PacketLossPercent(playerid),
			BytesEnviados,	(NetStats_BytesSent(playerid) >= GB ? ("GB") : (NetStats_BytesSent(playerid) >= MB ? ("MB") : (NetStats_BytesSent(playerid) >= KB ? ("KB") : ("Bytes")))),
			BytesRecebidos, (NetStats_BytesReceived(playerid) >= GB ? ("GB") : (NetStats_BytesReceived(playerid) >= MB ? ("MB") : (NetStats_BytesReceived(playerid) >= KB ? ("KB") : ("Bytes")))));

		ShowPlayerDialog(playerid, 25000, DIALOG_STYLE_TABLIST, "{FFFF00}# {FFFFFF}Status de conexão", connstring, "Fechar", "");
		SendClientMessage(playerid, 0xFFFF00FF, "Informando dados obtidos de sua conexão.");
		// Zerando dados obtidos
		pD[playerid][conProgress]=pD[playerid][conPingCount]=0;
		for(new i; i < 4; i++) {
		    pD[playerid][conPing][i] = 0;
		}
	}
	return 1;
}

/*
	Fim de script
*/
