(function () {
  'use strict';
  const TEAM_MEMBERS_WEBRESOURCE_NAME = 'solar_correctiveworkorder_team_members_pane.html';
  const FIELD_MAINTENANCE_TEAM = 'solar_maintenanceteamid';
  const FIELD_SCHEDULE_DATE = 'solar_cor_scheduleddate';
  function SolarCorrectiveWoOpenTeamMembersPane(primaryControl) {
    var formContext = primaryControl;
    if (!formContext || typeof formContext.getAttribute !== 'function') { console.warn('[CorrectiveWorkOrder] formContext is not available.'); return; }
    var teamAttr = formContext.getAttribute(FIELD_MAINTENANCE_TEAM);
    if (!teamAttr || !teamAttr.getValue()) {
      Xrm.Navigation.openAlertDialog({ title: 'Maintenance Team', text: 'Please select a Maintenance Team before opening the employee list.' });
      return;
    }
    window.SolarCorrectiveWoOpenTeamMembersPane = SolarCorrectiveWoOpenTeamMembersPane;
  }
})();
