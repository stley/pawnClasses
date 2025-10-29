#define FILTERSCRIPT
#include <open.mp>
#include <PawnPlus>

forward
    amxRegister(Amx:scrPointer, const name[]);
forward
    amxUnregister(Amx:scrPointer);
forward
    Amx:amxPingMe();    
forward
    classRegister(Amx:scrPointer, const className[], List:exportedFunctions);
forward
    classUnregister(const className[]);
forward
    pCOnAmxRegistered(index, Task:t);
forward
    classConstructor(classInstance);

#define MAX_AMX_SYMBOL  (60) //Max symbol names for Community Pawn Compiler 3.10+

static Pool:amxScriptPool;

enum amxScriptScheme{
    Amx:scriptPointer,
    String:scriptName,
    List:exportedClasses
};
enum classScheme{
    Amx:classScript,
    String:classTitle,
    List:publicFunctions,
    List:publicVars, //if needed, it would be better to use get and set functions.
    Pool:classObjects //Live object pool
};

stock pCOnAmxRegistered(index, Task:t){
    task_set_result(t, pool_has(amxScriptPool, index));
    return 1;
}

stock Task:pcAmxReg(const amxArr[amxScriptScheme]){
    new Task:t = task_new();
    new Map:amxMap = map_new();
    for(new i; i < _:amxScriptScheme; i++){
        map_add(amxMap, i, amxArr[amxScriptScheme:i]);
    }
    pCOnAmxRegistered(pool_add(amxScriptPool, amxMap), t);
    return t;
}


public Amx:amxPingMe(){
    return amx_this();
}


public amxRegister(Amx:scrPointer, const name[]){
    task_yield(1);
    new Data[amxScriptScheme];
    Data[scriptPointer] = scrPointer;
    Data[scriptName] = str_new(name);
    str_acquire(Data[scriptName]);
    Data[exportedClasses] = list_new();
    new Map:amxMap = map_new();
    for(new i; i < _:amxScriptScheme; i++){
        map_add(amxMap, i, Data[amxScriptScheme:i]);
    }
    new idx = pool_add(amxScriptPool, amxMap);
    if(pool_has(amxScriptPool, idx)){
        print_s( str_format("PawnClasses: new AMX registered: %s, with pointer %d.", name, _:scrPointer) );
    }
    else{
        print_s( str_format("PawnClasses: Failed to register new AMX instance with pointer %d an name %s.", _:scrPointer, name) );
    }
    //new res =  task_await( pcAmxReg(Data) );  
    return 1;
}
public amxUnregister(Amx:scrPointer){
    new index;
    if((index = isAmxRegistered(scrPointer)) != -1){
        new Map:amxMap = Map:pool_get(amxScriptPool, index);
        print_s( str_format("PawnClasses: Unloading AMX instance %d, name %S.", map_get(amxMap, scriptPointer), map_get(amxMap, scriptName) ) );
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
            new Map:amxMap;
            if(map_valid(amxMap = pool_get(amxScriptPool, i))){
                new exportedClass = map_get(amxMap, exportedClasses);
                for(new lit; lit < list_size(exportedClass); lit++){
                    new classMap = list_get(exportedClass, lit);
                    if(str_eq(str_new(className), map_get(classMap, classTitle))){
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
public classRegister(Amx:scrPointer, const className[], List:exportedFunctions){ 
    new scriptPoolIndex;
    if( (scriptPoolIndex = isAmxRegistered(scrPointer)) != -1){
        new Map:amxMap = Map:pool_get(amxScriptPool, scriptPoolIndex); //Fetch AMX instance from script pool

        new List:classes = List:map_get(amxMap, exportedClasses); //Get class list from AMX instance Map


        new Map:classMap = map_new(); //Create a new map for classes, to insert into class list
        map_set(classMap, classScript, _:scrPointer);
        
        new String:clsName = str_new(className);
        str_acquire(clsName); //So it persists after this function
        //Class Initialization
        map_set(classMap, classTitle, clsName);
        //If a valid list is specified, it will initialize with that list.
        //Otherwise, create a new list at runtime
        if(list_valid(exportedFunctions))
            map_set(classMap, publicFunctions, exportedFunctions);
        else
            map_set(classMap, publicFunctions, list_new());
        map_set(classMap, classObjects, pool_new());
        //Added class into exportedClass list
        

        printf("PawnClasses: AMX instance %d registered a new class: \"%s\" (count of publics: (methods: %d) )", _:scrPointer, className, list_size(exportedFunctions));
        return list_add(classes, classMap);
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
            }
            else continue;
        }
    }
    return -1;
}

forward classDestructor(classInstance);
public classDestructor(classInstance){

}


public OnFilterScriptInit(){
    amxScriptPool = pool_new();
    printf("PawnClasses started, will register classes from now on.");
    new name[32];
    amx_name(name);
    amxRegister(amx_this(), name);
    return 1;
}

public OnFilterScriptExit(){
    pool_delete_deep(amxScriptPool);
    printf("PawnClasses stopped.");
    return 1;
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
            print_s( str_format("%S - pointer %d | Number of registered classes: %d", map_get(amxMap, scriptName), _:scriptPointer, list_size(List:map_get(amxMap, exportedClasses))) );
        }
    }
    print("\n");
    return 1;
}


