/// @func scr_process_expansion_requests()
function scr_process_expansion_requests()
{
    var _min_villagers = 10;
    var _buffer_radius = 10; 

    for (var _k = 0; _k < array_length(global.kingdoms); _k++)
    {
        var _kingdom = global.kingdoms[_k];
        if (_kingdom.expansion_rally_active) continue;

        var _cap_id = _kingdom.capital_village_id;
        if (_cap_id == -1 || _cap_id >= array_length(global.villages)) continue;

        var _cap = global.villages[_cap_id];
        if (!_cap.expansion_request) continue;

        var _spare_villagers = [];
        for (var _mi = 0; _mi < array_length(_cap.member_ids); _mi++)
        {
            var _u = _cap.member_ids[_mi];
            if (instance_exists(_u) && _u.unit_type == "villager" && !_u.is_leader)
            {
                array_push(_spare_villagers, _u);
            }
        }

        if (array_length(_spare_villagers) < _min_villagers)
        {
            _cap.expansion_request = false;
            global.villages[_cap_id] = _cap;
            continue;
        }

        var _lowest_id = 9999999;
        var _leader_id = noone;
        for (var _i = 0; _i < array_length(_spare_villagers); _i++)
        {
            var _test_id = _spare_villagers[_i].id;
            if (_test_id < _lowest_id) {
                _lowest_id = _test_id;
                _leader_id = _spare_villagers[_i];
            }
        }

        _kingdom.expansion_rally_active = true;
        _kingdom.expansion_rally_x = _spare_villagers[0].grid_x; 
        _kingdom.expansion_rally_y = _spare_villagers[0].grid_y;
        
        _cap.expansion_request = false;
        global.villages[_cap_id] = _cap;
        global.kingdoms[_k] = _kingdom;

        var _new_cap_members = [];
        var _w = obj_world.world_width;

        for (var _ci = 0; _ci < array_length(_cap.member_ids); _ci++)
        {
            var _uid = _cap.member_ids[_ci];
            var _is_colonist = false;
            
            for (var _si = 0; _si < _min_villagers; _si++) {
                if (_uid == _spare_villagers[_si]) { _is_colonist = true; break; }
            }

            if (_is_colonist)
            {
                var _u = _uid;
                _u.village_id = -1; 
                _u.can_leave_territory = true;      
                _u.can_walk_on_resources = true;    
                
                if (_uid == _leader_id) _u.colonist_leader = true;
                else                    _u.colonist_leader = false;

                _u.walk_path = [];
                _u.walk_index = 0;
                _u.wander_pause_timer = 0;
                _u.path_cooldown = 0;
            }
            else {
                array_push(_new_cap_members, _uid);
            }
        }
        _cap.member_ids = _new_cap_members;
        global.villages[_cap_id] = _cap;
    }
}