/// @func scr_tile_in_union(_v, _gx, _gy)
/// @desc Returns true if the tile is inside any of the village's rects.
function scr_tile_in_union(_v, _gx, _gy)
{
    for (var _i = 0; _i < array_length(_v.territory_rects); _i++)
    {
        var _r = _v.territory_rects[_i];
        if (_gx >= _r.left && _gx <= _r.right
         && _gy >= _r.top  && _gy <= _r.bottom)
        {
            return true;
        }
    }
    return false;
}