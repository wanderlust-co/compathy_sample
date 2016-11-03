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

        var spot1 = { id: 11, name: 'spot 1', fsqSpotId: 'abc123', lat: 123.12, lng: 50.12 };
        var spot2 = { id: 12, name: 'spot 2', fsqSpotId: 'abc456', lat: 456.12, lng: 50.12 };
        var spot3 = { id: 13, name: 'spot 3', fsqSpotId: 'xyz123', lat: 888.88, lng: 88.12 };
        var spot4 = { id: 14, name: 'spot 4', fsqSpotId: 'xyz456', lat: 999.99, lng: 99.12 };


        // FIXME: use real API
        if (cc == 'AD') {
          deferred.resolve([spot1, spot2]);
        } else {
          deferred.resolve([spot3, spot4]);
        }

        //Restangular.one('spots').one('search').get(params).then(function(data) {
        //  deferred.resolve(data.spots);
        //}, function(err) {
        //  deferred.reject(err);
        //});

        return deferred.promise;
      }
    };
    return __SpotManager;
  }
})();

