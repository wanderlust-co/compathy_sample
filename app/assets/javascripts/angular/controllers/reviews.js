(function() {
  'use strict';

  angular.module('compathyClone')
  .controller('ReviewController', ReviewController);

  ReviewController.$inject = ['$scope', '$window', '$http', '$location', '$timeout', '$log', 'Tripnote'];

  function ReviewController($scope, $window, $http, $location, $timeout, $log, Tripnote) {
    $scope.addReviewComment = function() {
      $scope.isSaving = true;
      $http.post('/api/comments', {
        cmType: 'review',
        reviewId: $scope.reviewId,
        body: $scope.reviewNewComment,
      }).success(function(data) {
        $scope.isSaving = false;
        $scope.reviewNewComment = '';
        // $window.location.href = '/tripnotes/' + $scope.logbookId;
      }).error(function(msg) {
        $scope.isSaving = false;
      });
    };

    $scope.addLike = function() {
      if (!$scope.likeId) {
        $scope.isSaving = true;
        $http.post('/api/likes', {
          reviewId: $scope.reviewId,
        }).success(function(data) {
            $window.location.href = '/tripnotes/' + $scope.logbookId;
        }).error(function(msg) {
          $scope.isSaving = false;
        });
      }
    };

    $scope.removeLike = function() {
        if ($scope.likeId) {
        $http({
          url: '/api/likes/' + $scope.likeId,
          method: 'DELETE',
          params: {}
        }).success(function(/* data */) {
          $scope.likeId = null;
          var target = scope.likedUsers.filter(function(user) {
            return user.username == $scope.currentUser.username;
          })[0];
          if (target) {
            $scope.likedUsers.splice(scope.likedUsers.indexOf(target), 1);
          }
        }).error(function(msg) {
          console.log(msg);
        });
      }
    };

    $scope.logbookId = $window.location.href.match(/tripnotes\/([0-9]+)/)[1];
  }
})();
