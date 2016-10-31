(function() {
  'use strict';

  angular
  .module('cySubapp.plans')
  .controller('PlansNewController', PlansNewController);

  PlansNewController.$inject = ['$window', '$location', '$state', '$log']; //, 'cyCalendar', 'cyDevice', 'PlanManager'];

  function PlansNewController($window, $location, $state, $log) { //, cyCalendar, cyDevice, PlanManager) {
    var vm = this;
    vm.plan = {};

    vm.hoge = 'hoge---';
  }
})();

