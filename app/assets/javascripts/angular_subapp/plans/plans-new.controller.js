(function() {
  'use strict';

  angular
  .module('cySubapp.plans')
  .controller('PlansNewController', PlansNewController);

  PlansNewController.$inject = ['$window', '$location', '$state', '$log', 'cyCalendar', 'cyDevice', 'PlanManager'];

  function PlansNewController($window, $location, $state, $log, cyCalendar, cyDevice, PlanManager) {
    var vm = this;
    vm.plan = {};

    var loc = $location.search();
    if (loc.start) { vm.startDate = moment(loc.start, cyCalendar.exchangeDateFormat); }
    if (loc.end) { vm.endDate = moment(loc.end, cyCalendar.exchangeDateFormat); }

    PlanManager.findOrCreate(loc.start, loc.end).then(function(plan) {
      if (cyDevice.isMobile) {
        $state.go('plansEditOverview', { planId: plan.id }, { location: 'replace' });
      } else {
        console.log(plan)
        $state.go('plansEdit', { planId: plan.id }, { location: 'replace' });
      }
    }, function(err) {
      // TODO: redirect to some page or something
      $log.error('something wrong: ' + err);
    });

    // FIXME
    setDummyDataToAvoidMissingDirectiveDataError();
    function setDummyDataToAvoidMissingDirectiveDataError() {
      vm.dateOptions = angular.copy(cyCalendar.getDateOptions());
      vm.planDates = {
        startDate: moment(),
        endDate: moment()
      };
    }
  }
})();

