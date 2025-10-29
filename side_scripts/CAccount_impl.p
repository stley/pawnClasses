#include "classes/CAccount.p"
#include <PawnPlus>
#include <pp-hooks>



#define CLASS_DEFN CAccount

#define CLASS_PUBLIC:%1(%2) \
    forward CAccount_%1(%2); \
    public  CAccount_%1(%2)


static CAccount_Instance[MAX_PLAYERS];
static Pool:objectPoolIndex;
static classInstanceIndex;


CLASS_PUBLIC:CAccount(playerid){
    objectPoolIndex = Pool:amx_call_public(pcPointer, "classConstructor", "d", classInstanceIndex);
    //initialize!
    new Map:objectMap = map_new();
    for(new i; i < _:cAccount; i++){
        map_set(objectMap, i, -1);
    }
    CAccount_Instance[playerid] = pool_add(objectPoolIndex, objectMap);
    return 1;
}

CLASS_PUBLIC:CAccount_(playerid){
    printf("CAccount object destroyed!!");
    pool_remove_deep(objectPoolIndex, CAccount_Instance[playerid]);
    return 1;
}

CLASS_PUBLIC:getMoney(playerid){
    if(pool_has(objectPoolIndex, CAccount_Instance[playerid])){
        new Map:obj = Map:pool_get(objectPoolIndex, CAccount_Instance[playerid]);
        return map_get(obj, uMoney);
    }
    return 0;
}

CLASS_PUBLIC:setMoney(playerid, money){
    if(pool_has(objectPoolIndex, CAccount_Instance[playerid])){
        new Map:obj = Map:pool_get(objectPoolIndex, CAccount_Instance[playerid]);
        map_set(obj, uMoney, money);
        return 1;
    }
    return 0;
}

CLASS_PUBLIC:set(playerid, index, value){
    if(pool_has(objectPoolIndex, CAccount_Instance[playerid])){
        new Map:obj = Map:pool_get(objectPoolIndex, CAccount_Instance[playerid]);
        map_set(obj, index, value);
        return 1;
    }
    return 0;
}

CLASS_PUBLIC:get(playerid, index){
    if(pool_has(objectPoolIndex, CAccount_Instance[playerid])){
        new Map:obj = Map:pool_get(objectPoolIndex, CAccount_Instance[playerid]);
        return map_get(obj, index);
    }
    return 0;
}

hook pcRegisterClasses(){
    printf("Registering CAccount...");
    new List:publicsToExport = list_new();
    for(new i; i < amx_num_publics(); i++){
        new String:pub_name = amx_public_name_s(i);
        if(str_find(pub_name, str_new(#CLASS_DEFN))){
            str_acquire(pub_name);
            list_add(publicsToExport, pub_name);
        }
    }
    amx_call_public(pcPointer, "classRegister", "dsdd", _:amx_this(), #CLASS_DEFN, _:publicsToExport, 0);
}
#undef CLASS_DEFN