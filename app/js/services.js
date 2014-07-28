'use strict';

/* Services */


angular.module('mockappservices', []).
factory("MockupDataSource", ['$http', function($http) {
	
	var sdo = {
		getData: function() {
			var promise = $http({ method: 'GET', url: 'data/crawlerOutput.json' }).success(function(data, status, headers, config) {
				return data;
			});
			return promise;
		}
	}
	return sdo;
}])
.value('version', '0.1');
