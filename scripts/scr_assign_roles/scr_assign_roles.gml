/// @func scr_assign_roles(_village_id)
/// @desc Rebalances roles. First enforces hard minimums (e.g. 5 builders),
///       then fills the rest based on ratio targets.
function scr_assign_roles(_village_id)
{
    var _v = global.villages[_village_id];
    var _total = array_length(_v.member_ids);
    if (_total <= 1) return;

    // === Collect role pools ===
    var _pools = {
        soldier:  [],
        farmer:   [],
        miner:    [],
        builder:  [],
        villager: [],
    };

    for (var _i = 0; _i < _total; _i++)
    {
        var _u = _v.member_ids[_i];
        if (!instance_exists(_u)) continue;
        if (variable_struct_exists(_pools, _u.unit_type))
        {
            array_push(_pools[$ _u.unit_type], _u);
        }
    }

    var _assignable = array_length(_pools.soldier)
                    + array_length(_pools.farmer)
                    + array_length(_pools.miner)
                    + array_length(_pools.builder)
                    + array_length(_pools.villager);
    if (_assignable <= 1) return;

    // ============================================================
    // STEP 1: Hard Minimums (Builders > Miners > Farmers > Soldiers)
    // ============================================================
    var _available_villagers = [];
    for (var _i = 0; _i < array_length(_pools.villager); _i++)
    {
        array_push(_available_villagers, _pools.villager[_i]);
    }
    var _villager_idx = 0;

    var _min_builders = 5;
    var _min_miners   = 3;
    var _min_farmers  = 2;
    var _min_soldiers = 2;

    var _checks = [
        { type: "builder", min: _min_builders, current: array_length(_pools.builder) },
        { type: "miner",   min: _min_miners,   current: array_length(_pools.miner)   },
        { type: "farmer",  min: _min_farmers,  current: array_length(_pools.farmer)  },
        { type: "soldier", min: _min_soldiers, current: array_length(_pools.soldier) }
    ];

    for (var _ci = 0; _ci < array_length(_checks); _ci++)
    {
        var _entry = _checks[_ci];
        var _need = _entry.min - _entry.current;

        while (_need > 0 && _villager_idx < array_length(_available_villagers))
        {
            var _u = _available_villagers[_villager_idx];
            _villager_idx++;

            if (!instance_exists(_u)) continue;

            _u.unit_type = _entry.type;
            scr_apply_unit_type(_u, _entry.type);
            _need--;
        }
    }

    // Refresh villager pool after minimums
    var _remaining_villagers = [];
    for (var _i = _villager_idx; _i < array_length(_available_villagers); _i++)
    {
        if (instance_exists(_available_villagers[_i]))
        {
            array_push(_remaining_villagers, _available_villagers[_i]);
        }
    }
    _pools.villager = _remaining_villagers;

    // ============================================================
    // STEP 2: Ratio Targets
    // ============================================================
    _pools.soldier = []; _pools.farmer = []; _pools.miner = []; _pools.builder = [];
    for (var _i = 0; _i < _total; _i++)
    {
        var _u = _v.member_ids[_i];
        if (!instance_exists(_u)) continue;
        if (variable_struct_exists(_pools, _u.unit_type))
        {
            array_push(_pools[$ _u.unit_type], _u);
        }
    }

    var _t_miner   = floor(_assignable * 0.20);
    var _t_builder = floor(_assignable * 0.10);
    var _t_farmer  = floor(_assignable * 0.25);
    var _t_soldier = floor(_assignable * 0.30);
    var _t_villager = _assignable - _t_miner - _t_builder - _t_farmer - _t_soldier;

    // Ensure targets don't drop below minimums
    _t_builder = max(_t_builder, _min_builders);
    _t_miner   = max(_t_miner,   _min_miners);
    _t_farmer  = max(_t_farmer,  _min_farmers);
    _t_soldier = max(_t_soldier, _min_soldiers);
    
    _t_villager = _assignable - _t_miner - _t_builder - _t_farmer - _t_soldier;
    if (_t_villager < 0) _t_villager = 0;

    var _v_floor = floor(_assignable * 0.15);
    while (_t_villager < _v_floor)
    {
        if (_t_builder > _min_builders) { _t_builder--; _t_villager++; }
        else if (_t_miner > _min_miners) { _t_miner--; _t_villager++; }
        else if (_t_farmer > _min_farmers) { _t_farmer--; _t_villager++; }
        else if (_t_soldier > _min_soldiers) { _t_soldier--; _t_villager++; }
        else break;
    }

    var _n_miner   = array_length(_pools.miner);
    var _n_builder = array_length(_pools.builder);
    var _n_farmer  = array_length(_pools.farmer);
    var _n_soldier = array_length(_pools.soldier);
    var _n_villager = array_length(_pools.villager);

    // Fill shortages in ratio order: BUILDERS, MINERS, FARMERS, SOLDIERS
    var _villagers_available = _n_villager;

    var _add_builder = min(max(0, _t_builder - _n_builder), _villagers_available);
    _villagers_available -= _add_builder;

    var _add_miner = min(max(0, _t_miner - _n_miner), _villagers_available);
    _villagers_available -= _add_miner;

    var _add_farmer = min(max(0, _t_farmer - _n_farmer), _villagers_available);
    _villagers_available -= _add_farmer;

    var _add_soldier = min(max(0, _t_soldier - _n_soldier), _villagers_available);
    _villagers_available -= _add_soldier;

    _convert_n_units(_pools.villager, "builder", _add_builder);
    _convert_n_units(_pools.villager, "miner",   _add_miner);
    _convert_n_units(_pools.villager, "farmer",  _add_farmer);
    _convert_n_units(_pools.villager, "soldier", _add_soldier);

    // === Trim overages (only above targets) ===
    var _villagers_now = _n_villager - (_add_builder + _add_miner + _add_farmer + _add_soldier);
    var _villagers_to_add = max(0, _t_villager - _villagers_now);

    var _builder_after = _n_builder + _add_builder;
    var _builder_over  = max(0, _builder_after - _t_builder);
    var _trim_builder  = min(_builder_over, _villagers_to_add);
    _villagers_to_add -= _trim_builder;

    var _miner_after = _n_miner + _add_miner;
    var _miner_over  = max(0, _miner_after - _t_miner);
    var _trim_miner  = min(_miner_over, _villagers_to_add);
    _villagers_to_add -= _trim_miner;

    var _farmer_after = _n_farmer + _add_farmer;
    var _farmer_over  = max(0, _farmer_after - _t_farmer);
    var _trim_farmer  = min(_farmer_over, _villagers_to_add);
    _villagers_to_add -= _trim_farmer;

    var _soldier_after = _n_soldier + _add_soldier;
    var _soldier_over  = max(0, _soldier_after - _t_soldier);
    var _trim_soldier  = min(_soldier_over, _villagers_to_add);

    _convert_n_units(_pools.builder, "villager", _trim_builder);
    _convert_n_units(_pools.miner,   "villager", _trim_miner);
    _convert_n_units(_pools.farmer,  "villager", _trim_farmer);
    _convert_n_units(_pools.soldier, "villager", _trim_soldier);

    global.villages[_village_id] = _v;
}

/// @func _convert_n_units(_pool, _new_role, _count)
/// @desc Converts up to _count units from _pool to _new_role.
function _convert_n_units(_pool, _new_role, _count)
{
    var _done = 0;
    while (_done < _count && array_length(_pool) > 0)
    {
        var _idx = irandom(array_length(_pool) - 1);
        var _u = _pool[_idx];
        array_delete(_pool, _idx, 1);
        if (!instance_exists(_u)) continue;

        _u.unit_type = _new_role;
        scr_apply_unit_type(_u, _new_role);
        _done++;
    }
}