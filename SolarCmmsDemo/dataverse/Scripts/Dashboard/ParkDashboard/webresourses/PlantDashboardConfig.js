/**
 * PlantDashboard - Tab & Widget Visibility Configuration
 * 
 * Ορίζει ποια tabs και widgets εμφανίζονται.
 * 
 * Χρήση:
 * 1) Ανεβάστε σε Dataverse ως Script web resource (π.χ. solar_PlantDashboardConfig.js).
 * 2) Προσθέστε στο PlantDashboard.html πριν το main script:
 *    <script src="https://YOUR_ORG.crm4.dynamics.com/WebResources/solar_PlantDashboardConfig"></script>
 * 3) Αλλάξτε τα true/false παρακάτω.
 * 
 * URL params (αντικαθιστούν τα παρακάτω):
 *   ?tabs=workorders,livefeed,map  → μόνο αυτά τα tabs
 *   ?hide=windy,team               → κρύψιμο windy και team
 *   ?showMessageBar=0              → κρύψιμο MessageBar
 *   ?statsCards=preventiveHealth,criticalDefects → μόνο αυτά τα cards
 *   ?hideStatsCards=preventiveWorkflow          → κρύψιμο συγκεκριμένων cards
 *   ?showWeatherWidget=0           → κρύψιμο Weather widget
 *   ?showInverterStatus=0          → κρύψιμο Inverter Status
 */
(function () {
    'use strict';
    window.PlantDashboardConfig = window.PlantDashboardConfig || {};
    window.PlantDashboardConfig.visibleTabs = {
        workorders: true,
        livefeed: true,
        map: true,
        team: true,
        sitedetails: true,
        windy: false
    };
    window.PlantDashboardConfig.showMessageBar = true;
    window.PlantDashboardConfig.statsCards = {
        preventiveHealth: true,
        preventiveWorkflow: true,
        criticalDefects: true,
        correctiveWorkflow: true
    };
    window.PlantDashboardConfig.showWeatherWidget = true;
    window.PlantDashboardConfig.showInverterStatus = true;
})();
