/// @func scr_init_depth_enum()
/// @desc Not a real function — this defines the DEPTH enum once.
///       Place this in a script file (e.g. scr_depth.gml) so the enum
///       is available globally.
///
///       Lower value = drawn on top (GameMaker default).
///       Visual stack from top to bottom:
///         UI → Trees → Units → Buildings → Minerals → Borders → Terrain

enum DEPTH {
    UI        = -500,   // drawn last (on top)
	LABELS    = -300,   // village labels — above units, below UI
    TREES     = -150,
    UNITS     = -100,
    BUILDINGS =  -40,
    MINERALS  =  -20,
    BORDERS   =  -10,
    TERRAIN   =    0,   // drawn first (bottom)
}