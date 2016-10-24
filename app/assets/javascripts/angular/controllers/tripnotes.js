(function() {
  'use strict';

  angular.module('compathyClone')
  .controller('TripnotesShowCtrl', TripnotesShowCtrl);

  TripnotesShowCtrl.$inject = ['$scope', '$window', '$http', '$location', '$timeout', '$log', 'Tripnote'];

  function TripnotesShowCtrl($scope, $window, $http, $location, $timeout, $log, Tripnote) {
    $scope.addComment = function() {
      $scope.isSaving = true;
      $http.post( '/api/comments', {
        cmType: 'tripnote',
        logbookId: $scope.logbookId,
        body: $scope.logbookNewComment,
      }).success( function(data) {
        $scope.isSaving = false;

        // NOTE: changing specification by adulst reason
        //$scope.comments.push( data.responseBody.comment );

        $scope.logbookNewComment = '';
        $window.location.href = '/tripnotes/' + $scope.logbookId;
      }).error( function(msg) {
        $scope.isSaving = false;
      });
    };

    $scope.logbookId = $window.location.href.match(/tripnotes\/([0-9]+)/)[1];
    $scope.logbookNewComment = '';
  }
})();

