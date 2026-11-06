/// @func scr_try_expand_village()
/// @desc Grows each village's territory (territory_grid is the source of truth).
///       Each successful attempt claims a square patch of tiles.
function scr_try_expand_village()
{
    // ===== Tunables =====
    var _max_per_call = 8;   // expansion attempts per village per call
    var _chunk        = 2;   // patch radius: 0 = 1 tile, 1 = 3x3, 2 = 5x5, 3 = 7x7
    var _tiles_per_pop = 2;  // village wants to own pop * this many tiles
    var _min_pop      = 50;  // no expansion below this population

    var _w = obj_world.world_width;
    var _h = obj_world.world_height;

    for (var _vi = 0; _vi < array_length(global.villages); _vi++)
    {
        var _v   = global.villages[_vi];
        var _pop = array_length(_v.member_ids);

        if (_pop < _min_pop) continue;
        var _target_tiles = _pop * _tiles_per_pop;

        // Count owned tiles (bounds clamped)
        var _l = max(0, _v.left);
        var _t = max(0, _v.top);
        var _r = min(_w - 1, _v.right);
        var _b = min(_h - 1, _v.bottom);

        var _owned = 0;
        for (var _gy = _t; _gy <= _b; _gy++)
            for (var _gx = _l; _gx <= _r; _gx++)
                if (obj_world.territory_grid[_gx + _gy * _w] == _v.id) _owned++;

        if (_owned >= _target_tiles) continue;

        // Collect edge tiles
        var _edges = [];
        for (var _gy = _t; _gy <= _b; _gy++)
        {
            for (var _gx = _l; _gx <= _r; _gx++)
            {
                if (obj_world.territory_grid[_gx + _gy * _w] != _v.id) continue;

                var _is_edge = false;
                if (_gx > 0      && obj_world.territory_grid[(_gx - 1) + _gy * _w] != _v.id) _is_edge = true;
                if (_gx < _w - 1 && obj_world.territory_grid[(_gx + 1) + _gy * _w] != _v.id) _is_edge = true;
                if (_gy > 0      && obj_world.territory_grid[_gx + (_gy - 1) * _w] != _v.id) _is_edge = true;
                if (_gy < _h - 1 && obj_world.territory_grid[_gx + (_gy + 1) * _w] != _v.id) _is_edge = true;

                if (_is_edge) array_push(_edges, [_gx, _gy]);
            }
        }

        if (array_length(_edges) == 0) continue;

        var _max_r   = scr_advancement_max_radius(global.kingdoms[_v.kingdom_id].advancement_level);
        var _dxs     = [0, 1, 0, -1];
        var _dys     = [-1, 0, 1, 0];
        var _changed = false;

        repeat (_max_per_call)
        {
            var _edge      = _edges[irandom(array_length(_edges) - 1)];
            var _start_dir = irandom(3);

            for (var _di = 0; _di < 4; _di++)
            {
                var _dir = (_start_dir + _di) mod 4;
                var _nx  = _edge[0] + _dxs[_dir];
                var _ny  = _edge[1] + _dys[_dir];

                if (_nx < 0 || _nx >= _w || _ny < 0 || _ny >= _h) continue;

                var _nidx = _nx + _ny * _w;

                if (obj_world.territory_grid[_nidx] != -1)           continue;
                if (obj_world.terrain_grid[_nidx] == TERRAIN.WATER)  continue;
                if (point_distance(_v.cx, _v.cy, _nx, _ny) > _max_r) continue;

                // Claim a square patch centred on the new tile
                for (var _py = _ny - _chunk; _py <= _ny + _chunk; _py++)
                {
                    for (var _px = _nx - _chunk; _px <= _nx + _chunk; _px++)
                    {
                        if (_px < 0 || _px >= _w || _py < 0 || _py >= _h) continue;

                        var _pidx = _px + _py * _w;
                        if (obj_world.territory_grid[_pidx] != -1)           continue;
                        if (obj_world.terrain_grid[_pidx] == TERRAIN.WATER)  continue;
                        if (point_distance(_v.cx, _v.cy, _px, _py) > _max_r) continue;

                        obj_world.territory_grid[_pidx] = _v.id;
                        scr_mark_coastal_water(_px, _py);   // 1-tile water border (port-only)
                        array_push(_edges, [_px, _py]);

                        if (_px < _v.left)   _v.left   = _px;
                        if (_px > _v.right)  _v.right  = _px;
                        if (_py < _v.top)    _v.top    = _py;
                        if (_py > _v.bottom) _v.bottom = _py;
                    }
                }

                _changed = true;
                break;
            }
        }

        if (_changed) global.villages[_vi] = _v;
    }
}
