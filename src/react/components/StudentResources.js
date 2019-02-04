import React from 'react';
import PropTypes from 'prop-types';

import CampusSolutionsLinkContainer from '../containers/CampusSolutionsLinkContainer';
import Widget from './base/widget/Widget';

import '../stylesheets/box_model.scss';
import '../stylesheets/lists.scss';
import '../stylesheets/student_resources.scss';

const renderLinkSectionList = (linkObj) => {
  return (
    <li key={linkObj.urlId}>
      <CampusSolutionsLinkContainer linkObj={{...linkObj}}/>
    </li>
  );
};

const renderLinkSection = (resource) => {
  return (
    <div className="cc-react-student-resources-list" key={resource.section}>
      <h3 className="cc-react-no-margin">{resource.section}</h3>
      <ul className="cc-react-list-bullets">
        {resource.links.map(linkObj => renderLinkSectionList(linkObj))}
      </ul>
    </div>
  );
};

const StudentResources = (props) => {
  return (
    <Widget config={{...props.widgetConfig}}>
      <div className="cc-react-student-resources">
        {props.resources.map(resource => renderLinkSection(resource))}
        <div className="cc-react-student-resources-list">
          <h3 className="cc-react-no-margin">Financial Aid Forms</h3>
          <p className="cc-react-no-margin">Financial aid forms can be found in My Finances under Financial Resources</p>
        </div>
      </div>
    </Widget>
  );
};
StudentResources.propTypes = {
  resources: PropTypes.array.isRequired,
  widgetConfig: PropTypes.object.isRequired
};

export default StudentResources;
