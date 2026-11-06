/// @func scr_try_place_houses()
/// @desc For each village, if the pop is at 80% of housing cap and no house
///       is currently under construction, place a new house site.
function scr_try_place_houses()
{
    for (var _i = 0; _i < array_length(global.villages); _i++)
    {
        var _v = global.villages[_i];

        // Town hall must be complete first
        var _has_town_hall = false;
        for (var _bi = 0; _bi < array_length(_v.building_list); _bi++)
        {
            var _b = _v.building_list[_bi];
            if (instance_exists(_b) && _b.building_type == "town_hall")
            {
                _has_town_hall = true;
                break;
            }
        }
        if (!_has_town_hall) continue;

        // House count cap
        var _kingdom = global.kingdoms[_v.kingdom_id];
        var _max_houses = scr_max_houses_for_level(_kingdom.advancement_level);
        var _current_houses = scr_village_house_count(_v);
        if (_current_houses >= _max_houses) continue;

        // Population threshold (80% of housing cap)
        var _pop = array_length(_v.member_ids);
        var _cap = scr_village_housing_cap(_v);
        if (_pop < _cap * 0.8) continue;

        // Already building a house?
        var _pending_house = false;
        with (obj_building)
        {
            if (village_id != _v.id) continue;
            if (state != "construction") continue;
            if (building_type != "house_a" && building_type != "house_b") continue;
            _pending_house = true;
        }
        if (_pending_house) continue;

        // Find a spot
        var _spot = scr_find_house_spot(_i);
        if (_spot[0] == -1) continue;

        var _w = obj_world.world_width;
        var _h = obj_world.world_height;
        if (_spot[0] < 0 || _spot[0] + 1 >= _w) continue;
        if (_spot[1] < 0 || _spot[1] + 1 >= _h) continue;
        if (obj_world.terrain_grid[_spot[0] + _spot[1] * _w] == TERRAIN.WATER) continue;
        if (obj_world.terrain_grid[(_spot[0] + 1) + _spot[1] * _w] == TERRAIN.WATER) continue;
        if (obj_world.terrain_grid[_spot[0] + (_spot[1] + 1) * _w] == TERRAIN.WATER) continue;
        if (obj_world.terrain_grid[(_spot[0] + 1) + (_spot[1] + 1) * _w] == TERRAIN.WATER) continue;

        // Place the house site.
        // Sprites use a bottom-centre origin (same as the town hall), so a
        // 2-tile-wide house is centred at (spot_x + 1) * ts, bottom at (spot_y + 2) * ts.
        // If your house sprite origin is bottom-LEFT, change the x back to _spot[0] * _ts.
        var _ts = obj_world.tile_size;
        var _inst = instance_create_depth(
            (_spot[0] + 1) * _ts,
            (_spot[1] + 2) * _ts,
            DEPTH.BUILDINGS,
            obj_building
        );

        _inst.building_type = "house_a";
        _inst.building_size = 16;
        _inst.sprite_index  = spr_building_construction_16;
        _inst.state         = "construction";
        _inst.village_id    = _v.id;
        _inst.level         = _kingdom.advancement_level;

        // Footprint (2x2)
        _inst.footprint_left   = _spot[0];
        _inst.footprint_top    = _spot[1];
        _inst.footprint_right  = _spot[0] + 1;
        _inst.footprint_bottom = _spot[1] + 1;

        for (var _dy = 0; _dy <= 1; _dy++)
        {
            for (var _dx = 0; _dx <= 1; _dx++)
            {
                obj_world.block_grid[(_spot[0] + _dx) + (_spot[1] + _dy) * _w] = 1;
            }
        }

        _v.construction_id = _inst;
        global.villages[_i] = _v;
    }
}
