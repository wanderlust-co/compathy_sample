(function() {
  'use strict';

  angular
  .module('cySubapp')
  .config(configure);

  configure.$inject    = ['$locationProvider', '$logProvider']; //, 'APP_ENV'];

  function configure($locationProvider, $logProvider, APP_ENV) {
    $locationProvider.html5Mode(true);
    //$logProvider.debugEnabled(APP_ENV !== 'production');
  }
})();

