#!/usr/bin/nodejs

var sortPaths = require('sort-paths');

const getStdin = require('get-stdin');

getStdin().then(str => {
    console.log(sortPaths(str.split("\n")).join("\n"));
});

// array = array.sort(sorter)
