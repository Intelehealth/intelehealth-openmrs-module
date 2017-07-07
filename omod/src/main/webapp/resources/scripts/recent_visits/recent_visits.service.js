recentVisits.factory('RecentVisitFactory', [ '$http', '$q',
		function($http, $q) {

			return {
				fetchRecentVisits : function() {
					var url = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/visit";
					return $http.get(url);
				},
			};

		} ]);