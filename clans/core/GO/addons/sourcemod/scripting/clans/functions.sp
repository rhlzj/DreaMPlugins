	//=============================== CLANS КЛАНЫ ===============================//

/**
 * Check if clan is valid
 *
 * @param int clanid - clan's id
 * 
 * @return true - clan is valid, false - otherwise
 */
bool IsClanValid(int clanid)
{
	SQL_LockDatabase(g_hClansDB);
	char query[150];
	FormatEx(query, sizeof(query), "SELECT 1 FROM `clans_table` WHERE `clan_id` = '%d'", clanid);
	DBResultSet rSet = SQL_Query(g_hClansDB, query);
	SQL_UnlockDatabase(g_hClansDB);
	if(rSet != null && rSet.FetchRow())
	{
		delete rSet;
		return true;
	}
	delete rSet;
	return false;
}

/**
 * Получить имя клана
 *
 * @param int clanid - айди клана
 * @param char[] buffer - буффер, куда сохранять имя
 * @param int maxlength - размер буффера 
 */
void GetClanName(int clanid, char[] buffer, int maxlength)
{
	if(clanid != -1)
	{
		SQL_LockDatabase(g_hClansDB);
		char query[150];
		FormatEx(query, sizeof(query), "SELECT `clan_name` FROM `clans_table` WHERE `clan_id` = '%d'", clanid);
		DBResultSet rSet = SQL_Query(g_hClansDB, query);
		SQL_UnlockDatabase(g_hClansDB);
		if(rSet != null && rSet.FetchRow())
		{
			rSet.FetchString(0, buffer, maxlength);
		}
		delete rSet;
	}
}

/**
 * Установить имя клана
 *
 * @param int clanid - айди клана
 * @param char[] name - новое имя клана
 *
 * @return true - успешное переименование, false - имя занято
 */
bool SetClanName(int clanid, char[] name)
{
	char clanNameEscaped[MAX_CLAN_NAME*2+1];
	if(!g_hClansDB.Escape(name, clanNameEscaped, sizeof(clanNameEscaped)))
	{
		LogError("[CLANS] Failed to escape clanName in SetClanName!");
		return false;
	}
	SQL_LockDatabase(g_hClansDB);
	char query[150],
		 prevClanName[MAX_CLAN_NAME];
	FormatEx(query, sizeof(query), "SELECT 1 FROM `clans_table` WHERE `clan_name` = '%s'", clanNameEscaped);
	DBResultSet rSet = SQL_Query(g_hClansDB, query);
	SQL_UnlockDatabase(g_hClansDB);
	if(rSet != null && rSet.RowCount > 0)
	{
		delete rSet;
		return false;
	}
	GetClanName(clanid, prevClanName, sizeof(prevClanName));
	FormatEx(query, sizeof(query), "UPDATE `clans_table` SET `clan_name` = '%s' WHERE `clan_id` = '%d'", clanNameEscaped, clanid);
	g_hClansDB.Query(DB_LogError, query, 3);
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !strcmp(g_sClientData[i][CLIENT_CLANNAME], prevClanName))
		{
			FormatEx(g_sClientData[i][CLIENT_CLANNAME], MAX_NAME_LENGTH, "%s", name);
		}
	}
	UpdatePlayersClanTag();
	delete rSet;
	return true;
}

/**
 * Get number of clan's coins
 *
 * @param int clanid - clan's id
 * 
 * @return number of clan's coins
 */
int GetClanCoins(int clanid)
{
	SQL_LockDatabase(g_hClansDB);
	int coins = -1;
	char query[150];
	FormatEx(query, sizeof(query), "SELECT `clan_coins` FROM `clans_table` WHERE `clan_id` = '%d'", clanid);
	DBResultSet rSet = SQL_Query(g_hClansDB, query);
	SQL_UnlockDatabase(g_hClansDB);
	if(rSet != null && rSet.FetchRow())
	{
		coins = rSet.FetchInt(0);
	}
	delete rSet;
	return coins;
}

/**
 * Give coins to clan
 *
 * @param int clanid - clan's id
 * @param int coins - coint to be given
 * @param bool givenByAdmin - flag if admin gave coins to clan
 * 
 * @noretun
 */
void GiveClanCoins(int clanid, int coins, bool givenByAdmin)
{
	F_OnClanCoinsGive(clanid, coins, givenByAdmin);
	DB_ChangeClanCoins(clanid, coins);
}

