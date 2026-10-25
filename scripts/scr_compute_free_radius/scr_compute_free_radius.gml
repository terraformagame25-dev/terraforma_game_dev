/// @func scr_compute_free_radius(_village_id, _desired_radius)
/// @desc Largest radius this village can grow to without overlapping
///       another village. Borders may touch, but not cross.
///       Rectangles don't overlap if separated along x OR y — so the
///       binding constraint is the LARGER of the two possible limits.
function scr_compute_free_radius(_village_id, _desired_radius)
{
    var _v     = global.villages[_village_id];
    var _max_r = _desired_radius;

    for (var _i = 0; _i < array_length(global.villages); _i++)
    {
        if (_i == _village_id) continue;

        var _o = global.villages[_i];
        var _dx = abs(_o.cx - _v.cx);
        var _dy = abs(_o.cy - _v.cy);

        // Rectangles don't overlap if separated on x OR y.
        // Max my radius = separation along either axis - their radius.
        var _sep_x = _dx - _o.radius;
        var _sep_y = _dy - _o.radius;
        var _limit = max(_sep_x, _sep_y);

        if (_limit < _max_r) _max_r = _limit;
    }

    // Never shrink below current radius
    return max(_v.radius, _max_r);
}