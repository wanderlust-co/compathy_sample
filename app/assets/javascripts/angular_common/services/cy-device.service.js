(function() {
  'use strict';

  angular
  .module('cyCommon')
    .service('cyDevice', cyDevice);
  function cyDevice() {
    //see https://w3g.jp/blog/js_browser_sniffing2015
    var _ua = (function(u) {
      return {
        Tablet:(u.indexOf('windows') != -1 && u.indexOf('touch') != -1 && u.indexOf('tablet pc') == -1)
          || u.indexOf('ipad') != -1
          || (u.indexOf('android') != -1 && u.indexOf('mobile') == -1)
          || (u.indexOf('firefox') != -1 && u.indexOf('tablet') != -1)
          || u.indexOf('kindle') != -1
          || u.indexOf('silk') != -1
          || u.indexOf('playbook') != -1,
        Mobile:(u.indexOf('windows') != -1 && u.indexOf('phone') != -1)
          || u.indexOf('iphone') != -1
          || u.indexOf('ipod') != -1
          || (u.indexOf('android') != -1 && u.indexOf('mobile') != -1)
          || (u.indexOf('firefox') != -1 && u.indexOf('mobile') != -1)
          || u.indexOf('blackberry') != -1
      };
    })(navigator.userAgent.toLowerCase());
    return {
      isMobile: _ua.Mobile,
      isTablet: _ua.Tablet
    };
  }
})();
