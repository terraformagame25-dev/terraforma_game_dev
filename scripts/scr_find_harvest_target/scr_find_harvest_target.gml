/// @func scr_find_harvest_target(_unit)
/// @desc Picks the nearest harvestable resource tile for a miner.
///       Search area: village center ± (village.radius + 20) tiles.
///       Skips resources inside other kingdoms' territory.
///       Returns true and sets harvest_target_x/y on success.
function scr_find_harvest_target(_unit)
{
    if (_unit.village_id == -1) return false;

    var _v = global.villages[_unit.village_id];

    // === Determine which resource type to target ===
    var _wood_full  = (_v.resources.wood  >= _v.resource_caps.wood);
    var _stone_full = (_v.resources.stone >= _v.resource_caps.stone);

    if (_wood_full && _stone_full) return false;

    var _want_tree  = false;
    var _want_stone = false;

    if (_wood_full)       { _want_stone = true; }
    else if (_stone_full) { _want_tree  = true; }
    else
    {
        // Both available — 50/50 per-target coin flip
        if (irandom(1) == 0) _want_tree  = true;
        else                 _want_stone = true;
    }

    // === Search bounds ===
	var _search_r = 100;
	var _min_x = max(0, _v.cx - _search_r);
	var _max_x = min(obj_world.world_width  - 1, _v.cx + _search_r);
	var _min_y = max(0, _v.cy - _search_r);
	var _max_y = min(obj_world.world_height - 1, _v.cy + _search_r);

    // === Find nearest matching resource to the miner ===
    var _best_x    = -1;
    var _best_y    = -1;
    var _best_dist = 999999;

    var _grid = obj_world.resource_grid;
    var _w    = obj_world.world_width;

    for (var _ty = _min_y; _ty <= _max_y; _ty++)
    {
        for (var _tx = _min_x; _tx <= _max_x; _tx++)
        {
            var _idx = _tx + _ty * _w;
            var _res = _grid[_idx];

            if (_want_tree  && _res != RESOURCE.TREE)  continue;
            if (_want_stone && _res != RESOURCE.STONE) continue;
            if (_res == RESOURCE.NONE) continue;

            // Skip resources in other kingdoms' territory
            if (scr_tile_in_other_kingdom(_tx, _ty, _unit.kingdom_id)) continue;

            // Chebyshev distance to miner
            var _dx = abs(_tx - _unit.grid_x);
            var _dy = abs(_ty - _unit.grid_y);
            var _d  = max(_dx, _dy);

            if (_d < _best_dist)
            {
                _best_dist = _d;
                _best_x    = _tx;
                _best_y    = _ty;
            }
        }
    }

    if (_best_x == -1) return false;

    _unit.harvest_target_x = _best_x;
    _unit.harvest_target_y = _best_y;
    _unit.harvest_timer    = 0;
    return true;
}