/**
 * Set number of clan's coins
 *
 * @param int clanid - clan's id
 * @param int coins - number of coins to set
 * 
 * @return true - success, false - failed
 */
bool SetClanCoins(int clanid, int coins)
{
	return DB_SetClanCoins(clanid, coins);
}

/**
 * Get number of clan's kills
 *
 * @param int clanid - clan's id
 * 
 * @return number of clan's kills
 */
int GetClanKills(int clanid)
{
	SQL_LockDatabase(g_hClansDB);
	int kills = -1;
	char query[150];
	FormatEx(query, sizeof(query), "SELECT `clan_kills` FROM `clans_table` WHERE `clan_id` = '%d'", clanid);
	DBResultSet rSet = SQL_Query(g_hClansDB, query);
	SQL_UnlockDatabase(g_hClansDB);
	if(rSet != null && rSet.FetchRow())
	{
		kills = rSet.FetchInt(0);
	}
	delete rSet;
	return kills;
}

/**
 * Set number of clan's kills
 *
 * @param int clanid - clan's id
 * @param int kills - number of kills to set
 * 
 * @return true - success, false - failed
 */
bool SetClanKills(int clanid, int kills)
{
	return DB_SetClanKills(clanid, kills);
}

/**
 * Get number of clan's deaths
 *
 * @param int clanid - clan's id
 * 
 * @return number of clan's deaths
 */
int GetClanDeaths(int clanid)
{
	SQL_LockDatabase(g_hClansDB);
	int deaths = -1;
	char query[150];
	FormatEx(query, sizeof(query), "SELECT `clan_deaths` FROM `clans_table` WHERE `clan_id` = '%d'", clanid);
	DBResultSet rSet = SQL_Query(g_hClansDB, query);
	SQL_UnlockDatabase(g_hClansDB);
	if(rSet != null && rSet.FetchRow())
	{
		deaths = rSet.FetchInt(0);
	}
	delete rSet;
	return deaths;
}

/**
 * Set number of clan's deaths
 *
 * @param int clanid - clan's id
 * @param int deaths - number of deaths to set
 * 
 * @return true - success, false - failed
 */
bool SetClanDeaths(int clanid, int deaths)
{
	return DB_SetClanDeaths(clanid, deaths);
}

/**
 * Get number of members in clan
 *
 * @param int clanid - clan's id
 * 
 * @return number of members in clan
 */
int GetClanMembers(int clanid)
{
	SQL_LockDatabase(g_hClansDB);
	int members = 0;
	char query[150];
	FormatEx(query, sizeof(query), "SELECT 1 FROM `players_table` WHERE `player_clanid` = '%d'", clanid);
	DBResultSet rSet = SQL_Query(g_hClansDB, query);
	SQL_UnlockDatabase(g_hClansDB);
	if(rSet != null && rSet.FetchRow())
	{
		members = rSet.RowCount;
	}
	delete rSet;
	return members;
}

/**
 * Get maximum number of members in clan
 *
 * @param int clanid - clan's id
 * 
 * @return maximum number of members in clan
 */
int GetClanMaxMembers(int clanid)
{
	SQL_LockDatabase(g_hClansDB);
	int members = -1;
	char query[150];
	FormatEx(query, sizeof(query), "SELECT `maxmembers` FROM `clans_table` WHERE `clan_id` = '%d'", clanid);
	DBResultSet rSet = SQL_Query(g_hClansDB, query);
	SQL_UnlockDatabase(g_hClansDB);
	if(rSet != null && rSet.FetchRow())
	{
		members = rSet.FetchInt(0);
	}
	delete rSet;
	return members;
}

/**
 * Set maximum number of members in clan
 *
 * @param int clanid - clan's id
 * @param int maxMembers - maximum number of members in clan to set
 * 
 * @return true - success, false - failed
 */
bool SetClanMaxMembers(int clanid, int maxMembers)
{
	return DB_SetClanMaxMembers(clanid, maxMembers);
}

/**
 * Get clan type
 *
 * @param int clanid - clan's id
 * 
 * @return 0 - closed clan, 1 - open clan, -1 - clan is invalid
 */
