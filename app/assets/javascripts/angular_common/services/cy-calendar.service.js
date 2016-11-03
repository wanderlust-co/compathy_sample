(function() {
  'use strict';

  angular
    .module('cyCommon')
    .service('cyCalendar', cyCalendar);

  cyCalendar.$inject = ['$window', '$timeout'];

  function cyCalendar($window, $timeout) {
    var _cyCalendar = {
      exchangeDateFormat: 'YYYY-MM-DD',
      dayOfWeekFormat: 'ddd',
      rangeDateFormat: 'MM.DD',
      getDateOptions: function() {
        return {
          parentEl: '.calendar-parent',
          autoApply: true,
          minDate: moment(),
          locale: {
            format: moment.localeData().longDateFormat('L'),
            separator: ' - ',
            daysOfWeek: moment.weekdaysShort(),
            monthNames: moment.monthsShort(),
          },
          eventHandlers: {
            'apply.daterangepicker': function(ev) {
              if ($window.ga) {
                // FIXME: pretty hard-coding
                ga('send', 'event', 'CreatePlan', 'Calendar', 'CalendarModalEnd');
              }
            },
            'showCalendar.daterangepicker': function(ev) {
              if ($window.ga) {
                // FIXME: pretty hard-coding
                ga('send', 'event', 'CreatePlan', 'Calendar', 'CalendarModalStart');
              }
            }
          }
        };
      },
      openCalendar: function($event, trackAction) {
        $timeout(function() {
          angular.element($event.currentTarget).parent().find('input').trigger('click');
        }, 0);
        if ($window.ga) {
          ga('send', 'event', 'CreatePlan', trackAction, 'CalendarModalStart');
        }
      },
      formatDate: function(rawDate) {
        return moment(rawDate).format(this.getDateOptions().locale.format);
      }
    };
    return _cyCalendar;
  }
})();

