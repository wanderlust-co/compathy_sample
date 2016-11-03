(function() {
  'use strict';

  angular
  .module('cySubapp.plans')
  .controller('PlansEditController', PlansEditController);

  PlansEditController.$inject = [
    '$scope', '$window', '$location', '$stateParams', '$uibModal', '$log', '$timeout', '$translate', '$cookies',
    '$anchorScroll', 'uiGmapGoogleMapApi', 'SpotManager', 'CountryManager'
  ];

  function PlansEditController(
    $scope, $window, $location, $stateParams, $uibModal, $log, $timeout, $translate, $cookies,
    $anchorScroll, uiGmapGoogleMapApi, SpotManager, CountryManager
  ) {
    var vm = this;
    var mapSearchRadius = 0.05; // TODO: Tweak this value

    vm.planId = $stateParams.planId;
    vm.currentDay = 0;
    vm.plan   = {};
    vm.currentUser = {};
    vm.tl8 = {};

    vm.spotIsLoading = false;
    vm.per = 20;
    vm.page = 1;

    vm.hasMoreData = false;

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
      }
    };

    vm.spots          = [];

    CountryManager.getCountries().then(function(countries) {
      vm.selects.bkCountry.options = countries;
      vm.countries                 = countries;
    });

    activate();

    ///////////////////////////////////////////////////////////////
    // public methods
    ///////////////////////////////////////////////////////////////


    ///////////////////////////////////////////////////////////////
    // private methods
    ///////////////////////////////////////////////////////////////

    function activate() {
      $log.debug('activate()');
    }
  }
})();

