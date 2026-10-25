/// @func scr_village_pop_count(_v)
/// @desc Counts spare villagers in the village (excludes all role-assigned).
function scr_village_pop_count(_v)
{
    var _count = 0;
    for (var _i = 0; _i < array_length(_v.member_ids); _i++)
    {
        var _u = _v.member_ids[_i];
        if (!instance_exists(_u)) continue;
        _count++;
    }
    return _count;
}