gonzo.factory('changes', [function() {

  var changesdb = new PouchDB('v1_0_0-changes');
  PouchDB.replicate('http://127.0.0.1:5984/v1_0_0', 'v1_0_0-changes', {continuous: true});
  return changesdb;

}]);

gonzo.factory('listener', ['$rootScope', 'changes', function($rootScope, changes) {
  changes.changes({
    continuous: true,
    onChange: function(change) {
      if (!change.deleted) {
        $rootScope.$apply(function() {
          changes.get(change.id, function(err, doc) {
            $rootScope.$apply(function() {
              if (err) console.log(err);
              // console.log("listener: new result");
              $rootScope.$broadcast('delResult', change.id);
              $rootScope.$broadcast('delChange', change.id);

              $rootScope.$broadcast('newChange', doc);
              $rootScope.$broadcast('newResult', doc);
            });
          });
        });
      } else {
        $rootScope.$apply(function() {
          $rootScope.$broadcast('delResult', change.id);
          $rootScope.$broadcast('delChange', change.id);
        });
      }
    }
  });
}]);

gonzo.factory('changeWrapper', ['$q', '$rootScope', 'changes', function($q, $rootScope, changes) {

  return {
    query: function(text) {
      var deferred = $q.defer();
      var doc = {
        type: 'result',
        text: text
      };
      changes.query({map:
        function(doc) {
          if ("changes" == doc.collection) {
            emit([doc._id, 0], doc.output);
          }
          if ("report") {
            if (doc.changes) {
              for (var i in doc.changes) {
                emit([doc.changes[i], doc.senderid], doc._id);
              }
            }
          }
        }
      }, {reduce: false}, function(err, res) {
        $rootScope.$apply(function() {
          if (err) {
            deferred.reject(err);
          } else {
            deferred.resolve(res);
          }
        });
      });
      return deferred.promise;
    },
    add: function(text) {
      var deferred = $q.defer();
      var doc = {
        type: 'result',
        text: text
      };
      changes.post(doc, function(err, res) {
        $rootScope.$apply(function() {
          if (err) {
            deferred.reject(err);
          } else {
            deferred.resolve(res);
          }
        });
      });
      return deferred.promise;
    },
    remove: function(id) {
      var deferred = $q.defer();
      changes.get(id, function(err, doc) {
        $rootScope.$apply(function() {
          if (err) {
            deferred.reject(err);
          } else {
            changes.remove(doc, function(err, res) {
              $rootScope.$apply(function() {
                if (err) {
                  deferred.reject(err);
                } else {
                  deferred.resolve(res);
                }
              });
            });
          }
        });
      });
      return deferred.promise;
    }
  };

}]);