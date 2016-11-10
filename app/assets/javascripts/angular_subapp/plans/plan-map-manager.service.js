(function() {
  'use strict';

  angular
  .module('cySubapp.plans')
  .service('PlanMapManager', PlanMapManager);

  PlanMapManager.$inject = ['$timeout', 'uiGmapGoogleMapApi', 'RouteQueue', 'RouteResolver', 'PlanManager'];

  function PlanMapManager($timeout, uiGmapGoogleMapApi, RouteQueue, RouteResolver, PlanManager) {
    var currentDisplayedDirections = [];
    var cachedDisplayedDirections = {};
    var minZoomLevel = 17;

    var mapParams = {
      center: { latitude: 0, longitude: 0 },
      zoom: 13,
      control: {},
      bounds: {}
    };

    function clearDisplayedDirections() {
      _.merge(cachedDisplayedDirections, currentDisplayedDirections);
      angular.forEach(currentDisplayedDirections, function(cdd/*, key*/) {
        //NOTE: setMap without any argument clears displayedDirections.
        cdd.setMap();
      });
      //NOTE: Following code makes hash's contents blank with keeping hash's reference.
      //      Shouldn't initialize by '= {}'
      currentDisplayedDirections.splice(0, length);
    }

    var __PlanMapManager = {
      initMapParams: function() {
        return mapParams;
      },
      getSouthwest: function() {
        return mapParams.bounds.southwest;
      },
      getNortheast: function() {
        return mapParams.bounds.northeast;
      },
      setCenter: function(lat, lng) {
        mapParams.center = { latitude: lat, longitude: lng };
      },
      getCenter: function() {
        return mapParams.center;
      },
      setZoom: function(zoom) {
        mapParams.zoom = zoom;
      },
      getZoom: function() {
        return mapParams.zoom;
      },
      calcRoute: function(planItems, mapControl) {
        uiGmapGoogleMapApi.then(function(maps) {
          var rq = new RouteQueue();
          var routePoints = PlanManager.genRoutePoints(planItems);

          clearDisplayedDirections();
          rq.init();
          angular.forEach(routePoints, function(routePoint, idx) {
            var planItem = planItems[idx];
            var modeSeekOrders = [
              maps.TravelMode.TRANSIT,
              maps.TravelMode.DRIVING,
              maps.TravelMode.WALKING
            ];
            var retryLimitPerMode = 5;
            var mapTarget = mapControl.getGMap();
            var rr = new RouteResolver(maps, modeSeekOrders, retryLimitPerMode, routePoint, planItem,
              mapTarget, currentDisplayedDirections, cachedDisplayedDirections);
            rq.enqueue(rr);
          });
          rq.loop();
        });
      },
      fitMarkerBounds: function(markers, mapControl) {
        uiGmapGoogleMapApi.then(function(maps) {
          var bounds = new maps.LatLngBounds();
          angular.forEach(markers, function(marker) {
            bounds.extend(new maps.LatLng(marker.latitude, marker.longitude));
          });
          var map = mapControl.getGMap();
          map.fitBounds(bounds);
          $timeout(function() {
            // We don't want to zoom in too much! Taken from:
            // http://stackoverflow.com/a/7841121/1380850
            if (map.getZoom() > minZoomLevel) {
              vm.map.zoom = minZoomLevel;
            }
          }, 0);
        });
      }
    };

    return __PlanMapManager;
  }
})();

