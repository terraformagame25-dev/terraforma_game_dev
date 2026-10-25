/// @func scr_place_construction(_village_id)
/// @desc Places a construction marker at a valid 3x3 tile inside the village.
///       Uses scr_find_town_hall_spot to search for a placement.
function scr_place_construction(_village_id)
{
    var _v = global.villages[_village_id];
    if (variable_instance_exists(_v, "construction_id") && _v.construction_id != noone) return;

    var _ts = obj_world.tile_size;
    var _w  = obj_world.world_width;

    // Find a valid 3x3 spot near the village center
    var _spot = scr_find_town_hall_spot(_v.cx, _v.cy);

    if (_spot[0] == -1)
    {
        // Defensive — shouldn't happen since callers pre-check
        show_debug_message("WARNING: no valid town hall spot for village " + string(_village_id));
        return;
    }

    var _cx = _spot[0];
    var _cy = _spot[1];

    // SAFETY CHECK: Ensure the spot is not in water and is inside the world
    var _h = obj_world.world_height;
    if (_cx < 1 || _cx >= _w - 1 || _cy < 1 || _cy >= _h - 1) return;
    if (obj_world.terrain_grid[_cx + _cy * _w] == TERRAIN.WATER) return;

    // Update village center to the chosen spot
    _v.cx = _cx;
    _v.cy = _cy;
    global.villages[_village_id] = _v;

    var _inst = instance_create_depth(_cx * _ts + _ts * 0.5, (_cy + 2) * _ts, DEPTH.BUILDINGS, obj_building);
    
	_inst.x             = _cx * _ts + _ts * 0.5;
    _inst.y             = (_cy + 2) * _ts;
    _inst.sprite_index  = spr_building_construction_24;
    _inst.building_type = "town_hall";
    _inst.building_size = 24;

    var _kingdom = global.kingdoms[_v.kingdom_id];
    _inst.level = _kingdom.advancement_level;

    _inst.state      = "construction";
    _inst.village_id = _village_id;

    // Footprint (3x3 centered on _cx, _cy)
    _inst.footprint_left   = _cx - 1;
    _inst.footprint_top    = _cy - 1;
    _inst.footprint_right  = _cx + 1;
    _inst.footprint_bottom = _cy + 1;

    // Block the footprint
    for (var _by = -1; _by <= 1; _by++)
    {
        for (var _bx = -1; _bx <= 1; _bx++)
        {
            var _gx = _cx + _bx;
            var _gy = _cy + _by;
            if (_gx < 0 || _gx >= _w) continue;
            if (_gy < 0 || _gy >= obj_world.world_height) continue;
            obj_world.block_grid[_gx + _gy * _w] = 1;
        }
    }

    _v.construction_id = _inst;
    global.villages[_village_id] = _v;
}