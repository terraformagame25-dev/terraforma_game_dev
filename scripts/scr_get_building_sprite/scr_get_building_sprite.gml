/// @func scr_get_building_sprite(_type, _era, _is_roof)
/// @desc Returns the sprite for a building type at a given era.
///       _is_roof = false → body sprite
///       _is_roof = true  → roof mask sprite (for tinting)
///       Era 1 has no roof mask (natural thatch, no tinting).
///       Falls back to era 1 if the era-specific sprite doesn't exist.
function scr_get_building_sprite(_type, _era, _is_roof = false)
{
    switch (_type)
    {
        case "town_hall":
            switch (_era)
            {
                case 2:
                    return _is_roof
                        ? spr_building_town_hall_era2_roof
                        : spr_building_town_hall_era2;
                default:
                    // Era 1 — no roof mask
                    return _is_roof ? -1 : spr_building_town_hall_era1;
            }
            break;

        case "house_a":
            switch (_era)
            {
                case 2:
                    return _is_roof
                        ? spr_building_house_era2_a_roof
                        : spr_building_house_era2_a;
                default:
                    return _is_roof ? -1 : spr_building_house_era1_a;
            }
            break;

        case "house_b":
            switch (_era)
            {
                case 2:
                    return _is_roof
                        ? spr_building_house_era2_b_roof
                        : spr_building_house_era2_b;
                default:
                    return _is_roof ? -1 : spr_building_house_era1_b;
            }
            break;

        default:
            return -1;
    }
}