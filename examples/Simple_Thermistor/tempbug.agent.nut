// Copyright (c) 2015 Electric Imp
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT

/* REGISTER DEVICE CALLBACKS  ------------------------------------------------*/

device.on("data", function(datapoint) {
    // Log our datapoint
    server.log(http.jsonencode(datapoint));
    // Add code here to upload data to a web service
});