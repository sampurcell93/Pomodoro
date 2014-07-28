'use strict';

var app = angular.module('mocks', ['ngRoute','ngResource','mockappfilters','mockappservices']);

app.config(function($routeProvider, $locationProvider) {

  $routeProvider.when('/', {
    redirectTo: '/recent',
  });
 
  $routeProvider.when('/recent', {
    templateUrl: 'partials/flatitems.html',
    controller: RecentCntl,
    resolve: {
	    mockdata: function(MockupDataSource) {
		    return MockupDataSource.getData();
	    }
    }
  });
 
  $routeProvider.when('/user/:userId', {
    templateUrl: 'partials/userProjects.html',
    controller: UserCntl,
    resolve: {
	    mockdata: function(MockupDataSource) {
		    return MockupDataSource.getData();
	    }
    }     
  });
  
  $routeProvider.when('/user/:userId/project/:projectId', {
    templateUrl: 'partials/project.html',
    controller: ProjectCntl,
    resolve: {
	    mockdata: function(MockupDataSource) {
		    return MockupDataSource.getData();
	    }
    }      
  });
  
});

 
function ParseMockData($scope, $location) {
	
	var data = $scope.mockdata;

	// massage some data. massage it real good
	var i,j,k;
	var personMap = {};
	var allItems = [];
	for (i=0;i<data.length;i++) {
		var person = data[i];
	
		personMap[person.name] = person;
		for (j=0; j<person.projects.length; j++) {
			var project = person.projects[j];
	
			project.user = person;
			project.recentModifiedDate = new Date(0);
	
			for (k=0; k<project.items.length; k++) {
				var item = project.items[k];
				allItems.push(item);
	
				// create back-link
				item.project = project;
	
				// parse date
				var milliseconds = item.lastModified * 1000;
				item.lastModifiedDate = new Date(milliseconds);
			}
	
			// sort items by modified date
			project.items.sort(function (a, b) {
	    		if (a.lastModifiedDate.getTime() > b.lastModifiedDate.getTime())
	    			return -1
	    		if (a.lastModifiedDate.getTime() < b.lastModifiedDate.getTime())
			      return 1;
			    return 0;
			});
	
			// record summary in project
			if (project.items.length > 0)
				project.recentModifiedDate = project.items[0].lastModifiedDate;
		}
	
		// sort project list by most recent first
		person.projects.sort(function (a, b) {
			if (a.recentModifiedDate.getTime() > b.recentModifiedDate.getTime())
				return -1
			if (a.recentModifiedDate.getTime() < b.recentModifiedDate.getTime())
		      return 1;
		    return 0;
		});
	}
	
	// sort users by most recent update
	data.sort(function (a,b) {
		var dateA = new Date(0);
		var dateB = new Date(0);
	
		if (a.projects.length > 0)
			dateA = a.projects[0].recentModifiedDate;
	
		if (b.projects.length > 0)
			dateB = b.projects[0].recentModifiedDate;
	
		if (dateA.getTime() > dateB.getTime())
			return -1
		if (dateA.getTime() < dateB.getTime())
	      return 1;
	    return 0;    	
	
	});
	
	// sort all items
	allItems.sort(function (a, b) {
		if (a.lastModifiedDate.getTime() > b.lastModifiedDate.getTime())
			return -1
		if (a.lastModifiedDate.getTime() < b.lastModifiedDate.getTime())
	      return 1;
	    return 0;
	});	    
	
	allItems.splice(50);
	
	$scope.$parent.allItems = allItems;
	$scope.$parent.results = data;
	$scope.$parent.personMap = personMap;
	$scope.$parent.location = $location;

} 
 
function UserCntl($scope, $routeParams, $location, mockdata) {

	$scope.mockdata = mockdata.data;
	ParseMockData($scope,$location);

	$scope.userParam = $routeParams["userId"];

	$scope.$parent.selectedUser = null;
	for (var i=0; i<$scope.results.length; i++) {
		var user = $scope.results[i];
		if (user.name === $scope.userParam) {
			$scope.$parent.selectedUser = user;
		}
	}
	
	if (!$scope.$parent.selectedUser)
		$scope.$parent.location.path('/recent');	
}

function ProjectCntl($scope, $routeParams, $location, mockdata) {

	$scope.mockdata = mockdata.data;
	ParseMockData($scope,$location);

	$scope.userParam = $routeParams["userId"];
	$scope.projectParam = $routeParams["projectId"];
		
	// find user
	for (var i=0; i<$scope.results.length; i++) {
		var user = $scope.results[i];
		if (user.name === $scope.userParam) {
			$scope.$parent.selectedUser = user;
		}
	}		
		
	// find project
	for (var i=0; i<$scope.$parent.selectedUser.projects.length; i++) {
		var project = $scope.$parent.selectedUser.projects[i];
		if (project.name === $scope.projectParam) {
			$scope.$parent.selectedProject = project;
		}
	}
}

function RecentCntl($scope, $routeParams, $location, mockdata) {
  $scope.mockdata = mockdata.data;
  ParseMockData($scope,$location);
}

function mocksController($scope , $http, $location, MockupDataSource) {

	$scope.cachePath = function($item) {
		return 'data/cache/' + $item.project.user.name + '/' + $item.project.name + '/' + $item.name;
	}	
	
	$scope.projectPath = function($project) {
		return '#/user/'+$project.user.name+'/project/'+$project.name;
	}

	$scope.fullPath = function($item) {
		var prefix = 'KAYAK.com Product Development/+++ products +++/';
		var tailPath = $item.path.slice(prefix.length);

		return "http://dawn.ma.runwaynine.com/dropbox/+++ Products +++" + tailPath;
	}

	$scope.itemUser = function($item) {
		return $item.project.user;
	}

	$scope.swapUser = function($username) {
		$scope.selectedUser = $scope.personMap[$username];

		if ($scope.selectedUser) 
			$scope.location.path('/user/'+$scope.selectedUser.name);
		else
			$scope.location.path('/recent');
	}
}