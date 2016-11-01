(function() {
  'use strict';

  angular
  .module('cySubapp')
  .config(configure);

  configure.$inject =['$locationProvider', '$logProvider'];

  function configure($locationProvider, $logProvider, APP_ENV) {
    $locationProvider.html5Mode(true);
  }
})();