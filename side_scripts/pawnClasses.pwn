#define FILTERSCRIPT
#include <open.mp>
#include <PawnPlus>

forward
    amxRegister(Amx:scrPointer, const name[]);
forward
    amxUnregister(Amx:scrPointer);
forward
    Amx:amxPingMe(); //Ping from pawnClasses.inc
forward
    classRegister(Amx:scrPointer, const className[], Var:exportedFunctions);
forward
    classUnregister(const className[]);
forward
    pCOnAmxRegistered(index, Task:t);
forward
    classConstructor(classInstance);
forward
    classDestructor(classInstance, theObject);

#define MAX_AMX_SYMBOL  (60) //Max symbol names for Community Pawn Compiler 3.10+

static Pool:amxScriptPool;

enum amxScriptScheme{
    Amx:scriptPointer, //AMX instance pointer
    List:exportedClasses //List of exported classes from this AMX instance
};
enum classScheme{
    Amx:classScript, //AMX instance that registered the class
    String:classTitle, //Name of the class
    List:publicFunctions, //List of publics from the class
    Pool:classObjects //Live object pool
};


public Amx:amxPingMe(){
    return amx_this();
}


public amxRegister(Amx:scrPointer){
    new Map:amxMap = map_new();
    map_add(amxMap, scriptPointer, _:scrPointer);
    map_add(amxMap, exportedClasses, list_new()); 
    new idx = pool_add(amxScriptPool, amxMap);
    if(pool_has(amxScriptPool, idx)){
        print_s( str_format("PawnClasses: new AMX registered with pointer %d.", _:scrPointer) );
    }
    else{
        print_s( str_format("PawnClasses: Failed to register new AMX instance with pointer %d.", _:scrPointer) );
        return 0;
    }
    return 1;
}
public amxUnregister(Amx:scrPointer){
    new index;
    if((index = isAmxRegistered(scrPointer)) != -1){
        new Map:amxMap = Map:pool_get(amxScriptPool, index);
        print_s( str_format("PawnClasses: Unloading AMX instance %d.", map_get(amxMap, scriptPointer)) );
        pool_remove_deep(amxScriptPool, index);
        return 1;
    }
    else printf("Failed to unload AMX instance %d. Maybe it wasn't even registered before.", _:scrPointer);
    return 0;
}



stock isAmxRegistered(Amx:scrPointer){
    for(new i; i < pool_size(amxScriptPool); i++){
        if(pool_has(amxScriptPool, i)){
            new Map:amxMap = Map:pool_get(amxScriptPool, i);
            if(map_valid(amxMap)){
                if(scrPointer == Amx:map_get(amxMap, scriptPointer)){
                    return i;
                }
            }   
        }
    }
    return -1;
}
stock isClassRegistered(const className[]){
    for(new i; i < pool_size(amxScriptPool); i++){
        if(pool_has(amxScriptPool, i)){
            new Map:amxMap = Map:pool_get(amxScriptPool, i);
            if(map_valid(amxMap)){
                new Var:exportedclassesref = Var:map_get(amxMap, exportedClasses);
                new List:exportedClass = List:amx_get(exportedclassesref);
                for(new lit; lit < list_size(exportedClass); lit++){
                    new Map:classMap = Map:list_get(exportedClass, lit);
                    if(str_eq(str_new(className), String:map_get(classMap, classTitle))){
                        return _:classMap;
                    }
                    else continue;
                }
            }   
        }
    }
    return -1; 
}

/* 
Ideally, you would already expose or export both your public methods and variables here.
However, another helper will be available to add singular symbols to an already existent class.
*/
public classRegister(Amx:scrPointer, const className[], Var:exportedFunctions){ 
    new scriptPoolIndex;
    if( (scriptPoolIndex = isAmxRegistered(scrPointer)) != -1){
        new Map:amxMap = Map:pool_get(amxScriptPool, scriptPoolIndex); //Fetch AMX instance from script pool

        new List:classesList = List:map_get(amxMap, exportedClasses); //Get class list from AMX instance Map


        new Map:classMap = map_new(); //Create a new map for classes, to insert into class list
        map_set(classMap, classScript, _:scrPointer);
        
        new String:clsName = str_new(className);
        str_acquire(clsName); //So it persists after this function
        //Class Initialization
        map_set(classMap, classTitle, clsName);
        //If a valid list is specified, it will initialize with that list.
        //Otherwise, create a new list at runtime
        if(list_valid(List:amx_get(exportedFunctions)))
            map_set(classMap, publicFunctions, _:exportedFunctions);
        else
            map_set(classMap, publicFunctions, List:0);
        map_set(classMap, classObjects, pool_new());
        //Added class into exportedClass list
        

        printf("PawnClasses: AMX instance %d registered a new class: \"%s\" (count of publics: (methods: %d) )", _:scrPointer, className, list_size(List:amx_get(exportedFunctions)));
        return list_add(classesList, classMap);
    }
    else{
        printf("PawnClasses: Tried to register a class from an unregistered AMX instance %d, (className: %s).", _:scrPointer, className);
    }
    return 0;
}
public classUnregister(const className[]){
    return 1;
}

