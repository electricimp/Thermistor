// Copyright (c) 2015 Electric Imp
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT

// Include the Thermistor Library
#require "Thermistor.class.nut:2.0.0"

/* GLOBALS and CONSTANTS -----------------------------------------------------*/

// all calculations are done in Kelvin
// these are constants for this particular thermistor; if using a different one,
// check your datasheet
const b_therm = 3988;
const t0_therm = 298.15;
const WAKEINTERVAL_MIN = 15; // interval between wake-and-reads in minutes


/* RUNTIME BEGINS HERE -------------------------------------------------------*/

// Configure Pins
// pin 8 is driven high to turn off temp monitor (saves power) or low to read
therm_en_l <- hardware.pin8;
therm_en_l.configure(DIGITAL_OUT);
therm_en_l.write(1);
// pin 9 is the middle of the voltage divider formed by the NTC - read the analog voltage to determine temperature
temp_sns <- hardware.pin9;

// instantiate our thermistor class
myThermistor <- Thermistor(temp_sns, b_therm, t0_therm, 10, false);

therm_en_l.write(0);
imp.sleep(0.001);
local id = hardware.getdeviceid();
local datapoint = {
    "id" : id,
    "temp" : format("%.2f",myThermistor.read())
}
agent.send("data",datapoint);
therm_en_l.write(1);

//Sleep for 15 minutes and 1 second, minus the time past the 0:15
//so we wake up near each 15 minute mark (prevents drifting on slow DHCP)
imp.onidle( function() {
    server.sleepfor(1 + WAKEINTERVAL_MIN*60 - (time() % (WAKEINTERVAL_MIN*60)));
});

// full firmware is reloaded and run from the top on each wake cycle, so no need to construct a loop