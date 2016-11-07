(function() {
  'use strict';

  angular
    .module('cyCommon')
    .service('cyUtil', cyUtil);

  cyUtil.$inject = ['$timeout'];

  function cyUtil($timeout) {
    var _cyUtil = {
      isPresent: function(val) {
        return !this.isNullOrEmpty(val);
      },
      isBlank: function(val) {
        return this.isNullOrEmpty(val) || this.isNullOrUndefined(val);
      },
      isNullOrEmpty: function(val) {
        return val === null || typeof val === 'undefined' || val === '' || val.length === 0;
      },
      isNullOrUndefined: function(val) {
        return val === null || typeof val === 'undefined';
      },
      mergeArrays: function(destination, origin) {
        Array.prototype.push.apply(destination, origin);
      },
      limitStringWithEllipsis: function(text, maxLength) {
        return text.length > maxLength ? text.substr(0, maxLength - 1) + '…' : text.substr(0, maxLength);
      },
      // Function copied from https://davidwalsh.name/essential-javascript-functions
      poll: function(fn, callback, errback, timeout, interval) {
        var endTime = Number(new Date()) + (timeout || 2000);
        interval = interval || 100;
        (function p() {
          if (fn()) {
            callback();
          }
          else if (Number(new Date()) < endTime) {
            $timeout(p, interval);
          }
          else {
            errback(new Error('timed out for ' + fn + ': ' + arguments));
          }
        })();
      }
    };
    return _cyUtil;
  }
})();

