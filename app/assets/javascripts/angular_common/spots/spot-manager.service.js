(function() {
  'use strict';

  angular
  .module('cyCommon.spots')
  .service('SpotManager', SpotManager);

  SpotManager.$inject = ['$q', 'Restangular'];

  function SpotManager($q, Restangular) {
    var __SpotManager = {
      getFilteredList: function(cc) {
        var deferred = $q.defer();
        var params =  { cc: cc };

        Restangular.one('spots').one('search').get(params).then(function(data) {
          deferred.resolve(data.spots);
        }, function(err) {
          deferred.reject(err);
        });

        return deferred.promise;
      }
    };
    return __SpotManager;
  }
})();

