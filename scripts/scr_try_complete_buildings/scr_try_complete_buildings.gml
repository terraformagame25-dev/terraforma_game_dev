/// @func scr_try_complete_buildings()
/// @desc Completes any pending construction when 5+ builders are present
///       and resources are available.
function scr_try_complete_buildings()
{
    for (var _i = 0; _i < array_length(global.villages); _i++)
    {
        var _v = global.villages[_i];

        // Check for pending construction site owned by this village
        with (obj_building)
        {
            if (state != "construction")     continue;
            if (village_id != _v.id)         continue;

            var _site = id;

            var _site_gx = footprint_left;
            var _site_gy = footprint_top;
            var _site_ex = footprint_right;
            var _site_ey = footprint_bottom;

            // Count builders of the village near the site
            var _builders_present = 0;
            var _builders_list    = [];

            for (var _ci = 0; _ci < array_length(_v.member_ids); _ci++)
            {
                var _u = _v.member_ids[_ci];
                if (!instance_exists(_u)) continue;
                if (_u.unit_type != "builder") continue;

                // Within 4 tiles of the site's footprint
                var _dx = 0;
                var _dy = 0;

                if (_u.grid_x < _site_gx)      _dx = _site_gx - _u.grid_x;
                else if (_u.grid_x > _site_ex) _dx = _u.grid_x - _site_ex;

                if (_u.grid_y < _site_gy)      _dy = _site_gy - _u.grid_y;
                else if (_u.grid_y > _site_ey) _dy = _u.grid_y - _site_ey;

                var _dist = max(_dx, _dy);

                if (_dist <= 4)
                {
                    _builders_present++;
                    array_push(_builders_list, _u);
                }
            }

            if (_builders_present < 5) continue;

            // Cost per building type
            var _cost_wood  = 0;
            var _cost_stone = 0;

            switch (building_type)
            {
                case "town_hall":
                    _cost_wood = 100; _cost_stone = 50;
                    break;
                case "house_a":
                    _cost_wood =  50; _cost_stone = 20;
                    break;
                case "house_b":
                    _cost_wood = 100; _cost_stone = 50;
                    break;
            }

            if (_v.resources.wood  < _cost_wood)  continue;
            if (_v.resources.stone < _cost_stone) continue;

            _v.resources.wood  -= _cost_wood;
            _v.resources.stone -= _cost_stone;

            // Complete
            var _body = scr_get_building_sprite(building_type, level, false);
            sprite_index = _body;
            state        = "complete";

            // Clear builder targets
            for (var _bi = 0; _bi < array_length(_builders_list); _bi++)
            {
                var _b = _builders_list[_bi];
                if (instance_exists(_b)) _b.build_target_id = noone;
            }

            // Remove from pending
            if (_v.construction_id == _site) _v.construction_id = noone;

            // Add to village building list
            array_push(_v.building_list, _site);
            global.villages[_i] = _v;

        }
    }
}