#define FILTERSCRIPT
#include <open.mp>
#include <PawnPlus>
#include <pawnClasses>


public OnFilterScriptInit(){
    classRequire("classAccount");
    printf("%d", list_size(requiredPublics));
    return 1;
}
public OnFilterScriptExit(){
    return 1;
}