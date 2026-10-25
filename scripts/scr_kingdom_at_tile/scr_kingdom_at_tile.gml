/// @func scr_kingdom_at_tile(gx, gy)
/// @desc Returns the kingdom_id that owns this tile, or -1 if unowned wilderness.
///       Territory = union of all village AABBs belonging to that kingdom.
/// @param {real} gx  Grid X
/// @param {real} gy  Grid Y
/// @returns {real}   kingdom_id or -1
function scr_kingdom_at_tile(_gx, _gy)
{
    for (var _i = 0; _i < array_length(global.villages); _i++)
    {
        var _v = global.villages[_i];

        if (_gx < _v.left || _gx > _v.right)  continue;
        if (_gy < _v.top  || _gy > _v.bottom) continue;

        return _v.kingdom_id;
    }
    return -1;
}