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

            if (cc != vm.selects.country.model) {
              vm.selects.country.model = cc;
              if (!!cc) {
                SpotManager.getFilteredList(cc).then(function(data) {
                  $log.info(data);
                  vm.spots = data;
                  vm.spotIsLoading = false;
                });
              }
            }
          }
        }
      }
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
      $log.debug('activate()');
    }
  }
})();
