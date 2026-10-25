/// @func scr_try_form_villages()
/// @desc Runs periodically. Handles founding, expansion, migration, etc.
function scr_try_form_villages()
{

    // === Build unit list (snapshot) ===
    var _count = instance_number(obj_unit);
    var _units = array_create(_count);
    var _i = 0;
    with (obj_unit) { _units[_i] = id; _i++; }

    // ================================================================
    // Tunables
    // ================================================================
    var _cluster_radius      = 15;
    var _assimilation_radius = 30;
    var _founding_min        = 5;
    var _village_radius      = 5;
    var _migration_batch     = 10;

    // ================================================================
    // PASS 1: Unaffiliated villagers — lead-based founding & convergence
    // ================================================================
    var _lead = noone;

	for (var _li = 0; _li < _count; _li++)
	{
	    var _lu = _units[_li];
	    if (_lu.unit_type != "villager") continue;
	    if (_lu.village_id != -1)        continue;

        // Skip colonists actively marching to a rally point
        if (_lu.kingdom_id != -1) // <--- ADD THIS CHECK
        {
            var _lu_k = global.kingdoms[_lu.kingdom_id];
            if (_lu_k.expansion_rally_active) continue;
        }

	    // Skip units that are clearly broken / not yet placed.
	    if (!instance_exists(_lu))             continue;
	    if (_lu.x <= 0 && _lu.y <= 0)          continue;   // at world origin
	    if (_lu.grid_x <= 0 && _lu.grid_y <= 0) continue;  // at grid origin
	    if (_lu.walk_path == undefined)        continue;

	    if (_lead == noone || _lu.id < _lead.id)
	    {
	        _lead = _lu;
	    }
	}


    if (_lead != noone)
    {
        // Publish the beacon to obj_unit. Names MUST match the reader in Step.
        global.village_founder_id = _lead.id;
        global.village_founder_x  = _lead.grid_x;
        global.village_founder_y  = _lead.grid_y;

        // Refresh each call so followers always target the current tile.
        // (Leader is frozen in Step, but this is cheap insurance.)
        _lead.walk_path  = [];
        _lead.walk_index = 0;

        var _near = [];

        for (var _ni = 0; _ni < _count; _ni++)
        {
            var _nu = _units[_ni];
            if (_nu.unit_type != "villager") continue;
            if (_nu.village_id != -1)        continue;
			
            // Skip colonists actively marching to a rally point
            if (_nu.kingdom_id != -1) // <--- ADD THIS CHECK
            {
                var _nu_k = global.kingdoms[_nu.kingdom_id];
                if (_nu_k.expansion_rally_active) continue;
            }

            var _d = point_distance(_lead.grid_x, _lead.grid_y, _nu.grid_x, _nu.grid_y);

            if (_d <= _cluster_radius)
            {
                array_push(_near, _nu);
            }

            // Force convergence: if a follower is far, shove a path onto it so
            // they don't waste cycles choosing a random wander target first.
            // The Step code will also target the beacon once its current path empties.
            if (_nu.id != _lead.id && array_length(_nu.walk_path) == 0 && _d > _cluster_radius * 0.5)
            {
                var _path = scr_find_path(_nu.grid_x, _nu.grid_y, _lead.grid_x, _lead.grid_y, true);
				
				if (array_length(_path) > 0)
                {
                    _nu.walk_path          = _path;
                    _nu.walk_index         = 0;
                    _nu.wander_pause_timer = 0;
                    _nu.path_cooldown      = 0;
                }
            }
        }


        // Found when we have enough clustered.
        if (array_length(_near) >= _founding_min)
        {
            var _too_close = false;
            var _closest_village = -1;
            var _closest_dist    = 99999;

            for (var _vi = 0; _vi < array_length(global.villages); _vi++)
            {
                var _v  = global.villages[_vi];
                var _dx = 0;
                var _dy = 0;

                if (_lead.grid_x < _v.left)       _dx = _v.left - _lead.grid_x;
                else if (_lead.grid_x > _v.right) _dx = _lead.grid_x - _v.right;

                if (_lead.grid_y < _v.top)         _dy = _v.top - _lead.grid_y;
                else if (_lead.grid_y > _v.bottom) _dy = _lead.grid_y - _v.bottom;

                var _cheb = max(_dx, _dy);

                if (_cheb < _closest_dist)
                {
                    _closest_dist    = _cheb;
                    _closest_village = _vi;
                }

                if (_cheb < _assimilation_radius)
                {
                    _too_close = true;
                }
            }

            if (!_too_close)
            {
                var _spot = scr_find_town_hall_spot(_lead.grid_x, _lead.grid_y);

                if (_spot[0] != -1)
                {
                    var _new_id = scr_create_village(
                        _lead.grid_x, _lead.grid_y, _village_radius, "villager", -1, true
                    );
                    var _new_v = global.villages[_new_id];

                    // Lead becomes leader.
                    _lead.unit_type  = "leader";
                    _lead.village_id = _new_id;
                    _lead.kingdom_id = _new_v.kingdom_id;
                    _lead.is_leader  = true;
                    _lead.home_x     = _lead.grid_x;
                    _lead.home_y     = _lead.grid_y;
                    _lead.walk_path  = [];
                    _lead.walk_index = 0;

                    array_push(_new_v.member_ids, _lead.id);
                    global.villages[_new_id] = _new_v;

                    scr_apply_unit_type(_lead, "leader");

                    // Absorb nearby unaffiliated villagers.
                    for (var _ai = 0; _ai < array_length(_near); _ai++)
                    {
                        var _au = _near[_ai];
                        if (!instance_exists(_au) || _au.id == _lead.id) continue;

                        _au.village_id = _new_id;
                        _au.kingdom_id = _new_v.kingdom_id;
                        array_push(global.villages[_new_id].member_ids, _au.id);
                    }

                    // Clear beacon — a village exists now.
                    global.village_founder_id = noone;
                    global.village_founder_x  = -1;
                    global.village_founder_y  = -1;
                }
                else
                {
                    show_debug_message("Founding blocked: no valid town hall spot near lead.");
                }
            }
            else if (_closest_village != -1)
            {
                // Too close to an existing village — assimilate the cluster
                // into the nearest one instead of leaving them stranded forever.
                var _target_v = global.villages[_closest_village];

                for (var _ai2 = 0; _ai2 < array_length(_near); _ai2++)
                {
                    var _au2 = _near[_ai2];
                    if (!instance_exists(_au2)) continue;

                    _au2.village_id = _closest_village;
                    _au2.kingdom_id = _target_v.kingdom_id;

                    var _already_member = false;
                    for (var _mi = 0; _mi < array_length(_target_v.member_ids); _mi++)
                    {
                        if (_target_v.member_ids[_mi] == _au2.id) { _already_member = true; break; }
                    }
                    if (!_already_member)
                    {
                        array_push(_target_v.member_ids, _au2.id);
                    }
                }

                global.villages[_closest_village] = _target_v;

                global.village_founder_id = noone;
                global.village_founder_x  = -1;
                global.village_founder_y  = -1;

                show_debug_message("Cluster near village " + string(_closest_village) + " — assimilated " + string(array_length(_near)));
            }
        }
    }
    else
    {
        global.village_founder_id = noone;
        global.village_founder_x  = -1;
        global.village_founder_y  = -1;
    }

    // ================================================================
    // PASS 2: Found children from rally (Delegated to helper function)
    // ================================================================
    scr_try_found_from_rally();

    // ================================================================
    // PASS 3: Migration
    // ================================================================
    for (var _mvi = 0; _mvi < array_length(global.villages); _mvi++)
    {
        var _src = global.villages[_mvi];

        var _over_capacity = (array_length(_src.member_ids) >= scr_village_housing_cap(_src));
        var _is_cramped    = _src.cramped;

        if (!_over_capacity && !_is_cramped) continue;
        if (array_length(_src.member_ids) <= _founding_min) continue;

        var _best_sibling_id = -1;
        var _best_dist       = 99999;

        for (var _sj = 0; _sj < array_length(global.villages); _sj++)
        {
            if (_sj == _mvi) continue;

            var _sib = global.villages[_sj];
            if (_sib.kingdom_id != _src.kingdom_id) continue;
            if (array_length(_sib.member_ids) >= scr_village_housing_cap(_sib)) continue;

            var _d = point_distance(_src.cx, _src.cy, _sib.cx, _sib.cy);
            if (_d < _best_dist)
            {
                _best_dist       = _d;
                _best_sibling_id = _sj;
            }
        }

        if (_best_sibling_id == -1) continue;

        var _dest = global.villages[_best_sibling_id];
        var _migrated  = 0;
        var _remaining = [];

        for (var _ui = 0; _ui < array_length(_src.member_ids); _ui++)
        {
            var _unit_id = _src.member_ids[_ui];

            if (_migrated >= _migration_batch)
            {
                array_push(_remaining, _unit_id);
                continue;
            }

            var _unit = _unit_id;
            if (!instance_exists(_unit)) continue;
            if (_unit.is_leader)
            {
                array_push(_remaining, _unit.id);
                continue;
            }

            _unit.village_id = _best_sibling_id;
            _unit.kingdom_id = _dest.kingdom_id;
            array_push(_dest.member_ids, _unit.id);

            var _path = scr_find_path(_unit.grid_x, _unit.grid_y, _dest.cx, _dest.cy, true);
            
			if (array_length(_path) > 0)
            {
                _unit.walk_path          = _path;
                _unit.walk_index         = 0;
                _unit.wander_pause_timer = 0;
                _unit.path_cooldown      = 0;
            }

            _migrated++;
        }

        _src.member_ids = _remaining;
        global.villages[_mvi]              = _src;
        global.villages[_best_sibling_id] = _dest;
    }

    // ================================================================
    // PASS 4: Role assignment
    // ================================================================
    for (var _ri = 0; _ri < array_length(global.villages); _ri++)
    {
        scr_assign_roles(_ri);
    }

    // ================================================================
    // PASS 5 & 6: Village expansion & requests
    // ================================================================
    scr_try_expand_village();
    scr_set_expansion_requests();

    // ================================================================
    // PASS 7: Process requests (every 10 sec)
    // ================================================================
    if (!variable_global_exists("expansion_scan_timer"))
    {
        global.expansion_scan_timer = 0;
    }

    global.expansion_scan_timer++;
    if (global.expansion_scan_timer >= 10)
    {
        global.expansion_scan_timer = 0;
        scr_process_expansion_requests();
    }

    // ================================================================
    // PASS 8 & 9: House placement & Building completion
    // ================================================================
    scr_try_place_houses();
    scr_try_complete_buildings();
}