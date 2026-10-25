anim_timer += anim_speed

if (keyboard_check_pressed(vk_space))
{
    global.is_paused = !global.is_paused;
}