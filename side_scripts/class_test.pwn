#define FILTERSCRIPT
#include <open.mp>
#include <PawnPlus>
#include <pawnclasses>
#include <pp-hooks>


enum classAccount{
    accSQLID,
    accName[MAX_PLAYER_NAME],
    accMoney,
    accLevel
};
enum classAccountPublics{
    Constructor
};


static classAccount_plInstance[MAX_PLAYERS];
static classAccount_Index;
static Pool:classAccount_objectPool;

public OnFilterScriptInit(){
    print("Class Testing started.");
    regDummyClass();
    return 1;
}
public OnFilterScriptExit(){
    print("Class Testing stopped.");
    return 1;
}

#define CLASS_DEFN  classAccount

#define CLASS_PUBLIC:%1(%2) \
    forward classAccount_%1(%2); \
    public  classAccount_%1(%2)

CLASS_PUBLIC:Constructor(playerid){
    return 1;
}

/*
amxScriptScheme
    Amx:scriptPointer, //AMX instance pointer
    List:exportedClasses //List of exported classes from this AMX instance

classScheme
    Amx:classScript, //AMX instance that registered the class
    String:classTitle, //Name of the class
    List:publicFunctions, //List of publics from the class
    Pool:classObjects //Live object pool

*/
// public classRegister(Amx:scrPointer, const className[], Var:ref_exportedFunctions)
regDummyClass(){
    if(pcPointer){
        new List:publics = list_new();
        new public_name[61];
        printf("%d", amx_num_publics());
        for(new i; i < amx_num_publics(); i++){
            amx_public_name(i, public_name);
            print(public_name);
            new encode[3];
            if(strfind(public_name, #CLASS_DEFN) != -1){
                encode = amx_encode_public(i);
                list_add_arr(publics, encode);
            }
        }
        printf("Count of methods: %d", list_size(publics));
        classAccount_Index = amx_call_public(pcPointer, "classRegister", "dsd", _:amx_this(), #CLASS_DEFN, _:amx_var(publics)); //Where is the class located in the AMX instance class list
    }   
}