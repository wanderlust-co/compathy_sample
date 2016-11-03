(function() {
  'use strict';

  angular
  .module('cySubapp.plans')
  .factory('Plan', Plan);

  Plan.$inject = ['cyCalendar'];

  function Plan(cyCalendar) {
    /*//////////////////////////////////////////////////////////////////////////////////////
     * Constructor, with class name
     *//////////////////////////////////////////////////////////////////////////////////////
    function __Plan(id, userId, title, description, dateFrom, dateTo, dailyPlans, coverPhotoUrl, publicLinkUrl) {
      // Public properties, assigned to the instance ('this')
      this.id          = id;
      this.userId      = userId;
      this.title       = title;
      this.description = description;
      this.dateFrom    = dateFrom;
      this.dateTo      = dateTo;
      this.dailyPlans  = dailyPlans;
      this.coverPhotoUrl = coverPhotoUrl;
      this.publicLinkUrl = publicLinkUrl;
    }

    __Plan.prototype.COMPLETE_PLAN_MIN_DAYS        = 2;
    __Plan.prototype.COMPLETE_PLAN_MIN_DAILY_ITEMS = 3;
    __Plan.prototype.DAILY_PLAN_DATE_FORMAT = 'YYYY-MM-DD';

    /*//////////////////////////////////////////////////////////////////////////////////////
     * Private method, used with `call(this)` from Public methods
     *//////////////////////////////////////////////////////////////////////////////////////
    function calculateNumberofDays(startDate, endDate) {
      return endDate.diff(startDate, 'days') + 1;
    }

    /*//////////////////////////////////////////////////////////////////////////////////////
     * Public method, assigned to prototype
     *//////////////////////////////////////////////////////////////////////////////////////
    __Plan.prototype.meetsCompletionCriteria = function() {
      var dailyPlanLength      = this.dailyPlans.length;
      var dailyPlanItemLengths = this.dailyPlans.map(function(dp) { return dp.planItems.length; });
      var minPlanItemLength    = Math.min.apply(null, dailyPlanItemLengths);

      return (this.COMPLETE_PLAN_MIN_DAYS <= dailyPlanLength)
        && (this.COMPLETE_PLAN_MIN_DAILY_ITEMS <= minPlanItemLength);
    };

    __Plan.prototype.getNumberOfDays = function() {
      return calculateNumberofDays(this.dateFrom, this.dateTo);
    };

    __Plan.prototype.willLoseDataWithNewDates = function(mStartDay, mEndDay) {
      var numberOfDays = this.getNumberOfDays();
      var newNumber    = calculateNumberofDays(mStartDay, mEndDay);
      var hasData      = false;

      if (newNumber < numberOfDays) {
        for (var i = newNumber; i < numberOfDays; i++) {
          hasData = hasData || this.dailyPlans[i].planItems.length > 0;
        }
      }
      return hasData;
    };

    // NOTE: expected Moment object as start, end
    __Plan.prototype.updateDates = function(mStartDay, mEndDay) {
      var numberOfDays = this.getNumberOfDays();
      var newNumber    = calculateNumberofDays(mStartDay, mEndDay);
      var diff         = Math.abs(numberOfDays - newNumber);

      if (newNumber < numberOfDays) {
        this.dailyPlans.splice(newNumber, diff);
      } else if (numberOfDays < newNumber) {
        while (diff > 0) {
          this.dailyPlans.push({ planItems: [] });
          diff--;
        }
      }
      angular.forEach(this.dailyPlans, function(dailyPlan, idx) {
        dailyPlan.date = moment(mStartDay).add(idx, 'days').format(__Plan.prototype.DAILY_PLAN_DATE_FORMAT);
      });

      this.dateFrom = mStartDay;
      this.dateTo   = mEndDay;

      this.hasModified = true;
    };

    __Plan.prototype.getDayRange = function() {
      return (this.dateFrom ? this.dateFrom.format(cyCalendar.getDateOptions().locale.format) : '')
        + cyCalendar.getDateOptions().locale.separator
        + (this.dateTo ? this.dateTo.format(cyCalendar.getDateOptions().locale.format) : '');
    };

    /*//////////////////////////////////////////////////////////////////////////////////////
     * Static method, assigned to class
     * Instance ('this') is not available in static context
     *//////////////////////////////////////////////////////////////////////////////////////
    __Plan.build = function(data) {
      return new __Plan(
        data.id,
        data.userId,
        data.title,
        data.description,
        moment(data.dateFrom),
        moment(data.dateTo),
        data.dailyPlans,
        data.coverPhotoUrl,
        data.publicLinkUrl
      );
    };

    __Plan.buildPostData = function(plan) {
      // NOTE: DON'T angular.copy whole plan object as it cause too heavy process
      // FIXME: could be there better way...
      var postData      = {
        id:          plan.id,
        title:       plan.title,
        description: plan.description,
        dateFrom:    plan.dateFrom.clone().format(this.prototype.DAILY_PLAN_DATE_FORMAT),
        dateTo:      plan.dateTo.clone().format(this.prototype.DAILY_PLAN_DATE_FORMAT),
        dailyPlans:  [],
      };
      angular.forEach(plan.dailyPlans, function(dailyPlan) {
        var dp = { id: dailyPlan.id, date: dailyPlan.date, planItems: [] };
        angular.forEach(dailyPlan.planItems, function(pItem) {
          dp.planItems.push({
            id: pItem.id,
            spot: { id: pItem.spot.id, name: pItem.spot.name },
            body: pItem.body
          });
        });
        postData.dailyPlans.push(dp);
      });

      return postData;
    };

    return __Plan;
  }
})();

