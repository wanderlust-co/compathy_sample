(function() {
  'use strict';

  angular
  .module('cySubapp.plans')
  .service('PlanManager', PlanManager);

  PlanManager.$inject = ['$q', '$log', 'Restangular', 'Plan'];

  function PlanManager($q, $log, Restangular, Plan) {
    var currentPlan = Plan.build({});
    console.log(currentPlan)
    var currentDay  = 0;
    var dailyPlanDateFormat = 'YYYY-MM-DD';
    var dateAlertDisplayed = {};

    var __PlanManager = Restangular.service('plans');

    angular.extend(__PlanManager, {
      findOrCreate: function(start, end) {
        var deferred = $q.defer();
        __PlanManager.one('find_or_create').get({ start: start, end: end }).then(function(data) {
          deferred.resolve(data.plan);
        }, function(err) {
          deferred.reject(err);
        });
        return deferred.promise;
      },
      fetchEdit: function(id) {
        var deferred = $q.defer();

        if (currentPlan.id) {
          deferred.resolve(currentPlan);
        } else {
          __PlanManager.one(id).one('edit').get().then(function(data) {
            angular.extend(currentPlan, Plan.build(data.plan));
            deferred.resolve(currentPlan);
          }, function(err) {
            deferred.reject(err);
          });
        }
        return deferred.promise;
      },
      fetchPreview: function(id, key) {
        var deferred = $q.defer();

        if (currentPlan.id) {
          deferred.resolve(currentPlan);
        } else {
          __PlanManager.one(id).one('preview').get({ key: key }).then(function(data) {
            angular.extend(currentPlan, Plan.build(data.plan));
            deferred.resolve(currentPlan);
          }, function(err) {
            deferred.reject(err);
          });
        }
        return deferred.promise;
      },
      getCurrentPlan: function() {
        return currentPlan;
      },
      saveCurrentPlan: function() {
        var deferred = $q.defer();
        var postData = Plan.buildPostData(currentPlan);

        if (!currentPlan.hasModified) {
          $log.debug('currentPlan has not Modified');
          deferred.resolve(true);
          return deferred.promise;
        }

        __PlanManager.one(currentPlan.id)
          .customPUT({ plan: postData }).then(function(data) {
            angular.extend(currentPlan, Plan.build(data.plan));
            currentPlan.hasModified = false;
            deferred.resolve(true);
          }, function(err) {
            deferred.reject(err);
          });
        return deferred.promise;
      },
      deleteCurrentPlan: function() {
        return __PlanManager.one(currentPlan.id).remove();
      },
      getDailyPlan: function(dayIdx) {
        return currentPlan.dailyPlans[dayIdx];
      },
      setTitle: function(title) {
        currentPlan.title = title;
        currentPlan.hasModified = true;
      },
      setDescription: function(desc) {
        currentPlan.description = desc;
        currentPlan.hasModified = true;
      },
      setCurrentDay: function(dayIndex) {
        currentDay = dayIndex;
      },
      getCurrentDay: function() {
        return currentDay;
      },
      addPlanItem: function(dayIdx, sp, itemIdx) {
        var dailyPlan = currentPlan.dailyPlans[dayIdx];
        if (itemIdx) {
          dailyPlan.planItems.splice(itemIdx, 0, {
            spot: sp
          });
        } else {
          dailyPlan.planItems.push({
            spot: sp
          });
        }
        currentPlan.hasModified = true;
      },
      delPlanItem: function(dayIdx, itemIdx) {
        currentPlan.dailyPlans[dayIdx].planItems.splice(itemIdx, 1);
        currentPlan.hasModified = true;
      },
      getMemo: function(dayIdx, itemIdx) {
        return currentPlan.dailyPlans[dayIdx].planItems[itemIdx].body;
      },
      delDay: function(dayIndex) {
        if (currentPlan.dailyPlans.length == 1) {
          currentPlan.dailyPlans[0].planItems = [];
        } else {
          currentPlan.dailyPlans.splice(dayIndex, 1);
          angular.forEach(currentPlan.dailyPlans, function(dailyPlan, idx) {
            dailyPlan.date = moment(currentPlan.dateFrom).add(idx, 'days').format(dailyPlanDateFormat);
          });
          currentPlan.dateTo = moment(currentPlan.dateTo).subtract(1, 'day');
        }
        currentPlan.hasModified = true;
      },
      setPlanIsModified: function(isModified) {
        currentPlan.hasModified = isModified;
      },
      isPastDay: function(dayIndex) {
        dayIndex = dayIndex || currentDay;
        return moment(currentPlan.dateFrom).add(dayIndex, 'days').isBefore(moment(), 'days');
      },
      isPastPlan: function() {
        return moment(currentPlan.dateTo).isBefore(moment(), 'days');
      },
      isPlanDirty: function() {
        return currentPlan.hasModified;
      },
      genRoutePoints: function(planItems) {
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
      },
      createPublicLink: function() {
        var deferred = $q.defer();

        if (currentPlan.pubilcLinkUrl) {
          deferred.resolve(currentPlan.pubilcLinkUrl);
        } else {
          __PlanManager.one(currentPlan.id).one('public_link').post().then(function(data) {
            currentPlan.publicLinkUrl = data.publicLinkUrl;
            deferred.resolve(data.publicLinkUrl);
          }, function(err) {
            deferred.reject(err);
          });
        }
        return deferred.promise;
      },
      deletePublicLink: function() {
        var deferred = $q.defer();

        if (!currentPlan.publicLinkUrl) {
          deferred.resolve(true);
        } else {
          __PlanManager.one(currentPlan.id).one('public_link').remove().then(function(data) {
            currentPlan.publicLinkUrl = null;
            deferred.resolve(true);
          }, function(err) {
            deferred.reject(err);
          });
        }
        return deferred.promise;
      },
      setDateAlertDisplayed: function(day) {
        dateAlertDisplayed[day] = true;
      },
      getDateAlertDisplayed: function(day) {
        return dateAlertDisplayed[day] === true;
      }
    });

    return __PlanManager;
  }
})();

