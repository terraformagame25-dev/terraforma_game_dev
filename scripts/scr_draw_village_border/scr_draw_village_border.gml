/// @func scr_draw_village_border(_village_id, _color)
/// @desc Draws translucent fill on claimed tiles and a per-tile perimeter
///       outline that follows the actual territory shape.
function scr_draw_village_border(_village_id, _color)
{
    var _ts = obj_world.tile_size;
    var _w  = obj_world.world_width;
    var _h  = obj_world.world_height;

    var _v = global.villages[_village_id];

    // Camera cull
    var _cam = view_camera[0];
    var _cam_x = camera_get_view_x(_cam);
    var _cam_y = camera_get_view_y(_cam);
    var _cam_w = camera_get_view_width(_cam);
    var _cam_h = camera_get_view_height(_cam);

    var _pad = _ts * 4;
    var _cull_l = _cam_x - _pad;
    var _cull_t = _cam_y - _pad;
    var _cull_r = _cam_x + _cam_w + _pad;
    var _cull_b = _cam_y + _cam_h + _pad;

    // === Fill (translucent) ===
    draw_set_colour(_color);
    draw_set_alpha(0.15);

    for (var _gy = _v.top; _gy <= _v.bottom; _gy++)
    {
        for (var _gx = _v.left; _gx <= _v.right; _gx++)
        {
            var _idx = _gx + _gy * _w;
            if (obj_world.territory_grid[_idx] != _village_id) continue;

            var _px = _gx * _ts;
            var _py = _gy * _ts;

            if (_px + _ts < _cull_l) continue;
            if (_px > _cull_r)       continue;
            if (_py + _ts < _cull_t) continue;
            if (_py > _cull_b)       continue;

            draw_rectangle(_px, _py, _px + _ts, _py + _ts, false);
        }
    }

    // === Border (per-tile perimeter) ===
    draw_set_alpha(1);

    var _th = _ts;   // 1 tile thick

    for (var _gy = _v.top; _gy <= _v.bottom; _gy++)
    {
        for (var _gx = _v.left; _gx <= _v.right; _gx++)
        {
            var _idx = _gx + _gy * _w;
            if (obj_world.territory_grid[_idx] != _village_id) continue;

            var _px = _gx * _ts;
            var _py = _gy * _ts;

            if (_px + _ts < _cull_l) continue;
            if (_px > _cull_r)       continue;
            if (_py + _ts < _cull_t) continue;
            if (_py > _cull_b)       continue;

            // Check 4 neighbors — draw edge where neighbor is not claimed
            var _up_c = false, _dn_c = false, _lf_c = false, _rt_c = false;

            if (_gy > 0)
            {
                if (obj_world.territory_grid[_gx + (_gy - 1) * _w] == _village_id) _up_c = true;
            }
            if (_gy < _h - 1)
            {
                if (obj_world.territory_grid[_gx + (_gy + 1) * _w] == _village_id) _dn_c = true;
            }
            if (_gx > 0)
            {
                if (obj_world.territory_grid[(_gx - 1) + _gy * _w] == _village_id) _lf_c = true;
            }
            if (_gx < _w - 1)
            {
                if (obj_world.territory_grid[(_gx + 1) + _gy * _w] == _village_id) _rt_c = true;
            }

            if (!_up_c) draw_rectangle(_px, _py,                 _px + _ts, _py + _th,        false);
            if (!_dn_c) draw_rectangle(_px, _py + _ts - _th,      _px + _ts, _py + _ts,        false);
            if (!_lf_c) draw_rectangle(_px, _py,                  _px + _th, _py + _ts,        false);
            if (!_rt_c) draw_rectangle(_px + _ts - _th, _py,      _px + _ts, _py + _ts,        false);
        }
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
}