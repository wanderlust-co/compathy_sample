'use strict';

angular.module('compathyClone')
  .config(['$translateProvider', function ($translateProvider) {
    $translateProvider
      .useStaticFilesLoader({
        prefix: '/languages/',
        suffix: '.json?201512041944' // FIXME: work around for cache problem
      })
      .useCookieStorage();

    // CAUTION: need these config to avoid store "undefined" to NG_TRANSLATE_LANG_KEY in cookie
    //          it might cause error: Uncaught SyntaxError: Unexpected token u
    $translateProvider.preferredLanguage('ja');
    $translateProvider.fallbackLanguage('en');

    // NOTE: see more at: http://angular-translate.github.io/docs/#/guide/19_security
    $translateProvider.useSanitizeValueStrategy('escaped');
  }]);