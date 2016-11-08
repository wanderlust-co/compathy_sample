(function() {
  'use strict';

  angular
  .module('cySubapp.plans')
  .controller('PlansEditController', PlansEditController);

  PlansEditController.$inject = [
    '$scope', '$window', '$location', '$stateParams', '$uibModal', '$log', '$timeout', '$translate', '$cookies',
    '$anchorScroll', 'uiGmapGoogleMapApi', 'SpotManager', 'CountryManager', 'PlanManager'
  ];

  function PlansEditController(
    $scope, $window, $location, $stateParams, $uibModal, $log, $timeout, $translate, $cookies,
    $anchorScroll, uiGmapGoogleMapApi, SpotManager, CountryManager, PlanManager
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
          onChange: function(cc) {
            vm.spotIsLoading = true;

            //選択リストに変更があったらccを元にareaの情報をオプションに追加
            console.log(cc);
            console.log(vm.selects.country)
            if (!cc.nil) {
              SpotManager.getAreasListBy(cc).then(function(areas) {
                console.log(areas)
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

            //選択リストに変更があったら国に紐づくスポット情報を出力
            if (cc != vm.selects.country.model) {
              vm.selects.country.model = cc;
              if (!!cc) {
                SpotManager.getFilteredList(cc, vm.page, vm.per).then(function(data) {
                  $log.info(data);
                  console.log(data);
                  vm.spots = data;
                  vm.spotIsLoading = false;
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
            console.log(stId)
            if (stId != vm.selects.state.model) {
              vm.selects.state.model = stId;
              vm.spots = vm.spots.filter(vm.getBkFilteredSpots);
              setSpotMarkers();
              fitMarkerBounds(vm.spotMarkers);
              if ($window.ga) {
                $window.ga('send', 'event', 'CreatePlan', 'Wishlist', 'SelectState');
              }
            }
          }
        }
      },
    };

    vm.spots = [];

    CountryManager.getCountries().then(function(countries) {
      vm.selects.country.options = countries;
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
      PlanManager.fetchEdit(vm.planId).then(function(data) {
        $log.debug('activate()');
        $log.debug(data);
      });
    }
  }
})();
