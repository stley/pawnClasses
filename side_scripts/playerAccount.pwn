#define FILTERSCRIPT

#include <open.mp>
#undef MAX_PLAYERS
#define MAX_PLAYERS (50)
#include <PawnPlus>
#include <pawnclasses>

#include "CAccount_impl.p"


public OnPlayerConnect(playerid){
    printf("playerid %d connected, creating CAccount object for him...");
    CAccount_CAccount(playerid); //CAccount constructor
    printf("playerid %d has $%d.", CAccount_getMoney(playerid));
    CAccount_setMoney(playerid, 5000);
    printf("playerid %d has $%d.", CAccount_getMoney(playerid));
    new money = CAccount_get(playerid, uMoney);
    printf("playerid %d has $%d.", money);
    CAccount_setMoney(playerid, 5000);
    printf("playerid %d has $%d.", money);
    money = CAccount_get(playerid, uMoney);
    printf("playerid %d has $%d.", money);
    return 1;
}