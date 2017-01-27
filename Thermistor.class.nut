// Copyright (c) 2017 Electric Imp
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT

class Thermistor {

    static VERSION = "2.0.0";

    _beta = null;
    _t0 = null;

    _pin = null;
    _pointsPerRead = null;

    _highSide = null;

    constructor(pin, b, t0, points = 10.0, highSide = true) {
        _pin = pin;
        _pin.configure(ANALOG_IN);

        if (typeof points == "boolean") {
            _pointsPerRead = 10.0;
            _highSide = points;
        } else {
            _pointsPerRead = points * 1.0;
            _highSide = highSide;
        }

        _beta = b * 1.0;
        _t0 = t0 * 1.0;
    }

    // read thermistor in Celsius
    function read() {
        return (readK() - 273.15);
    }

    // read thermistor in Kelvin
    function readK(cb = null) {
        local vrat_raw = 0;
        for (local i = 0; i < _pointsPerRead; i++) {
            vrat_raw += _pin.read();
            imp.sleep(0.001); // sleep to allow thermistor pin to recharge
        }
        local v_rat = vrat_raw / (_pointsPerRead * 65535.0);

        local ln_therm = 0;
        if (_highSide) {
            ln_therm = math.log(v_rat / (1.0 - v_rat));
        } else {
            ln_therm = math.log((1.0 - v_rat) / v_rat);
        }

        return (_t0 * _beta) / (_beta - _t0 * ln_therm);
    }
}
