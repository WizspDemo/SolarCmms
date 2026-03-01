/**
 * Verify data-testid attributes in PlantDashboard
 * Paste this script in the browser DevTools Console (F12) when viewing the dashboard
 */
(function () {
  const checks = [
    { id: 'plant-dashboard-root', selector: '[data-testid="plant-dashboard-root"]' },
    { id: 'plant-dashboard-app', selector: '[data-testid="plant-dashboard-app"]' },
    { id: 'operations-pivot', selector: '[data-testid="operations-pivot"]' },
    { id: 'work-orders-list', selector: '[data-testid="work-orders-list"]' },
    { id: 'main-content-area', selector: '[data-testid="main-content-area"]' },
    { id: 'telemetry-sidebar', selector: '[data-testid="telemetry-sidebar"]' },
    { id: 'stats-cards', selector: '[data-testid="stats-cards"]' },
    { id: 'weather-widget', selector: '[data-testid="weather-widget"]' },
    { id: 'windy-map-widget', selector: '[data-testid="windy-map-widget"]' },
    { id: 'plot-cell-BN-01', selector: '[data-testid="plot-cell-BN-01"]' },
  ];

  function runInDoc(doc, label) {
    const results = [];
    checks.forEach(({ id, selector }) => {
      const el = doc.querySelector(selector);
      results.push({ id, found: !!el });
    });
    return { label, results };
  }

  let output = '\n=== PlantDashboard data-testid Verification ===\n\n';

  // Try main document first
  const mainResults = runInDoc(document, 'Main document');
  output += `[${mainResults.label}]\n`;
  mainResults.results.forEach(({ id, found }) => {
    output += `  ${found ? '✓' : '✗'} ${id}\n`;
  });

  // Check iframes (web resource is often in iframe)
  const iframes = document.querySelectorAll('iframe');
  if (iframes.length > 0) {
    output += `\n[Found ${iframes.length} iframe(s)]\n`;
    iframes.forEach((iframe, i) => {
      try {
        const doc = iframe.contentDocument || iframe.contentWindow?.document;
        if (doc) {
          const iframeResults = runInDoc(doc, `iframe ${i + 1}`);
          output += `\n[${iframeResults.label}]\n`;
          iframeResults.results.forEach(({ id, found }) => {
            output += `  ${found ? '✓' : '✗'} ${id}\n`;
          }
          );
        } else {
          output += `  iframe ${i + 1}: Cannot access (cross-origin)\n`;
        }
      } catch (e) {
        output += `  iframe ${i + 1}: Error - ${e.message}\n`;
      }
    });
  }

  const totalFound = mainResults.results.filter((r) => r.found).length;
  const totalChecks = mainResults.results.length;
  output += `\n--- Summary ---\n`;
  output += `Found ${totalFound}/${totalChecks} elements in main document.\n`;
  output += totalFound === totalChecks
    ? '\n✓ All data-testid attributes are present!\n'
    : '\n⚠ Some elements missing. Try: Ctrl+Shift+R (hard refresh) or clear cache.\n';

  console.log(output);
  return output;
})();
