/// @func scr_find_house_spot(_village_id)
/// @desc Returns [gx, gy] for the best house placement tile, or [-1, -1]
///       if none found. Prefers tiles near the town hall with randomness.
function scr_find_house_spot(_village_id)
{
    var _v = global.villages[_village_id];

    var _best = [-1, -1];
    var _best_dist = 999999;

    for (var _gy = _v.top; _gy <= _v.bottom - 1; _gy++)
    {
        for (var _gx = _v.left; _gx <= _v.right - 1; _gx++)
        {
            if (!scr_house_fits(_v, _gx, _gy)) continue;

            var _d = point_distance(_gx, _gy, _v.cx, _v.cy);

            // Distance-based with random tie-break
            if (_d < _best_dist || (_d == _best_dist && irandom(1) == 0))
            {
                _best_dist = _d;
                _best      = [_gx, _gy];
            }
        }
    }

    return _best;
}