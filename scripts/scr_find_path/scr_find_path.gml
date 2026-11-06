/// @func scr_find_path(_start_gx, _start_gy, _goal_gx, _goal_gy, _allow_resource_goal)
/// @desc A* pathfinding (4-directional). _allow_resource_goal lets the path
///       enter resource tiles (miners / colonists). Search is capped so an
///       unreachable goal can't flood the whole island.
function scr_find_path(_start_gx, _start_gy, _goal_gx, _goal_gy, _allow_resource_goal = false)
{
    var _w     = obj_world.world_width;
    var _h     = obj_world.world_height;
    var _grid  = obj_world.terrain_grid;
    var _block = obj_world.block_grid;

    if (_goal_gx < 0 || _goal_gx >= _w) return [];
    if (_goal_gy < 0 || _goal_gy >= _h) return [];

    var _goal_idx = _goal_gx + _goal_gy * _w;

    if (_grid[_goal_idx] == TERRAIN.WATER) return [];

    if (_block[_goal_idx] == 1)
    {
        if (!_allow_resource_goal) return [];
        if (obj_world.resource_grid[_goal_idx] == RESOURCE.NONE) return [];
    }

    if (_start_gx == _goal_gx && _start_gy == _goal_gy) return [];

    var _open      = ds_priority_create();
    var _g_scores  = {};
    var _came_from = {};
    var _closed    = {};

    var _start_idx = _start_gx + _start_gy * _w;

    _g_scores[$ string(_start_idx)] = 0;
    ds_priority_add(_open, _start_idx, scr_heuristic(_start_gx, _start_gy, _goal_gx, _goal_gy));

    var _dx = [ 0, 1, 0, -1];
    var _dy = [-1, 0, 1,  0];

    var _iter     = 0;
    var _max_iter = 6000;

    while (!ds_priority_empty(_open))
    {
        if (++_iter > _max_iter) break;

        var _current = ds_priority_delete_min(_open);
        var _ckey    = string(_current);

        if (_closed[$ _ckey]) continue;
        _closed[$ _ckey] = true;

        if (_current == _goal_idx)
        {
            ds_priority_destroy(_open);
            return scr_reconstruct_path(_came_from, _start_idx, _goal_idx);
        }

        var _cx = _current mod _w;
        var _cy = _current div _w;

        for (var _i = 0; _i < 4; _i++)
        {
            var _nx = _cx + _dx[_i];
            var _ny = _cy + _dy[_i];

            if (_nx < 0 || _nx >= _w) continue;
            if (_ny < 0 || _ny >= _h) continue;

            var _n_idx = _nx + _ny * _w;

            if (_block[_n_idx] == 1)
            {
                var _is_resource = (obj_world.resource_grid[_n_idx] != RESOURCE.NONE);
                if (!(_allow_resource_goal && _is_resource)) continue;
            }

            if (_grid[_n_idx] == TERRAIN.WATER) continue;

            var _nkey = string(_n_idx);
            if (_closed[$ _nkey]) continue;

            var _tentative_g = _g_scores[$ _ckey] + 1;

            var _existing = _g_scores[$ _nkey];
            if (!variable_struct_exists(_g_scores, _nkey) || _tentative_g < _existing)
            {
                _g_scores[$ _nkey]  = _tentative_g;
                _came_from[$ _nkey] = _ckey;

                var _f = _tentative_g + scr_heuristic(_nx, _ny, _goal_gx, _goal_gy);
                ds_priority_add(_open, _n_idx, _f);
            }
        }
    }

    ds_priority_destroy(_open);
    return [];
}

/// @func scr_heuristic(_ax, _ay, _bx, _by)
function scr_heuristic(_ax, _ay, _bx, _by)
{
    return abs(_ax - _bx) + abs(_ay - _by);
}

/// @func scr_reconstruct_path(_came_from, _start_idx, _goal_idx)
function scr_reconstruct_path(_came_from, _start_idx, _goal_idx)
{
    var _w = obj_world.world_width;
    var _path = [];

    var _current = _goal_idx;
    while (_current != _start_idx)
    {
        var _cx = _current mod _w;
        var _cy = _current div _w;
        array_insert(_path, 0, [_cx, _cy]);

        _current = real(_came_from[$ string(_current)]);

        if (array_length(_path) > 10000) break;
    }

    return _path;
}
