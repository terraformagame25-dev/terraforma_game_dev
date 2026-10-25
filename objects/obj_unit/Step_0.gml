// At the very top of obj_unit Step event
if (global.is_paused) exit;

// ============================================================
// 0. PUSH OUT OF BLOCKED TILE
// ============================================================
var _my_idx = grid_x + grid_y * obj_world.world_width;
if (obj_world.block_grid[_my_idx] == 1)
{
    var _exempt = false;
    if (unit_type == "miner")
    {
        var _res = obj_world.resource_grid[_my_idx];
        if (_res == RESOURCE.TREE || _res == RESOURCE.STONE) _exempt = true;
    }

    if (!_exempt)
    {
        var _placed = false;
        var _radius = 1;
        var _w      = obj_world.world_width;

        while (!_placed && _radius <= 5)
        {
            for (var _dy = -_radius; _dy <= _radius && !_placed; _dy++)
            {
                for (var _dx = -_radius; _dx <= _radius && !_placed; _dx++)
                {
                    if (abs(_dx) != _radius && abs(_dy) != _radius) continue;

                    var _nx = grid_x + _dx;
                    var _ny = grid_y + _dy;

                    if (!scr_tile_allowed_for_unit(self, _nx, _ny)) continue;

                    x          = _nx * obj_world.tile_size + obj_world.tile_size * 0.5;
                    y          = _ny * obj_world.tile_size + obj_world.tile_size;
                    grid_x     = _nx;
                    grid_y     = _ny;
                    walk_path      = [];
                    walk_index     = 0;
                    path_allow_res = false;
                    _placed    = true;
                }
            }
            _radius++;
        }
    }
}

// ============================================================
// YANK BACK: if a non-miner is not on a claimed territory tile, teleport home
// ============================================================
if (village_id != -1 && unit_type != "miner" && !path_allow_res)
{

    if (obj_world.territory_grid[_my_idx] != village_id)
    {
        var _v = global.villages[village_id];
        x              = _v.cx * obj_world.tile_size + obj_world.tile_size * 0.5;
        y              = _v.cy * obj_world.tile_size + obj_world.tile_size;
        grid_x         = _v.cx;
        grid_y         = _v.cy;
        walk_path      = [];
        walk_index     = 0;
        path_allow_res = false;
    }
}