int GetClanType(int clanid)
{
	SQL_LockDatabase(g_hClansDB);
	int type = -1;
	char query[150];
	FormatEx(query, sizeof(query), "SELECT `clan_type` FROM `clans_table` WHERE `clan_id` = '%d'", clanid);
	DBResultSet rSet = SQL_Query(g_hClansDB, query);
	SQL_UnlockDatabase(g_hClansDB);
	if(rSet != null && rSet.FetchRow())
	{
		type = rSet.FetchInt(0);
	}
	delete rSet;
	return type;
}

/**
 * Set clan type
 *
 * @param int clanid - clan's id
 * @param int type - 0 - closed clan, 1 - open clan
 * 
 * @return true - success, false - failed
 */
bool SetClanType(int clanid, int type)
{
	if(type < CLAN_CLOSED || type > CLAN_OPEN)
		return false;
	return DB_SetClanType(clanid, type);
}

/**
 *
 * Create clan with online leader
 *
 * @param int leader - leader's id
 * @param char[] clanName - clan's name
 * @param int createdBy - who create a clan (if leader create it by himself/herself createdBy is -1, otherwise - id of administator)
 */
void CreateClan(int leader, char[] clanName, int createdBy = -1)
{
	if(leader == createdBy)
		createdBy = -1;
	DB_CreateClan(leader, clanName, createdBy);
	UpdateLastClanCreationTime(leader);
}

/**
 * Reset clan by it's id
 *
 * @param int clanid - clan's id
 *
 * @return true - success, false - failed
 */
bool ResetClan(int clanid)
{
	if(!IsClanValid(clanid))
		return false;
	DB_ResetClan(clanid);
	return true;
}

/*
 * Удаление клана по айди
 *
 * @param int clanid - айди клана
 */
void DeleteClan(int clanid)
{
	char clanName[MAX_CLAN_NAME];
	GetClanName(clanid, clanName, sizeof(clanName));
	DB_DeleteClan(clanid);
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !strcmp(g_sClientData[i][CLIENT_CLANNAME], clanName))
		{
			ClearClientData(i);
			F_OnClientDeleted(playerID[i], clanid);
		}
	}
	
	F_OnClanDeleted(clanid);
}

	//=============================== CLIENTS ===============================//
/**
 * Очистить данные игрока
 *
 * @param int client - айди игрока
 */
void ClearClientData(int client)
{
	if(client && client <= MaxClients)
	{
		ClanClient = -1;
		g_sClientData[client][CLIENT_CLANNAME] = "";
		if(!g_bCSS34 && IsClientInGame(client) && WantToChangeTag(client))
			CS_SetClientClanTag(client, "");
	}
}

/**
 * Update all online players' clan tag
 */
void UpdatePlayersClanTag()
{
	for(int i = 1; i <= MaxClients; ++i)
		if(IsClientInGame(i))
			UpdatePlayerClanTag(i);
}

/**
 * Update online player's clan tag
 *
 * @param int client - player's id
 */
void UpdatePlayerClanTag(int client)
{	
	if(ClanClient != -1 && WantToChangeTag(client))
	{
		if(g_iClientData[client][CLIENT_ROLE] == CLIENT_LEADER)
		{
			char leaderTag[16];
			FormatEx(leaderTag, sizeof(leaderTag), "♦ %s", g_sClientData[client][CLIENT_CLANNAME]);
			CS_SetClientClanTag(client, leaderTag);
		}
		else
		{
			CS_SetClientClanTag(client, g_sClientData[client][CLIENT_CLANNAME]);
		}
	}
	else if(WantToChangeTag(client))
	{
		CS_SetClientClanTag(client, "");
	}
}

void ClanTagCallback(Handle owner, Handle hndl, const char[] error, int client)	//хе, ну а че не
{
	if(hndl == INVALID_HANDLE)
	{
		LogError("[CLANS] Query Fail load client's role: %s;", error);
	}
	else if(SQL_FetchRow(hndl))
	{
		int role = SQL_FetchInt(hndl, 0);
		if(role == CLIENT_LEADER)
		{
			char leaderTag[16];
			FormatEx(leaderTag, sizeof(leaderTag), "♦ %s", g_sClientData[client][CLIENT_CLANNAME]);
			CS_SetClientClanTag(client, leaderTag);
		}
		else
		{
			CS_SetClientClanTag(client, g_sClientData[client][CLIENT_CLANNAME]);
		}
	}
	else
	{
		CS_SetClientClanTag(client, "");
	}
}

