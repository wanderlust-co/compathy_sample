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
      templateUrl: '/templates/subapp/plans/new',
      controller: 'PlansNewController',
      controllerAs: 'vm',
      reloadOnSearch: false
    })
    ;
  }
})();