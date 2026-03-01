/**
 * Solar Corrective Work Order – Maintenance Team Members pane (from View)
 *
 * Model-driven app (Dataverse). Opens the team members pane when the user
 * clicks the button from a list view, using the SELECTED record.
 *
 * Usage:
 * - Upload this JS as a web resource (type JavaScript).
 * - Add a Command Bar button on the Solar Corrective Work Order list VIEW
 *   (not the form): Action = Run JavaScript.
 * - Library: the web resource containing this script.
 * - Function name: SolarCorrectiveWoViewOpenTeamMembersPane
 * - Parameters: Add BOTH (in order): SelectedControlSelectedItemIds, SelectedControl. Script tries both.
 *
 * The HTML pane (solar_correctiveworkorder_team_members_pane.html) is reused.
 * Assign uses Web API (recordId is passed) since there is no form context.
 */
(function () {
  'use strict';

  const TEAM_MEMBERS_WEBRESOURCE_NAME = 'solar_correctiveworkorder_team_members_pane.html';
  const ENTITY_NAME = 'solar_corrective_work_order';
  const FIELD_MAINTENANCE_TEAM = 'solar_maintenanceteamid';
  const FIELD_SCHEDULE_DATE = 'solar_cor_scheduleddate';
  const PANE_ID = 'solarTeamMembersPane';

  function showError(title, text) {
    if (typeof Xrm !== 'undefined' && Xrm.Navigation && Xrm.Navigation.openAlertDialog) {
      Xrm.Navigation.openAlertDialog({ title: title || 'Error', text: text || '' });
    } else {
      window.alert((title || 'Error') + ': ' + (text || ''));
    }
  }

  function getRecordIdFromSelectedItemIds(selectedItemIds) {
    if (!selectedItemIds || typeof selectedItemIds !== 'string') return null;
    var ids = selectedItemIds.split(',').map(function (s) { return s.trim().replace(/[{}]/g, ''); }).filter(Boolean);
    return ids.length === 1 ? ids[0] : null;
  }

  function getRecordIdFromGrid(gridControl) {
    try {
      if (!gridControl || typeof gridControl.getGrid !== 'function') return null;
      var grid = gridControl.getGrid();
      if (!grid || typeof grid.getSelectedRows !== 'function') return null;
      var rows = grid.getSelectedRows();
      var rowsLen = rows && (typeof rows.getLength === 'function' ? rows.getLength() : rows.length);
      if (!rows || !rowsLen) return null;
      var row = (typeof rows.get === 'function' ? rows.get(0) : (Array.isArray(rows) ? rows[0] : rows[0]));
      var data = (row && row.data) || (row && row.getData && row.getData());
      if (!data) return null;
      var entity = data.getEntity && data.getEntity();
      if (!entity) return null;
      var id = entity.getId && entity.getId();
      return id ? (id + '').replace(/[{}]/g, '') : null;
    } catch (e) {
      return null;
    }
  }

  var LOOKUP_VALUE_FIELD = '_' + FIELD_MAINTENANCE_TEAM + '_value';

  function fetchRecordData(recordId) {
    var select = '?$select=' + LOOKUP_VALUE_FIELD + ',' + FIELD_SCHEDULE_DATE;
    return Xrm.WebApi.retrieveRecord(ENTITY_NAME, recordId, select)
      .then(function (record) {
        var team = record[FIELD_MAINTENANCE_TEAM] || record[LOOKUP_VALUE_FIELD];
        var scheduleDate = record[FIELD_SCHEDULE_DATE];

        var teamId = null;
        var teamName = '';
        if (team) {
          if (typeof team === 'string') {
            teamId = team.replace(/[{}]/g, '');
          } else if (team.id || team.guid) {
            teamId = (team.id || team.guid || '').replace(/[{}]/g, '');
            teamName = team.name || '';
          }
        }

        var scheduleDateString = null;
        if (scheduleDate) {
          // For DateOnly fields Dataverse may return a plain "YYYY-MM-DD" string
          // or a UTC-midnight datetime "YYYY-MM-DDT22:00:00Z" (for UTC+2 timezones).
          // Using toISOString() would lose 1 day in UTC+2, so we use local date components.
          if (typeof scheduleDate === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(scheduleDate)) {
            scheduleDateString = scheduleDate; // already plain date string
          } else {
            var d = scheduleDate instanceof Date ? scheduleDate : new Date(scheduleDate);
            if (!isNaN(d.getTime())) {
              var yr = d.getFullYear();
              var mo = String(d.getMonth() + 1).padStart(2, '0');
              var dy = String(d.getDate()).padStart(2, '0');
              scheduleDateString = yr + '-' + mo + '-' + dy;
            }
          }
        }

        return { teamId: teamId, teamName: teamName, scheduleDate: scheduleDateString, recordId: recordId };
      });
  }

  function openPane(navigationData) {
    var dataJson = JSON.stringify(navigationData);

    try {
      sessionStorage.setItem('solar_team_members_pane_data', dataJson);
    } catch (e) {}

    // No formContext when from view – Assign will use Web API
    try {
      (window.top || window).__solarCorrectiveWoFormContext = null;
    } catch (e) {}

    function getOrCreatePane() {
      try {
        var existing = Xrm.App.sidePanes.getPane && Xrm.App.sidePanes.getPane(PANE_ID);
        if (existing) return Promise.resolve(existing);
      } catch (e) {}
      return Xrm.App.sidePanes.createPane({
        title: 'Maintenance Team Members',
        paneId: PANE_ID,
        canClose: true,
        width: 450,
      }).catch(function (err) {
        if (err && (err.code === 2415919128 || (err.message && err.message.indexOf('Duplicate paneId') >= 0))) {
          var p = Xrm.App.sidePanes.getPane && Xrm.App.sidePanes.getPane(PANE_ID);
          if (p) return Promise.resolve(p);
        }
        throw err;
      });
    }

    return getOrCreatePane().then(function (pane) {
      return pane.navigate({
        pageType: 'webresource',
        webresourceName: TEAM_MEMBERS_WEBRESOURCE_NAME,
        data: dataJson,
      });
    });
  }

  function SolarCorrectiveWoViewOpenTeamMembersPane(param1, param2) {
    try {
    if (typeof Xrm === 'undefined' || !Xrm.App || !Xrm.App.sidePanes) {
      showError('Environment', 'Xrm.App.sidePanes not available. Try opening a record first, then use the form button.');
      return;
    }
    var r1 = getRecordIdFromSelectedItemIds(param1);
    var r2 = getRecordIdFromSelectedItemIds(param2);
    var g1 = getRecordIdFromGrid(param1);
    var g2 = getRecordIdFromGrid(param2);
    var recordId = r1 || r2 || g1 || g2;
    if (!recordId) {
      showError(
        'Select a record',
        'Please select exactly one Solar Corrective Work Order in the list, then try again.'
      );
      return;
    }

    fetchRecordData(recordId)
      .then(function (data) {
        if (!data.teamId) {
          showError(
            'Maintenance Team',
            'The selected record has no Maintenance Team. Open the record and select a team first.'
          );
          return;
        }
        return openPane(data);
      })
      .catch(function (error) {
        console.error('[CorrectiveWoView] Error:', error);
        showError(
          'Error',
          'An error occurred while opening the employee list.\n\n' +
            (error && error.message ? error.message : String(error))
        );
      });
    } catch (e) {
      showError('Script Error', (e && e.message) ? e.message : String(e));
    }
  }

  window.SolarCorrectiveWoViewOpenTeamMembersPane = SolarCorrectiveWoViewOpenTeamMembersPane;
})();
