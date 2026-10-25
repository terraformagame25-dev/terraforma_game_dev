/// @func scr_set_expansion_requests()
function scr_set_expansion_requests()
{
    for (var _i = 0; _i < array_length(global.villages); _i++)
    {
        var _v = global.villages[_i];
        
        // 1. Only capitals can spawn children
        if (!_v.is_capital) continue;
        if (_v.expansion_request) continue;

        // 2. Check max child village count
        var _kingdom = global.kingdoms[_v.kingdom_id];
        var _max_children = scr_max_child_villages_for_level(_kingdom.advancement_level);
        var _current_children = array_length(_kingdom.village_ids) - 1;
        
        if (_current_children >= _max_children) 
        {
            // Uncomment the line below if you want to see why it's failing
            // show_debug_message("Expansion fail for " + string(_v.id) + ": Max children reached (" + string(_current_children) + "/" + string(_max_children) + ")");
            continue;
        }

        // 3. Must have completed town hall
        var _has_town_hall = false;
        for (var _bi = 0; _bi < array_length(_v.building_list); _bi++)
        {
            var _b = _v.building_list[_bi];
            if (instance_exists(_b) && _b.building_type == "town_hall")
            {
                if (_b.state != "construction") _has_town_hall = true;
            }
        }
        if (!_has_town_hall) 
        {
            show_debug_message("Expansion fail for " + string(_v.id) + ": Town hall not complete.");
            continue;
        }

        // 4. Must have max houses for the current level
        var _max_houses = scr_max_houses_for_level(_kingdom.advancement_level);
        var _current_houses = scr_village_house_count(_v);
        if (_current_houses < _max_houses) 
        {
            show_debug_message("Expansion fail for " + string(_v.id) + ": Houses " + string(_current_houses) + "/" + string(_max_houses));
            continue;
        }

        // 5. Must have at least 10 villagers
        var _villagers = 0;
        for (var _mi = 0; _mi < array_length(_v.member_ids); _mi++)
        {
            var _uid = _v.member_ids[_mi];
            if (instance_exists(_uid) && _uid.unit_type == "villager" && !_uid.is_leader)
            {
                _villagers++;
            }
        }
        if (_villagers < 10) 
        {
            show_debug_message("Expansion fail for " + string(_v.id) + ": Only " + string(_villagers) + "/10 villagers.");
            continue;
        }

        // All conditions met — request expansion
        show_debug_message("EXPANSION REQUESTED for village " + string(_v.id));
        _v.expansion_request = true;
        global.villages[_i] = _v;
    }
}