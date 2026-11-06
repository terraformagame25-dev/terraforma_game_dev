/// @func scr_noise_2d(_x, _y, _seed)
/// @desc Returns a smooth pseudo-random value in [0, 1] for a 2D coordinate.
function scr_noise_2d(_x, _y, _seed = 0)
{
    var _x0 = floor(_x);
    var _y0 = floor(_y);
    var _x1 = _x0 + 1;
    var _y1 = _y0 + 1;

    var _fx = _x - _x0;
    var _fy = _y - _y0;

    var _sx = _fx * _fx * (3 - 2 * _fx);
    var _sy = _fy * _fy * (3 - 2 * _fy);

    var _n00 = _hash_2d(_x0, _y0, _seed);
    var _n10 = _hash_2d(_x1, _y0, _seed);
    var _n01 = _hash_2d(_x0, _y1, _seed);
    var _n11 = _hash_2d(_x1, _y1, _seed);

    var _nx0 = lerp(_n00, _n10, _sx);
    var _nx1 = lerp(_n01, _n11, _sx);

    return lerp(_nx0, _nx1, _sy);
}

/// @func _hash_2d(_x, _y, _seed)
/// @desc Deterministic hash of an integer lattice point -> [0, 1].
///       Intermediates are masked to 31 bits so the multiply never overflows
///       64-bit range (which previously could flatten the noise).
function _hash_2d(_x, _y, _seed)
{
    var _h = (_x * 374761393 + _y * 668265263 + _seed * 1274126177) & 0x7FFFFFFF;
    _h = ((_h ^ (_h >> 13)) * 1274126177) & 0x7FFFFFFF;
    _h = _h ^ (_h >> 16);
    return (_h & 0xFFFFFF) / 0xFFFFFF;
}

/// @func scr_noise_2d_octaves(_x, _y, _seed, _octaves, _persistence)
function scr_noise_2d_octaves(_x, _y, _seed, _octaves = 3, _persistence = 0.5)
{
    var _total = 0;
    var _amp   = 1;
    var _freq  = 1;
    var _norm  = 0;

    for (var _i = 0; _i < _octaves; _i++)
    {
        _total += scr_noise_2d(_x * _freq, _y * _freq, _seed + _i * 101) * _amp;
        _norm  += _amp;
        _amp   *= _persistence;
        _freq  *= 2;
    }

    return _total / _norm;
}
