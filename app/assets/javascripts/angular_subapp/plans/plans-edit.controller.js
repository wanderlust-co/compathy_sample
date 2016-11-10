(function() {
  'use strict';

  angular
  .module('cySubapp.plans')
  .controller('PlansEditController', PlansEditController);

  PlansEditController.$inject = [
    '$scope', '$window', '$location', '$stateParams', '$uibModal', '$log', '$timeout', '$translate', '$cookies',
    '$anchorScroll', 'uiGmapGoogleMapApi', 'SpotManager', 'CountryManager', 'cyUtil', 'cyCalendar', 'PlanManager'
  ];

  function PlansEditController(
    $scope, $window, $location, $stateParams, $uibModal, $log, $timeout, $translate, $cookies,
    $anchorScroll, uiGmapGoogleMapApi, SpotManager, CountryManager, cyUtil, cyCalendar, PlanManager
  ) {
    var vm = this;
    var mapSearchRadius = 0.05; // TODO: Tweak this value

    vm.planId = $stateParams.planId;
    vm.currentDay = 0;
    vm.plan   = {};
    vm.currentUser = {};
    vm.tl8 = {};

    vm.planDates = {
      startDate: vm.plan.dateFrom,
      endDate: vm.plan.dateTo
    }

    vm.dayRange = '';

    vm.dateOptions = angular.copy(cyCalendar.getDateOptions());
    vm.dateOptions.eventHandlers['apply.daterangepicker'] = function(ev) {
      updateDates(ev.model.startDate, ev.model.endDate);
    };

    vm.spotIsLoading = false;
    vm.per = 20;
    vm.page = 1;
    vm.hasMoreData = false;

    vm.selects = {
      country: {
        model: null,
        options: [],
        config: {
          create: false,
          sortField: 'name',
          valueField: 'cc',
          labelField: 'name',
          searchField: ['name', 'cc'],
          maxItems: 1,
          selectOnTab: true,
          onChange: function(cc, areaId) {
            vm.spotIsLoading = true;
            console.log(vm.selects.country);
            console.log(vm.selects.state);
            //国が選択されたらccを元にareaの情報をオプションに追加
            if (!cc.nil) {
              SpotManager.getAreasListBy(cc).then(function(areas) {
                vm.selects.state.options = areas;
              });
            } else if ($scope.params && $scope.params.area) {
              SpotManager.getAreasListBy($scope.params.area.cc).then(function(areas) {
                vm.rsCountry.options = generateSelectizeOptAreas(areas);
              });
              vm.selectize.settings.placeholder = vm.tl8.plan__spot_search_placeholder_keyword;
              vm.selectize.updatePlaceholder();
            } else {
              CountryManager.getCountries().then(function(countries) {
                var selectizeOptCountries = generateSelectizeOptCountries(countries);
                vm.rsCountry.options = selectizeOptCountries;
                vm.countries         = selectizeOptCountries;
              });
              vm.selectize.settings.placeholder = vm.tl8.plan__spot_search_placeholder_list;
              vm.selectize.updatePlaceholder();
            }

            //国が選択されたら国に紐づくスポット情報を出力
            if (cc != vm.selects.country.model) {
              vm.selects.country.model = cc;
              if (!!cc) {
                SpotManager.getFilteredList(cc, areaId, vm.page, vm.per).then(function(data) {
                  $log.info(data);
                  vm.spots = data;
                  vm.spotIsLoading = false;
                  setSpotMarkers();
                  if (0 < vm.spots.length) {
                    fitMarkerBounds(vm.spotMarkers);
                  }
                });
              }
            }

          }
        }
      },
      state: {
        model: null,
        options: [],
        config: {
          create: false,
          sortField: 'name',
          valueField: 'id',
          labelField: 'name',
          searchField: ['name'],
          maxItems: 1,
          selectOnTab: true,
          //stateが選択されたらspot情報をフィルタリング
          onChange: function(stId) {
            if (stId != vm.selects.state.model) {
              vm.selects.state.model = stId;
              if (!!stId) {
                SpotManager.getFilteredList(null, stId, vm.page, vm.per).then(function(data) {
                  $log.info(data);
                  vm.spots = data;
                  vm.spotIsLoading = false;
                });
              }
            }
          }
        }
      },
    };

    vm.spots = [];

    vm.map = {
      center: { latitude: 0, longitude: 0 },
      zoom: 3,
      control: {},
      bounds: {}
    };
    vm.mapOptions = {
      scaleControl: true,
      mapTypeControl: false,
      scrollwheel: true,
      streetViewControl: false,
      zoomControl: true,
    };

    vm.spotMarkers = [];

    vm.addPlanItem = addPlanItem;
    vm.save = save;
    vm.setCurrentDay = setCurrentDay;

    CountryManager.getCountries().then(function(countries) {
      vm.selects.country.options = countries;
      vm.countries                 = countries;
    });


    $scope.$on('rectangleSearch', function(/* event */) {
      spotSearchByRectangle();
    });

    activate();

    ///////////////////////////////////////////////////////////////
    // public methods
    ///////////////////////////////////////////////////////////////

    function addPlanItem(sp) {
      PlanManager.addPlanItem(vm.currentDay, sp);
    }

    function save() {
      PlanManager.saveCurrentPlan().then(function(data) {
        $log.debug(data);
      });
    }

    function setCurrentDay(index) {
      vm.currentDay = index;
      PlanManager.setCurrentDay(index);
    }

    ///////////////////////////////////////////////////////////////
    // private methods
    ///////////////////////////////////////////////////////////////

    vm.getBkFilteredSpots = function(spot/*, index*/) {
      var ret = true;
      // NOTE: Filtering is done by the client only while using the Wishlist!
      if (!vm.isSpotSearch) {
        if (cyUtil.isPresent(vm.selects.state.model)) {
          ret = spot.state.id === parseInt(vm.selects.state.model);
        }
      }
      return ret;
    };

    function activate() {
      PlanManager.fetchEdit(vm.planId).then(function(data) {
        $log.debug('activate()');
        vm.plan = data;
        vm.dayRange = vm.plan.getDayRange();
        setSpotMarkers();
        refreshRouteAndMarkers();

        setGmapEvents();
      });
    }

    function updateDates(start, end, dontUpdateMap) {
      vm.plan.updateDates(start, end);
      vm.dayRange = vm.plan.getDayRange();
    }

    function setSpotMarkers() {
      var targetSpots = vm.spots;

      vm.spotMarkers = targetSpots.map(function(spot) {
        var marker = {
          id: spot.id,
          name: spot.name,
          latitude: spot.lat,
          longitude: spot.lng
        };

        marker.onClick = function() {
          $log.debug('marker.onClick');
        };
        marker.spot = spot;
        marker.closeClick = function() {
          $log.debug('marker.closeClick');
        };

        return marker;
      });
    }

    function setPlanMarkers() {
      vm.planMarkers = vm.plan.dailyPlans[vm.currentDay].planItems.map(function(pItem, index) {
        var spot = pItem.spot;
        var marker = {
          id: spot.id,
          name: spot.name,
          latitude: spot.lat,
          longitude: spot.lng
        };

        marker.onClick = function() {
          $log.debug('marker.onClick');
        };
        marker.spot = spot;
        marker.closeClick = function() {
          $log.debug('marker.closeClick');
        };

        return marker;
      });
      if (vm.planMarkers.length > 0) {
        fitMarkerBounds(vm.planMarkers);
      }
    }

    function fitMarkerBounds(markers) {
      if (cyUtil.isBlank(markers)) {
        vm.map.zoom = 3;
        return;
      }

      uiGmapGoogleMapApi.then(function(maps) {
        var bounds = new maps.LatLngBounds();
        angular.forEach(markers, function(marker) {
          bounds.extend(new maps.LatLng(marker.latitude, marker.longitude));
        });

        var map = vm.map.control.getGMap();
        map.fitBounds(bounds);
      });
    }

    function refreshRouteAndMarkers() {
      $log.debug('refreshRouteAndMarkers');
      setPlanMarkers();
      //PlanMapManager.calcRoute(vm.plan.dailyPlans[vm.currentDay].planItems, vm.map.control);
    }

    function setGmapEvents() {
      uiGmapGoogleMapApi.then(function(maps) {
        maps.event.addListener(vm.map.control.getGMap(), 'idle', function() {
          $log.debug('idle');
          $scope.$broadcast('showRectangleSearchButton');
        });
      });
    }

    function spotSearchByRectangle() {
      $log.debug('spotSearchByRectangle');
    }
  }
})();

