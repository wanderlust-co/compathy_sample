(function() {
  'use strict';

  angular
  .module('cySubapp.plans')
  .controller('PlansEditController', PlansEditController);

  PlansEditController.$inject = [
    '$scope', '$window', '$location', '$stateParams', '$uibModal', '$log', '$timeout', '$translate', '$cookies',
    '$anchorScroll', 'uiGmapGoogleMapApi', 'SpotManager', 'CountryManager', 'cyUtil', 'cyCalendar', 'PlanManager', 'PlanMapManager'
  ];

  function PlansEditController(
    $scope, $window, $location, $stateParams, $uibModal, $log, $timeout, $translate, $cookies,
    $anchorScroll, uiGmapGoogleMapApi, SpotManager, CountryManager, cyUtil, cyCalendar, PlanManager, PlanMapManager
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
      cat2: {
        model: null,
        options: [],
        config: {
          create: false,
          sortField: 'parentId',
          valueField: 'id',
          labelField: vm.locale,
          searchField: ['urlName', vm.locale],
          maxItems: 1,
          selectOnTab: true,
          onChange: function(id) {
            if (id != vm.selects.cat2.model) {
              vm.selects.cat2.model = id;
              vm.spotSearchPanelParams = {
                sw: vm.map.bounds.southwest, ne: vm.map.bounds.northeast
              };

              vm.searchSpot(
                /* cc             */null,
                /* areaId         */null,
                /* sw             */vm.map.bounds.southwest,
                /* ne             */vm.map.bounds.northeast,
                /* searchText     */vm.spotSearchPanelParams.searchText,
                /* zoom           */null,
                /* page           */1
                );

              if ($window.ga) {
                $window.ga('send', 'event', 'CreatePlan', 'Search', 'SelectCategory2');
              }
            }
          }
        }
      },
    };

    vm.spots = [];

    vm.spotSearchPanelParams = {
      country: null,
      area:    null,
      searchText: '',
      cat0Ids: [],
      cat2Ids: [],
      sw: null,
      ne: null,
      zoom: 0
    };

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
    vm.planMarkers = [];

    vm.addPlanItem = addPlanItem;
    vm.delPlanItem = delPlanItem;
    vm.save = save;
    vm.setCurrentDay = setCurrentDay;

    vm.spotSearchByRectangle = function() {
      vm.spotSearchPanelParams = {
        searchText: vm.spotSearchPanelParams.searchText,
        sw: vm.map.bounds.southwest, ne: vm.map.bounds.northeast
      };

      vm.searchSpot(
        /* cc             */null,
        /* areaId         */null,
        /* sw             */vm.map.bounds.southwest,
        /* ne             */vm.map.bounds.northeast,
        /* searchText     */vm.spotSearchPanelParams.searchText,
        /* zoom           */null,
        /* page           */1
        );
    };

    CountryManager.getCountries().then(function(countries) {
      vm.selects.country.options = countries;
      vm.countries                 = countries;
    });

    vm.searchSpot = function(cc, areaId, sw, ne, searchText, zoom, page) {
      vm.spotIsLoading = true;
      vm.spotThumbCheckTimer = null;
      vm.per = 20;
      page = page || 1;

      $scope.$broadcast('hideRectangleSearchButton');

      SpotManager.getFilteredList(
        /* cc             */cc,
        /* areaId         */areaId,
        /* sw             */sw,
        /* ne             */ne,
        /* searchText     */searchText,
        /* zoom           */zoom,
        /* cat0Ids        */cyUtil.isNullOrEmpty(vm.cat1Name) ? [] : APP_CONST.CY_CAT0_IDS[vm.cat1Name],
        /* cat2Ids        */cyUtil.isNullOrEmpty(vm.selects.cat2.model) ? [] : [vm.selects.cat2.model],
        /* page           */page,
        /* per            */vm.per,
        /* orderBy        */vm.orderBy,
        /* orderDirection */vm.orderDirection,
        /* excludeIds     */[]).then(function(spots) {
          vm.hasMoreData = spots.length == vm.per;
          if (1 < page) {
            cyUtil.mergeArrays(vm.spots, spots);
          } else {
            vm.spots = spots;
          }
          // loadSpotThumbnails();
          setSpotMarkers();
          if (0 < vm.spots.length) {
            fitMarkerBounds(vm.spotMarkers);
          }
        }, function(err) {
          $log.debug(err);
          $window.alert(vm.tl8.error_sorry);
        }).finally(function() {
          vm.spotIsLoading = false;
        });
    };

    $scope.$on('rectangleSearch', function() {
      vm.spotSearchByRectangle();
    });

    activate();

    ///////////////////////////////////////////////////////////////
    // public methods
    ///////////////////////////////////////////////////////////////

    function addPlanItem(sp) {
      function hidePreviousCalcResult() {
        angular.forEach(vm.plan.dailyPlans[vm.currentDay].planItems, function(pItem, idx) {
          if (idx !== vm.plan.dailyPlans[vm.currentDay].planItems.length - 2) { return; }
          if (pItem.route) {
            pItem.route.isLoaded = false;
          }
        });
      }

      PlanManager.addPlanItem(vm.currentDay, sp);
      hidePreviousCalcResult();
      refreshRouteAndMarkers();
      // closeSpotView();
      setSpotMarkers();
    }

    function delPlanItem(idx) {
      PlanManager.delPlanItem(vm.currentDay, idx);
      refreshRouteAndMarkers();
      setSpotMarkers();
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

    function closeSpotView() {
      vm.spotView.isOpened = false;
      vm.spotView.spot = null;
    }

    ///////////////////////////////////////////////////////////////
    // private methods
    ///////////////////////////////////////////////////////////////

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
      PlanMapManager.calcRoute(vm.plan.dailyPlans[vm.currentDay].planItems, vm.map.control);

    }

    function setGmapEvents() {
      uiGmapGoogleMapApi.then(function(maps) {
        maps.event.addListener(vm.map.control.getGMap(), 'idle', function() {
          $log.debug('idle');
          $scope.$broadcast('showRectangleSearchButton');
        });
      });
    }
  }
})();

