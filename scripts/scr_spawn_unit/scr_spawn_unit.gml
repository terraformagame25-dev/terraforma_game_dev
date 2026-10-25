/// @func scr_spawn_unit(_gx, _gy, _type)
/// @desc Spawns a unit at the given grid tile.
///        Rules:
///          - Water and blocked tiles → rejected
///          - Inside a village → joins that village
///          - On free land → spawns unaffiliated
///        Returns the instance id, or noone if the tile is invalid.
function scr_spawn_unit(_gx, _gy, _type = "villager")
{
    var _w = obj_world.world_width;
    var _h = obj_world.world_height;

    // Bounds check
    if (_gx < 0 || _gx >= _w) return noone;
    if (_gy < 0 || _gy >= _h) return noone;

    var _idx = _gx + _gy * _w;

    // Terrain checks
    if (obj_world.terrain_grid[_idx] == TERRAIN.WATER) return noone;
    if (obj_world.block_grid[_idx]   == 1)             return noone;

    // Find which village (if any) contains the tile
    var _target_village_id = -1;
    for (var _i = 0; _i < array_length(global.villages); _i++)
    {
        var _v = global.villages[_i];
        if (scr_tile_in_union(_v, _gx, _gy))
        {
            _target_village_id = _v.id;
            break;
        }
    }

    // === Create the unit ===
    var _unit = instance_create_depth(
        _gx * obj_world.tile_size,
        _gy * obj_world.tile_size,
        DEPTH.UNITS,
        obj_unit
    );

    _unit.grid_x = _gx;
    _unit.grid_y = _gy;
    _unit.x      = _gx * obj_world.tile_size;
    _unit.y      = _gy * obj_world.tile_size;

    scr_apply_unit_type(_unit, _type);

    // === Affiliation ===
    if (_target_village_id != -1)
    {
        // Spawned inside a village — assign to it
        scr_assign_unit_to_village(_unit, _target_village_id);
    }
    else
    {
        // Spawned on free land — unaffiliated
        _unit.village_id = -1;
        _unit.kingdom_id = -1;
        _unit.is_hostile = true;
    }

    return _unit;
}