'use strict';

/* Filters */

var filters = angular.module('mockappfilters',[]);

filters.filter('shortDate', function() {
  return function(date) {
  	//return date;
    return moment(date).format("DD MMM YYYY");
  }
});

filters.filter('fromNow', function() {
  return function(date) {
  	//return date;
    return moment(date).fromNow();
  }
});