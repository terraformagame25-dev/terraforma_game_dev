/// @func scr_can_place_house(_village_id)
/// @desc Returns true if at least one valid tile exists for a 2x2 house
///       inside the village border, respecting gaps.
function scr_can_place_house(_village_id)
{
    var _v = global.villages[_village_id];
    var _w = obj_world.world_width;

    for (var _gy = _v.top; _gy <= _v.bottom - 1; _gy++)
    {
        for (var _gx = _v.left; _gx <= _v.right - 1; _gx++)
        {
            if (scr_house_fits(_v, _gx, _gy))
            {
                return true;
            }
        }
    }
    return false;
}