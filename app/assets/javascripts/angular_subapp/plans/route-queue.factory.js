(function() {
  'use strict';

  angular
  .module('cySubapp.plans')
  .factory('RouteQueue', RouteQueue);

  RouteQueue.$inject = ['$log'];
  function RouteQueue($log) {
    function __RouteQueue() {
      this.overLimit = false;
      this.__array = [];
    }
    __RouteQueue.prototype.size = function() {
      return this.__array.length;
    };
    __RouteQueue.prototype.enqueue = function(obj) {
      this.__array.push(obj);
    };
    __RouteQueue.prototype.dequeue = function() {
      if (this.__array.length > 0) {
        return this.__array.shift();
      }
      return null;
    };
    __RouteQueue.prototype.init = function() {
      this.__array = [];
    };

    __RouteQueue.prototype.loop = function() {
      var sleepTime = 0;
      if (this.size() <= 0) {
        return;
      }
      var rr = this.dequeue();
      $log.debug(rr.status);
      if (rr.status === 'OK') {
        this.overLimit = false;
        this.loop();
        return;
      }else if (rr.status === 'CY_NO_ROUTE') {
        this.overLimit = false;
        this.loop();
        return;
      }else if (rr.status === 'CY_OVER_RETRY_LIMIT') {
        this.overLimit = false;
        this.loop();
        return;
      }else if (rr.status === 'ZERO_RESULTS') {
        this.overLimit = false;
        if (rr.modes.length !== 0) {
          //NOTE: shift travelMode
          rr.modes.shift();
          rr.status = 'CY_DEFAULT';
          //FIXME: Should set max of retryLimit as initial value of the mode
          rr.retryLimitPerMode = 3;
          this.enqueue(rr);
        }
        this.loop();
        return;
      }else if (rr.status === 'OVER_QUERY_LIMIT' || this.overLimit) {
        sleepTime = 2000;
        this.overLimit = true;
      }else if (rr.status === 'CY_UPDATING') {
        this.overLimit = false;
        sleepTime = 1000;
      }
      rr.status = 'CY_UPDATING';
      rr.resolve().then(
        function(status) {
          rr.status = status;
        },
        function(status) {
          rr.status = status;
        }
      );
      this.enqueue(rr);
      _.delay(function(self) {
        self.loop();
      }, sleepTime, this);
    };
    return __RouteQueue;
  };
})();
