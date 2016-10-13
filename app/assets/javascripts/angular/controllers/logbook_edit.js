(function() {
  'use strict';

  angular.module('compathyClone')
  .controller('LogbookEditController', LogbookEditController);

  LogbookEditController.$inject = ['$scope', '$window', '$http', '$location', '$timeout'];

  function LogbookEditController($scope, $window, $http, $location, $timeout) {
    $scope.hoge = 'hoge-';
  }
})();

