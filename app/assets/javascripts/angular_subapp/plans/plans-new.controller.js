(function() {
  'use strict';

  angular.module('cySubapp.plans')
  .controller('PlansNewController', PlansNewController);

  PlansNewController.$inject = ['$window', '$location', '$state', '$log'];

  function PlansNewController($window, $location, $state, $log) {
    var vm = this;
    vm.plan = {};

    vm.hoge = 'hoge---------';
  }
})();