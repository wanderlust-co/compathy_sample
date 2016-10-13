(function() {
  'use strict';

  angular.module('compathyClone')
  .controller('LogbookEditController', LogbookEditController);

  LogbookEditController.$inject = ['$scope', '$window', '$http', '$location', '$timeout'];

  function LogbookEditController($scope, $window, $http, $location, $timeout) {
    var MAX_UPLOAD = 3;

    $scope.hoge = 'hoge-';
    $scope.logbook = {
      id: 1
    };

    $scope.fileuploadOptions = {
      url: '/api/user_photos/with_episode',
      autoUpload: false, //true,
      singleFileUploads: true,
      limitConcurrentUploads: 3,
      dropZone: null, // NOTE: disable drag & drop because of duplicate uploading bug.
      maxNumberOfFiles: MAX_UPLOAD,
      submit: function (e, data) {
        // NOTE: should evaluate functions to add them FormData before start upload
        data.formData =  {
          logbookId: $scope.logbook.id,
        };
      },
      done: function(e, data) {
        console.log('done');
        console.log(data);
        //var ep = data.result.responseBody.episode;
        //$scope.logbook.episodes.push( ep );
        //$scope.sectionedEpisodes = genSectionedEpisodes();
      },
      processstart: function() {
        $scope.isUploading = true;
      },
      stop: function(e, data) {
        $scope.isUploading = false;

        console.log('stop');
        console.log(data);

        //updateEpisodesPageNum();

        //$scope.logbook.$update(function(l, h){
        //  $scope.logbook = l;
        //  $scope.sectionedEpisodes = genSectionedEpisodes();
        //  initMap();

        //  // NOTE: remove uploaded files in queue
        //  for(var cs = $scope.$$childHead; cs; cs = cs.$$nextSibling) {
        //    if (cs.queue) {
        //      cs.queue = [];
        //      break;
        //    }
        //  }
        //});
      }
    };

  }
})();

