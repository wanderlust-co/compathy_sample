(function() {
  'use strict';

  angular
  .module('cySubapp', [
    'ui.router',
    'cySubapp.plans',
    ]);
  //.run(activate);

  //activate.$inject = ['cyAuth', 'cyLocale'];

  //function activate(cyAuth, cyLocale) {
  //  cyAuth.getCurrentUser().then(function(user) {
  //    cyLocale.setLocale(user.locale);
  //  });
  //}
})();

