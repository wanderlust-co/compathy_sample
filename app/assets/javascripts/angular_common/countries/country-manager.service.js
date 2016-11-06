(function() {
  'use strict';

  angular
  .module('cyCommon.countries')
  .service('CountryManager', CountryManager);

  CountryManager.$inject = ['$q', 'Restangular'];

  function CountryManager($q, Restangular) {
    var countries;
    var __CountryManager = Restangular.service('countries');

    angular.extend(__CountryManager, {
      getCountries: function() {
        var deferred = $q.defer();
        if (!!countries) {
          deferred.resolve(angular.copy(countries));
        } else {
          __CountryManager.one().get({ all: true }).then(function(data) {
            countries = data.countries;
            deferred.resolve(angular.copy(countries));
          }, function(err) {
            deferred.reject(err);
          });
        }

        return deferred.promise;
      }
    });
    return __CountryManager;
  }
})();
