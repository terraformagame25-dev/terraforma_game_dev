/// @func scr_try_expand_village()
function scr_try_expand_village()
{
    // Process all villages, but only expand ONE tile per village per frame
    // to ensure the queue is perfectly stable and no overlaps occur.
    for (var _vi = 0; _vi < array_length(global.villages); _vi++)
    {
        var _v = global.villages[_vi];
        var _pop = array_length(_v.member_ids);
        
        // How many tiles total should this village own?
        // Starting square is 11x11 = 121 tiles. Let's use 1 tile per 2 pop.
        var _target_tiles = floor(_pop * 0.5);
        if (_target_tiles < 50) continue; // Wait until pop > 100

        // Count how many tiles we currently own
        var _owned = 0;
        var _w = obj_world.world_width;
        var _h = obj_world.world_height;
        
        // Scan the bounding box quickly
        for (var _gy = _v.top; _gy <= _v.bottom; _gy++) {
            for (var _gx = _v.left; _gx <= _v.right; _gx++) {
                if (obj_world.territory_grid[_gx + _gy * _w] == _v.id) _owned++;
            }
        }

        if (_owned >= _target_tiles) continue;

        // === EXPAND ===
        // Find all edge tiles strictly within our bounding box
        var _edges = [];
        for (var _gy = _v.top; _gy <= _v.bottom; _gy++)
        {
            for (var _gx = _v.left; _gx <= _v.right; _gx++)
            {
                if (obj_world.territory_grid[_gx + _gy * _w] != _v.id) continue;

                // Is it an edge? (Has at least one non-owned neighbor)
                var _is_edge = false;
                if (_gx > 0 && obj_world.territory_grid[(_gx - 1) + _gy * _w] != _v.id) _is_edge = true;
                if (_gx < _w - 1 && obj_world.territory_grid[(_gx + 1) + _gy * _w] != _v.id) _is_edge = true;
                if (_gy > 0 && obj_world.territory_grid[_gx + (_gy - 1) * _w] != _v.id) _is_edge = true;
                if (_gy < _h - 1 && obj_world.territory_grid[_gx + (_gy + 1) * _w] != _v.id) _is_edge = true;

                if (_is_edge) array_push(_edges, [_gx, _gy]);
            }
        }

        if (array_length(_edges) == 0) continue;

        // Pick a random edge and try to expand in a random direction
        var _edge = _edges[irandom(array_length(_edges) - 1)];
        var _ex = _edge[0];
        var _ey = _edge[1];

        var _dirs = [0, 1, 2, 3];
        for (var _s = 0; _s < 4; _s++) {
            var _r = irandom(3);
            var _tmp = _dirs[_s];
            _dirs[_s] = _dirs[_r];
            _dirs[_r] = _tmp;
        }

        var _max_r = scr_advancement_max_radius(global.kingdoms[_v.kingdom_id].advancement_level);
        var _claimed = false;

        for (var _di = 0; _di < 4 && !_claimed; _di++)
        {
            var _dir = _dirs[_di];
            var _nx = _ex;
            var _ny = _ey;

            switch (_dir) {
                case 0: _ny -= 1; break; // North
                case 1: _nx += 1; break; // East
                case 2: _ny += 1; break; // South
                case 3: _nx -= 1; break; // West
            }

            if (_nx < 0 || _nx >= _w || _ny < 0 || _ny >= _h) continue;

            var _nidx = _nx + _ny * _w;

            // STRICT CHECKS
            if (obj_world.territory_grid[_nidx] != -1) continue; // No overlapping!
            if (obj_world.terrain_grid[_nidx] == TERRAIN.WATER) continue; // No water!
            if (point_distance(_v.cx, _v.cy, _nx, _ny) > _max_r) continue; // Max radius!

            // CLAIM
            obj_world.territory_grid[_nidx] = _v.id;
            _claimed = true;
        }

        // Update bounding box if we claimed a tile
        if (_claimed)
        {
            if (_nx < _v.left)   _v.left = _nx;
            if (_nx > _v.right)  _v.right = _nx;
            if (_ny < _v.top)    _v.top = _ny;
            if (_ny > _v.bottom) _v.bottom = _ny;
            global.villages[_vi] = _v;
        }
    }
}