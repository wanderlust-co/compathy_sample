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
        var params = { cc: cc };

        var spot1 = { id: 11, name: 'spot 1', fsqSpotId: 'a1', lat: 111.00, lng: 11 };
        var spot2 = { id: 12, name: 'spot 2', fsqSpotId: 'a2', lat: 121.00, lng: 12 };
        var spot3 = { id: 13, name: 'spot 3', fsqSpotId: 'a3', lat: 131.00, lng: 13 };
        var spot4 = { id: 14, name: 'spot 4', fsqSpotId: 'a4', lat: 141.00, lng: 14 };

        if (cc == 'AD') {
          deferred.resolve([spot1, spot2]);
        } else {
          deferred.resolve([spot3, spot4]);
        }

        // Restangular.one('spots').one('serach').get(params).then(function(data) {
        //   deferred.resolve(data.spots);
        // }, function(err) {
        //   deferred.reject(err);
        // });

        return deferred.promise;
      }
    };
    return __SpotManager;
  }
})();