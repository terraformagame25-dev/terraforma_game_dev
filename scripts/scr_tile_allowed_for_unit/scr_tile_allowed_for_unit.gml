/// @func scr_tile_allowed_for_unit(unit, gx, gy, allow_res_override)
/// @desc Master permission gate. Combines terrain rules with kingdom / village
///       territory rules. Every movement, path step, and target check should
///       go through this instead of scr_tile_is_roamable directly.
///
///       Rules:
///         - Physical terrain (water, blocked, resource-by-type) via
///           scr_tile_is_roamable.
///         - Never enter a foreign kingdom's territory. (Alliances TBD.)
///         - Miners may leave their own village, but are still blocked by
///           foreign kingdoms.
///         - Non-miners must stay inside their own village bounds.
///         - Unaffiliated villagers (village_id == -1) have no village bounds,
///           so they are only subject to the foreign-kingdom rule.
///
/// @param {id}     unit                The unit instance
/// @param {real}   gx                  Grid X to test
/// @param {real}   gy                  Grid Y to test
/// @param {bool}   allow_res_override  Optional: pass true to allow stepping
///                                     on resource tiles (used by beacon
///                                     followers whose path may cross trees).
/// @returns {bool}                     true if the unit may occupy (gx, gy)
function scr_tile_allowed_for_unit(_unit, _gx, _gy, _allow_res_override = false)
{
    var _allow_res = (_unit.unit_type == "miner") || _allow_res_override;

    if (!scr_tile_is_roamable(_unit, _gx, _gy, _allow_res)) return false;

    var _owner_kingdom = scr_kingdom_at_tile(_gx, _gy);

    // Foreign kingdom — blocked. (TODO: if scr_is_ally(...) return true;)
    if (_owner_kingdom != -1 && _owner_kingdom != _unit.kingdom_id) return false;

    // Miners: free to roam wilderness + own kingdom.
    if (_unit.unit_type == "miner") return true;

    // Unaffiliated villagers: no village bounds to enforce.
    if (_unit.village_id == -1) return true;

    // Non-miners: must stay inside their village's actual claimed tiles.
    var _idx = _gx + _gy * obj_world.world_width;
    if (obj_world.territory_grid[_idx] != _unit.village_id) return false;

    return true;
}