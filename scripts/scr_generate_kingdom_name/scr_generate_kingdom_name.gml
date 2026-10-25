/// @func scr_generate_kingdom_name()
/// @desc Returns a random fantasy-sounding kingdom name.
function scr_generate_kingdom_name()
{
    var _starts = ["Ael", "Bri", "Cal", "Dor", "Eld", "Fen", "Gor",
                   "Hal", "Ith", "Jar", "Kel", "Lor", "Mor", "Nor",
                   "Or", "Pel", "Quel", "Rav", "Sil", "Tor", "Uth",
                   "Val", "Wyn", "Xan", "Yor", "Zel"];

    var _mids = ["a", "e", "i", "o", "u", "ar", "en", "ir", "ol", "un"];

    var _ends = ["ia", "ath", "or", "wyn", "ric", "gard", "helm",
                 "shire", "fell", "moor", "stead", "burg", "haven",
                 "mark", "dale", "thorn", "vane"];

    var _pattern = irandom(2);
    var _name = "";

    switch (_pattern)
    {
        case 0:  // 2 syllables
            _name = _starts[irandom(array_length(_starts) - 1)]
                  + _ends[irandom(array_length(_ends) - 1)];
            break;

        case 1:  // 3 syllables
            _name = _starts[irandom(array_length(_starts) - 1)]
                  + _mids[irandom(array_length(_mids) - 1)]
                  + _ends[irandom(array_length(_ends) - 1)];
            break;

        case 2:  // 2-part with hyphen
            _name = _starts[irandom(array_length(_starts) - 1)]
                  + _ends[irandom(array_length(_ends) - 1)]
                  + " "
                  + _starts[irandom(array_length(_starts) - 1)]
                  + _ends[irandom(array_length(_ends) - 1)];
            break;
    }

    return _name;
}