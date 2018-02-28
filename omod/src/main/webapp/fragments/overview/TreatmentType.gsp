<style>
.input{
	background : #F9F9F9;
	display: block;
}

.labelspace{
	padding-left: 30px;
}
</style>
<div id="advice" class="long-info-section" ng-controller="TypeController">
	<div class="info-header">
		<i class="icon-comments"></i>
		<h3>Treatment Type</h3>
	</div>
	<div class="input">
		Please select what type of treatment you will be prescribing -
		<br/>
		<br/>
		<label>
							<input type="radio"  value="Ayurvedic" ng-model="treatment">
							Ayurvedic
					</label>
		<label class = 'labelspace'>
				<input type="radio" value="Allopathic" ng-model="treatment">
				Allopathic
		</label>
		<label class = 'labelspace'>
				<input type="radio"  value="Combination" ng-model="treatment">
				Combination
		</label>
		<button type="button"  ng-click = 'addtype()' ng-disabled = "isDiasbled" style=" margin-left: 30px;" ng-show = "alerts.length == 0">Add Treatment Type</button>
<br/>
<br/>
<div uib-alert ng-repeat="alert in alerts" ng-class="'alert-' + (alert.type || 'info')" close="closeAlert(\$index)">{{alert.msg}}</div>
	</div>
		<p>{{errortext}}</p>
	</div>
	<div>
		<p>*please delete current treatment type to reselect the treatment type.</p>
	</div>
    <div>
        <a href="#" class="right back-to-top">Back to top</a>
    </div>
		<br/>
</div>


<script>

	var app = angular.module('TreatmentType', ['recentVisit']);

	app.factory('TreatmentTypeFactory1', function(\$http, \$filter){
	  var patient = "${ patient.uuid }";
	  var date = new Date();
	  date = \$filter('date')(new Date(), 'yyyy-MM-dd');
	  var url = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/encounter";
	      url += "?patient=" + patient;
	      url += "&encounterType=" + window.constantConfigObj.encounterTypeVisitNote;
	      url += "&fromdate=" + date;
	  return {
	    async: function(){
	      return \$http.get(url).then(function(response){
	        return response.data.results;
	      });
	    }
	  };
	});

	app.factory('TreatmentTypeFactory2', function(\$http){
	  var patient = "${ patient.uuid }";
	  var url1 = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/encounter";
	  var date2 = new Date();
	  var json = {
	      patient: patient,
	      encounterType: "window.constantConfigObj.encounterTypeVisitNote",
	      encounterDatetime: date2
	  };
	  return {
	    async: function(){
	      return \$http.post(url1, JSON.stringify(json)).then(function(response){
	        return response.data.uuid;
	      });
	    }
	  };
	});


	app.controller('TypeController', function(\$scope, \$http, \$timeout, TreatmentTypeFactory1, TreatmentTypeFactory2, recentVisitFactory){
		var patient = "${patient.uuid}";
		\$scope.alerts = [];
		var date2 = new Date();
		var path = window.location.search;
		var i = path.indexOf("visitId=");
		var visitId = path.substr(i + 8, path.length);
		\$scope.visitEncounters = [];
		\$scope.visitObs = [];
		\$scope.visitNoteData = [];
		\$scope.visitNotePresent = true;
		\$scope.visitStatus = false;
		\$scope.encounterUuid = "";
		\$scope.isDiasbled = false;
		recentVisitFactory.fetchVisitEncounterObs(visitId).then(function(data) {
			\$scope.visitDetails = data.data;
				if (\$scope.visitDetails.stopDatetime == null || \$scope.visitDetails.stopDatetime == undefined) {
					\$scope.visitStatus = true;
				}
				else {
					\$scope.visitStatus = false;
				}
				\$scope.visitEncounters = data.data.encounters;
				if(\$scope.visitEncounters.length !== 0) {
				\$scope.visitNotePresent = true;
					angular.forEach(\$scope.visitEncounters, function(value, key){
						var isVital = value.display;
						if(isVital.match("Visit Note") !== null) {
							\$scope.encounterUuid = value.uuid;
							 var encounterUrl =  "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/encounter/" + \$scope.encounterUuid;
							 \$http.get(encounterUrl).then(function(response) {
							 	angular.forEach(response.data.obs, function(v, k){
								var encounter = v.display;
								if(encounter.match("treatment_type") !== null) {
									\$scope.alerts.push({"msg":v.display.slice(16,v.display.length), "uuid": v.uuid});
									}
								});
							 }, function(response) {
						    	\$scope.error = "Get Encounter Obs Went Wrong";
							 		\$scope.statuscode = response.status;
								});
							}
						});
					}
					else {
						\$scope.visitNotePresent = false;
					}
					}, function(error) {
					console.log(error);
				});

	\$scope.types = ['Ayurvedic', 'Allopathic', 'Combination'];

	// \$scope.check = function(){
	// 	console.log(\$scope.alerts.length);
	// 	if(\$scope.alerts.length !== '0'){
	// 		return true;
	// 	}
	// };

	\$timeout(function(){
		var promise = TreatmentTypeFactory1.async().then(function(d){
			var length = d.length;
		if(length > 0) {
			angular.forEach(d, function(value, key){
				\$scope.data = value.uuid;
			});
		} else {
			\$scope.data2 = "Created an Encounter";
			TreatmentTypeFactory2.async().then(function(d2){
				\$scope.data = d2;
			})
		};
		return \$scope.data;
		});

		promise.then(function(x){

			\$scope.addtype = function(){
				\$scope.isDiasbled = true;
				console.log(\$scope.alerts);
				if(\$scope.treatment != ''){
				if (\$scope.alerts.indexOf(\$scope.treatment) == -1){
								\$scope.alerts.push({msg: \$scope.treatment})
								  var url2 = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/obs";
											\$scope.json = {
															concept: '91f72312-069f-4344-83c8-13fe61d37970',
															person: patient,
															obsDatetime: date2,
															value: \$scope.treatment,
															encounter: \$scope.encounterUuid
											}
											console.log(\$scope.json);
											\$http.post(url2, JSON.stringify(\$scope.json)).then(function(response){
												if(response.data){
																\$scope.statuscode = "Success";
																angular.forEach(\$scope.alerts, function(v, k){
									var encounter = v.msg;
									if(encounter.match(\$scope.treatment) !== null) {
									v.uuid = response.data.uuid;
									}
								});
								\$scope.treatment = "";
														}
											}, function(response){
												\$scope.statuscode = "Failed to create Obs";
											});
				}
			};
}
			\$scope.closeAlert = function(index) {
	  		if (\$scope.visitStatus) {
					\$scope.isDiasbled = false;
				\$scope.deleteurl = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/obs/" + \$scope.alerts[index].uuid + "?purge=true";
	                	\$http.delete(\$scope.deleteurl).then(function(response){
											console.log(response);
			                \$scope.alerts.splice(index, 1);
			        		\$scope.errortext = "";
	                		\$scope.statuscode = "Success";
	                	}, function(response){
	                		\$scope.statuscode = "Failed to delete Obs";
	                	});
	        }
  		};

		});

	},2000);

});

</script>