//Objects!!




public classConstructor(classInstance){
    for(new i; i < pool_size(amxScriptPool); i++){
        if(pool_has(amxScriptPool, i)){
            new Map:amxMap = Map:pool_get(amxScriptPool, i);
            if(map_valid(amxMap)){
                new List:exportedClass = List:map_get(amxMap, exportedClasses);
                new Map:classMap = Map:list_get(exportedClass, classInstance);
                new objPoolIndex = pool_add(Pool:map_get(classMap, classObjects), 0);
                print_s( str_format("New object for class %S: objectPool %d.", map_get(classMap, classTitle), objPoolIndex) );
                return objPoolIndex;
            }
            else continue;
        }
    }
    return -1;
}


public classDestructor(classInstance, theObject){
    for(new i; i < pool_size(amxScriptPool); i++){
        if(pool_has(amxScriptPool, i)){
            new Map:amxMap = Map:pool_get(amxScriptPool, i);
            if(map_valid(amxMap)){
                new List:exportedClass = List:map_get(amxMap, exportedClasses);
                new Map:classMap = Map:list_get(exportedClass, classInstance);
                new Pool:objectPool = Pool:map_get(classMap, classObjects);
                if(pool_has(objectPool, theObject)){
                    print_s( str_format("Destroyed object for class %S: objectPool %d.", map_get(classMap, classTitle), theObject) );
                    pool_remove_deep(objectPool, theObject);
                    return 1;
                }
            }
            else continue;
        }
    }
    return -1;
}


public OnFilterScriptInit(){
    amxScriptPool = pool_new();
    printf("PawnClasses started, will register classes from now on.");
    return 1;
}

public OnFilterScriptExit(){
    pool_delete_deep(amxScriptPool);
    printf("PawnClasses stopped.");
    return 1;
}


forward pC_classRequire(const className[], Var:locallist_pointer);
public pC_classRequire(const className[], Var:locallist_pointer){
    new List:locallist = List:amx_get(locallist_pointer);
    new Map:classMap = Map:isClassRegistered(className);
    if(classMap != Map:-1){
        for(new i; i < list_size(locallist); i++){
            new List:exported = List:amx_get(Var:map_get(classMap, publicFunctions));
            for(new l; l < list_size(exported); l++){
                new encoded[6];
                list_get_arr(exported, l, encoded);
                new checkid = list_add_arr(locallist, encoded);
                if(checkid == l) printf("ok");
                else printf("ok?");
            }
        }
    }
}


//PawnClasses RCON command processor


#define PCCMD:%0(%1) \
    forward rcon_cmd_%0(%1); \
    public rcon_cmd_%0(%1)

public OnRconCommand(cmd[]){
    new input[32];
    for(new i; i < strlen(cmd); i++){
        if(i == sizeof(input)) break;
        if(cmd[i] == ' ') break;
        input[i] = cmd[i];
    }
    new funcstr[61];
    format(funcstr, sizeof(funcstr), "rcon_cmd_%s", input);
    if(funcidx(funcstr))
        return CallLocalFunction(funcstr, "");
    return 0;
}


PCCMD:amxlist(){
    print("\nAMX Registered Instances:");
    for(new it; it < pool_size(amxScriptPool); it++){
        if(pool_has(amxScriptPool, it)){
            new Map:amxMap = Map:pool_get(amxScriptPool, it);
            print_s( str_format("AMX Instance with pointer %d | Number of registered classes: %d", _:scriptPointer, list_size(List:map_get(amxMap, exportedClasses))) );
        }
    }
    print("\n");
    return 1;
}
