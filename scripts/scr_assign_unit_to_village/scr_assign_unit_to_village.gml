/// @func scr_assign_unit_to_village(_unit, _village_id)
/// @desc Assigns a unit to a village. Appends to member_ids if not already present.
function scr_assign_unit_to_village(_unit, _village_id)
{
    var _v = global.villages[_village_id];

    // Set position/kingdom regardless
    _unit.village_id = _village_id;
    _unit.kingdom_id = _v.kingdom_id;

    // Already in list? Skip push to avoid duplicates
    var _already = false;
    for (var _i = 0; _i < array_length(_v.member_ids); _i++)
    {
        if (_v.member_ids[_i] == _unit.id)
        {
            _already = true;
            break;
        }
    }

    if (!_already)
    {
        array_push(_v.member_ids, _unit.id);
        global.villages[_village_id] = _v;
    }
}