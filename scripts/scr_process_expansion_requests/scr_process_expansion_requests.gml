/// @func scr_process_expansion_requests()
/// @desc For each kingdom whose capital requests expansion: pick 10 spare
///       villagers as colonists, choose a leader FROM those colonists, detach
///       them from the capital and start a rally. The leader chooses the actual
///       founding spot later (rally_x/y = -1 means "not chosen yet").
function scr_process_expansion_requests()
{
    var _min_villagers = 10;

    for (var _k = 0; _k < array_length(global.kingdoms); _k++)
    {
        var _kingdom = global.kingdoms[_k];
        if (_kingdom.expansion_rally_active) continue;

        var _cap_id = _kingdom.capital_village_id;
        if (_cap_id == -1 || _cap_id >= array_length(global.villages)) continue;

        var _cap = global.villages[_cap_id];
        if (!_cap.expansion_request) continue;

        var _spare = [];
        for (var _mi = 0; _mi < array_length(_cap.member_ids); _mi++)
        {
            var _u = _cap.member_ids[_mi];
            if (instance_exists(_u) && _u.unit_type == "villager" && !_u.is_leader)
                array_push(_spare, _u);
        }

        if (array_length(_spare) < _min_villagers)
        {
            _cap.expansion_request = false;
            global.villages[_cap_id] = _cap;
            continue;
        }

        // Colonists = first N spare villagers; leader = lowest id AMONG THEM
        var _colonists = [];
        for (var _i = 0; _i < _min_villagers; _i++) array_push(_colonists, _spare[_i]);

        var _leader = _colonists[0];
        for (var _i = 1; _i < array_length(_colonists); _i++)
            if (_colonists[_i].id < _leader.id) _leader = _colonists[_i];

        _kingdom.expansion_rally_active      = true;
        _kingdom.expansion_rally_x           = -1;   // leader picks the spot
        _kingdom.expansion_rally_y           = -1;
        _kingdom.expansion_rally_age         = 0;
        _kingdom.expansion_source_village_id = _cap_id;
        global.kingdoms[_k] = _kingdom;

        var _new_members = [];
        for (var _ci = 0; _ci < array_length(_cap.member_ids); _ci++)
        {
            var _uid = _cap.member_ids[_ci];

            var _is_colonist = false;
            for (var _si = 0; _si < array_length(_colonists); _si++)
            {
                if (_uid == _colonists[_si]) { _is_colonist = true; break; }
            }

            if (_is_colonist && instance_exists(_uid))
            {
                _uid.village_id            = -1;   // kingdom_id stays: marks them as colonists
                _uid.can_leave_territory   = true;
                _uid.can_walk_on_resources = true;
                _uid.colonist_leader       = (_uid == _leader);
                _uid.walk_path             = [];
                _uid.walk_index            = 0;
                _uid.path_allow_res        = false;
                _uid.wander_pause_timer    = 0;
                _uid.path_cooldown         = 0;
            }
            else
            {
                array_push(_new_members, _uid);
            }
        }

        _cap.member_ids        = _new_members;
        _cap.expansion_request = false;
        global.villages[_cap_id] = _cap;
    }
}