// ============================================================
// 1. AI — target selection
// ============================================================
if (array_length(walk_path) == 0)
{
    if (wander_pause_timer > 0)
    {
        wander_pause_timer--;
    }
    else if (path_cooldown > 0)
    {
        path_cooldown--;
    }
    else
    {
        var _target_gx           = grid_x;
        var _target_gy           = grid_y;
        var _skip_path           = false;
        var _allow_resource_path = false;

        // ----------------------------------------------------
        // MINER
        // ----------------------------------------------------
        if (unit_type == "miner")
        {
            if (harvest_target_x != -1)
            {
                if (scr_try_harvest(self))
                {
                    wander_pause_timer = 10;
                }
                _skip_path = true;
            }
            else
            {
                var _v = global.villages[village_id];
                var _wood_full  = (_v.resources.wood  >= _v.resource_caps.wood);
                var _stone_full = (_v.resources.stone >= _v.resource_caps.stone);

                if (_wood_full && _stone_full)
                {
                    if (grid_x != _v.cx || grid_y != _v.cy)
                    {
                        _target_gx    = _v.cx;
                        _target_gy    = _v.cy;
                        path_cooldown = irandom_range(5, 15);
                    }
                    else
                    {
                        _target_gx    = grid_x + irandom_range(-3, 3);
                        _target_gy    = grid_y + irandom_range(-3, 3);
                        path_cooldown = irandom_range(5, 15);
                    }
                }
                else
                {
                    if (scr_find_harvest_target(self))
                    {
                        _target_gx           = harvest_target_x;
                        _target_gy           = harvest_target_y;
                        path_cooldown        = irandom_range(5, 15);
                        _allow_resource_path = true;
                    }
                    else
                    {
                        wander_pause_timer = 30;
                        _skip_path         = true;
                    }
                }
            }
        }
        // ----------------------------------------------------
        // BUILDER
        // ----------------------------------------------------
        else if (unit_type == "builder")
        {
            var _site = noone;

            if (build_target_id != noone && instance_exists(build_target_id))
            {
                if (build_target_id.state == "construction") _site = build_target_id;
                else                                        build_target_id = noone;
            }

            if (_site == noone)
            {
                var _best_priority = 9999;
                var _best_site     = noone;

                with (obj_building)
                {
                    if (state != "construction")        continue;
                    if (village_id != other.village_id) continue;

                    var _prio = 99;
                    switch (building_type)
                    {
                        case "town_hall": _prio = 1; break;
                        case "mine":      _prio = 2; break;
                        case "barracks":  _prio = 3; break;
                        case "house_a":   _prio = 4; break;
                        case "house_b":   _prio = 5; break;
                        default:          _prio = 6; break;
                    }

                    if (_prio < _best_priority)
                    {
                        _best_priority = _prio;
                        _best_site     = id;
                    }
                }

                if (_best_site != noone)
                {
                    build_target_id = _best_site;
                    _site           = _best_site;
                }
            }

            if (_site != noone)
            {
                var _site_gx = floor(_site.x / obj_world.tile_size);
                var _site_gy = floor(_site.y / obj_world.tile_size);
                var _dx      = abs(grid_x - _site_gx);
                var _dy      = abs(grid_y - _site_gy);

                if (_dx > 4 || _dy > 4)
                {
                    _target_gx    = _site_gx;
                    _target_gy    = _site_gy;
                    path_cooldown = irandom_range(5, 15);
                }
                else
                {
                    _skip_path = true;
                }
            }
            else
            {
                var _wr = max(1, wander_radius);
                _target_gx = grid_x + irandom_range(-_wr, _wr);
                _target_gy = grid_y + irandom_range(-_wr, _wr);
                if (village_id != -1)
                {
                    var _v = global.villages[village_id];
                    _target_gx = clamp(_target_gx, _v.left, _v.right);
                    _target_gy = clamp(_target_gy, _v.top,  _v.bottom);
                }
            }
        }
        // ----------------------------------------------------
        // LEADER
        // ----------------------------------------------------
        else if (unit_type == "leader" && leader_anchor_x != -1)
        {
            var _wr = max(1, wander_radius);
            _target_gx = leader_anchor_x + irandom_range(-_wr, _wr);
            _target_gy = leader_anchor_y + irandom_range(-_wr, _wr);
            if (village_id != -1)
            {
                var _v = global.villages[village_id];
                _target_gx = clamp(_target_gx, _v.left, _v.right);
                _target_gy = clamp(_target_gy, _v.top,  _v.bottom);
            }
        }
        // ----------------------------------------------------
        // VILLAGER
        // ----------------------------------------------------
        else if (unit_type == "villager")
        {
            var _must_reach = false;

            if (village_id == -1)
            {
                if (!variable_global_exists("village_founder_id"))
                {
                    global.village_founder_id = noone;
                    global.village_founder_x  = -1;
                    global.village_founder_y  = -1;
                }

                // 1. CHECK FOR EXPANSION RALLY
                var _is_colonist = false;
                if (kingdom_id != -1)
                {
                    var _k = global.kingdoms[kingdom_id];
                    if (_k.expansion_rally_active)
                    {
                        _is_colonist = true;

                        if (colonist_leader)
                        {
                            // === LEADER LOGIC ===
                            // Update the rally point to the leader's position
                            _k.expansion_rally_x = grid_x;
                            _k.expansion_rally_y = grid_y;

                            // If we don't have a spot yet, find one!
                            if (_k.expansion_rally_x == grid_x && _k.expansion_rally_y == grid_y)
                            {
                                // Spiral search from current position
                                var _found_spot = false;
                                for (var _r = 12; _r <= 80 && !_found_spot; _r += 4)
                                {
                                    for (var _step = 0; _step < 8 && !_found_spot; _step++)
                                    {
                                        var _rx = grid_x + lengthdir_x(_r, _step * 45);
                                        var _ry = grid_y + lengthdir_y(_r, _step * 45);
                                        
                                        if (_rx < 0 || _rx >= obj_world.world_width) continue;
                                        if (_ry < 0 || _ry >= obj_world.world_height) continue;

                                        if (scr_find_town_hall_spot(_rx, _ry)[0] != -1)
                                        {
                                            // Check buffer against all villages
                                            var _too_close = false;
                                            for (var _vi = 0; _vi < array_length(global.villages); _vi++)
                                            {
                                                var _ev = global.villages[_vi];
                                                var _dx = 0, _dy = 0;
                                                if (_rx < _ev.left) _dx = _ev.left - _rx;
                                                else if (_rx > _ev.right) _dx = _rx - _ev.right;
                                                if (_ry < _ev.top) _dy = _ev.top - _ry;
                                                else if (_ry > _ev.bottom) _dy = _ry - _ev.bottom;
                                                if (max(_dx, _dy) < 10) { _too_close = true; break; }
                                            }
                                            
                                            if (!_too_close)
                                            {
                                                _target_gx = _rx;
                                                _target_gy = _ry;
                                                _found_spot = true;
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // If already at the spot, stand still
                            if (grid_x == _target_gx && grid_y == _target_gy)
                            {
                                _skip_path = true;
                            }
                        }
                        else
                        {
                            // === FOLLOWER LOGIC ===
                            // Target the current position of the leader (or the rally)
                            _target_gx = _k.expansion_rally_x;
                            _target_gy = _k.expansion_rally_y;
                            
                            // If close enough, stand still
                            if (point_distance(grid_x, grid_y, _target_gx, _target_gy) <= 3)
                            {
                                _skip_path = true;
                            }
                        }

                        _allow_resource_path = true;
                        _must_reach          = true;
                    }
                }

                // 2. IF NOT A COLONIST, DO BEACON LOGIC
                if (!_is_colonist)
                {
                    if (global.village_founder_id == id)
                    {
                        _target_gx = grid_x;
                        _target_gy = grid_y;
                        _skip_path = true;
                    }
                    else if (global.village_founder_id == noone
                          || !instance_exists(global.village_founder_id))
                    {
                        if (global.village_founder_id != noone)
                        {
                            global.village_founder_id = noone;
                            global.village_founder_x  = -1;
                            global.village_founder_y  = -1;
                        }
                        _target_gx = grid_x + irandom_range(-2, 2);
                        _target_gy = grid_y + irandom_range(-2, 2);
                    }
                    else
                    {
                        _target_gx           = global.village_founder_x;
                        _target_gy           = global.village_founder_y;
                        _allow_resource_path = true;
                        _must_reach          = true;

                        if (_target_gx == grid_x && _target_gy == grid_y)
                        {
                            wander_pause_timer = 5;
                            _skip_path         = true;
                        }
                    }
                }
            }
            else
            {
                var _kingdom = global.kingdoms[kingdom_id];

                if (_kingdom.expansion_rally_active)
                {
                    var _rx = _kingdom.expansion_rally_x;
                    var _ry = _kingdom.expansion_rally_y;

                    if (_rx < 0 || _rx >= obj_world.world_width
                     || _ry < 0 || _ry >= obj_world.world_height)
                    {
                        _kingdom.expansion_rally_active = false;
                        _target_gx = grid_x + irandom_range(-wander_radius, wander_radius);
                        _target_gy = grid_y + irandom_range(-wander_radius, wander_radius);
                    }
                    else if (_rx == grid_x && _ry == grid_y)
                    {
                        _kingdom.expansion_rally_active = false;
                        _target_gx = grid_x + irandom_range(-wander_radius, wander_radius);
                        _target_gy = grid_y + irandom_range(-wander_radius, wander_radius);
                    }
                    else
                    {
                        _target_gx  = _rx;
                        _target_gy  = _ry;
                        _must_reach = true;
                    }
                }
                else
                {
                    var _wr = max(1, wander_radius);
                    _target_gx = grid_x + irandom_range(-_wr, _wr);
                    _target_gy = grid_y + irandom_range(-_wr, _wr);

                    var _v = global.villages[village_id];
                    _target_gx = clamp(_target_gx, _v.left, _v.right);
                    _target_gy = clamp(_target_gy, _v.top,  _v.bottom);
                }
            }

            if (_must_reach
             && (!scr_tile_allowed_for_unit(self, _target_gx, _target_gy, _allow_resource_path) && !_allow_resource_path
              || !scr_line_is_clear(grid_x, grid_y, _target_gx, _target_gy) && !_allow_resource_path))
            {
                var _wr = max(1, wander_radius);
                _target_gx  = grid_x + irandom_range(-_wr, _wr);
                _target_gy  = grid_y + irandom_range(-_wr, _wr);
                _must_reach = false;
            }

            if (_target_gx == grid_x && _target_gy == grid_y && !_skip_path)
            {
                wander_pause_timer = 5;
                _skip_path         = true;
            }
        }
        // ----------------------------------------------------
        // DEFAULT — soldier, farmer, etc.
        // ----------------------------------------------------
        else
        {
            var _wr = max(1, wander_radius);
            _target_gx = grid_x + irandom_range(-_wr, _wr);
            _target_gy = grid_y + irandom_range(-_wr, _wr);
            if (village_id != -1)
            {
                var _v = global.villages[village_id];
                _target_gx = clamp(_target_gx, _v.left, _v.right);
                _target_gy = clamp(_target_gy, _v.top,  _v.bottom);
            }
        }

        // ============================================================
        // TARGET CLAMP: force non-miners to target tiles inside their village
        // ============================================================
        if (village_id != -1 && unit_type != "miner" && !_allow_resource_path)
        {
            var _v = global.villages[village_id];
            _target_gx = clamp(_target_gx, _v.left, _v.right);
            _target_gy = clamp(_target_gy, _v.top,  _v.bottom);
        }

        // ----------------------------------------------------
        // Validate target against the gate.
        // ----------------------------------------------------
        if (!_skip_path && !_allow_resource_path)
        {
            if (!scr_tile_allowed_for_unit(self, _target_gx, _target_gy))
            {
                var _ok  = false;
                var _wr2 = max(1, wander_radius);

                for (var _t = 0; _t < 8; _t++)
                {
                    var _tx2 = grid_x + irandom_range(-_wr2, _wr2);
                    var _ty2 = grid_y + irandom_range(-_wr2, _wr2);

                    if (village_id != -1)
                    {
                        var _v2 = global.villages[village_id];
                        _tx2 = clamp(_tx2, _v2.left, _v2.right);
                        _ty2 = clamp(_ty2, _v2.top,  _v2.bottom);
                    }

                    if (scr_tile_allowed_for_unit(self, _tx2, _ty2))
                    {
                        _target_gx = _tx2;
                        _target_gy = _ty2;
                        _ok        = true;
                        break;
                    }
                }

                if (!_ok)
                {
                    wander_pause_timer = 15;
                    _skip_path         = true;
                }
            }
        }

        // ----------------------------------------------------
        // Path generation
        // ----------------------------------------------------
        if (!_skip_path)
        {
            if (_target_gx < 0 || _target_gx >= obj_world.world_width)  _target_gx = grid_x;
            if (_target_gy < 0 || _target_gy >= obj_world.world_height) _target_gy = grid_y;

            if (scr_tile_allowed_for_unit(self, _target_gx, _target_gy, _allow_resource_path))
            {
                if (scr_line_is_clear(grid_x, grid_y, _target_gx, _target_gy))
                {
                    walk_path      = [[_target_gx, _target_gy]];
                    walk_index     = 0;
                    path_allow_res = _allow_resource_path;
                    path_cooldown  = irandom_range(5, 15);
                }
                else
                {
                    var _new_path = scr_find_path(grid_x, grid_y, _target_gx, _target_gy, _allow_resource_path);

                    if (array_length(_new_path) > 0)
                    {
                        // Post-filter: truncate at the first disallowed tile.
                        var _safe = [];
                        for (var _p = 0; _p < array_length(_new_path); _p++)
                        {
                            var _pgx = _new_path[_p][0];
                            var _pgy = _new_path[_p][1];
                            if (!scr_tile_allowed_for_unit(self, _pgx, _pgy, _allow_resource_path)) break;
                            array_push(_safe, _new_path[_p]);
                        }
                        if (array_length(_safe) > 0)
                        {
                            walk_path      = _safe;
                            walk_index     = 0;
                            path_allow_res = _allow_resource_path;
                            path_cooldown  = irandom_range(5, 15);
                        }
                    }
                }
            }

            // Fallback wiggle.
            if (array_length(walk_path) == 0)
            {
                for (var _i = 0; _i < 12; _i++)
                {
                    var _wx = grid_x + irandom_range(-2, 2);
                    var _wy = grid_y + irandom_range(-2, 2);
                    if (_wx == grid_x && _wy == grid_y)                    continue;
                    if (!scr_tile_allowed_for_unit(self, _wx, _wy))        continue;
                    if (!scr_line_is_clear(grid_x, grid_y, _wx, _wy))      continue;

                    walk_path      = [[_wx, _wy]];
                    walk_index     = 0;
                    path_allow_res = false;
                    path_cooldown  = irandom_range(5, 15);
                    break;
                }
            }

            if (array_length(walk_path) == 0) wander_pause_timer = 15;
        }
    }
}

// ============================================================
// 2. MOVEMENT
// ============================================================
var _moving = false;

if (walk_index < array_length(walk_path))
{
    var _target_gx = walk_path[walk_index][0];
    var _target_gy = walk_path[walk_index][1];

    // ============================================================
    // STEP CLAMP: ultimate safeguard — never step outside village bounds
    // ============================================================
    if (village_id != -1 && unit_type != "miner" && !path_allow_res)
    {
        var _v = global.villages[village_id];
        if (_target_gx < _v.left || _target_gx > _v.right
         || _target_gy < _v.top  || _target_gy > _v.bottom)
        {
            walk_path          = [];
            walk_index         = 0;
            path_allow_res     = false;
            wander_pause_timer = 5;
        }
    }

    if (!scr_tile_allowed_for_unit(self, _target_gx, _target_gy, path_allow_res))
    {
        walk_path          = [];
        walk_index         = 0;
        path_allow_res     = false;
        wander_pause_timer = 5;
    }
    else
    {
        var _tx   = _target_gx * obj_world.tile_size;
        var _ty   = _target_gy * obj_world.tile_size;
        var _dx   = _tx - x;
        var _dy   = _ty - y;
        var _dist = point_distance(x, y, _tx, _ty);

        if (_dist <= move_speed)
        {
            x        = _tx;
            y        = _ty;
            grid_x   = _target_gx;
            grid_y   = _target_gy;
            walk_index++;

            if (walk_index >= array_length(walk_path))
            {
                walk_path          = [];
                walk_index         = 0;
                path_allow_res     = false;
                wander_pause_timer = irandom_range(wander_pause_min, wander_pause_max);
            }
        }
        else
        {
            x += (_dx / _dist) * move_speed;
            y += (_dy / _dist) * move_speed;
            _moving = true;
            if (abs(_dx) > 0.1) image_xscale = sign(_dx);
        }
    }
}

// ============================================================
// 3. STATE + SPRITE
// ============================================================
state = _moving ? "walk" : "idle";

var _target_spr = (state == "walk") ? spr_walk : spr_idle;

if (sprite_index != _target_spr) {
    sprite_index = _target_spr;
    image_index  = 0;
}