/// @func scr_recompute_bounds_from_rects(_village_id)
/// @desc Recomputes the village bounding box from its territory_rects.
function scr_recompute_bounds_from_rects(_village_id)
{
    var _v = global.villages[_village_id];

    if (array_length(_v.territory_rects) == 0) return;

    var _min_x = 999999, _max_x = -999999;
    var _min_y = 999999, _max_y = -999999;

    for (var _i = 0; _i < array_length(_v.territory_rects); _i++)
    {
        var _r = _v.territory_rects[_i];
        if (_r.left   < _min_x) _min_x = _r.left;
        if (_r.right  > _max_x) _max_x = _r.right;
        if (_r.top    < _min_y) _min_y = _r.top;
        if (_r.bottom > _max_y) _max_y = _r.bottom;
    }

    _v.left   = _min_x;
    _v.top    = _min_y;
    _v.right  = _max_x;
    _v.bottom = _max_y;

    _v.cx = (_v.left + _v.right)  div 2;
    _v.cy = (_v.top  + _v.bottom) div 2;
    _v.radius = max(_v.right - _v.left, _v.bottom - _v.top) div 2;

    global.villages[_village_id] = _v;
}