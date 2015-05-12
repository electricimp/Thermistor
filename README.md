#Thermistor Class

This class makes it simple for an imp to read an NTC (“Negative Temperature Coefficient”) thermistor and determine the temperature. Thermistors are essentially temperature-dependent resistors. To use as a thermometer, a thermistor is used as half of a resistive divider, where the voltage across the full divider is known. The Imp then reads the voltage at the center of the divider to determine the ratio of resistance of the thermistor and the bias resistor (also the nominal resistance of the thermistor), [from which the temperature can be derived](http://en.wikipedia.org/wiki/Thermistor).

**To add this library to your project, add** `#require "Thermistor.class.nut:1.0.0"` **to the top of your device code**

## Usage

### Hardware

A resistive divider can be formed with the thermistor on the top or the bottom; this class allows for either configuration. The top of the divider should be connected to the same rail as an imp’s V<sub>DDA</sub> pin (or V<sub>DD</sub> pin, in the case of the imp001, as V<sub>DD</sub> and V<sub>DDA</sub> are internally connected). The bottom of the divider should be connected to ground.

The resistance of the bias resistor in the voltage divider should be equal to the nominal resistance of the thermistor (the resistance at T0).  This simplifies the temperature calculation and allows the largest dynamic range.

The center of the divider must be connected to a pin capable of analog input. On the imp001, any pin can be used as an analog input. On the imp002 or imp003, only some pins can be configured this way, so check the [Imp Pin Mux chart](http://electricimp.com/docs/hardware/imp/pinmux/).

### Software

The thermistor class takes three to five parameters (three required, two optional):

| Parameter Name | Description | Optional/Required |
|----------------|-------------|-------------------|
| *pin* | Imp pin object capable of ANALOG_IN | Required |
| *b_therm* | Thermistor ß parameter, from datasheet | Required |
| *t0_therm* | Thermistor T0 parameter, from datasheet | Required |
| *points* | number of readings to average when reading the thermistor | Optional, defaults to 10 |
| *high_side_therm* | Set `false` to place thermistor on low side of divider | Optional, defaults to `true` |

The ß and T0 parameters are all available on the thermistor datasheet:

| Parameter | Meaning |
|-----------|---------|
| ß | Characteristic of the thermistor. Most thermistors have many ß values listed, for various temperature ranges. Choose the value for the temperature range you will be operating in. |
| T0 | Temperature at which the nominal resistance (R) of the thermistor is measured. Typically room temperature (~25ºC) |

### Constructor

```squirrel
const b_therm = 3988
const t0_therm = 298.15

pin <- hardware.pin9

// Thermistor on bottom of divider

myThermistor <- Thermistor(pin, b_therm, t0_therm, 10, false)
```

### Class Methods

### Reading a thermistor

The thermistor object provides three methods for reading the temperature: *readK()*, *readC()* and *readF()*. These return the temperature in Kelvin, Celsius and Fahrenheit, respectively.

```squirrel
local kelvin = therm.readK()
local celsius = therm.readC()
local fahrenheit = therm.readF()
```

## License

Thermistor is licensed under [MIT License](./LICENSE).

