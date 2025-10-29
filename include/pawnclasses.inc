//This file will include common functions and maybe variables for PawnPlus extension "PawnClasses"
//https://github.com/stley (1berkeley)

#if defined _pawnclasses_included
    #endinput
#endif
#define _pawnclasses_included
#include <pp-hooks>

new Amx:pcPointer;


stock pcRegisterClasses(){
    return 1;
}

hook ret OnFilterScriptInit(){
    pcPointer = Amx:CallRemoteFunction("amxPingMe", "");
    new name[32];
    amx_name(name);
    CallRemoteFunction("amxRegister", "ds", amx_this(), name);
    pcRegisterClasses();
    return 0;
}


//Only in cases where the class is not registered from this script.
stock pcResolve(const function[], const fmt[], ...){
    if(pawn_native_exists(function[])){
        return CallLocalFunction(function, fmt, ...);
    }
    return 1;
}