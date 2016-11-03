(function() {
  'use strict';

  angular
    .module('cySubapp.bookmarks')
    .service('BookmarkManager', BookmarkManager);

  BookmarkManager.$inject = ['$q', 'Restangular'];

  function BookmarkManager($q, Restangular) {
    var getRecentResult = {};
    var needReload = true;

    var __BookmarkManager = {
      getListByCc: function(username, cc) {
        return Restangular.one('users', username).one('bookmarks', cc).get();
      },
      getRecent: function(username) {
        var deferred = $q.defer();

        if (needReload) {
          Restangular.one('users', username).one('bookmarks', 'recent').get()
            .then(function(data) {
              needReload = false;
              getRecentResult = data;
              deferred.resolve(data);
            });
        } else {
          deferred.resolve(getRecentResult);
        }
        return deferred.promise;
      },
      createBookmark: function(spotId) {
        var bkType = 'spot';
        var bkId = spotId;
        return Restangular.all('bookmarks').post({ bookmark:{ bkType: bkType, bkId: bkId } });
      },
      destroyBookmark: function(bookmarkId) {
        return Restangular.one('bookmarks', bookmarkId).remove();
      },
      setNeedReload: function() {
        needReload = true;
      }
    };
    return __BookmarkManager;
  };
})();
