// Copyright (c) 2015 Electric Imp
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT

// Include the Thermistor Library
#require "Thermistor.class.nut:1.0.0"

/* GLOBALS and CONSTANTS -----------------------------------------------------*/

// all calculations are done in Kelvin
// these are constants for this particular thermistor; if using a different one,
// check your datasheet
const b_therm = 3988;
const t0_therm = 298.15;
const r_therm = 10000;
const INTERVAL = 900; // interval between wake-and-reads in seconds (15 minutes)

function getTemp() {
	// schedule the next temperature reading
	imp.wakeup(INTERVAL, getTemp);

	// hardware id is used to separate feeds on Xively, so provide it with the data
	local id = hardware.getdeviceid();

	// tempreature can also be returned in Kelvin or Celsius
	local datapoint = {
	    "id" : id,
	    "temp" : format("%.2f",myThermistor.read())
	}

	server.log("Temp: " + datapoint.temp);
	agent.send("data", datapoint);
}

/* RUNTIME BEGINS HERE -------------------------------------------------------*/

// Configure Pins
// Pin 7 is the middle of the voltage divider formed by the NTC - read the analog voltage to determine temperature
temp_sns <- hardware.pin7;

// Instantiate our thermistor class
// This shows the thermistor on the bottom of the divider
myThermistor <- Thermistor(temp_sns, b_therm, t0_therm, r_therm, 10, false);

// This function will schedule itself to re-run after it is first called
// Just call it once to start the loop.
getTemp();
