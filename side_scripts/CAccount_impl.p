#include "classes/CAccount.p"
#include <PawnPlus>
#include <pp-hooks>



#define CLASS_PUBLIC(func, args) \
	forward CLASS_DEFN##::##func args; \
	public CLASS_DEFN##::##func args

static CAccount::Instance[MAX_PLAYERS];
static objectPoolIndex;
static classInstanceIndex;

#define CLASS_DEFN  CAccount

CLASS_PUBLIC(CAccount, (playerid)){
    objectPoolIndex = CallRemoteFunction("classConstructor", "d", classInstanceIndex);
    //initialize!
    new Map:objectMap = map_new();
    for(new i; i < sizeof(CAccount); i++){
        map_set(objectMap, i, -1);
    }
    CAccount::Instance[playerid] = pool_add(objectPoolIndex, objectMap);
    return 1;
}

CLASS_PUBLIC(CAccount_, (playerid)){
    printf("CAccount object destroyed!!");
    pool_remove_deep(objectPoolIndex, CAccount::Instance[playerid]);
    return 1;
}

CLASS_PUBLIC(getMoney, (playerid)){
    if(pool_has(objectPoolIndex, CAccount::Instance[playerid])){
        new Map:obj = pool_get(objectPoolIndex, CAccount::Instance[playerid]);
        return map_get(obj, uMoney);
    }
    else return -10;
}

CLASS_PUBLIC(setMoney, (playerid, money)){
    if(pool_has(objectPoolIndex, CAccount::Instance[playerid])){
        new Map:obj = pool_get(objectPoolIndex, CAccount::Instance[playerid]);
        map_set(obj, uMoney, money);
        return 1;
    }
    return 0;
}


//Class Registration
#if defined FILTERSCRIPT

    hook ret OnFilterScriptInit(&ret){
        new List:publicsToExport = list_new();
        for(new i; i < amx_num_publics(); i++){
            new String:pub_name = amx_public_name_s(i);
            if(str_find(pub_name, str_new(#CLASS_DEFN))){
                str_acquire(pub_name);
                list_add(publicsToExport, pub_name);
            }
        }
        classInstanceIndex = CallRemoteFunction("classRegister", "dsdd", amx_this(), #CLASS_DEFN, _:publicsToExport, 0);
        return 0;
    }
    hook ret OnFilterScriptExit(&ret){
        CallRemoteFunction("classUnregister", "d", classInstanceIndex);
        return 0;
    }
#else
    hook ret OnGameModeInit(&ret){
        for(new i; i < amx_num_publics(); i++){
            new String:pub_name = amx_public_name_s(i);
            if(str_find(pub_name, str_new(#CLASS_DEFN))){
                str_acquire(pub_name);
                list_add(publicsToExport, pub_name);
            }
        }
        classInstanceIndex = CallRemoteFunction("classRegister", "dsdd", amx_this(), #CLASS_DEFN, _:publicsToExport, 0);
        return 0;
    }
    hook ret OnGameModeExit(&ret){
        CallRemoteFunction("classUnregister", "d", classInstanceIndex);
        return 0;
    }
#endif

#undef CLASS_DEFN