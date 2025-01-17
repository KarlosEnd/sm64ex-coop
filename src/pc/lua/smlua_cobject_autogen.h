/* THIS FILE IS AUTOGENERATED */
/* SHOULD NOT BE MANUALLY CHANGED */
#ifndef SMLUA_COBJECT_AUTOGEN_H
#define SMLUA_COBJECT_AUTOGEN_H

enum LuaObjectAutogenType {
    LOT_AUTOGEN_MIN = 1000,
    LOT_ANIMATION,
    LOT_AREA,
    LOT_CAMERA,
    LOT_CAMERAFOVSTATUS,
    LOT_CAMERASTOREDINFO,
    LOT_CAMERATRIGGER,
    LOT_CHARACTER,
    LOT_CONTROLLER,
    LOT_CUTSCENE,
    LOT_CUTSCENESPLINEPOINT,
    LOT_CUTSCENEVARIABLE,
    LOT_FLOORGEOMETRY,
    LOT_GRAPHNODE,
    LOT_GRAPHNODEOBJECT,
    LOT_GRAPHNODEOBJECT_SUB,
    LOT_HANDHELDSHAKEPOINT,
    LOT_INSTANTWARP,
    LOT_LAKITUSTATE,
    LOT_LINEARTRANSITIONPOINT,
    LOT_MARIOANIMATION,
    LOT_MARIOBODYSTATE,
    LOT_MARIOSTATE,
    LOT_MODETRANSITIONINFO,
    LOT_NETWORKPLAYER,
    LOT_OBJECT,
    LOT_OBJECTHITBOX,
    LOT_OBJECTNODE,
    LOT_OBJECTWARPNODE,
    LOT_OFFSETSIZEPAIR,
    LOT_PARALLELTRACKINGPOINT,
    LOT_PLAYERCAMERASTATE,
    LOT_PLAYERGEOMETRY,
    LOT_SPAWNINFO,
    LOT_SURFACE,
    LOT_TRANSITIONINFO,
    LOT_WALLCOLLISIONDATA,
    LOT_WARPNODE,
    LOT_WARPTRANSITION,
    LOT_WARPTRANSITIONDATA,
    LOT_WAYPOINT,
    LOT_WHIRLPOOL,
    LOT_AUTOGEN_MAX,
};

struct LuaObjectField* smlua_get_object_field_autogen(u16 lot, const char* key);

#endif
