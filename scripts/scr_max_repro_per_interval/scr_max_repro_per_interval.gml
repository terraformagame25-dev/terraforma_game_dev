/// @func scr_max_repro_per_interval(_level)
/// @desc New villagers spawned per reproduction interval, by advancement level.
function scr_max_repro_per_interval(_level)
{
    switch (_level)
    {
        case 1: return 3;
        case 2: return 8;
        case 3: return 20;
        case 4: return 50;
    }
    return 3;
}