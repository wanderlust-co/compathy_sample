(function() {
  'use strict';

  angular.module('cySubapp')
  .config(configure);

  configure.$inject = ['$stateProvider', '$urlRouterProvider'];

  function configure($stateProvider, $urlRouterProvider) {
    $urlRouterProvider.otherwise('/404');
    $stateProvider
    .state('plansNew', {
      url: '/plans/new',
      templateUrl: '/templates/subapp/plans/edit',
      controller: 'PlansNewController',
      controllerAs: 'vm',
      reloadOnSearch: false
    })
    .state('plansEdit', {
      url: '/plans/{planId:int}/edit',
      templateUrl: '/templates/subapp/plans/edit',
      controller: 'PlansEditController',
      controllerAs: 'vm',
      reloadOnSearch: false
    })
    ;
  }
})();