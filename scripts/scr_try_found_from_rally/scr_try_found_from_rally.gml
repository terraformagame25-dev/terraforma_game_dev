/// @func scr_try_found_from_rally()
/// @desc Called once per village scan. When enough colonists have gathered at
///       the leader-chosen rally spot, found a child village. If the rally takes
///       too long, send every colonist home so none are stranded.
function scr_try_found_from_rally()
{
    var _found_min    = 8;    // colonists are 10; tolerate a couple of stragglers
    var _arrival_r    = 3;
    var _timeout_scan = 90;   // scans (~90 s at the default scan interval)

    for (var _k = 0; _k < array_length(global.kingdoms); _k++)
    {
        var _kingdom = global.kingdoms[_k];
        if (!_kingdom.expansion_rally_active) continue;

        _kingdom.expansion_rally_age++;

        var _rx = _kingdom.expansion_rally_x;
        var _ry = _kingdom.expansion_rally_y;

        // ---- Timeout: send colonists home, cancel the rally ----
        if (_kingdom.expansion_rally_age > _timeout_scan)
        {
            var _src = _kingdom.expansion_source_village_id;
            if (_src == -1 || _src >= array_length(global.villages)) _src = _kingdom.capital_village_id;

            var _stragglers = [];
            with (obj_unit)
            {
                if (unit_type == "villager" && village_id == -1 && kingdom_id == _k)
                    array_push(_stragglers, id);
            }

            for (var _si = 0; _si < array_length(_stragglers); _si++)
            {
                var _s = _stragglers[_si];
                if (!instance_exists(_s)) continue;
                _s.colonist_leader = false;
                _s.walk_path       = [];
                _s.walk_index      = 0;
                if (_src != -1) scr_assign_unit_to_village(_s, _src);   // yank-back teleports them home
            }

            _kingdom.expansion_rally_active = false;
            _kingdom.expansion_rally_x      = -1;
            _kingdom.expansion_rally_y      = -1;
            _kingdom.expansion_rally_age    = 0;
            global.kingdoms[_k] = _kingdom;
            continue;
        }

        global.kingdoms[_k] = _kingdom;

        // Leader hasn't picked a spot yet
        if (_rx == -1) continue;

        // ---- Count arrivals ----
        var _arrived = [];
        var _leader  = noone;

        with (obj_unit)
        {
            if (unit_type != "villager") continue;
            if (kingdom_id != _k)        continue;
            if (village_id != -1)        continue;

            if (point_distance(_rx, _ry, grid_x, grid_y) <= _arrival_r)
            {
                array_push(_arrived, id);
                if (colonist_leader) _leader = id;
            }
        }

        if (array_length(_arrived) < _found_min) continue;
        if (_leader == noone) continue;   // leader must be present to found

        // ---- Found the child village ----
        var _child_id = scr_create_village(_rx, _ry, 5, "villager", _k, false);
        var _child    = global.villages[_child_id];

        for (var _ai = 0; _ai < array_length(_arrived); _ai++)
        {
            var _u = _arrived[_ai];
            if (!instance_exists(_u)) continue;

            _u.village_id      = _child_id;
            _u.kingdom_id      = _k;
            _u.walk_path       = [];
            _u.walk_index      = 0;
            _u.path_allow_res  = false;

            if (_u == _leader)
            {
                _u.unit_type       = "leader";
                scr_apply_unit_type(_u, "leader");
                _u.leader_anchor_x = _u.grid_x;
                _u.leader_anchor_y = _u.grid_y;
            }
            else
            {
                scr_apply_unit_type(_u, "villager");   // resets colonist permissions
            }
            _u.colonist_leader = false;

            array_push(_child.member_ids, _u.id);
        }
        global.villages[_child_id] = _child;

        // Any colonist who didn't make it simply goes home
        var _late = [];
        with (obj_unit)
        {
            if (unit_type == "villager" && village_id == -1 && kingdom_id == _k)
                array_push(_late, id);
        }
        var _home = _kingdom.expansion_source_village_id;
        if (_home == -1 || _home >= array_length(global.villages)) _home = _kingdom.capital_village_id;
        for (var _li = 0; _li < array_length(_late); _li++)
        {
            var _lu = _late[_li];
            if (!instance_exists(_lu)) continue;
            _lu.colonist_leader = false;
            _lu.walk_path       = [];
            _lu.walk_index      = 0;
            scr_assign_unit_to_village(_lu, _child_id);   // join the new village instead
        }

        _kingdom.expansion_rally_active = false;
        _kingdom.expansion_rally_x      = -1;
        _kingdom.expansion_rally_y      = -1;
        _kingdom.expansion_rally_age    = 0;
        global.kingdoms[_k] = _kingdom;
    }
}
