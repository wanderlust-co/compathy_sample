(function() {
  'use strict';

  angular.module('compathyClone')
  .controller('LogbookEditController', LogbookEditController);

  LogbookEditController.$inject = ['$scope', '$window', '$http', '$location', '$timeout', 'Tripnote'];

  function LogbookEditController($scope, $window, $http, $location, $timeout, Tripnote) {
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
      // beforeSend: function(xhr) {
      //   // NOTE: we need it explicitly as this request is not using $http
      //   xhr.setRequestHeader('X-XSRF-TOKEN', $cookies.get('XSRF-TOKEN'));
      // },
      submit: function (e, data) {
        // NOTE: should evaluate functions to add them FormData before start upload
        data.formData =  {
          logbookId: $scope.logbook.id
        };
      },
      done: function(e, data) {
        console.log('done');
        console.log(data)

        // var $review = $('.saved-review:first').clone();
        // $review.find('h3').text(review.body);
        // $review.find('img').attr('src', review.photos[0].image_url);
        // $('.saved-reviews').append($review);
        // $('.preview').html("")

        var review = data.result.review;
        $scope.tripnote.tripnote.reviews.push( review );
      },
      processstart: function() {
        $scope.isUploading = true;
      },
      stop: function(e, data) {
        $scope.isUploading = false;

        console.log('stop');
        console.log(data);

        // updateEpisodesPageNum();

        // $scope.logbook.$update(function(l, h){
        //  $scope.logbook = l;
        //  $scope.sectionedEpisodes = genSectionedEpisodes();
        //  initMap();

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

  function initLogbook(logbookId) {
    $scope.tripnote = Tripnote.getDraft({id: logbookId}, function(){
      // console.log($scope.tripnote);
      // $scope.sectionedEpisodes = genSectionedEpisodes();
      // console.log($scope.logbook)
      // initMap();

      // if ( $scope.logbook.episodes.length < 1 ) {
      //   var modalInstance = $uibModal.open({
      //     templateUrl: '/templates/modals/tripnote_new',
      //     controller: 'NewTripnoteModalCtrl',
      //     backdrop: 'static',
      //     keyboard: false
      //   });

      //   modalInstance.result.then( function( answer ) {
      //     if ( answer === true ) {
      //       setTimeout(function() {
      //         angular.element('#fileUploadBtn').click();
      //       }, 10);
      //     } else {
      //       $window.history.back();
      //     }
      //   });
      // }

      // if ( localStorageService.get( 'needMoreLogbookInfo' ) ) {
      //   localStorageService.remove( 'needMoreLogbookInfo' );
      //   openRequireInputModal();
      // }

      // updateEpisodesPageNum();
      // setAutoSave();
    });
  }

  // ---------------------------------------------------------------------------------
  // main
  // ---------------------------------------------------------------------------------

  var logbookId = $window.location.href.match(/tripnotes\/([0-9]+)\/edit/)[1];
  var AUTO_SAVE_INTERVAL = 5000;  // NOTE: 5 sec

  initLogbook(logbookId);

  // NOTE: prevent from that AngularGM creates mapData its own apart from this controller scope.
  // $scope.mapData = MapManager.getMapData();
  // $scope.mapData.options.draggable = true;

  $scope.tl8 = {};
  // $translate('confirm_leave_page_with_draft').then(function(t){ $scope.tl8.confirmDraft = t; });
  // $translate('confirm_leave_page_losing_data').then(function(t){ $scope.tl8.confirmLoseData = t; });
  // $translate('confirm_delete').then(function(t){ $scope.tl8.confirmDelete = t; });
  // $translate('error_refresh').then(function(t){ $scope.tl8.errorRefresh = t; });

  $scope.autoSave     = null;
  $scope.isSaving     = false;
  $scope.isUploading  = false;
  $scope.introDone    = true;
  // $scope.introOptions = IntroManager[$translate.use()].options();
  $scope.isEditing    = true;
  $scope.isAutoSaveEnabled = true;

  // $scope.themeTags  = THEME_TAGS[$translate.use()];
  var isPickingSpot = false;

  // FIXME: prevent from initial auto save
  $timeout( function() {
    $scope.isEditing = false;
  }, AUTO_SAVE_INTERVAL * 2);

  $window.onbeforeunload = function() {
    if ($scope.logbook.episodes.length == 0 || $scope.isRedirectAllow){ return; }
    return getConfirmMsg();
  };
}
})();
