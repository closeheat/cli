app.controller('HomeController', ['$scope', function($scope) {
  $scope.name = 'Angular';

  $scope.heading = function() {
    return 'Hello Beautiful World of ' + $scope.name;
  };
}]);
