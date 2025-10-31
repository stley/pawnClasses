//This file will include common functions and maybe variables for PawnPlus extension "PawnClasses"
//https://github.com/stley (1berkeley)

#if defined _pawnclasses_included
    #endinput
#endif
#define _pawnclasses_included
#include <pp-hooks>

new Amx:pcPointer; //pawnClasses.amx pointer

new List:requiredPublics;

pcInit(){
    pcPointer = Amx:CallRemoteFunction("amxPingMe", "");
    if(pcPointer){
        amx_call_public(pcPointer, "amxRegister", "d", _:amx_this());
        requiredPublics = list_new();
    }
}

pcExit(){
    if(pcPointer){
        amx_call_public(pcPointer, "amxUnregister", "d", _:amx_this());
        list_delete(requiredPublics);
    }
}

#if defined FILTERSCRIPT
hook ret OnFilterScriptInit()
#else
hook ret OnGameModeInit()
#endif
{
    pcInit();   
    return 0;
}

#if defined FILTERSCRIPT
hook ret OnFilterScriptExit(&ret)
#else
hook ret OnGameModeExit(&ret)
#endif
{
    pcExit();   
    return 0;
}




stock classRequire(const className[]){
    if(pcPointer)
        amx_call_public(pcPointer, "pC_classRequire", "sd", className, _:amx_var(requiredPublics));
}