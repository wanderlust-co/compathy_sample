(function() {
  'use strict';

  angular.module('compathyClone')
  .controller('LogbookEditController', LogbookEditController);

  LogbookEditController.$inject = ['$scope', '$window', '$http', '$location', '$timeout', '$log', 'Tripnote'];

  function LogbookEditController($scope, $window, $http, $location, $timeout, $log, Tripnote) {
    var MAX_UPLOAD = 3;
    var logbookId = $window.location.href.match(/tripnotes\/([0-9]+)\/edit/)[1];
    $scope.logbook = {
      id: logbookId
    };
    $scope.fileuploadOptions = {
      url: '/user_photos/with_episode',
      autoUpload: true,
      singleFileUploads: true,
      limitConcurrentUploads: 3,
      dropZone: null, // NOTE: disable drag & drop because of duplicate uploading bug.
      maxNumberOfFiles: MAX_UPLOAD,
      submit: function (e, data) {
        // NOTE: should evaluate functions to add them FormData before start upload
        data.formData =  {
          logbookId: $scope.logbook.id
        };
      },
      done: function(e, data) {
        console.log('done');
        console.log(data)

        var review = data.result.review;
        $scope.tripnote.reviews.push( review );
      },
      processstart: function() {
        $scope.isUploading = true;
      },
      stop: function(e, data) {
        $scope.isUploading = false;

        console.log('stop');
        console.log(data);
         // NOTE: remove uploaded files in queue
         for(var cs = $scope.$$childHead; cs; cs = cs.$$nextSibling) {
           if (cs.queue) {
             cs.queue = [];
             break;
           }
         }
        // });
      }
    };

    function updateEpisodesPageNum() {
      var i = 1;

      angular.forEach( $scope.sectionedEpisodes, function( secedEp ) {
        angular.forEach( secedEp.episodes, function( ep ) {
          ep.pageNum = i;
          i++;
        });
      });
    }

    function genSectionedEpisodes() {
      if ( ! $scope.logbook.episodes ) { return []; }

      var result = [];
      var sortedEpisodes = $scope.logbook.episodes.sort( function(a,b) { return new Date(a.date) - new Date(b.date) } );
      angular.forEach( sortedEpisodes, function( ep, index ) {
        var dt = new Date(ep.date);
        var formattedDate = dt.getUTCFullYear() + '/' +
                    ('00' + (dt.getUTCMonth()+1) ).slice(-2) + '/' +
                    ('00' + dt.getUTCDate() ).slice(-2);

        var secedEp = result.filter( function( _secedEp, idx ) {
          return _secedEp.date == formattedDate;
        })[0];

        if (!secedEp) {
          secedEp = { date: formattedDate, day: ep.day, episodes: [], states: [] };
          result.push( secedEp );
        }

        secedEp.episodes.push(ep);

        if ( ep.state ) {
          var stateId = secedEp.states.filter( function( st, idx ) {
            return st.id == ep.state.id;
          })[0];

          if ( ! stateId ) {
            secedEp.states.push( ep.state );
          }
        }
      });
      return result.sort( function(a, b) { return a.day - b.day } );
    }

    $scope.saveAndShowPreview = function() {
      $scope.isSaving = true;
      $scope.tripnote.$update( function() {
        $scope.isSaving = false;
        $scope.isRedirectAllow = true;
        $window.location.replace('/tripnotes/' + $scope.logbook.id + '/edit');
      });
    };

    $scope.setCover = function(photo) {
      Tripnote.setCoverPhoto({
        id: $scope.tripnote.id,
        cover_photo_id: photo.id
      }, function(data) {
        $scope.tripnote.cover.photo = data['photo'];
        console.log(data['photo']);
      }, function(msg) {
        console.log(msg);
      });
    };

    $scope.rmReview = function(review) {
      var idx;

        idx = $scope.tripnote.reviews.map( function(e) { return e.id } ).indexOf(review.id);
        $scope.tripnote.reviews.splice( idx, 1 );

    };

    function initLogbook(logbookId) {
      $scope.tripnote = Tripnote.getDraft({id: logbookId}, function(){

      });
    }

    $scope.publish = function() {
      $http.put('/api/tripnotes/' + logbookId + '/openness', {openness: 10}).then(function(data) {
        $log.info(data);
        $window.location.href = '/tripnotes/' + logbookId;
      });
    };
  // ---------------------------------------------------------------------------------
  // main
  // ---------------------------------------------------------------------------------

    var logbookId = $window.location.href.match(/tripnotes\/([0-9]+)\/edit/)[1];
    var AUTO_SAVE_INTERVAL = 5000;  // NOTE: 5 sec

    initLogbook(logbookId);

    $scope.tl8 = {};

    $scope.autoSave     = null;
    $scope.isSaving     = false;
    $scope.isUploading  = false;
    $scope.introDone    = true;

    $scope.isEditing    = true;
    $scope.isAutoSaveEnabled = true;

    var isPickingSpot = false;

    $timeout( function() {
      $scope.isEditing = false;
    }, AUTO_SAVE_INTERVAL * 2);

    $window.onbeforeunload = function() {
      if ($scope.logbook.episodes.length == 0 || $scope.isRedirectAllow){ return; }
      return getConfirmMsg();
    };
  }
})();