/**
 * Get online client's id in database
 *
 * @param int client - player's id
 *
 * @return client's id in database
 */
int GetClientIDinDB(int client)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client))
		return -1;
	return ClanClient;
}

/**
 * Get client's id in database by his/her steam
 *
 * @param char[] auth - player's steam
 *
 * @return client's id in database
 */
int GetClientIDinDBbySteam(char[] auth)
{
	char playerAuth[33];
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			GetClientAuthId(i, AuthId_Steam3, playerAuth, sizeof(playerAuth));
			if(!strcmp(playerAuth, auth))
				return playerID[i];
		}
	}
	SQL_LockDatabase(g_hClansDB);
	int clientID = -1;
	char query[150];
	FormatEx(query, sizeof(query), "SELECT `player_id` FROM `players_table` WHERE `player_steam` = '%s'", auth);
	DBResultSet rSet = SQL_Query(g_hClansDB, query);
	SQL_UnlockDatabase(g_hClansDB);
	if(rSet != null && rSet.FetchRow())
	{
		clientID = rSet.FetchInt(0);
	}
	delete rSet;
	return clientID;
}

/**
 * Get client's name by client's id in database
 *
 * @param int clientID - client's id in database
 * @param char[] buffer - buffer to contain the name
 * @param int maxlength - buffer's size
 */
void GetClientNameByID(int clientID, char[] buffer, int maxlength)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(playerID[i] == clientID)
		{
			GetClientName(i, buffer, maxlength);
			return;
		}
	}
	SQL_LockDatabase(g_hClansDB);
	char query[150];
	FormatEx(query, sizeof(query), "SELECT `player_name` FROM `players_table` WHERE `player_id` = '%d'", clientID);
	DBResultSet rSet = SQL_Query(g_hClansDB, query);
	SQL_UnlockDatabase(g_hClansDB);
	if(rSet != null && rSet.FetchRow())
	{
		rSet.FetchString(0, buffer, maxlength);
	}
	delete rSet;
}

/**
 * Check if online player in clan
 *
 * @param int client - player's id
 *
 * @return true - player in any clan, false otherwise
 */
bool IsClientInClan(int client)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) || ClanClient < 0)
	//if(client < 1 || client > MaxClients || !IsClientInGame(client))
		return false;
	return true; //Если что то будет не так, то тут было: strcmp(g_sClientData[client][CLIENT_CLANNAME], "") == 0;
	//return strcmp(g_sClientData[client][CLIENT_CLANNAME], "") != 0;
}

/**
 * Check if player in clan
 *
 * @param int clientID - player's id in database
 *
 * @return true - player in any clan, false otherwise
 */
bool IsClientInClanByID(int clientID)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(playerID[i] == clientID)
			return IsClientInClan(i);
	}
	SQL_LockDatabase(g_hClansDB);
	char query[150];
	FormatEx(query, sizeof(query), "SELECT 1 FROM `players_table` WHERE `player_id` = '%d'", clientID);
	DBResultSet rSet = SQL_Query(g_hClansDB, query);
	SQL_UnlockDatabase(g_hClansDB);
	if(rSet != null && rSet.FetchRow())
	{
		delete rSet;
		return true;
	}
	delete rSet;
	return false;
}


/**
 * Get client's clan id in database by client's id
 *
 * @param int clientID - player's id in database
 *
 * @return client's clan id
 */
int GetClientClanByID(int clientID)
{
	if(clientID < 0)
		return -1;
	SQL_LockDatabase(g_hClansDB);
	int clanid = -1;
	char query[150];
	FormatEx(query, sizeof(query), "SELECT `player_clanid` FROM `players_table` WHERE `player_id` = '%d'", clientID);
	DBResultSet rSet = SQL_Query(g_hClansDB, query);
	SQL_UnlockDatabase(g_hClansDB);
	if(rSet != null && rSet.FetchRow())
	{
		clanid = rSet.FetchInt(0);
	}
	delete rSet;
	return clanid;
}

/**
 * Check if players in different clans
 *
 * @param int client - player's id
 *
 * @param int other - other player's id
 *
 * @return true - players in different clans, otherwise - false
 */
bool AreClientsInDifferentClans(int client, int other)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) || other < 1 || other > MaxClients || !IsClientInGame(other))
		return true;
	return strcmp(g_sClientData[client][CLIENT_CLANNAME], g_sClientData[other][CLIENT_CLANNAME]) != 0;
}

