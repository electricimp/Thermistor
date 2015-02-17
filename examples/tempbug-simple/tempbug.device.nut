// Copyright (c) 2015 Electric Imp
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT


/* GLOBALS and CONSTANTS -----------------------------------------------------*/

// all calculations are done in Kelvin
// these are constants for this particular thermistor; if using a different one,
// check your datasheet
const b_therm = 3988;
const t0_therm = 298.15;
const r_therm = 10000;
const INTERVAL = 900; // interval between wake-and-reads in seconds (15 minutes)

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

function getTemp() {
	// schedule the next temperature reading
	imp.wakeup(INTERVAL, getTemp);

	// hardware id is used to separate feeds on Xively, so provide it with the data
	local id = hardware.getdeviceid();
	// tempreature can also be returned in Kelvin or Celsius
	local datapoint = {
	    "id" : id,
	    "temp" : format("%.2f",myThermistor.readC())
	}
	server.log("Temp: "+datapoint.temp);
	agent.send("data",datapoint);
}

/* REGISTER AGENT CALLBACKS --------------------------------------------------*/

/* RUNTIME BEGINS HERE -------------------------------------------------------*/

// Configure Pins
// pin 9 is the middle of the voltage divider formed by the NTC - read the analog voltage to determine temperature
temp_sns <- hardware.pin7;
// instantiate sensor classes

// instantiate our thermistor class
// this shows the thermistor on the bottom of the divider
myThermistor <- thermistor(temp_sns, b_therm, t0_therm, r_therm, 10, false);

// this function will schedule itself to re-run after it is first called
// just call it once to start the loop.
getTemp();

