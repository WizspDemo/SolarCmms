/**
 * Solar Corrective Work Order – Maintenance Team Members pane
 *
 * Model-driven app (Dataverse).
 * Opens a side pane with an HTML web resource that shows
 * Maintenance Team members and their job counts.
 *
 * Usage:
 * - Upload this JS as a web resource (type JavaScript).
 * - On the Solar Corrective Work Order form Command Bar,
 *   add a button with Action = Run JavaScript.
 * - Library: the web resource containing this script.
 * - Function name: SolarCorrectiveWoOpenTeamMembersPane
 * - Parameter: PrimaryControl.
 *
 * The HTML web resource loaded in the pane is set in
 * TEAM_MEMBERS_WEBRESOURCE_NAME. It receives teamId and
 * scheduleDate (YYYY-MM-DD) via the data parameter.
 */
(function () {
  'use strict';

  // HTML web resource name as uploaded to Dataverse (Solardev).
  const TEAM_MEMBERS_WEBRESOURCE_NAME = 'solar_correctiveworkorder_team_members_pane.html';

  // Logical names of form fields on Corrective Work Order (Dataverse).
  const FIELD_MAINTENANCE_TEAM = 'solar_maintenanceteamid';
  const FIELD_SCHEDULE_DATE = 'solar_cor_scheduleddate';

  /**
   * Handler for the ribbon / command bar button.
   * Signature: function (primaryControl)
   */
  function SolarCorrectiveWoOpenTeamMembersPane(primaryControl) {
    var formContext = primaryControl;
    if (!formContext || typeof formContext.getAttribute !== 'function') {
      console.warn('[CorrectiveWorkOrder] formContext is not available.');
      return;
    }

    var teamAttr = formContext.getAttribute(FIELD_MAINTENANCE_TEAM);
    if (!teamAttr || !teamAttr.getValue()) {
      Xrm.Navigation.openAlertDialog({
        title: 'Maintenance Team',
        text: 'Please select a Maintenance Team before opening the employee list.',
      });
      return;
    }

    var teamValue = teamAttr.getValue()[0];
    var teamId = (teamValue.id || '').replace(/[{}]/g, '');

    var scheduleAttr = formContext.getAttribute(FIELD_SCHEDULE_DATE);
    var scheduleDate = scheduleAttr && scheduleAttr.getValue ? scheduleAttr.getValue() : null;

    // Normalize to YYYY-MM-DD.
    // Use duck-typing instead of instanceof Date: Dataverse returns Date objects from within
    // the UCI framework that may fail instanceof checks due to cross-realm prototype differences.
    // Use LOCAL date methods (getFullYear/getMonth/getDate): the field is DateTime/UserLocal,
    // so getValue() returns the date in the user's local timezone. Using UTC methods would
    // shift the date by the UTC offset (e.g. UTC+2 → 2026-02-26 becomes 2026-02-25 in UTC).
    var scheduleDateString = null;
    if (scheduleDate && typeof scheduleDate.getFullYear === 'function') {
      var y = scheduleDate.getFullYear();
      var mo = scheduleDate.getMonth() + 1;
      var d = scheduleDate.getDate();
      scheduleDateString = y + '-' + (mo < 10 ? '0' + mo : mo) + '-' + (d < 10 ? '0' + d : d);
    } else if (typeof scheduleDate === 'string' && scheduleDate.length >= 10) {
      var parsed = scheduleDate.substring(0, 10);
      if (/^\d{4}-\d{2}-\d{2}$/.test(parsed)) {
        scheduleDateString = parsed;
      }
    }

    var paneId = 'solarTeamMembersPane';

    function getOrCreatePane() {
      try {
        var existing = Xrm.App.sidePanes.getPane && Xrm.App.sidePanes.getPane(paneId);
        if (existing) {
          return Promise.resolve(existing);
        }
      } catch (e) {}
      return Xrm.App.sidePanes.createPane({
        title: 'Maintenance Team Members',
        paneId: paneId,
        canClose: true,
        width: 450,
      }).catch(function (err) {
        // Duplicate paneId: pane exists but getPane didn't find it – try getPane again
        if (err && (err.code === 2415919128 || (err.message && err.message.indexOf('Duplicate paneId') >= 0))) {
          var p = Xrm.App.sidePanes.getPane && Xrm.App.sidePanes.getPane(paneId);
          if (p) return Promise.resolve(p);
        }
        throw err;
      });
    }

    var panePromise = getOrCreatePane();

    // Store formContext so pane can set solar_employee when user clicks Assign
    try {
      (window.top || window).__solarCorrectiveWoFormContext = formContext;
    } catch (e) {}

    var recordId = null;
    try {
      recordId = formContext.data.entity.getId();
    } catch (e) {}

    var navigationData = {
      teamId: teamId,
      teamName: teamValue.name || '',
      scheduleDate: scheduleDateString,
      recordId: recordId,
    };
    var dataJson = JSON.stringify(navigationData);

    // Share data via window.top (primary – accessible from pane iframe, same origin).
    // sessionStorage is isolated per iframe so it cannot be read by the pane directly.
    try {
      (window.top || window).__solarTeamMembersPaneData = navigationData;
    } catch (ignore) {}

    // Also keep sessionStorage as secondary (works if form and pane happen to share context).
    try {
      sessionStorage.setItem('solar_team_members_pane_data', dataJson);
    } catch (ignore) {}

    panePromise
      .then(function (pane) {
        return pane.navigate({
          pageType: 'webresource',
          webresourceName: TEAM_MEMBERS_WEBRESOURCE_NAME,
          data: dataJson,
        });
      })
      .catch(function (error) {
        console.error('[CorrectiveWorkOrder] Failed to create/navigate pane:', error);
        Xrm.Navigation.openAlertDialog({
          title: 'Error',
          text:
            'An error occurred while opening the employee list.\n\n' +
            (error && error.message ? error.message : String(error)),
        });
      });
  }

  // Expose function on global scope for ribbon.
  window.SolarCorrectiveWoOpenTeamMembersPane = SolarCorrectiveWoOpenTeamMembersPane;
})();