/**
 * Поставить нового лидера в клане по айди игрока в базе данных
 * Проверять, что игрок состоит в этом клане!
 *
 * @param int leaderid - айди нового лидера в базе данных
 * @param int clanid - айди клана
 */
void SetClanLeaderByID(int leaderid, int clanid)
{
	SetClientRoleByID(leaderid, CLIENT_LEADER);
}

/**
 * Get player's role by his/her id
 *
 * @param int clientID - player's id in database
 *
 * @return player's role
*/
int GetClientRoleByID(int clientID)
{
	if(clientID < 0)
		return -1;
	/*for(int i = 1; i <= MaxClients; i++)
	{
		if(playerID[i] == clientID)
			return g_iClientData[i][CLIENT_ROLE];
	}*/
	SQL_LockDatabase(g_hClansDB);
	int role = -1;
	char query[150];
	FormatEx(query, sizeof(query), "SELECT `player_role` FROM `players_table` WHERE `player_id` = '%d'", clientID);
	DBResultSet rSet = SQL_Query(g_hClansDB, query);
	SQL_UnlockDatabase(g_hClansDB);
	if(rSet != null && rSet.FetchRow())
	{
		role = rSet.FetchInt(0);
	}
	delete rSet;
	return role;
}

/**
 * Check if player is clan leader by id
 *
 * @param int clientID - player's id in database
 *
 * @return true - player is clan leader, otherwise - false
 */
bool IsClientClanLeaderByID(int clientID)
{
	return GetClientRoleByID(clientID) == CLIENT_LEADER;
}

/**
 * Check if player is clan co-leader by id
 *
 * @param int clientID - player's id
 *
 * @return true - player is clan co-leader, otherwise - false
 */
bool IsClientClanCoLeaderByID(int clientID)
{
	return GetClientRoleByID(clientID) == CLIENT_COLEADER;
}

/**
 * Check if player is clan elder by id
 *
 * @param int clientID - player's id in database
 *
 * @return true - player is clan elder, otherwise - false
 */
bool IsClientClanElderByID(int clientID)
{
	return GetClientRoleByID(clientID) == CLIENT_ELDER;
}

/**
 * Set player's role by id
 *
 * @param int clientID - player's id in database
 * @param int newRole - new role of the player
 *
 * @return true if succeed, false otherwise
*/
bool SetClientRoleByID(int clientID, int newRole)
{
	if(newRole < CLIENT_MEMBER || newRole > CLIENT_LEADER || clientID < 0)
		return false;
	DB_SetClientRole(clientID, newRole);
	for(int i = 1; i <= MaxClients; i++)
	{
		if(playerID[i] == clientID)
			g_iClientData[i][CLIENT_ROLE] = newRole;
	}
	return true;
}

/**
 * Get client's kills in current clan by client's id
 *
 * @param int clientID - client's id in database
 *
 * @return number of client's kills
 */
int GetClientKillsInClanByID(int clientID)
{
	if(clientID < 0)
		return -1;
	SQL_LockDatabase(g_hClansDB);
	char query[150];
	FormatEx(query, sizeof(query), "SELECT `player_kills` FROM `players_table` WHERE `player_id` = '%d'", clientID);
	DBResultSet rSet = SQL_Query(g_hClansDB, query);
	SQL_UnlockDatabase(g_hClansDB);
	if(rSet != null && rSet.FetchRow())
	{
		return rSet.FetchInt(0);
	}
	delete rSet;
	return -1;
}

/**
 * Set client kills in clan by client's id
 *
 * @param int clientID - client's id in database
 *
 * @param int kills - player's kills to set
 *
 * @return true - success, false - failed
 */
bool SetClientKillsInClanByID(int clientID, int kills)
{
	if(clientID < 0)
		return false;
	int clanid = GetClientClanByID(clientID);
	if(clanid == -1)
		return false;
	int killsNow = GetClientKillsInClanByID(clientID);
	int killsToAddToClan = kills - killsNow;
	DB_SetClientKills(clientID, kills);
	DB_ChangeClanKills(clanid, killsToAddToClan);
	return true;
}

/**
 * Изменение числа убийств игрока
 *
 * @param int clientID - айди игрока в БД
 * @param int amountToAdd - число, на сколько изменить число убийств
 *
 * @return true - success, false - failed
 */
