(function() {
  'use strict';

  angular
  .module('cyCommon.spots')
  .service('SpotManager', SpotManager);

  SpotManager.$inject = ['$q', 'Restangular', 'cyUtil', 'APP_CONST'];

  function SpotManager($q, Restangular, cyUtil, APP_CONST) {
    var __SpotManager = {
      getAreasListBy: function(cc) {
        var deferred = $q.defer();
        if (cyUtil.isPresent(cc)) {
          deferred.resolve(APP_CONST.CY_AREAS.filter(function(area) {
            return area.cc == cc;
          }, cc));
        }else {
          deferred.reject();
        }
        return deferred.promise;
      },
      getFilteredList: function(cc, areaId, sw, ne, searchText, zoom, cat0Ids, cat2Ids, page, per, orderBy, orderDirection, excludedIds, isGlobalSearch) {
        var deferred = $q.defer();
        var params =  {
          cc: cc, areaId: areaId, sw: sw, ne: ne, searchText: searchText, zoom: zoom,
          'cat0Ids[]': cat0Ids, 'cat2Ids[]': cat2Ids,
          page: page, per: per, orderBy: orderBy, orderDirection: orderDirection, 'excludedIds[]': excludedIds,
          isGlobalSearch: isGlobalSearch
        };

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