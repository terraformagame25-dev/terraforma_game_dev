/// @func scr_max_child_villages_for_level(_level)
/// @desc Returns the maximum number of child villages a kingdom can have
///       at the given advancement level.
function scr_max_child_villages_for_level(_level)
{
    switch (_level)
    {
        case 1: return 2;
        case 2: return 4;
        case 3: return 6;
        case 4: return 7;
    }
    return 2; // Default to level 1
}