bool ChangeClientKillsInClanByID(int clientID, int amountToAdd)
{
	if(clientID < 0)
		return false;
	char query[200];
	/*FormatEx(query, sizeof(query), "UPDATE `players_table` SET `player_kills` = `player_kills`+'%d' WHERE `player_id` = '%d'", amountToAdd, clientID);
	g_hClansDB.Query(DB_ClientError, query, 1);
	FormatEx(query, sizeof(query), "SELECT `player_clanid` FROM `players_table` WHERE `player_id` = '%d'", clientID);
	g_hClansDB.Query(DB_ChangeClientKillsInClan, query, amountToAdd);*/
	
	Transaction txn = SQL_CreateTransaction();
	FormatEx(query, sizeof(query), "UPDATE `players_table` SET `player_kills` = `player_kills`+'%d' WHERE `player_id` = '%d'", amountToAdd, clientID);
	txn.AddQuery(query);
	FormatEx(query, sizeof(query), "UPDATE `clans_table` SET `clans_kills` = `clans_kills` + '%d' WHERE `clan_id` = (SELECT `player_clanid` FROM `players_table` WHERE `player_id` = '%d')", amountToAdd, clientID);
	txn.AddQuery(query);
	SQL_ExecuteTransaction(g_hClansDB, txn);
	return true;
}

/**
 * Get client's deaths in current clan by client's id
 *
 * @param int clientID - client's id in database
 *
 * @return number of client's deaths
 */
int GetClientDeathsInClanByID(int clientID)
{
	if(clientID < 0)
		return -1;
	SQL_LockDatabase(g_hClansDB);
	char query[150];
	FormatEx(query, sizeof(query), "SELECT `player_deaths` FROM `players_table` WHERE `player_id` = '%d'", clientID);
	DBResultSet rSet = SQL_Query(g_hClansDB, query);
	SQL_UnlockDatabase(g_hClansDB);
	if(rSet != null && rSet.FetchRow())
	{
		return rSet.FetchInt(0);
	}
	delete rSet;
	return -1;
}
/**
 * Set client's deaths in current clan by client's id
 *
 * @param int clientID - player's id in database
 *
 * @param int deaths - client's deaths to set
 *
 * @return true - success, false - failed
 */
bool SetClientDeathsInClanByID(int clientID, int deaths)
{
	if(clientID < 0)
		return false;
	int clanid = GetClientClanByID(clientID);
	if(clanid == -1)
		return false;
	int deathsNow = GetClientDeathsInClanByID(clientID);
	int deathsToAddToClan = deaths - deathsNow;
	DB_SetClientDeaths(clientID, deaths);
	DB_ChangeClanDeaths(clanid, deathsToAddToClan);
	return true;
}

/**
 * Изменение числа смертей игрока
 *
 * @param int clientID - айди игрока в БД
 * @param int amountToAdd - число, на сколько изменить число смертей
 *
 * @return true - success, false - failed
 */
bool ChangeClientDeathsInClanByID(int clientID, int amountToAdd)
{
	if(clientID < 0)
		return false;
	char query[400];
	/*FormatEx(query, sizeof(query), "UPDATE `players_table` SET `player_deaths` = `player_deaths`+'%d' WHERE `player_id` = '%d'", amountToAdd, clientID);
	g_hClansDB.Query(DB_ClientError, query, 1);
	FormatEx(query, sizeof(query), "SELECT `player_clanid` FROM `players_table` WHERE `player_id` = '%d'", clientID);
	g_hClansDB.Query(DB_ChangeClientDeathsInClan, query, amountToAdd);*/
	
	Transaction txn = SQL_CreateTransaction();
	FormatEx(query, sizeof(query), "UPDATE `players_table` SET `player_deaths` = `player_deaths`+'%d' WHERE `player_id` = '%d'", amountToAdd, clientID);
	txn.AddQuery(query);
	FormatEx(query, sizeof(query), "UPDATE `clans_table` SET `clans_deaths` = `clans_deaths` + '%d' WHERE `clan_id` = (SELECT `player_clanid` FROM `players_table` WHERE `player_id` = '%d')", amountToAdd, clientID);
	txn.AddQuery(query);
	SQL_ExecuteTransaction(g_hClansDB, txn);
	return true;
}

