/// @func scr_village_housing_cap(_v)
/// @desc Calculates the max population for a village based on its buildings.
///       Base cap is 20. Buildings add more based on their era (level).
function scr_village_housing_cap(_v)
{
    var _cap = 50;

    for (var _i = 0; _i < array_length(_v.building_list); _i++)
    {
        var _b = _v.building_list[_i];
        if (!instance_exists(_b)) continue;

        switch (_b.level)
        {
            case 1: // Era 1
                if (_b.building_type == "town_hall") _cap += 20;
                if (_b.building_type == "house_a")   _cap += 10;
                if (_b.building_type == "house_b")   _cap += 20;
                break;

            case 2: // Era 2
                if (_b.building_type == "town_hall") _cap += 50;
                if (_b.building_type == "house_a")   _cap += 20;
                if (_b.building_type == "house_b")   _cap += 30;
                break;
            
            // case 3 and 4 can be added later
        }
    }

    return _cap;
}

function scr_village_house_count(_v)
{
    var _count = 0;
    for (var _i = 0; _i < array_length(_v.building_list); _i++)
    {
        var _b = _v.building_list[_i];
        if (!instance_exists(_b)) continue;
        if (_b.building_type == "house_a" || _b.building_type == "house_b")
        {
            _count++;
        }
    }
    return _count;
}