/// @func scr_draw_village_territory(_village_id, _color)
/// @desc Draws the union of all territory rects with translucent fill and
///       a 4-pixel-thick opaque outline on the perimeter.
function scr_draw_village_territory(_village_id, _color)
{
    var _ts = obj_world.tile_size;
    var _v  = global.villages[_village_id];

    // Camera cull
    var _cam   = view_camera[0];
    var _cam_x = camera_get_view_x(_cam);
    var _cam_y = camera_get_view_y(_cam);
    var _cam_w = camera_get_view_width(_cam);
    var _cam_h = camera_get_view_height(_cam);

    var _pad = _ts * 4;
    var _cull_l = _cam_x - _pad;
    var _cull_t = _cam_y - _pad;
    var _cull_r = _cam_x + _cam_w + _pad;
    var _cull_b = _cam_y + _cam_h + _pad;

    var _th = 4;   // border thickness in pixels

    draw_set_colour(_color);

    for (var _gy = _v.top; _gy <= _v.bottom; _gy++)
    {
        for (var _gx = _v.left; _gx <= _v.right; _gx++)
        {
            if (!scr_tile_in_union(_v, _gx, _gy)) continue;

            var _px = _gx * _ts;
            var _py = _gy * _ts;

            if (_px + _ts < _cull_l) continue;
            if (_px > _cull_r)       continue;
            if (_py + _ts < _cull_t) continue;
            if (_py > _cull_b)       continue;

            // Fill
            draw_set_alpha(0.15);
            draw_rectangle(_px, _py, _px + _ts, _py + _ts, false);

            // Outline on edges where neighbor is outside the union
            draw_set_alpha(1);

            if (!scr_tile_in_union(_v, _gx, _gy - 1))
                draw_rectangle(_px, _py, _px + _ts, _py + _th, false);

            if (!scr_tile_in_union(_v, _gx, _gy + 1))
                draw_rectangle(_px, _py + _ts - _th, _px + _ts, _py + _ts, false);

            if (!scr_tile_in_union(_v, _gx - 1, _gy))
                draw_rectangle(_px, _py, _px + _th, _py + _ts, false);

            if (!scr_tile_in_union(_v, _gx + 1, _gy))
                draw_rectangle(_px + _ts - _th, _py, _px + _ts, _py + _ts, false);
        }
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
}