void KillFunc(int attackerID, int victimID, int amount)
{
	Transaction txn = SQL_CreateTransaction();
	char query[400];
	if(victimID != -1)
	{
		FormatEx(query, sizeof(query), "UPDATE `players_table` SET `player_deaths` = `player_deaths`+'%d' WHERE `player_id` = '%d'", amount, victimID);
		txn.AddQuery(query);
		FormatEx(query, sizeof(query), "UPDATE `clans_table` SET `clan_deaths` = `clan_deaths` + '%d' WHERE `clan_id` = (SELECT `player_clanid` FROM `players_table` WHERE `player_id` = '%d')", amount, victimID);
		txn.AddQuery(query);
	}
	if(attackerID != -1)
	{
		FormatEx(query, sizeof(query), "UPDATE `players_table` SET `player_kills` = `player_kills`+'%d' WHERE `player_id` = '%d'", amount, attackerID);
		txn.AddQuery(query);
		FormatEx(query, sizeof(query), "UPDATE `clans_table` SET `clan_kills` = `clan_kills` + '%d' WHERE `clan_id` = (SELECT `player_clanid` FROM `players_table` WHERE `player_id` = '%d')", amount, attackerID);
		txn.AddQuery(query);
	}
	SQL_ExecuteTransaction(g_hClansDB, txn);
}

/**
 * Get clien't time in clan by client's id in database
 *
 * @param int clientID - client's index in database
 *
 * @return client's time in clan. Returns -1 if client isn't in any clan
 */
int GetClientTimeInClanByID(int clientID)
{
	if(clientID < 0)
		return -1;
	SQL_LockDatabase(g_hClansDB);
	int time = -1;
	char query[150];
	FormatEx(query, sizeof(query), "SELECT `player_timejoining` FROM `players_table` WHERE `player_id` = '%d'", clientID);
	DBResultSet rSet = SQL_Query(g_hClansDB, query);
	SQL_UnlockDatabase(g_hClansDB);
	if(rSet != null && rSet.FetchRow())
	{
		time = rSet.FetchInt(0);
	}
	delete rSet;
	return time;
}

/**
 * Get clan client's name by client's id
 *
 * @param int clientID - client's id in database
 * @param char[] buffer - buffer to contain the name
 * @param int maxlength - buffer size
 */
void GetClanClientNameByID(int clientID, char[] buffer, int maxlength)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && playerID[i] == clientID)
		{
			GetClientName(i, buffer, maxlength);
			return;
		}
	}
	if(clientID < 0)
		return;
	SQL_LockDatabase(g_hClansDB);
	char query[150];
	FormatEx(query, sizeof(query), "SELECT `player_name` FROM `players_table` WHERE `player_id` = '%d'", clientID);
	DBResultSet rSet = SQL_Query(g_hClansDB, query);
	SQL_UnlockDatabase(g_hClansDB);
	if(rSet != null && rSet.FetchRow())
	{
		rSet.FetchString(0, buffer, maxlength);
	}
	delete rSet;
}

/**
 * Create online clan client
 *
 * @param int client - client's id
 * @param int clanid - clan's id
 @ @param int role - client's role
 */
void CreateClient(int client, int clanid, int role)
{
	char name[MAX_NAME_LENGTH+1], auth[33];
	ClearClientData(client);
	GetClientName(client, name, sizeof(name));
	GetClientAuthId(client, AuthId_Steam3, auth, sizeof(auth));
	DB_CreateClientByData(name, auth, clanid, role);
	DB_LoadClient(client);
}

/**
 * Reset player's stats in clan by player's id
 *
 * @param int clientID - player's id in database
 */
void ResetClient(int clientID)
{
	DB_ResetClient(clientID);
}

/**
 * Delete client by his/her id in database
 *
 * @param int clientID - player's id in database
 *
 * @return true - success, false - failed
 */
bool DeleteClientByID(int clientID)
{
	if(clientID < 0)
		return false;
	int clanid = GetClientClanByID(clientID);
	int clanMembers = GetClanMembers(clanid);	
	if(clanMembers == 1)	//Если в клане нет никого еще, кроме того, кого удаляют ( лидер кому-то не угодил или сам ливнуть решил :( )
	{
		DeleteClan(clanid);
	}
	else	//Если в клане все же есть еще люди
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(playerID[i] == clientID)
			{
				ClearClientData(i);
			}
		}
		DB_PreDeleteClient(clientID);
		F_OnClientDeleted(clientID, clanid);
	}
	if(!g_bCSS34)
		UpdatePlayersClanTag();
	return true;
}

