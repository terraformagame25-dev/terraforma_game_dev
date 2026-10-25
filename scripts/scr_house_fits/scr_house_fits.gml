/// @func scr_house_fits(_v, _gx, _gy)
/// @desc Returns true if a 2x2 house can be placed with its bottom-left
///       tile at (_gx, _gy). Checks the 2x2 footprint, then a 1-tile gap
///       from all other buildings.
function scr_house_fits(_v, _gx, _gy)
{
    // 2x2 footprint check
    if (!scr_rect_can_place_building(_v, _gx, _gy, _gx + 1, _gy + 1))
        return false;

    // 1-tile gap check from every other building
    var _gap = 1;

    with (obj_building)
    {
        var _pad = _gap;
        var _bx  = _gx - _pad;
        var _by  = _gy - _pad;
        var _bw  = 2 + _pad * 2;
        var _bh  = 2 + _pad * 2;

        var _this_l = footprint_left;
        var _this_t = footprint_top;
        var _this_r = footprint_right;
        var _this_b = footprint_bottom;

        // AABB overlap test (inclusive edges)
        if (_bx <= _this_r && _bx + _bw > _this_l
         && _by <= _this_b && _by + _bh > _this_t)
        {
            return false;
        }
    }

    return true;
}