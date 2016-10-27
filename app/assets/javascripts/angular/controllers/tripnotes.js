(function() {
  'use strict';

  angular.module('compathyClone')
  .controller('TripnotesShowController', TripnotesShowControll);

  TripnotesShowControll.$inject = ['$scope', '$window', '$http', '$location', '$timeout', '$element', '$log', 'Tripnote'];

  function TripnotesShowControll($scope, $window, $http, $location, $timeout, $element, $log, Tripnote) {
    $scope.favTripnote = function(alertFavTripnote, alertSeeFavorites) {
      $scope.isSaving = true;

      $http.post('/api/favorites', {
        favorite: { tripnote_id: $scope.logbookId }
      }).success(function(data) {
        // $scope.favoriteId = data.responseBody.favorite.id;
        $scope.isSaving = false;

        var curNum = angular.element('.jsFavCount')[0].textContent;
        console.log(curNum);
        angular.element('.jsFavCount').text(parseInt(curNum) + 1);
        $window.location.href = '/tripnotes/' + $scope.logbookId;
      }).error(function(msg) {
        $scope.isSaving = false;
        console.log(msg);
      });
    };

    $scope.openLightboxModal = function(image) {
      var index = 0;
      var images = [image];
      Lightbox.openModal(images, index);
    };

    $scope.unfavTripnote = function(favId) {
      if (favId > 0) {
        $scope.isSaving = true;
        $http.delete('/api/favorites/' + favId
        ).success(function(data) {
          $scope.favoriteId = null;
          var curNum = angular.element('.jsFavCount')[0].textContent;
          angular.element('.jsFavCount').text(parseInt(curNum) - 1);
          $scope.isSaving   = false;
          $window.location.href = '/tripnotes/' + $scope.logbookId;
        }).error(function(msg) {
          $scope.isSaving = false;
          console.log(msg);
        });
      }
    };

    $scope.addComment = function() {
      $scope.isSaving = true;
      $http.post('/api/comments', {
        cmType: 'tripnote',
        logbookId: $scope.logbookId,
        body: $scope.logbookNewComment,
      }).success(function(data) {
        $scope.isSaving = false;

        $scope.logbookNewComment = '';
        $window.location.href = '/tripnotes/' + $scope.logbookId;
      }).error(function(msg) {
        $scope.isSaving = false;
      });
    };

    $scope.logbookId = $window.location.href.match(/tripnotes\/([0-9]+)/)[1];
    $scope.logbookNewComment = '';
  }
})();
