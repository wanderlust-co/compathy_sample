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
        $window.location.href = '/tripnotes/' + $scope.logbookId;
      }).error(function(msg) {
        $scope.isSaving = false;
      });
    };

    $scope.logbookId = $window.location.href.match(/tripnotes\/([0-9]+)/)[1];
  }
})();
