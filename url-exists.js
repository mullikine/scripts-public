#!/usr/bin/nodejs
// npm install url-exists

var urlExists = require('url-exists');

var lastarg = process.argv[process.argv.length - 1];
//console.log(lastarg);
urlExists(lastarg, function(err, exists) {
    //console.log(typeof exists); // boolean
    process.exit(exists ? 0 : 1);
});

// cant do this because it is asynchronously waiting
//process.exit(1)