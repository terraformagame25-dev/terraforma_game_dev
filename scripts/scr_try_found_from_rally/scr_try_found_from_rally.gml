/// @func scr_try_found_from_rally()
function scr_try_found_from_rally()
{
    var _found_min    = 10;
    var _arrival_r    = 3; // Tight radius so they must gather closely

    for (var _k = 0; _k < array_length(global.kingdoms); _k++)
    {
        var _kingdom = global.kingdoms[_k];
        if (!_kingdom.expansion_rally_active) continue;

        var _rx = _kingdom.expansion_rally_x;
        var _ry = _kingdom.expansion_rally_y;
        var _cap_id = _kingdom.capital_village_id;

        // Count villagers at the rally
        var _arrived = [];
        var _leader = noone;
        
        with (obj_unit)
        {
            if (unit_type != "villager")    continue;
            if (kingdom_id != _k)          continue;
            if (village_id != -1)          continue; 
            if (!_kingdom.expansion_rally_active) continue;

            var _d = point_distance(_rx, _ry, grid_x, grid_y);
            if (_d <= _arrival_r)
            {
                array_push(_arrived, id);
                if (colonist_leader) _leader = id;
            }
        }

        if (array_length(_arrived) < _found_min) continue;

        // === Found the child ===
        var _child_id = scr_create_village(_rx, _ry, 5, "villager", _k, false);
        var _child = global.villages[_child_id];

        // Absorb the arriving villagers into the child village
        for (var _ai = 0; _ai < array_length(_arrived); _ai++)
        {
            var _u = _arrived[_ai];
            if (!instance_exists(_u)) continue;

            // If this was the leader, promote them
            if (_u.id == _leader)
            {
                _u.unit_type  = "leader";
                _u.is_leader  = true;
                scr_apply_unit_type(_u, "leader");
            }

            _u.village_id = _child_id;
            _u.kingdom_id = _k;
            _u.walk_path  = [];
            _u.walk_index = 0;
            _u.colonist_leader = false;

            array_push(_child.member_ids, _u.id);
            global.villages[_child_id] = _child;
        }

        // Clear the rally
        _kingdom.expansion_rally_active = false;
        _kingdom.expansion_rally_x = -1;
        _kingdom.expansion_rally_y = -1;
        global.kingdoms[_k] = _kingdom;
    }
}