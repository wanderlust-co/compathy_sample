(function() {
  'use strict';

  angular.module('compathyClone')
  .controller('TripnotesShowController', TripnotesShowControll);

  TripnotesShowControll.$inject = ['$scope', '$window', '$http', '$location', '$timeout', '$log', 'Tripnote'];

  function TripnotesShowControll($scope, $window, $http, $location, $timeout, $log, Tripnote) {
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
    $scope.logbookNewComment = '';
  }
})();
