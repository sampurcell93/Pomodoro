var express = require("express");
var app = express();
var port = process.env.PORT || 3700;
 
app.use(express.static(__dirname + '/app')); 
app.listen(port);

console.log("Listening on port " + port);