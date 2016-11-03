(function() {
  'use strict';

  angular
  .module('cySubapp.plans')
  .controller('PlansEditController', PlansEditController);

  PlansEditController.$inject = [
    '$scope', '$window', '$location', '$stateParams', '$uibModal', '$log', '$timeout', '$translate', '$cookies',
    '$anchorScroll', 'uiGmapGoogleMapApi', 'BookmarkManager', 'SpotManager', 'PlanMarker',
    'cyAuth', 'cyUtil', 'cyCalendar', 'RouteResolver', 'RouteQueue', 'PlanManager', 'CountryManager', 'HotelManager',
    'Lightbox', 'APP_CONST',
    'CY_CAT0_IDS', 'CY_CAT0S', 'CY_CAT2S', 'CY_SPOT_ORDER_BY', 'CY_ORDER_BY_DIRECTIONS',
    'NO_IMAGE_URL'
  ];

  function PlansEditController(
    $scope, $window, $location, $stateParams, $uibModal, $log, $timeout, $translate, $cookies,
    $anchorScroll, uiGmapGoogleMapApi, BookmarkManager, SpotManager, PlanMarker,
    cyAuth, cyUtil, cyCalendar, RouteResolver, RouteQueue, PlanManager, CountryManager, HotelManager,
    Lightbox, APP_CONST,
    CY_CAT0_IDS, CY_CAT0S, CY_CAT2S, CY_SPOT_ORDER_BY, CY_ORDER_BY_DIRECTIONS,
    NO_IMAGE_URL
  ) {
    var vm = this;
    var mapSearchRadius = 0.05; // TODO: Tweak this value

    vm.planId = $stateParams.planId;
    vm.currentDay = 0;
    vm.plan   = {};
    vm.currentUser = {};
    vm.tl8 = {};
    vm.showBookmarks = true;
    vm.translationNumOfDay = { numOfDay: 1 };
    vm.isSpotSearch = false;
    vm.utils = cyUtil;
    vm.setCurrentDay = setCurrentDay;
    vm.getDay = getDay;
    vm.delDay = delDay;
    vm.addDay = addDay;
    vm.getDayRange = getDayRange;
    vm.getDayOfWeek = getDayOfWeek;
    vm.showCalendar = showCalendar;
    vm.showBookmarkPanel   = showBookmarkPanel;
    vm.showSpotSearchPanel = showSpotSearchPanel;
    vm.openSpotView = openSpotView;
    vm.cancelMapEventAfterFitBounds = true;
    vm.spotsWithoutThumbs = [];
    vm.spotThumbCheckTimer = null;
    vm.spotThumbInterval = 2000; // Poll the server every 2 seconds
    vm.spotThumbDefaultTimeLimit = 60000; // Poll for a whole minute
    vm.spotThumbTimeLimit = vm.spotThumbDefaultTimeLimit;
    vm.spotThumbProcessedTimeOut = 12000; // Once we detect activity on the backend, we give it 12 seconds to finish
    vm.maxCarouselSize = 5;
    // TODO: Tweak the following value
    // Reference: http://gis.stackexchange.com/questions/7430/what-ratio-scales-do-google-maps-zoom-levels-correspond-to
    vm.minZoomLevel = 17;
    vm.fsqAttribution = {
      prefix: '<a target="_blank" href="http://foursquare.com/venue/',
      analytics: '?ref=' + APP_CONST.FSQ_CLIENT_ID + '" analytics-on="click" analytics-category="CreatePlan" analytics-event="Foursquare" analytics-label="OpenVenueLinkFrom',
      suffix: '">' + APP_CONST.FSQ_ATTRIBUTION_TEXT + '</a>',
      suffixIcon: '"><span class="planIconFoursquare" alt="' + APP_CONST.FSQ_ATTRIBUTION_TEXT + '"></span></a>',
      spotView: 'SpotView',
      carousel: 'Carousel',
      poweredBy: APP_CONST.FSQ_ATTRIBUTION_TEXT
    };
    vm.fsqBasePath = 'https://foursquare.com/img/categories_v2/';
    // TODO: We should probably use our own icons to avoid copyright problems with Foursquare
    vm.fsqCategoryIcons = {
      sites: vm.fsqBasePath + 'shops/camerastore_bg_88.png',
      restaurants: vm.fsqBasePath + 'food/default_bg_88.png',
      hotels: vm.fsqBasePath + 'travel/hostel_bg_88.png',
      default: vm.fsqBasePath + 'travel/touristinformation_bg_88.png'
    };

    vm.locale = $translate.use();

    $translate([
      'confirm_leave_page_losing_data',
      'error_access_forbidden',
      'error_please_login',
      'error_sorry',
      'plan__confirm_delete_day',
      'plan__confirm_delete_days',
      'plan__no_state_option_name',
      'plan__refresh_dates']).then(function(t) {
        vm.tl8 = t;
      });

    vm.calendar = cyCalendar;
    vm.planDates = {
      startDate: vm.plan.dateFrom,
      endDate: vm.plan.dateTo
    };
    vm.dayRange = '';

    vm.openRegisterSpotModal = function() {
      var modal = $uibModal.open({
        templateUrl: '/templates/common/spots/register_spot',
        controller: 'ModalRegisterSpotController',
        controllerAs: 'vm',
        backdrop: 'static',
        windowClass: 'modalPlanRegisterSpot',
        resolve: {
          latLng: function() { return [vm.map.center.latitude, vm.map.center.longitude].join(); },
          spotName: function() { return vm.spotSearchPanelParams.searchText; }
        }
      });

      modal.result.then(function(result) {
        if (result.type === 'registered') {
          var spot = result.value;
          addPlanItem(spot);
          vm.spots = [];
          vm.spotSearchPanelParams = {};
          setActiveSpotMarker(spot, /* scrollToCard */true, /* isInPlan */true);
          setPlanMarkers();
          setFsqIconToPlannedSpotForRegisteredSpot();
          loadSpotThumbnails();
          if ($window.ga) { $window.ga('send', 'event', 'CreatePlan', 'RegisterSpot', ''); }
        } else if (result.type === 'cancel') {
          if ($window.ga) { $window.ga('send', 'event', 'CreatePlan', 'CancelRegisterSpot', ''); }
        }
      });
    };

    vm.spotIsLoading = false;
    vm.per = 20;
    vm.page = 1;
    vm.orderByOptions = CY_SPOT_ORDER_BY;
    vm.orderBy = vm.orderByOptions.episodes;
    vm.previousOrderBy = vm.orderBy;
    vm.orderDirections = CY_ORDER_BY_DIRECTIONS;
    vm.orderDirection = CY_ORDER_BY_DIRECTIONS.descending;
    vm.hasMoreData = false;
    vm.cat1Name = '';
    vm.cat2Base = CY_CAT2S;
    vm.selects = {
      bkCountry: {
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
          onChange: function(cc) {
            function applyBkCountryFilter(data) {
              vm.bookmarkSpots = data.bookmarks.map(mapBookmarkToSpot);
              if (!vm.isSpotSearch) {
                vm.spots = vm.bookmarkSpots;
              }
              resetBkStates(vm.bookmarkSpots);
              setSpotMarkers();
              fitMarkerBounds(vm.spotMarkers);
              vm.spotIsLoading = false;
            }

            if (cc != vm.selects.bkCountry.model) {
              vm.selects.bkCountry.model = cc;
              vm.spotIsLoading = true;
              if (cyUtil.isPresent(cc)) {
                BookmarkManager.getListByCc(vm.currentUser.username, cc).then(applyBkCountryFilter);
              } else {
                BookmarkManager.getRecent(vm.currentUser.username).then(applyBkCountryFilter);
              }

              if ($window.ga) {
                $window.ga('send', 'event', 'CreatePlan', 'Wishlist', 'SelectCountry');
              }
            }
          }
        }
      },
      bkState: {
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
          onChange: function(stId) {
            if (stId != vm.selects.bkState.model) {
              vm.selects.bkState.model = stId;
              vm.spots = vm.bookmarkSpots.filter(vm.getBkFilteredSpots);
              setSpotMarkers();
              fitMarkerBounds(vm.spotMarkers);
              if ($window.ga) {
                $window.ga('send', 'event', 'CreatePlan', 'Wishlist', 'SelectState');
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

    vm.bookmarkSpots  = [];
    vm.resultSpots    = [];
    vm.spots          = [];

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
    vm.spotSearchPanelOnSelectCountry = function(co) {
      resetCategoryFilter();
      vm.spotSearchPanelParams = { country: co };
      vm.searchSpot(
        /* cc             */co.cc,
        /* areaId         */null,
        /* sw             */null,
        /* ne             */null,
        /* searchText     */null,
        /* zoom           */null,
        /* page           */1
        );
    };
    vm.spotSearchPanelOnSelectArea = function(area) {
      resetCategoryFilter();
      vm.spotSearchPanelParams = { area: area };
      vm.searchSpot(
        /* cc             */null,
        /* areaId         */area.id,
        /* sw             */null,
        /* ne             */null,
        /* searchText     */null,
        /* zoom           */null,
        /* page           */1
        );
    };

    // TODO: its not unified with `searchSpot` because of mixing the spot and other spots.
    vm.spotSearchPanelOnSelectSpot = function(spot) {
      resetCategoryFilter();
      vm.map.center = { latitude: spot.lat, longitude: spot.lng };
      vm.map.zoom   = 15;

      vm.spotIsLoading = true;

      var southwest = {
        latitude: spot.lat - mapSearchRadius,
        longitude: spot.lng - mapSearchRadius
      };
      var northeast = {
        latitude: spot.lat + mapSearchRadius,
        longitude: spot.lng + mapSearchRadius
      };

      vm.spotSearchPanelParams = {
        spot: spot, zoom: vm.map.zoom, sw: southwest, ne: northeast
      };

      vm.spotIsLoading = true;
      vm.spotThumbCheckTimer = null;
      vm.per = 20;

      $scope.$broadcast('hideRectangleSearchButton');

      SpotManager.getFilteredList(
        /* cc             */null,
        /* areaId         */null,
        /* sw             */southwest,
        /* ne             */northeast,
        /* searchText     */null,
        /* zoom           */null,
        /* cat0Ids        */cyUtil.isNullOrEmpty(vm.cat1Name) ? [] : CY_CAT0_IDS[vm.cat1Name],
        /* cat2Ids        */cyUtil.isNullOrEmpty(vm.selects.cat2.model) ? [] : [vm.selects.cat2.model],
        /* page           */1,
        /* per            */vm.per,
        /* orderBy        */vm.orderBy,
        /* orderDirection */vm.orderDirection,
        /* excludeIds     */[spot.id]).then(function(spots) {
          addFlagsToSpots(spots);
          vm.hasMoreData = spots.length == vm.per;

          vm.spots = [spot];
          cyUtil.mergeArrays(vm.spots, spots);

          loadSpotThumbnails();
          setSpotMarkers();
          setActiveSpotMarker(vm.spots[0]);
        }, function(err) {
          $log.debug(err);
          $window.alert(vm.tl8.error_sorry);
        }).finally(function() {
          vm.spotIsLoading = false;
        });
    };

    vm.spotSearchPanelOnInputText = function(text) {
      // NOTE: its just a trial. sometime we forget selecting category while searching with the text.
      resetCategoryFilter();

      vm.spotSearchPanelParams = {
        searchText: text, zoom: vm.map.zoom, sw: vm.map.bounds.southwest, ne: vm.map.bounds.northeast
      };

      vm.searchSpot(
        /* cc             */null,
        /* areaId         */null,
        /* sw             */vm.map.bounds.southwest,
        /* ne             */vm.map.bounds.northeast,
        /* searchText     */text,
        /* zoom           */vm.map.zoom,
        /* page           */1
        );
    };

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

    vm.processCat0 = function(name) {
      vm.selects.cat2.model = null;
      vm.selects.cat2.options.length = 0;
      if (name != vm.cat1Name) {
        vm.cat1Name = name;
        cyUtil.mergeArrays(vm.selects.cat2.options, vm.cat2Base.filter(function(cat) {
          return CY_CAT0_IDS[name].indexOf(cat.parentId) >= 0;
        }));
        if ($window.ga) { $window.ga('send', 'event', 'CreatePlan', 'Search', 'SelectCategory0'); }
        if (name === 'hotels') { // TODO: There should be a cleaner way to do this
          vm.previousOrderBy = vm.orderBy;
          vm.orderBy = vm.orderByOptions.price;
        } else {
          vm.orderBy = vm.previousOrderBy;
        }
      } else {
        vm.cat1Name = '';
        if ($window.ga) { $window.ga('send', 'event', 'CreatePlan', 'Search', 'DeselectCategory0'); }
        if (name === 'hotels') {
          vm.orderBy = vm.previousOrderBy;
        }
      }

      vm.spotSearchPanelParams = {
        searchText: vm.spotSearchPanelParams.searchText,
        sw: vm.map.bounds.southwest,
        ne: vm.map.bounds.northeast
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

    vm.setOrderBy = function(orderBy) {
      if (vm.orderBy !== orderBy) {
        if (orderBy !== vm.orderByOptions.price) {
          vm.previousOrderBy = orderBy;
        }
        vm.orderBy = orderBy;
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
          $window.ga('send', 'event', 'CreatePlan', 'Search', 'ChangedSortOrderTo' + orderBy);
        }
      }
    };

    vm.loadMoreSpot = function() {
      if (!vm.isSpotSearch || vm.spotIsLoading || !vm.hasMoreData) { return; }

      vm.page += 1;
      vm.searchSpot(
        /* cc             */vm.spotSearchPanelParams.country ? vm.spotSearchPanelParams.country.cc : null,
        /* areaId         */vm.spotSearchPanelParams.area ? vm.spotSearchPanelParams.area.id : null,
        /* sw             */vm.spotSearchPanelParams.sw,
        /* ne             */vm.spotSearchPanelParams.ne,
        /* searchText     */vm.spotSearchPanelParams.searchText,
        /* zoom           */vm.spotSearchPanelParams.zoom,
        /* page           */vm.page
        );
    };

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
        /* cat0Ids        */cyUtil.isNullOrEmpty(vm.cat1Name) ? [] : CY_CAT0_IDS[vm.cat1Name],
        /* cat2Ids        */cyUtil.isNullOrEmpty(vm.selects.cat2.model) ? [] : [vm.selects.cat2.model],
        /* page           */page,
        /* per            */vm.per,
        /* orderBy        */vm.orderBy,
        /* orderDirection */vm.orderDirection,
        /* excludeIds     */[]).then(function(spots) {
          addFlagsToSpots(spots);
          vm.hasMoreData = spots.length == vm.per;
          if (1 < page) {
            cyUtil.mergeArrays(vm.spots, spots);
          } else {
            vm.spots = spots;
          }
          loadSpotThumbnails();
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

    vm.map = {
      tilesloaded: vm.initRoute,
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
    vm.spotMarkers   = [];
    vm.planMarkers = [];

    vm.updateDates = updateDates;
    vm.addPlanItem = addPlanItem;
    vm.delPlanItem = delPlanItem;
    vm.editMemo = editMemo;
    vm.likeSpot = likeSpot;
    vm.unlikeSpot = unlikeSpot;

    vm.didClickBtnHybrid = didClickBtnHybrid;

    vm.openGuideModal = openGuideModal;

    vm.initRoute = function(/* e, eName */) {
      if (_.isEmpty(vm.plan)) { return; }
      if (isMapInitiated) { return; }
      isMapInitiated = true;

      $log.debug('vm.plan');
      $log.debug(vm.plan);
      vm.calcRoute(genRoutePoints(vm.plan.dailyPlans[vm.currentDay].planItems));
    };
    $scope.$on('openSpotView', function(event, spot) {
      closeBookmarkView();
      openSpotView(spot);
    });
    $scope.$on('addPlanItem', function(event, spot) {
      addPlanItem(spot);
    });
    $scope.$on('hideAllWindows', function(/* event */) {
      hideAllWindows();
    });
    $scope.$on('likeSpot', function(event, spot) {
      likeSpot(spot);
    });
    $scope.$on('unlikeSpot', function(event, spot) {
      unlikeSpot(spot);
    });
    $scope.$on('rectangleSearch', function(/* event */) {
      vm.spotSearchByRectangle();
    });

    vm.getFsqAttribution = function(spot, isCarousel, isIcon) {
      var link = vm.fsqAttribution.poweredBy;
      if (cyUtil.isPresent(spot)) {
        link = vm.fsqAttribution.prefix + spot.fsqSpotId + vm.fsqAttribution.analytics
        + (isCarousel ? vm.fsqAttribution.carousel : vm.fsqAttribution.spotView)
        + (isIcon ? vm.fsqAttribution.suffixIcon : vm.fsqAttribution.suffix);
      }
      return link;
    };
    vm.toggleSpotView = function() {
      closeSpotView();
      openBookmarkView();
    };
    vm.spotView = {
      isOpened: false,
      spot: null,
      page: 1,
      hasMore: false,
      isLoading: false,
      loadMoreEpisodes: function() {
        if (vm.spotView.hasMore) {
          vm.spotView.page = vm.spotView.page + 1;
          vm.spotView.isLoading = true;
          SpotManager.getMoreEpisodes(vm.spotView.spot.id, vm.spotView.page).then(function(data) {
            cyUtil.mergeArrays(vm.spotView.spot.episodes, data.episodes);
            vm.spotView.hasMore = data.hasMore;
          }).finally(function() {
            vm.spotView.isLoading = false;
          });
        }
      },
      carouselPics: [],
    };
    vm.openLightboxModal = function(index) {
      Lightbox.openModal(vm.spotView.carouselPics, index);
    };
    vm.bookmarkView = {
      isOpened: true
    };
    vm.getBkFilteredSpots = function(spot/*, index*/) {
      var ret = true;
      // NOTE: Filtering is done by the client only while using the Wishlist!
      if (!vm.isSpotSearch) {
        if (cyUtil.isPresent(vm.selects.bkState.model)) {
          ret = spot.state.id === parseInt(vm.selects.bkState.model);
        }
      }
      return ret;
    };

    var isMapInitiated = false;
    var _spotButtonSelector = '.btn-hybrid';
    var _spotMoveClass = 'btn-hybrid-move';

    // FYI: its very good information for connected sortable:
    //      https://github.com/angular-ui/ui-sortable/issues/254
    //
    // NOTE: function calls and orders
    //
    //         when NOT connect update:
    //            update( src-ui ) -> stop ( src-ui )
    //
    //         when connect update:
    //            update( src-ui ) -> remove( src-ui ) -> receive( dst-ui )
    //            -> update( dst-ui ) -> stop( src-ui )
    vm.sortableOptions = {
      //appendTo: '.planContainer',
      connectWith: '.sortable-connect',
      cancel: '.spotNoMore',
      dropOnEmpty: true,
      //helper: 'clone',
      opacity: 0.3,
      scrollSensitivity: 60,
      scrollSpeed: 30,
      // TODO: handle: '.draggable-handle',
      // TODO: placeholder: 'episodePlaceholder',
      // TODO: forcePlaceholderSize: true,
      // TODO: forceHelperSize: true,
      start: function(e, ui) {
        $log.debug('start');
        $log.debug(ui.item.find('.spotName')[0].textContent);
        ui.item.find(_spotButtonSelector).addClass(_spotMoveClass);
      },
      remove: function(e, ui) {
        $log.debug('remove');
        $log.debug(ui.item.find('.spotName')[0].textContent);
      },
      update: function(e, ui) {
        var bookmarkClass = 'sortableBookmarks';
        var planItemClass = 'sortablePlanItems';

        $log.debug('update');
        $log.debug(ui.item.find('.spotName')[0].textContent);

        // HINT: connected sortable 1st call (for src-ui)
        //       or not connected sortable 1st call
        if (!ui.item.sortable.received) {
          $log.debug('1st');

          // planItems  => bookmarks
          if (e.target.classList.contains(planItemClass)
              && ui.item.sortable.droptarget.hasClass(bookmarkClass)) {
            ui.item.sortable.cancel();
            $log.debug('planItems => bookmarks');
          }

          // bookmarks => bookmarks
          if (e.target.classList.contains(bookmarkClass)
              && ui.item.sortable.droptarget.hasClass(bookmarkClass)) {
            ui.item.sortable.cancel();
            $log.debug('bookmarks => bookmarks');
          }

          // planItems  => planItems
          if (e.target.classList.contains(planItemClass)
              && ui.item.sortable.droptarget.hasClass(planItemClass)) {
            PlanManager.setPlanIsModified(true);
            $log.debug('planItems => planItems');
          }

          // bookmarks => planItems
          if (e.target.classList.contains(bookmarkClass)
              && ui.item.sortable.droptarget.hasClass(planItemClass)) {
            $log.debug('bookmarks => planItems');
            // FIXME: want to access filtered bookmarks to get target spot
            //        by ui.item.sortable.index, but couldn't..
            var spotId = parseInt(ui.item.attr('data-spot-id'));
            var sp   = vm.spots.filter(function(spot) {
              return spot.id == spotId;
            })[0];

            if (cyUtil.isNullOrEmpty(ui.item.sortable.droptargetModel)) {
              ui.item.sortable.droptargetModel = [];
            }

            PlanManager.addPlanItem(vm.currentDay, sp, ui.item.sortable.dropindex);
            vm.map.center = { latitude: sp.lat, longitude: sp.lng };

            if ($window.ga) {
              $window.ga('send', 'event', 'CreatePlan', 'AddSpot', 'FromDragDrop');
            }

            ui.item.sortable.cancel();
            addFlagsToSpots(vm.spots);
          }
        } else {
          // HINT: connected sortable 2nd call (for dst-ui)
          $log.debug('2nd');
          if (e.target.classList.contains('planItems')) {
            $log.debug('case of moving form tripboard to plan items');
          } else {
            $log.debug('case of moving form plan items to tripboard');
          }
        }
      },
      receive: function(e, ui) {
        $log.debug('receive');
        $log.debug(ui.item.find('.spotName')[0].textContent);
      },
      stop: function(e, ui) {
        $log.debug('stop');
        $log.debug(ui.item.find('.spotName')[0].textContent);
        refreshRouteAndMarkers();
        ui.item.find(_spotButtonSelector).removeClass(_spotMoveClass);
      }
    };

    vm.calcRoute = function() {};
    uiGmapGoogleMapApi.then(function(maps) {
      vm.currentDisplayedDirections = [];
      vm.cachedDisplayedDirections = {};
      var rq = new RouteQueue();
      vm.calcRoute = function(routePoints) {
        clearDisplayedDirections();
        rq.init();
        angular.forEach(routePoints, function(routePoint, idx) {
          var planItem = vm.plan.dailyPlans[vm.currentDay].planItems[idx];
          var modeSeekOrders = [
            maps.TravelMode.TRANSIT,
            maps.TravelMode.DRIVING,
            maps.TravelMode.WALKING
          ];
          var retryLimitPerMode = 5;
          var mapTarget = vm.map.control.getGMap();
          var rr = new RouteResolver(maps, modeSeekOrders, retryLimitPerMode, routePoint, planItem,
            mapTarget, vm.currentDisplayedDirections, vm.cachedDisplayedDirections);
          rq.enqueue(rr);
        });
        rq.loop();
        return;
      };
      $scope.$watch('vm.showBookmarks',
        function(newVal) {
          if (!newVal) {
            $timeout(function() {
              if (vm.map.control.hasOwnProperty('getGMap')) {
                maps.event.trigger(vm.map.control.getGMap(), 'resize');
              }
            }, 100);
          }
        }
      );

      // NOTE: prevent from remaining map size comes from preview page
      $timeout(function() {
        if (vm.map.control.hasOwnProperty('getGMap')) {
          maps.event.trigger(vm.map.control.getGMap(), 'resize');
        }
      }, 100);
    });

    cyAuth.getCurrentUser().then(function(user) {
      vm.currentUser = user;
      PlanManager.fetchEdit(vm.planId).then(function(plan) {
        vm.plan = plan;
        resetCalendar();
        vm.spotIsLoading = true;
        BookmarkManager.getRecent(user.username).then(function(data) {
          vm.bookmarkSpots = data.bookmarks.map(mapBookmarkToSpot);
          if (vm.bookmarkSpots.length == 0) {
            initSpotSearchPanel();
          } else {
            initBookmarkPanel();
          }
          // TODO: remove also at the server.
          //vm.selects.bkCountry.options = data.allBkCountries;
          activate();
        }).then(function(err) {
          $log.debug(err);
        }).finally(function() {
          vm.spotIsLoading = false;
        });
      }, function(err) {
        $log.debug(err);
        $window.alert(vm.tl8.error_access_forbidden);
        $window.location.href = '/';
      });
    }, function(err) {
      $log.debug(err);
      $window.alert(vm.tl8.error_please_login);
      $window.location.href = '/';
    });

    CountryManager.getCountries().then(function(countries) {
      vm.selects.bkCountry.options = countries;
      vm.countries                 = countries;
    });

    // NOTE: We use angular.copy (Angular's version of JavaScript Object Deep Cloning):
    // Since the options are dynamic (they are updated during the reading call), and they are being watched by Angular,
    // the Digest cycle became an infinite loop effectively breaking the Angular lifecycle.
    vm.dateOptions = angular.copy(cyCalendar.getDateOptions());
    vm.dateOptions.eventHandlers['apply.daterangepicker'] = function(ev) {
      // TODO: Maybe we can have the start-date and end-date watched by Angular and simplify this process
      updateDates(ev.model.startDate, ev.model.endDate);

      if ($window.ga) {
        $window.ga('send', 'event', 'CreatePlan', 'ChangeDate', 'CalenderMenuEnd');
      }
    };

    vm.openPlanBasicInfoModal = function() {
      var modal = $uibModal.open({
        templateUrl: '/templates/subapp/plans/modal-plan-basic-info',
        controller: 'ModalPlanBasicInfoController',
        controllerAs: 'vm',
        backdrop: 'static',
        windowClass: 'modalPlanBasicInfo',
        resolve: {
          planTitle:       function() { return vm.plan.title; },
          planDescription: function() { return vm.plan.description; },
        }
      });

      modal.result.then(function(result) {
        if (vm.plan.willLoseDataWithNewDates(result.dateFrom, result.dateTo)
          && !$window.confirm(vm.tl8.plan__confirm_delete_days)) {
          return false;
        }

        PlanManager.setTitle(result.title);
        PlanManager.setDescription(result.description);

        vm.plan.updateDates(result.dateFrom, result.dateTo);
        vm.dayRange = vm.plan.getDayRange();
      });
    };

    vm.cleanSelectize = function(propertyName) {
      vm.selects[propertyName].model = null;
      vm.selects[propertyName].config.onChange();
    };

    vm.showSpotLoading = function() {
      if (vm.isSpotSearch && !vm.spotIsLoading && !vm.hasMoreData && vm.spots.length > 0) {
        if (!vm.rectangleSearch) { $scope.$broadcast('showRectangleSearchButton'); }
        return true;
      }
      return false;
    };

    vm.isInitialSearch = function() {
      return cyUtil.isNullOrEmpty(vm.spotSearchPanelParams.searchText)
        && cyUtil.isNullOrEmpty(vm.cat1Name)
        && cyUtil.isNullOrEmpty(vm.selects.cat2.model);
    };

    $window.onbeforeunload = function() {
      if (PlanManager.isPlanDirty()) {
        return vm.tl8.confirm_leave_page_losing_data;
      }
    };

    // FIXME: there should be a better way...
    angular.element('footer').hide();
    angular.element('.goToTopWrapper').hide();

    $scope.$on('$destroy', function() {
      angular.element('footer').show();
      angular.element('.goToTopWrapper').show();
    });

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
      closeSpotView();
      openBookmarkView();
      hideAllWindows();
      addFlagsToSpots(vm.spots);
      setSpotMarkers();
    }

    function delPlanItem(idx) {
      PlanManager.delPlanItem(vm.currentDay, idx);
      refreshRouteAndMarkers();
      addFlagsToSpots(vm.spots);
      setSpotMarkers();
    }

    function editMemo(planItem) {
      var modal = $uibModal.open({
        templateUrl: '/templates/subapp/plans/modal-plan-edit-memo',
        controller: 'ModalPlanEditMemoController',
        controllerAs: 'vm',
        backdrop: 'static',
        windowClass: 'modalPlanEditMemo',
        resolve: {
          memo: function() { return planItem.body; },
          spotInfo: function() { return { name: planItem.spot.name }; }
        }
      });

      modal.result.then(function(result) {
        if (planItem.body != result) {
          planItem.body = result;
          PlanManager.setPlanIsModified(true);
        }
      });
    }

    function likeSpot(spot) {
      BookmarkManager.createBookmark(spot.id).then(function(data) {
        var bookmark = data.bookmark;
        spot.bookmarkId = bookmark.id;
        vm.bookmarkSpots.unshift(spot);
        // NOTE: update selects(countries/states) with adding spot
        var selectOptions = vm.selects.bkCountry.options;
        var ccIsContained = _.any(selectOptions, 'cc', spot.country.cc);
        if (!ccIsContained) {
          var length = vm.selects.bkCountry.options.length;
          var country = spot.country;
          vm.selects.bkCountry.options.push({ $order: length, name: country.name, cc: country.cc, urlName: country.urlName, ja: country.ja, en: country.en });
        }
        BookmarkManager.setNeedReload();
        setSpotMarkers();
      });
    };

    function unlikeSpot(spot) {
      var bookmarkId = spot.bookmarkId;
      BookmarkManager.destroyBookmark(bookmarkId).then(function(/*data*/) {
        spot.bookmarkId = null;
        angular.forEach(vm.bookmarkSpots, function(bs, idx) {
          if (bs.id === spot.id) {
            vm.bookmarkSpots.splice(idx, 1);
            if (!vm.isSpotSearch) {
              //NOTE: also update vm.spots if bookmarkView is opened
              vm.spots = vm.bookmarkSpots.filter(vm.getBkFilteredSpots);
            }
          }
        });
        addFlagsToSpots(vm.spots);
        setSpotMarkers();
      });
    };

    function openBookmarkView() {
      vm.bookmarkView.isOpened = true;
    }
    function closeBookmarkView() {
      vm.bookmarkView.isOpened = false;
    }

    function openSpotView(spot) {
      if (!vm.spotView.spot || vm.spotView.spot.id !== spot.id) {
        vm.spotView.carouselPics = [];
        vm.spotView.numOfStarsFull = [];
        if (spot.stars) {
          vm.spotView.numOfStarsFull = new Array(Math.floor(spot.stars));
          vm.spotView.showStarHalf   = (Math.floor(spot.stars) !== Math.round(spot.stars));
        }
        SpotManager.getOneWithEpisodes(spot.id).then(function(data) {
          spot.episodes = data.episodes;
          vm.spotView.page = 1;
          vm.spotView.hasMore = data.hasMore;
          var episodes = spot.episodes.slice(0, vm.maxCarouselSize);
          angular.forEach(episodes, function(episode) {
            vm.spotView.carouselPics.push({
              url: episode.photos[0].mediumUrl,
              isEpisode: true,
              caption: episode.body
            });
          });
          if (vm.spotView.carouselPics.length < vm.maxCarouselSize) {
            var limit = vm.maxCarouselSize - vm.spotView.carouselPics.length;
            var replaceFirst = false;
            if (vm.spotView.carouselPics.length === 0) {
              if (spot.thumbnailUrl.indexOf(vm.fsqBasePath) !== 0) {
                vm.spotView.carouselPics.push({
                  // TODO: Remove this "replace" once we update all the DB's spots to use the new FSQ default size
                  url: spot.thumbnailUrl.replace('/300x500/', '/' + APP_CONST.FSQ_DEFAULT_SIZE + '/'),
                  isEpisode: false,
                  caption: vm.getFsqAttribution(spot, true, false),
                  icon: vm.getFsqAttribution(spot, true, true)
                });
                replaceFirst = true;
              }
            }
            SpotManager.getFoursquarePicsBySpot(spot.fsqSpotId, limit).then(function(urls) {
              if (replaceFirst && vm.spotView.carouselPics.length > 0) {
                var replaceIndex = urls.indexOf(vm.spotView.carouselPics[0].url);
                if (replaceIndex < 0) {
                  urls = urls.slice(0, 4);
                }
                else {
                  urls.splice(replaceIndex, 1);
                }
              }
              angular.forEach(urls, function(url) {
                vm.spotView.carouselPics.push({
                  url: url,
                  isEpisode: false,
                  caption: vm.getFsqAttribution(spot, true, false),
                  icon: vm.getFsqAttribution(spot, true, true)
                });
              });
              if (limit === vm.maxCarouselSize && vm.spotView.carouselPics.length > 0) {
                spot.thumbnailUrl = vm.spotView.carouselPics[0].url;
              }
            });
          }
        }, function(err) {
          $log.debug(err);
        });
        vm.spotView.spot = spot;
      }
      closeBookmarkView();
      vm.spotView.isOpened = true;
    }

    function closeSpotView() {
      vm.spotView.isOpened = false;
      vm.spotView.spot = null;
    }

    function searchMarkerFromSpotMarkers(sp) {
      var marker = vm.spotMarkers.filter(function(mk) {
        if (mk.id === sp.id) { return mk; }
      })[0];
      return marker;
    }
    function searchMarkerFromPlanMarkers(sp) {
      var marker = vm.planMarkers.filter(function(mk) {
        if (mk.id === sp.id) { return mk; }
      })[0];
      return marker;
    }

    function didClickBtnHybrid(sp, scrollCard, isInPlan) {
      setActiveSpotMarker(sp, scrollCard, isInPlan);
    }

    function setActiveSpotMarker(sp, scrollCard, isInPlan) {
      var marker = isInPlan ? searchMarkerFromPlanMarkers(sp) : searchMarkerFromSpotMarkers(sp);
      var category = sp.categoryName;
      if (cyUtil.isNullOrEmpty(category)) {
        category = 'etc';
      }
      if (!marker) {
        if (isInPlan) {
          var icon        = PlanMarker.getIcon('plans', category);
          marker          = PlanMarker.getMarker(sp, icon, 10);
          vm.planMarkers  = [marker];
        }
        else {
          var icon        = PlanMarker.getIcon('like', category);
          marker          = PlanMarker.getMarker(sp, icon, 1);
          vm.spotMarkers  = [marker];
        }
      }
      vm.map.center = { latitude: sp.lat + getMapInfoWindowHeightOffSet(), longitude: sp.lng };
      hideAllWindows();
      setHighlightCard(sp, true, scrollCard);
      marker.show = true;
    }

    function setHighlightCard(spot, isHighlighted, scrollCard) {
      function highlight(prefix, marker) {
        marker.spot.isHighlighted = isHighlighted;
        if (!scrollCard || !isHighlighted) { return; }
        $timeout(function() {
          $location.hash(prefix + '-' + marker.id);
          $anchorScroll();
        }, 0);
      }
      var planMarker = searchMarkerFromPlanMarkers(spot);
      var spotMarker = searchMarkerFromSpotMarkers(spot);
      if (planMarker) { highlight('plan', planMarker); }
      if (spotMarker) { highlight('spot', spotMarker); }
    }

    function getDayOfWeek(index) {
      if (cyUtil.isNullOrUndefined(vm.plan) || cyUtil.isNullOrUndefined(vm.plan.dateFrom)) { return ''; }
      return vm.plan.dateFrom.clone().add(index, 'day').format(cyCalendar.dayOfWeekFormat);
    }

    function getDayRange() {
      return (vm.plan.dateFrom ? vm.plan.dateFrom.format(cyCalendar.getDateOptions().locale.format) : '')
        + cyCalendar.getDateOptions().locale.separator
        + (vm.plan.dateTo ? vm.plan.dateTo.format(cyCalendar.getDateOptions().locale.format) : '');
    }

    function setCurrentDay(index) {
      if (index === vm.currentDay) {
        if (cyUtil.isPresent(vm.planMarkers)) {
          fitMarkerBounds(vm.planMarkers);
        }
        return;
      }

      vm.currentDay = index;
      PlanManager.setCurrentDay(index);
      vm.translationNumOfDay = { numOfDay: index + 1 };
      refreshRouteAndMarkers();
      setFsqIconToPlannedSpotForRegisteredSpot();
      if ($window.ga) {
        $window.ga('send', 'event', 'CreatePlan', 'Other', 'DateClick');
      }
    }

    function getDay(index) {
      if (vm.plan.dateFrom) {
        return vm.plan.dateFrom.clone()
          .add(index || vm.currentDay, 'day')
          .format(cyCalendar.getDateOptions().locale.format);
      }
    }

    function addDay() {
      updateDates(vm.plan.dateFrom, vm.plan.dateTo.clone().add(1, 'days'), true);
    }

    function delDay(index) {
      if (vm.plan.dailyPlans.length <= index) { return; }

      if (vm.plan.dailyPlans[index].planItems.length > 0
          && !$window.confirm(vm.tl8.plan__confirm_delete_day)) {
        resetCalendar();
        return;
      }

      PlanManager.delDay(index);

      if (index <= vm.currentDay && 0 < vm.currentDay) { setCurrentDay(vm.currentDay - 1); }

      resetCalendar();

      refreshRouteAndMarkers();
    }

    function showCalendar() {
      resetCalendar();
      angular.element('#daysRange').trigger('click');
      if ($window.ga) {
        $window.ga('send', 'event', 'CreatePlan', 'ChangeDate', 'CalenderMenuOpen');
      }
    }
    function openGuideModal(route) {
      $uibModal.open({
        templateUrl: '/templates/subapp/plans/modal-guide-plan-routes',
        controller: 'ModalGuidePlanRoutesController',
        controllerAs: 'vm',
        windowClass: 'guidePlanRoutes',
        resolve: { route: function() { return route; } }
      });
    }

    // NOTE: expected Moment object as start, end
    function updateDates(start, end, dontUpdateMap) {
      if (vm.plan.willLoseDataWithNewDates(start, end)
          && !$window.confirm(vm.tl8.plan__confirm_delete_days)) {
        resetCalendar();
        return false;
      }

      vm.plan.updateDates(start, end);
      vm.dayRange = vm.plan.getDayRange();

      var newNumOfDays = vm.plan.getNumberOfDays();
      if (newNumOfDays - 1 < vm.currentDay && 0 < vm.currentDay) {
        setCurrentDay(newNumOfDays - 1);
      }

      if (!dontUpdateMap) { refreshRouteAndMarkers(); }
      return true;
    }

    function initBookmarkPanel() {
      vm.isSpotSearch = false;
      vm.spots = vm.bookmarkSpots.filter(vm.getBkFilteredSpots);
      addFlagsToSpots(vm.spots);
      setSpotMarkers();
    }

    function showBookmarkPanel() {
      function isInBkCountries(cc) {
        var result = vm.selects.bkCountry.options.filter(function(bkCoOpt) {
          if (bkCoOpt.cc === cc) { return bkCoOpt; }
        })[0];

        return !!result;
      }
      vm.isSpotSearch = false;
      $scope.$broadcast('hideRectangleSearchButton');
      vm.resultSpots = vm.spots;
      vm.spots = [];

      if (cyUtil.isBlank(vm.spotSearchPanelParams.country)) {
        vm.selects.bkCountry.model = 'dummy';
        vm.selects.bkCountry.config.onChange(null);
        return;
      }

      if (cyUtil.isPresent(vm.spotSearchPanelParams.country)
          && !isInBkCountries(vm.spotSearchPanelParams.country.cc)) {
        vm.selects.bkCountry.model = 'dummy';
        vm.selects.bkCountry.config.onChange(null);
        return;
      }

      if (cyUtil.isPresent(vm.spotSearchPanelParams.country.cc)) {
        vm.selects.bkCountry.model = null;
        vm.selects.bkCountry.config.onChange(vm.spotSearchPanelParams.country.cc);
        return;
      }

      vm.spots = vm.bookmarkSpots.filter(vm.getBkFilteredSpots);
      addFlagsToSpots(vm.spots);
      setSpotMarkers();
    }

    function initSpotSearchPanel() {
      vm.isSpotSearch = true;
      vm.spots = vm.resultSpots;
      addFlagsToSpots(vm.spots);
      setSpotMarkers();
    }

    function showSpotSearchPanel() {
      vm.isSpotSearch = true;
      vm.spots = [];

      if (cyUtil.isPresent(vm.selects.bkState.model)
          && parseInt(vm.selects.bkState.model) === 0) {
        var cc = vm.selects.bkCountry.model;
        var co = vm.countries.find(function(_co) {
          return _co.cc === cc;
        });
        vm.spotSearchPanelOnSelectCountry(co);
        return;
      }

      if (cyUtil.isPresent(vm.selects.bkCountry.model)) {
        var cc = vm.selects.bkCountry.model;
        var co = vm.countries.filter(function(_co) {
          return _co.cc === cc;
        })[0];
        vm.spotSearchPanelOnSelectCountry(co);

        return;
      }

      vm.spots = vm.resultSpots;
      // FIXME: This could impact performance because of the "Load More" functionality
      addFlagsToSpots(vm.spots);
      setSpotMarkers();
    }

    ///////////////////////////////////////////////////////////////
    // private methods
    ///////////////////////////////////////////////////////////////

    function addFlagsToSpots(spots) {
      angular.forEach(spots, function(spot) {
        spot.isInPlan = false;
        spot.isInBookmark = false;
      });
      var planItems = _.flatten(_.map(vm.plan.dailyPlans, 'planItems'));
      var planSpots = _.map(planItems, 'spot.id');
      var bookmarkSpots = _.map(vm.bookmarkSpots, 'id');
      angular.forEach(spots, function(spot) {
        spot.isInPlan = _.includes(planSpots, spot.id);
        spot.isInBookmark = _.includes(bookmarkSpots, spot.id);
      });
    }

    function loadSpotThumbnails() {
      vm.spotsWithoutThumbs = [];
      angular.forEach(vm.spots, function(spot) {
        if (spot.thumbnailUrl === APP_CONST.WAITING_UPLOAD_URL) {
          setFsqSpotIcon(spot);
          vm.spotsWithoutThumbs.push(spot.id);
        }
        else if (spot.thumbnailUrl.indexOf(vm.fsqBasePath) === 0) {
          vm.spotsWithoutThumbs.push(spot.id);
        }
      });
      if (vm.spotsWithoutThumbs.length > 0) {
        vm.spotThumbCheckTimer = null;
        vm.spotThumbTimeLimit = vm.spotThumbDefaultTimeLimit;
        loopSpotThumbCheck();
      }
    }

    function loopSpotThumbCheck() {
      vm.spotThumbCheckTimer = $timeout(function() {
        $log.debug('loading thumbs for ' + vm.spotsWithoutThumbs.length + ' spots!');
        SpotManager.getSpotsThumbsById(vm.spotsWithoutThumbs).then(function(thumbs) {
          var previousAmount = vm.spotsWithoutThumbs.length;
          vm.spotsWithoutThumbs = [];
          angular.forEach(thumbs, function(thumb) {
            if (cyUtil.isPresent(thumb.thumbnail_url) && thumb.thumbnail_url.indexOf(vm.fsqBasePath) !== 0) {
              var tempArray = vm.spots.filter(function(spot) {
                return spot.id === thumb.id;
              });
              if (tempArray.length > 0) { tempArray[0].thumbnailUrl = thumb.thumbnail_url; }
            }
            else {
              vm.spotsWithoutThumbs.push(thumb.id);
            }
          });
          vm.spotThumbTimeLimit -= vm.spotThumbInterval;
          if (vm.spotsWithoutThumbs.length > 0 && vm.spotThumbTimeLimit > 0) {
            if (vm.spotsWithoutThumbs.length < previousAmount && vm.spotThumbTimeLimit > vm.spotThumbProcessedTimeOut) {
              vm.spotThumbTimeLimit = vm.spotThumbProcessedTimeOut;
            }
            loopSpotThumbCheck();
          }
        });
      }, vm.spotThumbInterval);
    }

    function activate() {
      $log.debug('activate()');
      setSpotMarkers();
      setPlanMarkers();
      setFsqIconToPlannedSpotForRegisteredSpot();
      vm.calcRoute(genRoutePoints(vm.plan.dailyPlans[vm.currentDay].planItems));
      setGmapEvents();
      vm.dayRange = vm.plan.getDayRange();

      if (PlanManager.isPastPlan()) {
        $timeout(function() {
          if ($window.confirm(vm.tl8.plan__refresh_dates)) {
            vm.openPlanBasicInfoModal(); // NOTE: We could use vm.showCalendar(), but it could be easily ignored by the user.
          }
        }, 2000);
      }

      var leadingLinks = angular.fromJson($cookies.get('_compathy2_links'));
      if (cyUtil.isPresent(leadingLinks) && cyUtil.isPresent(leadingLinks.first_login)) {
        if ($window.ga) { ga('send', 'event', 'CreatePlan', 'Display', 'FromLeadingLinks'); }
        $cookies.remove('_compathy2_links', { path: '/' });
        leadingLinks.first_login = false;
        $cookies.put('_compathy2_links', angular.toJson(leadingLinks), { path: '/' });
        vm.spotIsLoading = true;
        vm.isSpotSearch = true;
        $timeout(function() {
          if (leadingLinks.area_id) {
            angular.forEach(APP_CONST.CY_AREAS, function(area) {
              if (area.id == leadingLinks.area_id) {
                // FIXME: as we're using cy_constants we loose name localization
                vm.spotSearchPanelParams.searchText = vm.locale == 'ja' ? area.name : area.originalName;
                vm.searchSpot(null, area.id);
              }
            });
          } else {
            CountryManager.getCountries().then(function(countries) {
              countries.forEach(function(country) {
                if (country.cc == leadingLinks.country.toUpperCase()) {
                  vm.spotSearchPanelParams.searchText = country.name;
                  vm.searchSpot(country.cc);
                }
              });
            });
          }
        }, 1000);
      }
    }

    function setGmapEvents() {
      uiGmapGoogleMapApi.then(function(maps) {
        maps.event.addListener(vm.map.control.getGMap(), 'dragend', function() {
          $log.debug('gmap drag end');
        });

        maps.event.addListener(vm.map.control.getGMap(), 'idle', function() {
          $log.debug('idle');

          $timeout(function() {
            updateSpotSearchPanelParams();
          }, 1000);

          if (!vm.isSpotSearch || vm.spotIsLoading) {
            return;
          }
          if (vm.cancelMapEventAfterFitBounds) {
            $log.debug('cancelEventAfterFitBounds');
            vm.cancelMapEventAfterFitBounds = false;
            return;
          }
          vm.rectangleSearch = true;
          $scope.$broadcast('showRectangleSearchButton');
        });

        updateSpotSearchPanelParams();
      });
    }

    function updateSpotSearchPanelParams() {
      vm.spotSearchPanelParams.zoom   = vm.map.zoom;
      vm.spotSearchPanelParams.sw     = vm.map.bounds.southwest;
      vm.spotSearchPanelParams.ne     = vm.map.bounds.northeast;
    }

    // NOTE: do it here as its view specific requirement.
    function bkNoStatePadding() {
      angular.forEach(vm.bookmarkSpots, function(spot) {
        if (_.isUndefined(spot.state)) {
          spot.state = {
            id: 0,
            name: vm.tl8.plan__no_state_option_name
          };
        }
      });
    }

    function resetBkStates(spots) {
      bkNoStatePadding();
      vm.selects.bkState.model = '';
      vm.selects.bkState.options.length = 0;
      angular.forEach(spots, function(spot) {
        if (!spot.state) { return; }
        var st = vm.selects.bkState.options.filter(function(st) {
          return st.name === spot.state.name;
        })[0];
        if (!st) {
          vm.selects.bkState.options.push(spot.state);
        }
      });
      addFlagsToSpots(vm.spots);
    }

    function resetCategoryFilter() {
      vm.cat1Name = '';
      vm.selects.cat2.model = null;
    }

    function setDefaultMarkerProps(marker) {
      marker.infoWindowTemplate = '/templates/subapp/plans/info-window';
      marker.infoWindowOptions = {
        disableAutoPan: true,
        maxWidth: 350,
        maxHeight: 320
      };
    }

    function setSpotMarkers() {
      addFlagsToSpots(vm.spots);
      var targetSpots = vm.spots.filter(vm.getBkFilteredSpots);
      vm.spotMarkers = targetSpots.map(function(spot) {
        var category = spot.categoryName;
        if (cyUtil.isNullOrEmpty(category)) { category = 'etc'; }
        var type = 'normal';
        if (spot.isInBookmark) { type = 'like'; }
        if (spot.isInPlan) { type = 'plans'; }
        var icon   = PlanMarker.getIcon(type, category, 0, spot.isInPlan);
        var marker = PlanMarker.getMarker(spot, icon, 100);
        marker.onClick = function() {
          setActiveSpotMarker(spot, true);
          if ($window.ga) {
            $window.ga('send', 'event', 'CreatePlan', 'Map', 'SpotPin');
          }
        };
        marker.spot = spot;
        marker.closeClick = function() {
          setHighlightCard(spot, false, false);
        };
        setDefaultMarkerProps(marker);
        return marker;
      });
    }

    function setPlanMarkers() {
      addFlagsToSpots(vm.spots);
      vm.planMarkers = vm.plan.dailyPlans[vm.currentDay].planItems.map(function(pItem, index) {
        var spot = pItem.spot;
        var category = spot.categoryName;
        if (cyUtil.isNullOrEmpty(category)) {
          category = 'etc';
        }
        //NOTE: copy base_marker without reference
        var number = index + 1;
        var icon = PlanMarker.getIcon('plans', category, number);
        var marker = PlanMarker.getMarker(spot, icon, 200 - number);
        marker.onClick = function() {
          setActiveSpotMarker(spot, /* scrollToCard */true, /* isInPlan */true);
          if ($window.ga) {
            $window.ga('send', 'event', 'CreatePlan', 'Map', 'SpotPin');
          }
        };
        marker.spot = spot;
        marker.closeClick = function() {
          hideAllWindows();
        };
        setDefaultMarkerProps(marker);
        return marker;
      });
      if (vm.planMarkers.length > 0) {
        fitMarkerBounds(vm.planMarkers);
      }
    }

    // TODO: find a better way
    function setFsqIconToPlannedSpotForRegisteredSpot() {
      angular.forEach(vm.plan.dailyPlans[vm.currentDay].planItems, function(pItem) {
        if (pItem.spot.thumbnailUrl === APP_CONST.WAITING_UPLOAD_URL) {
          setFsqSpotIcon(pItem.spot);
        }
      });
    }

    function setFsqSpotIcon(spot) {
      switch (spot.categoryName) {
      case Object.keys(vm.fsqCategoryIcons)[0]:
        spot.thumbnailUrl = vm.fsqCategoryIcons[Object.keys(vm.fsqCategoryIcons)[0]];
        break;
      case Object.keys(vm.fsqCategoryIcons)[1]:
        spot.thumbnailUrl = vm.fsqCategoryIcons[Object.keys(vm.fsqCategoryIcons)[1]];
        break;
      case Object.keys(vm.fsqCategoryIcons)[2]:
        spot.thumbnailUrl = vm.fsqCategoryIcons[Object.keys(vm.fsqCategoryIcons)[2]];
        break;
      default:
        spot.thumbnailUrl = vm.fsqCategoryIcons[Object.keys(vm.fsqCategoryIcons)[3]];
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
        $timeout(function() {
          // We don't want to zoom in too much! Taken from:
          // http://stackoverflow.com/questions/3334729/google-maps-v3-fitbounds-zoom-too-close-for-single-marker#answer-7841121
          if (!map.getZoom() || map.getZoom() > vm.minZoomLevel) {
            vm.map.zoom = vm.minZoomLevel;
            map.setZoom(vm.minZoomLevel);
          }
        }, 0);
        vm.cancelMapEventAfterFitBounds = true;
      });
    }


    function hideAllWindows() {
      angular.forEach(vm.spotMarkers, function(mk/*, idx*/) {
        mk.show = false;
        if (_.isUndefined(mk.spot)) { return; }
        setHighlightCard(mk.spot, false, false);
      });

      angular.forEach(vm.planMarkers, function(mk) {
        mk.show = false;
        if (_.isUndefined(mk.spot)) { return; }
        setHighlightCard(mk.spot, false, false);
      });
    }

    function genRoutePoints(planItems) {
      var routePoints = [];
      var len = planItems.length;
      angular.forEach(planItems, function(pItem, idx) {
        if (idx === len - 1) { return; }
        var routePoint = {};
        var startSpot = pItem.spot;
        var endSpot   = planItems[idx + 1].spot;
        routePoint.start = {
          name: startSpot.name,
          latlng: startSpot.lat + ',' + startSpot.lng
        };
        routePoint.end = {
          name: endSpot.name,
          latlng: endSpot.lat + ',' + endSpot.lng
        };
        routePoints.push(routePoint);
      });
      return routePoints;
    };

    // FIXME: we have to move calcRoute function into PlanManager.
    //   - when you save plan,
    //       - PlanManager call API
    //       - PlanManager update currentPlan because it needs updating of planItem.id, plan.coverPhotoUrl
    //       - to update, we using Plan.build but it doesn't keep planItem.route
    //       - so we need to restore planItem.route.
    //       - And, since the save button triggered by global header,
    //         and its in another scope of plansEditController, it need to communicate using $emit
    //       - accidently, the alert event is able to be caught by plansEditController, I use it for now.
    $scope.$on('alert', function() {
      vm.calcRoute(genRoutePoints(vm.plan.dailyPlans[vm.currentDay].planItems));
    });

    function refreshRouteAndMarkers() {
      $log.debug('refreshRouteAndMarkers');
      setPlanMarkers();
      vm.calcRoute(genRoutePoints(vm.plan.dailyPlans[vm.currentDay].planItems));
    }

    function clearDisplayedDirections() {
      _.merge(vm.cachedDisplayedDirections, vm.currentDisplayedDirections);
      angular.forEach(vm.currentDisplayedDirections, function(cdd/*, key*/) {
        //NOTE: setMap without any argument clears displayedDirections.
        cdd.setMap();
      });
      //NOTE: Following code makes hash's contents blank with keeping hash's reference.
      //      Shouldn't initialize by '= {}'
      vm.currentDisplayedDirections.splice(0, length);
    }

    function resetCalendar() {
      vm.planDates.startDate = vm.plan.dateFrom;
      vm.planDates.endDate = vm.plan.dateTo;
    }

    function mapBookmarkToSpot(bk) {
      var spot = bk.spot;
      if (cyUtil.isNullOrEmpty(spot.episode)) {
        spot.episode = bk.episode;
      }
      return spot;
    }

    // NOTE: we need to modify here when make change to info window layout / styles
    function getMapInfoWindowHeightOffSet() {
      // NOTE:
      //       0: 32
      //       1: 32
      //       2: 32
      //       3: 16
      //       4: 8
      //       5: 4
      //       6: 2
      //       7: 1
      //       8: 0.5
      //       9: 0.25
      //       10: 0.125
      //       11: 0.0625
      //       ...

      var curZoom = vm.map.control.getGMap().getZoom();
      var baseNum = 7; // NOTE: it depends on the height of info window
      var minZoom = 2;
      var offset  = 1;
      var diff;

      if (curZoom === baseNum) {
        return offset;
      } else if (curZoom < baseNum) {
        if (curZoom < minZoom) {
          curZoom = minZoom;
        }

        diff = baseNum - curZoom;
        for (var i = 0; i < diff; i++) {
          offset = offset * 2;
        }
        return offset;
      } else if (baseNum < curZoom) {
        diff = curZoom - baseNum;
        for (var i = 0; i < diff; i++) {
          offset = offset / 2;
        }
        return offset;
      }
    }
  }
})();
