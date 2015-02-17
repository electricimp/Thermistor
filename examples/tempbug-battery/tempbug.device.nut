// Copyright (c) 2015 Electric Imp
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT

/* GLOBALS and CONSTANTS -----------------------------------------------------*/

// all calculations are done in Kelvin
// these are constants for this particular thermistor; if using a different one,
// check your datasheet
const b_therm = 3988;
const t0_therm = 298.15;
const r_therm = 100000.0;
const WAKEINTERVAL_MIN = 15; // interval between wake-and-reads in minutes

/* CLASS AND GLOBAL FUNCTION DEFINITIONS -------------------------------------*/
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
        return this.read() - 273.15;
    }

    // read thermistor in Fahrenheit
    function readF() {
        return ((this.read() - 273.15) * 9.0 / 5.0 + 32.0);
    }
}

/* REGISTER AGENT CALLBACKS --------------------------------------------------*/

/* RUNTIME BEGINS HERE -------------------------------------------------------*/

// Configure Pins
// pin 8 is driven high to turn off temp monitor (saves power) or low to read
therm_en_l <- hardware.pin8;
therm_en_l.configure(DIGITAL_OUT);
therm_en_l.write(1);
// pin 9 is the middle of the voltage divider formed by the NTC - read the analog voltage to determine temperature
temp_sns <- hardware.pin9;
// instantiate sensor classes

// instantiate our thermistor class
myThermistor <- thermistor(temp_sns, b_therm, t0_therm, r_therm, 10, false);

therm_en_l.write(0);
imp.sleep(0.001);
local id = hardware.getdeviceid();
local datapoint = {
    "id" : id,
    "temp" : format("%.2f",myThermistor.readF())
}
agent.send("data",datapoint);
therm_en_l.write(1);

//Sleep for 15 minutes and 1 second, minus the time past the 0:15
//so we wake up near each 15 minute mark (prevents drifting on slow DHCP)
imp.onidle( function() {
    server.sleepfor(1 + WAKEINTERVAL_MIN*60 - (time() % (WAKEINTERVAL_MIN*60)));
});

// full firmware is reloaded and run from the top on each wake cycle, so no need to construct a loop
