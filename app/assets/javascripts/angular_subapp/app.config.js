(function() {
  'use strict';

  angular
  .module('cySubapp')
  .config(configure)
  .config(configureMap);

  configure.$inject = ['$locationProvider', '$logProvider'];
  configureMap.$inject = ['uiGmapGoogleMapApiProvider', 'APP_CONST'];

  function configure($locationProvider, $logProvider, APP_ENV) {
    $locationProvider.html5Mode(true);
  }

  function configureMap(uiGmapGoogleMapApiProvider, APP_CONST) {
    var locale = 'ja';
    uiGmapGoogleMapApiProvider.configure({
      key: APP_CONST.GOOGLE_API_KEY,
      v: '3.21',
      libraries: 'places,weather,geometry,visualization',
      laguage: locale
    });
  }
})();

