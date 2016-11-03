(function() {
  'use strict';

  angular
    .module('cyCommon.restangular.v3', ['restangular'])
    .config(configure);

  configure.$inject = ['RestangularProvider'];

  function configure(RestangularProvider) {
    RestangularProvider.setBaseUrl('/api');
    RestangularProvider.addResponseInterceptor(function(
        data/*, operation, what, url, response, deferred*/) {
      var extractData = data;
      // NOTE: API response should have "responseStatus" property
      if (data.responseStatus === 1200) {
        extractData = data.responseBody;
      }
      return extractData;
    });
  }
})();