/**
 * Set client's clan id (only if client is online)
 *
 * @param int client - player's id
 * @param int clanid - clan id
 * @param int role - role of player. 0 - member, 1 - elder, 2 - co-leader, 4 - leader
 *
 * @return true - success, false - failed
 */
bool SetOnlineClientClan(int client, int clanid, int role)	//Переписать
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) || !IsClanValid(clanid))
		return false;
	
	if(IsClientInClan(client))
	{
		DeleteClientByID(ClanClient);
	}
	CreateClient(client, clanid, role);
	return true;
}

/**
 * Check if player has a permission to do smth
 *
 * @param int client - player's id
 * @param int permission - permission id
 * @return true if player has the permission, false otherwise
*/
bool CanPlayerDo(int client, int permission)
{
	if(client < 0 || client > MaxClients)
		return false;
	int role = GetClientRoleByID(ClanClient);
	switch(permission)
	{
		case 1:	//invite
			return g_iRInvitePerm & role > 0;
		case 2: //givecoins
			return g_iRGiveCoinsToClan & role > 0;
		case 3: //expand
			return g_iRExpandClan & role > 0;
		case 4: //kick
			return g_iRKickPlayer & role > 0;
		case 5: //change type
			return g_iRChangeType & role > 0;
		case 6: //change role
			return g_iRChangeRole & role > 0;
		default:
			return false;
	}
}

/**
 * Check if role has a permission to do smth
 *
 * @param int role - role's index
 * @param int permission - permission id
 * @return true if player has the permission, false otherwise
*/
bool CanRoleDo(int role, int permission)
{
	if(role < CLIENT_MEMBER || role > CLIENT_LEADER)
		return false;
	switch(permission)
	{
		case 1:	//invite
			return g_iRInvitePerm & role > 0;
		case 2: //givecoins
			return g_iRGiveCoinsToClan & role > 0;
		case 3: //expand
			return g_iRExpandClan & role > 0;
		case 4: //kick
			return g_iRKickPlayer & role > 0;
		case 5: //change type
			return g_iRChangeType & role > 0;
		case 6: //change role
			return g_iRChangeRole & role > 0;
		default:
			return false;
	}
}

/**
 * Проверка, что игрок может делать хоть что-то
 *
 * @param int client - айди игрока
 *
 * @return true - игрок может делать хоть что-то, false иначе
 * @deprecated since 1.7
 */
bool CanPlayerDoAnything(int client)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client))
		return false;
	int check;
	int role = GetClientRoleByID(ClanClient);
	check = g_iRInvitePerm & role;
	check |= g_iRGiveCoinsToClan & role;
	check |= g_iRExpandClan & role;
	check |= g_iRKickPlayer & role;
	check |= g_iRChangeType & role;
	check |= g_iRChangeRole & role;
	return check > 0;
}

/**
 * Проверка, что роль может делать хоть что-то
 *
 * @param int role - индекс роли
 *
 * @return true - игрок может делать хоть что-то, false иначе
 */
bool CanRoleDoAnything(int role)
{
	if(role < CLIENT_MEMBER || role > CLIENT_LEADER)
		return false;
	int check;
	check = g_iRInvitePerm & role;
	check |= g_iRGiveCoinsToClan & role;
	check |= g_iRExpandClan & role;
	check |= g_iRKickPlayer & role;
	check |= g_iRChangeType & role;
	check |= g_iRChangeRole & role;
	return check > 0;
}

	//=============================== OTHERS ОСТАЛЬНЫЕ ===============================//

/**
 * Converting seconds to time
 *
 * @param int seconds
 * @param char[] buffer - time, format: MONTHS:DAYS:HOURS:MINUTES:SECONDS
 * @param int maxlength - size of buffer
 * @param int client - who will see the time
 */
void SecondsToTime(int seconds, char[] buffer, int maxlength, int client)
{
	int months, days, hours, minutes;
	months = seconds/2678400;
	seconds -= 2678400*months;
	days = seconds/86400;
	seconds -= 86400*days;
	hours = seconds/3600;
	seconds -= 3600*hours;
	minutes = seconds/60;
	seconds -= 60*minutes;
	FormatEx(buffer, maxlength, "%T", "Time", client, months, days, hours, minutes, seconds);
}