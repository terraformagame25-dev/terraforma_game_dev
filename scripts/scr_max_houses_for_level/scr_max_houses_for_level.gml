/// @func scr_max_houses_for_level(_level)
/// @desc Max houses allowed per village at the given kingdom advancement level.
function scr_max_houses_for_level(_level)
{
    switch (_level)
    {
        case 1: return 5;
        case 2: return 10;
        case 3: return 20;
        case 4: return 30;
    }
    return 5;
}