/// @func scr_kingdom_at_tile(gx, gy)
/// @desc Returns the kingdom_id that owns this tile, or -1 if unowned wilderness.
///       Uses the real per-tile territory_grid.
function scr_kingdom_at_tile(_gx, _gy)
{
    var _vid = scr_village_at_tile(_gx, _gy);
    if (_vid == -1 || _vid >= array_length(global.villages)) return -1;
    return global.villages[_vid].kingdom_id;
}
