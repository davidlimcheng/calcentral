'use strict';

var angular = require('angular');

angular.module('calcentral.factories').factory('degreeProgressFactory', function(apiService) {
  var undergraduateRequirementsUrl = '/api/academics/degree_progress/ugrd';
  // var undergraduateRequirementsUrl = '/dummy/json/degree_progress_ugrd_all_complete.json';
  var graduateMilestonesUrl = '/api/academics/degree_progress/grad';

  var getUndergraduateRequirements = function(options) {
    return apiService.http.request(options, undergraduateRequirementsUrl);
  };

  var getGraduateMilestones = function(options) {
    return apiService.http.request(options, graduateMilestonesUrl);
  };

  return {
    getGraduateMilestones: getGraduateMilestones,
    getUndergraduateRequirements: getUndergraduateRequirements
  };
});
