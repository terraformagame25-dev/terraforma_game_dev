/// @func scr_tile_in_village_bounds(_village, _gx, _gy)
/// @desc Returns true if the tile is inside the village's bounding box.
function scr_tile_in_village_bounds(_village, _gx, _gy)
{
    return (_gx >= _village.left && _gx <= _village.right
         && _gy >= _village.top  && _gy <= _village.bottom);
}