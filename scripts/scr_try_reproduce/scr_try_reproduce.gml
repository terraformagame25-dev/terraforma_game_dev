function scr_try_reproduce(_a, _b, _village_id)
{
    var _v = global.villages[_village_id];
    var _ts = obj_world.tile_size;
    var _w = obj_world.world_width;

    // Find free tile near _a
    var _found = false;
    var _sx = -1;
    var _sy = -1;

    for (var _r = 0; _r <= 3 && !_found; _r++)
    {
        for (var _dy = -_r; _dy <= _r && !_found; _dy++)
        {
            for (var _dx = -_r; _dx <= _r && !_found; _dx++)
            {
                if (_r > 0 && max(abs(_dx), abs(_dy)) != _r) continue;

                var _cx = _a.grid_x + _dx;
                var _cy = _a.grid_y + _dy;

                if (_cx < 0 || _cx >= obj_world.world_width)  continue;
                if (_cy < 0 || _cy >= obj_world.world_height) continue;

                var _idx = _cx + _cy * _w;

                if (obj_world.terrain_grid[_idx] == TERRAIN.WATER)  continue;
                if (obj_world.block_grid[_idx]   == 1)              continue;
                if (!scr_tile_in_union(_v, _cx, _cy))               continue;

                _sx = _cx;
                _sy = _cy;
                _found = true;
            }
        }
    }

    if (!_found) return false;

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
    _baby.village_id = _village_id;
    _baby.kingdom_id = _v.kingdom_id;
    _baby.repro_cooldown = irandom_range(900, 1800);   // newborn waits longer

    array_push(_v.member_ids, _baby.id);
    global.villages[_village_id] = _v;

    return true;
}