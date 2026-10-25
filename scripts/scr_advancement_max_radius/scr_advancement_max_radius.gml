/// @func scr_advancement_max_radius(_level)
/// @desc Max claim radius (in tiles) from the village center for a kingdom
///       at the given advancement level.
function scr_advancement_max_radius(_level)
{
    switch (_level)
    {
        case 1: return 20;
        case 2: return 35;
        case 3: return 50;
        case 4: return 100;
    }
    return 20;
}