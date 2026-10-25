var _scale = 0.5;   // 0.5 = half size, 0.75 = 3/4 size, 1.0 = original

if (unit_type == "leader")
{
    var _body_spr  = (state == "walk") ? spr_body_walk  : spr_body_idle;
    var _tunic_spr = (state == "walk") ? spr_tunic_walk : spr_tunic_idle;

    var _kcol = c_white;
    if (kingdom_id != -1 && kingdom_id < array_length(global.kingdoms))
    {
        _kcol = global.kingdoms[kingdom_id].color;
    }

    draw_sprite_ext(_body_spr,  image_index, x, y, image_xscale * _scale, _scale, 0, c_white, 1);
    draw_sprite_ext(_tunic_spr, image_index, x, y, image_xscale * _scale, _scale, 0, _kcol,   1);
}
else
{
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * _scale, _scale, 0, c_white, 1);
}