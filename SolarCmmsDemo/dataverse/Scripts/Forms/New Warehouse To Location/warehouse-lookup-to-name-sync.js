/**
 * New Warehouse To Location – Συγχρονισμός Warehouse Lookup → Name
 *
 * Model-driven app (Dataverse). Όταν επιλέγεται τιμή στο Warehouse Lookup,
 * η τιμή μπαίνει αυτόματα στο πεδίο Name (solar_warehousetolocationname).
 *
 * Φόρμα: New Warehouse To Location (formHeaderTitle_0 / header_title)
 *
 * Custom control / Form library: όταν ζητήσει "function" δώστε:  warehouseToNameSyncStart
 * (ή OnLoad αν ζητάει handler για Form OnLoad)
 */
(function () {
  'use strict';

  const FORM_HEADER_TITLE = 'New Warehouse To Location';
  const WAREHOUSE_LOOKUP_SELECTORS = [
    'input[data-id="solar_warehouse.fieldControl-LookupResultsDropdown_solar_warehouse_textInputBox_with_filter_new"]',
    'input[aria-label="Warehouse, Lookup"]',
    'input[placeholder="Look for Warehouse"]',
    'input[id*="solar_warehouse"][id*="LookupResultsDropdown_solar_warehouse_0_textInputBox_with_filter_new"]',
  ];

  const NAME_FIELD_SELECTORS = [
    'input[data-id="solar_warehousetolocationname.fieldControl-text-box-text"]',
    'input[aria-label="Name"][id*="solar_warehousetolocationname"]',
    'input[id*="solar_warehousetolocationname"][id*="fieldControl-text-input-component"]',
  ];

  function isThisForm() {
    var titleEl = document.querySelector('h1#formHeaderTitle_0, h1[data-id="header_title"]');
    return titleEl && (titleEl.title === FORM_HEADER_TITLE || (titleEl.textContent || '').trim() === FORM_HEADER_TITLE);
  }

  function findElement(selectors, description) {
    for (var i = 0; i < selectors.length; i++) {
      var el = document.querySelector(selectors[i]);
      if (el) {
        console.log('[New Warehouse To Location] Βρέθηκε: ' + description, el);
        return el;
      }
    }
    return null;
  }

  function syncWarehouseToName() {
    if (!isThisForm()) {
      console.log('[New Warehouse To Location] Δεν βρέθηκε η φόρμα "' + FORM_HEADER_TITLE + '", παράλειψη.');
      return;
    }

    var warehouseInput = findElement(WAREHOUSE_LOOKUP_SELECTORS, 'Warehouse Lookup');
    var nameInput = findElement(NAME_FIELD_SELECTORS, 'Name (Warehouse to location name)');

    if (!warehouseInput || !nameInput) {
      if (!warehouseInput) console.warn('[New Warehouse To Location] Δεν βρέθηκε το πεδίο Warehouse Lookup.');
      if (!nameInput) console.warn('[New Warehouse To Location] Δεν βρέθηκε το πεδίο Name.');
      return;
    }

    function copyValue() {
      var value = (warehouseInput.value || '').trim();
      if (value && nameInput.value !== value) {
        nameInput.value = value;
        nameInput.dispatchEvent(new Event('input', { bubbles: true }));
        nameInput.dispatchEvent(new Event('change', { bubbles: true }));
        console.log('[New Warehouse To Location] Ενημερώθηκε το Name με:', value);
      }
    }

    warehouseInput.addEventListener('change', copyValue);
    warehouseInput.addEventListener('input', copyValue);
    warehouseInput.addEventListener('blur', copyValue);

    var observer = new MutationObserver(function () {
      copyValue();
    });
    observer.observe(warehouseInput, {
      attributes: true,
      attributeFilter: ['value'],
      characterData: true,
      subtree: true,
    });

    setTimeout(copyValue, 500);
    setTimeout(copyValue, 2000);

    console.log('[New Warehouse To Location] Ενεργό: Warehouse Lookup → Name sync.');
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', syncWarehouseToName);
  } else {
    syncWarehouseToName();
  }

  /** Συνάρτηση για Custom Control / Form Library – αυτό πληκτρολογείτε όταν ζητάει "function". */
  function warehouseToNameSyncStart() {
    syncWarehouseToName();
  }

  window.warehouseToNameSyncStart = warehouseToNameSyncStart;

  /** Εναλλακτικά για Form OnLoad handler (αν ζητάει OnLoad). */
  window.OnLoad = function (executionContext) {
    syncWarehouseToName();
  };
})();
