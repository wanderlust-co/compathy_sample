'use strict';

angular.module('tripnoteServices', ['ngResource'])
.service('Tripnote', ['$resource', function($resource) {
  function parseCyReseponse(data) {
    return angular.fromJson(data)['tripnote'];
  }

  return $resource('/api/tripnotes/:id/:subCtrl', {
    // v: '20150708',
    id: '@id'
  }, {
    getDraft: {
      method: 'GET',
      params: {
        subCtrl: 'edit'
      },
      transformResponse: parseCyReseponse
    },
    update: {
      method: 'PUT',
      transformRequest: function(obj) {
        return angular.toJson({logbook: obj})
      },
      transformResponse: parseCyReseponse
    },
    addFriends: {
      method: 'POST',
      params: {
        subCtrl: 'friends'
      }
    },
    removeFriend: {
      method: 'DELETE',
      params: {
        subCtrl: 'friends'
      }
    },
    setCoverPhoto: {
      method: 'PUT',
      params: {
        subCtrl: 'cover_photo'
      }
    }
  });
}]);