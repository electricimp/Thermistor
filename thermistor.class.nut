// Copyright (c) 2015 Electric Imp
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT

class thermistor {
    _beta = null;
    _t0 = null;

    _pin = null;
    _pointsPerRead = null;

    _highSide = null;

    constructor(pin, b, t0, points = 10, highSide = true) {
        _pin = pin;
        _pin.configure(ANALOG_IN);
        _highSide = highSide;

        _beta = b * 1.0;
        _t0 = t0 * 1.0;
        _pointsPerRead = points * 1.0;
    }

    // read thermistor in Kelvin
    function readK() {
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

    // read thermistor in Celsius
    function readC() {
        return this.readK() - 273.15;
    }

    // read thermistor in Fahrenheit
    function readF() {
        return ((this.readK() - 273.15) * 9.0 / 5.0 + 32.0);
    }
}
