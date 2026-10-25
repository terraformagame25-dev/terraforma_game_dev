/// @func scr_tile_in_other_kingdom(_gx, _gy, _kingdom_id)
/// @desc Returns true if the tile is inside any village of a kingdom
///       other than the given one.
function scr_tile_in_other_kingdom(_gx, _gy, _kingdom_id)
{
    var _owner = scr_kingdom_at_tile(_gx, _gy);
    return (_owner != -1 && _owner != _kingdom_id);
}