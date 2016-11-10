(function() {
  'use strict';

  angular
  .module('cySubapp.plans')
  .factory('RouteResolver', RouteResolver);
  RouteResolver.$inject = ['$q'];
  function RouteResolver($q) {
    function __RouteResolver(maps, modes, retryLimitPerMode, routePoint, planItem, mapTarget, displayedDirections, cachedDisplayedDirections) {
      this.maps = maps;
      this.modes = modes; // ['TRANSIT', 'DRIVING','WALKING']
      this.retryLimitPerMode = retryLimitPerMode;
      this.routePoint = routePoint;
      this.planItem = planItem;
      this.mapTarget = mapTarget;
      this.displayedDirections = displayedDirections;
      this.cachedDisplayedDirections = cachedDisplayedDirections;
      this.status = 'CY_DEFAULT';
    }
    __RouteResolver.prototype.resolve = function() {
      var def = $q.defer();
      if (this.retryLimitPerMode-- <= 0) {
        var status = 'CY_OVER_RETRY_LIMIT';
        this.planItem.route.isLoaded = true;
        def.resolve(status);
        return def.promise;
      }
      var start = this.routePoint.start.latlng;
      var end = this.routePoint.end.latlng;
      var maps = this.maps;
      var mode = this.modes[0];
      var modesSize = this.modes.length;
      var request = {
        origin: start,
        destination: end,
        travelMode: mode, // 'TRANSIT' || 'DRIVING' || 'WALKING'
        unitSystem: maps.UnitSystem.METRIC,
        transitOptions: {
          // NOTE: Set arrivalTime or departureTime
          // departureTime: new Date(1337675679473),
          modes: [
            maps.TransitMode.BUS,
            maps.TransitMode.RAIL,
            maps.TransitMode.SUBWAY,
            maps.TransitMode.TRAIN,
            maps.TransitMode.TRAM
          ]
          // routingPreference: google.maps.TransitRoutePreference.FEWER_TRANSFERS
          // NOTE: Using this option, you can bias the options returned,
          //       rather than accepting the default best route chosen by the API.
        },
        // NOTE:  true when alternative routes is required
        // provideRouteAlternatives: true
      };
      var cachekey = String(start) + '-' + String(end);
      var mapTarget = this.mapTarget;
      var planItem = this.planItem;
      var displayedDirections = this.displayedDirections;
      var cachedDisplayedDirections = this.cachedDisplayedDirections;
      var directions;
      var rendererOptions = {
        suppressMarkers: true,
        suppressInfoWindows: true,
        hideRouteList: true,
        preserveViewport: true
      };
      var displayedDirection = new maps.DirectionsRenderer(rendererOptions);
      var directionsService = new maps.DirectionsService();
      var isCacheHit = false;
      var cachedDd = cachedDisplayedDirections[cachekey];
      if (cachedDd) {
        var mode;
        var route;
        if (cachedDd.directions) {
          mode = cachedDd.directions.request.travelMode;
          route = cachedDd.directions.routes[0];
        }
        if (route && mode) {
          var leg = route.legs[0];
          planItem.route = {
            distance: leg.distance.text,
            duration: leg.duration.text,
            travelMode: mode,
            steps: leg.steps,
            startAddress: leg.start_address,
            endAddress: leg.end_address,
            hasDirection: true,
            isLoaded: true
          };
          displayedDirection.setMap(mapTarget);
          displayedDirection.setDirections(cachedDd.directions);
          displayedDirections.push(displayedDirection);
          def.resolve(cachedDd.directions.status);
        } else {
          var status = 'CY_NO_ROUTE';
          planItem.route = {
            distance: 'NO DISTANCE',
            duration: 'NO DURATION',
            //FIXME: This property may be not used(with CY_NO_ROUTE)
            travelMode: 'WALKING',
            steps: [],
            startAddress: '',
            endAddress: '',
            hasDirection: false,
            isLoaded: true
          };
          def.resolve(status);
        }
        isCacheHit = true;
      }
      if (isCacheHit === true) {
        return def.promise;
      }

      directionsService.route(request, function(directionsResult, status) {
        if (status === 'OK') {
          var leg = directionsResult.routes[0].legs[0];
          var steps = leg.steps;
          displayedDirection.setMap(mapTarget);
          displayedDirection.setDirections(directionsResult);
          displayedDirections.push(displayedDirection);
          cachedDisplayedDirections[cachekey] = displayedDirection;
          planItem.route = {
            distance: leg.distance.text,
            duration: leg.duration.text,
            travelMode: mode,
            steps: steps,
            startAddress: leg.start_address,
            endAddress: leg.end_address,
            hasDirection: true,
            isLoaded: true
          };
          def.resolve(status);
        }else {
          planItem.route = {
            distance: 'NO DISTANCE',
            duration: 'NO DURATION',
            travelMode: mode,
            steps: [],
            startAddress: '',
            endAddress: '',
            hasDirection: false,
            isLoaded: false
          };
          if (modesSize === 1) {
            var status = 'CY_NO_ROUTE';
            planItem.route.isLoaded = true;
            if (directionsResult) {
              displayedDirection.setDirections(directionsResult);
            }
            displayedDirections.push(displayedDirection);
            cachedDisplayedDirections[cachekey] = displayedDirection;
            def.resolve(status);
            return def.promise;
          }
          def.reject(status);
        }
      });
      return def.promise;
    };
    return __RouteResolver;
  }
})();
