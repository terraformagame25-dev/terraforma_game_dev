var _ts = obj_world.tile_size;

for (var _i = 0; _i < array_length(global.villages); _i++)
{
    var _v = global.villages[_i];
    var _k = global.kingdoms[_v.kingdom_id];
    var _color = _k.color;

    var _px = _v.cx * _ts;
    var _py = _v.cy * _ts;

    var _pop  = array_length(_v.member_ids);
    var _name = string(_v.name);

    var _label_text = _name + " " + string(_pop);

    var _tw_raw  = string_width(_label_text);
    var _th_raw  = string_height(_label_text);

    var _scale    = 0.25;
    var _tw       = _tw_raw  * _scale;
    var _th_txt   = _th_raw  * _scale;

    var _lx = _px + _ts * 0.5;
    var _ly = _py - _ts * 2 - _th_txt * 0.5;

    var _pad_x = 3;
    var _pad_y = 1;

    var _star_scale  = 0.5;
    var _star_render = 8 * _star_scale;
    var _star_gap    = 2;
    var _star_offset = 0;
    if (_v.is_capital) _star_offset = _star_render + _star_gap;

    // Background pill
    draw_set_colour(make_colour_rgb(60, 60, 70));
    draw_set_alpha(0.9);
    draw_rectangle(
        _lx - _pad_x - _star_offset,
        _ly - _pad_y,
        _lx + _tw + _pad_x,
        _ly + _th_txt + _pad_y,
        false
    );
    draw_set_alpha(1);

    // Capital star
    if (_v.is_capital)
    {
        var _star_x = _lx - _star_render - _star_gap;
        var _star_y = _ly + (_th_txt - _star_render) * 0.5;

        draw_sprite_ext(spr_ui_star, 0, _star_x, _star_y,
                        _star_scale, _star_scale, 0,
                        make_colour_rgb(240, 200, 60), 1);
    }

    // Text
    draw_set_colour(_color);
    draw_text_transformed(_lx, _ly, _label_text, _scale, _scale, 0);

    draw_set_colour(c_white);
}