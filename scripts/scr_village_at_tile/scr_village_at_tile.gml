/// @func scr_village_at_tile(gx, gy)
/// @desc Returns the village_id containing this tile, or -1 if none.
function scr_village_at_tile(_gx, _gy)
{
    for (var _i = 0; _i < array_length(global.villages); _i++)
    {
        var _v = global.villages[_i];
        if (_gx < _v.left || _gx > _v.right)  continue;
        if (_gy < _v.top  || _gy > _v.bottom) continue;
        return _i;
    }
    return -1;
}