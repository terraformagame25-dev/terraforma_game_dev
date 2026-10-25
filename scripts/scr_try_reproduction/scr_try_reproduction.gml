/// @func scr_try_reproduction()
/// @desc Every interval: for each village with ≥2 spare villagers, spawn up
///       to X new villagers (X = level-based max), capped by housing capacity.
function scr_try_reproduction()
{
    for (var _vi = 0; _vi < array_length(global.villages); _vi++)
    {
        var _v = global.villages[_vi];

        // Housing cap
        var _pop = array_length(_v.member_ids);
        var _cap = scr_village_housing_cap(_v);
        if (_pop >= _cap) continue;

        // Need at least 2 spare villagers
        var _villagers = scr_village_pop_count(_v);
        if (_villagers < 2) continue;

        // How many to spawn this interval
        var _kingdom = global.kingdoms[_v.kingdom_id];
        var _x = scr_max_repro_per_interval(_kingdom.advancement_level);

        // Don't exceed housing cap
        var _room = _cap - _pop;
        var _to_spawn = min(_x, _room);

        // Spawn near the town hall
        for (var _n = 0; _n < _to_spawn; _n++)
        {
            scr_spawn_repro_villager(_v, _vi);
        }
    }
}
function array_in_ext(_array, _value)
{
    for (var _i = 0; _i < array_length(_array); _i++)
    {
        if (_array[_i] == _value) return true;
    }
    return false;
}

/// @func scr_spawn_repro_villager(_v, _village_index)
/// @desc Spawns a newborn villager in a free tile near the town hall.
///       Returns the newborn instance, or noone if no valid spot.
function scr_spawn_repro_villager(_v, _village_index)
{
    var _ts = obj_world.tile_size;
    var _w  = obj_world.world_width;

    // Find a free tile near the town hall (or village center as fallback)
    var _cx = _v.cx;
    var _cy = _v.cy;

    var _spot_found = false;
    var _sx = -1;
    var _sy = -1;

    for (var _r = 0; _r <= 5 && !_spot_found; _r++)
    {
        for (var _dy = -_r; _dy <= _r && !_spot_found; _dy++)
        {
            for (var _dx = -_r; _dx <= _r && !_spot_found; _dx++)
            {
                if (_r > 0 && max(abs(_dx), abs(_dy)) != _r) continue;

                var _test_x = _cx + _dx;
                var _test_y = _cy + _dy;

                if (_test_x < 0 || _test_x >= obj_world.world_width)  continue;
                if (_test_y < 0 || _test_y >= obj_world.world_height) continue;

                var _idx = _test_x + _test_y * _w;

                if (obj_world.terrain_grid[_idx] == TERRAIN.WATER)  continue;
                if (obj_world.block_grid[_idx]   == 1)              continue;
                if (!scr_tile_in_union(_v, _test_x, _test_y))        continue;

                _sx = _test_x;
                _sy = _test_y;
                _spot_found = true;
            }
        }
    }

    if (!_spot_found) return noone;

    var _baby = instance_create_depth(
        _sx * _ts,
        _sy * _ts,
        DEPTH.UNITS,
        obj_unit
    );

    _baby.grid_x = _sx;
    _baby.grid_y = _sy;
    _baby.x      = _sx * _ts;
    _baby.y      = _sy * _ts;

    scr_apply_unit_type(_baby, "villager");
    _baby.village_id = _v.id;
    _baby.kingdom_id = _v.kingdom_id;

    array_push(_v.member_ids, _baby.id);
    global.villages[_village_index] = _v;

    return _baby;
}