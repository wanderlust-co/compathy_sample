(function() {
  'use strict';

  angular
  .module('cySubapp.plans')
  .controller('PlansMapSearchBoxController', PlansMapSearchBoxController);

  PlansMapSearchBoxController.$inject = ['$scope'];

  function PlansMapSearchBoxController($scope) {
    var vm = this;
    vm.showRectangleSearchButton = false;
    vm.rectangleSearch = function() {
      $scope.$emit('rectangleSearch');
    };
    $scope.$on('showRectangleSearchButton', function() {
      vm.showRectangleSearchButton = true;
    });
    $scope.$on('hideRectangleSearchButton', function() {
      vm.showRectangleSearchButton = false;
    });
  };
})();
