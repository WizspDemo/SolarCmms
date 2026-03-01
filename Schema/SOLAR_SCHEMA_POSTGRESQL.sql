-- =====================================================================================
-- Solar Plant Management System - PostgreSQL Database Schema
-- =====================================================================================
-- Version: 1.0.0
-- Generated: January 27, 2026
-- Database: PostgreSQL 13+
-- Description: Complete DDL for Solar Plant Maintenance Management System
--              Includes 37 tables with full column definitions, constraints, and indexes
--              Covers master data, inventory, maintenance, tasks, and transactions
-- =====================================================================================

-- Enable UUID extension for GUID support
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================================================
-- MASTER DATA TABLES (Wave 1 - No Dependencies)
-- =====================================================================================

-- Countries Master Table
CREATE TABLE Countries (
    ID SERIAL PRIMARY KEY,
    Title VARCHAR(255) NOT NULL COMMENT 'Country name',
    ISOAlpha2 CHAR(2) COMMENT 'ISO 3166-1 alpha-2 code',
    ISOAlpha3 CHAR(3) COMMENT 'ISO 3166-1 alpha-3 code',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE Countries IS 'Master list of countries for location references';
CREATE INDEX idx_countries_iso2 ON Countries(ISOAlpha2);

-- Suppliers Master Table
CREATE TABLE Suppliers (
    ID SERIAL PRIMARY KEY,
    Code VARCHAR(255) UNIQUE COMMENT 'Unique supplier code',
    Title VARCHAR(255) NOT NULL COMMENT 'Supplier name',
    Description TEXT COMMENT 'Supplier description',
    Notes TEXT COMMENT 'Additional notes (HTML supported)',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE Suppliers IS 'Supplier master data for equipment and parts';
CREATE INDEX idx_suppliers_code ON Suppliers(Code) WHERE Code IS NOT NULL;
CREATE INDEX idx_suppliers_active ON Suppliers(Active);

-- Manufacturer Brands Master Table
CREATE TABLE ManufacturerBrands (
    ID SERIAL PRIMARY KEY,
    Code VARCHAR(255) UNIQUE COMMENT 'Unique manufacturer code',
    Title VARCHAR(255) NOT NULL COMMENT 'Manufacturer/Brand name',
    Logo VARCHAR(255) COMMENT 'Logo file reference',
    Description TEXT COMMENT 'Brand description (HTML supported)',
    Website VARCHAR(2083) COMMENT 'Manufacturer website URL',
    Notes TEXT COMMENT 'Additional notes',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE ManufacturerBrands IS 'Manufacturer and brand master data';
CREATE INDEX idx_manufacturers_code ON ManufacturerBrands(Code) WHERE Code IS NOT NULL;
CREATE INDEX idx_manufacturers_active ON ManufacturerBrands(Active);

-- DNO (Distribution Network Operator) Master Table
CREATE TABLE DNO (
    ID SERIAL PRIMARY KEY,
    Code VARCHAR(255) COMMENT 'DNO identifier code',
    Title VARCHAR(255) NOT NULL COMMENT 'DNO name',
    EmergencyNumber VARCHAR(255) COMMENT 'Emergency contact number',
    Description TEXT COMMENT 'DNO description',
    Telephone VARCHAR(255) COMMENT 'General contact telephone',
    Email VARCHAR(255) COMMENT 'Contact email',
    Website VARCHAR(2083) COMMENT 'DNO website',
    Notes TEXT COMMENT 'Additional notes (HTML supported)',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE DNO IS 'Distribution Network Operators (Grid operators)';
CREATE INDEX idx_dno_code ON DNO(Code) WHERE Code IS NOT NULL;

-- Device Channels Table
CREATE TABLE DeviceChannels (
    ID SERIAL PRIMARY KEY,
    Title VARCHAR(255) NOT NULL COMMENT 'Channel name',
    Alias VARCHAR(255) UNIQUE COMMENT 'Unique channel alias',
    Description TEXT COMMENT 'Channel description',
    UserAgentSubstrings TEXT COMMENT 'Device inclusion rules (user agent patterns)',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE DeviceChannels IS 'Device channel configuration for multi-device support';
CREATE INDEX idx_devicechannels_alias ON DeviceChannels(Alias) WHERE Alias IS NOT NULL;
CREATE INDEX idx_devicechannels_active ON DeviceChannels(Active);

-- Document Set Categories
CREATE TABLE DocumentSetCategories (
    ID SERIAL PRIMARY KEY,
    Title VARCHAR(255) NOT NULL COMMENT 'Category name',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE DocumentSetCategories IS 'Categories for document set organization';

-- Location Configuration Item Types
CREATE TABLE LocationConfigurationItemTypes (
    ID SERIAL PRIMARY KEY,
    Code VARCHAR(255) UNIQUE COMMENT 'Unique item type code',
    Title VARCHAR(255) NOT NULL COMMENT 'Item type name',
    Description TEXT COMMENT 'Item type description',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE LocationConfigurationItemTypes IS 'Types of configuration items for locations';
CREATE INDEX idx_locconfitemtypes_code ON LocationConfigurationItemTypes(Code) WHERE Code IS NOT NULL;
CREATE INDEX idx_locconfitemtypes_active ON LocationConfigurationItemTypes(Active);

-- Maintenance Teams
CREATE TABLE MaintenanceTeams (
    ID SERIAL PRIMARY KEY,
    Code VARCHAR(255) UNIQUE COMMENT 'Unique team code',
    Title VARCHAR(255) NOT NULL COMMENT 'Team name',
    Description TEXT COMMENT 'Team description',
    TeamLeader VARCHAR(255) COMMENT 'Team leader (email/username)',
    Notes TEXT COMMENT 'Additional notes (HTML supported)',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE MaintenanceTeams IS 'Maintenance team definitions';
CREATE INDEX idx_maintenanceteams_code ON MaintenanceTeams(Code) WHERE Code IS NOT NULL;
CREATE INDEX idx_maintenanceteams_active ON MaintenanceTeams(Active);

-- Service Companies
CREATE TABLE ServiceCompanys (
    ID SERIAL PRIMARY KEY,
    Code VARCHAR(255) UNIQUE COMMENT 'Unique service company code',
    Title VARCHAR(255) NOT NULL COMMENT 'Company name',
    Description TEXT COMMENT 'Company description',
    ContactPerson VARCHAR(255) COMMENT 'Primary contact person',
    Email VARCHAR(255) COMMENT 'Contact email',
    Phone VARCHAR(255) COMMENT 'Contact phone',
    Website VARCHAR(2083) COMMENT 'Company website',
    Notes TEXT COMMENT 'Additional notes (HTML supported)',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE ServiceCompanys IS 'External service company master data';
CREATE INDEX idx_servicecompanys_code ON ServiceCompanys(Code) WHERE Code IS NOT NULL;
CREATE INDEX idx_servicecompanys_active ON ServiceCompanys(Active);

-- Settings/Configuration Table
CREATE TABLE Settings (
    ID SERIAL PRIMARY KEY,
    Title VARCHAR(255) UNIQUE NOT NULL COMMENT 'Configuration key',
    Value TEXT COMMENT 'Configuration value',
    Description TEXT COMMENT 'Setting description',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE Settings IS 'Application configuration settings';

-- Section Template
CREATE TABLE SectionTemplate (
    ID SERIAL PRIMARY KEY,
    Code VARCHAR(255) UNIQUE COMMENT 'Unique template code',
    Title VARCHAR(255) NOT NULL COMMENT 'Template name',
    Description TEXT COMMENT 'Template description',
    TemplateType VARCHAR(50) COMMENT 'Template type' CHECK (TemplateType IN ('String', 'Combiner', 'Inverter', 'Transformer')),
    Notes TEXT COMMENT 'Additional notes (HTML supported)',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE SectionTemplate IS 'Templates for section configurations';
CREATE INDEX idx_sectiontemplate_code ON SectionTemplate(Code) WHERE Code IS NOT NULL;
CREATE INDEX idx_sectiontemplate_type ON SectionTemplate(TemplateType);
CREATE INDEX idx_sectiontemplate_active ON SectionTemplate(Active);

-- =====================================================================================
-- HIERARCHICAL CATEGORY TABLES (Wave 1 - Self-Referencing)
-- =====================================================================================

-- Equipment Categories (Hierarchical)
CREATE TABLE EquipmentCategories (
    ID SERIAL PRIMARY KEY,
    Code VARCHAR(255) UNIQUE COMMENT 'Unique category code',
    Title VARCHAR(255) NOT NULL COMMENT 'Category name',
    Description TEXT COMMENT 'Category description (HTML supported)',
    MainType VARCHAR(50) COMMENT 'Main category type' CHECK (MainType IN ('Equipment', 'Asset')),
    ParentID INTEGER REFERENCES EquipmentCategories(ID) ON DELETE SET NULL COMMENT 'Parent category for hierarchy',
    Notes TEXT COMMENT 'Additional notes',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    CategoryType VARCHAR(255) COMMENT 'Calculated category type',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE EquipmentCategories IS 'Hierarchical categories for equipment classification';
CREATE INDEX idx_equipmentcategories_code ON EquipmentCategories(Code) WHERE Code IS NOT NULL;
CREATE INDEX idx_equipmentcategories_parent ON EquipmentCategories(ParentID);
CREATE INDEX idx_equipmentcategories_maintype ON EquipmentCategories(MainType);
CREATE INDEX idx_equipmentcategories_active ON EquipmentCategories(Active);

-- Parts Categories (Hierarchical)
CREATE TABLE PartsCategories (
    ID SERIAL PRIMARY KEY,
    Code VARCHAR(255) UNIQUE COMMENT 'Unique category code',
    Title VARCHAR(255) NOT NULL COMMENT 'Category name',
    Description TEXT COMMENT 'Category description (HTML supported)',
    Level VARCHAR(50) DEFAULT 'Category Level #1' COMMENT 'Category level' CHECK (Level IN ('Category Level #1', 'Category Level #2', 'Category Level #3')),
    ParentID INTEGER REFERENCES PartsCategories(ID) ON DELETE SET NULL COMMENT 'Parent category for hierarchy',
    Notes TEXT COMMENT 'Additional notes',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE PartsCategories IS 'Hierarchical categories for parts classification';
CREATE INDEX idx_partscategories_code ON PartsCategories(Code) WHERE Code IS NOT NULL;
CREATE INDEX idx_partscategories_parent ON PartsCategories(ParentID);
CREATE INDEX idx_partscategories_level ON PartsCategories(Level);
CREATE INDEX idx_partscategories_active ON PartsCategories(Active);

-- Assets Categories (Hierarchical)
CREATE TABLE AssetsCategories (
    ID SERIAL PRIMARY KEY,
    Code VARCHAR(255) UNIQUE COMMENT 'Unique category code',
    Title VARCHAR(255) NOT NULL COMMENT 'Category name',
    Description TEXT COMMENT 'Category description (HTML supported)',
    ParentID INTEGER REFERENCES AssetsCategories(ID) ON DELETE SET NULL COMMENT 'Parent category for hierarchy',
    Notes TEXT COMMENT 'Additional notes',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE AssetsCategories IS 'Hierarchical categories for asset classification';
CREATE INDEX idx_assetscategories_code ON AssetsCategories(Code) WHERE Code IS NOT NULL;
CREATE INDEX idx_assetscategories_parent ON AssetsCategories(ParentID);
CREATE INDEX idx_assetscategories_active ON AssetsCategories(Active);

-- Corrective Task Categories (Hierarchical)
CREATE TABLE CorrectiveTaskCategories (
    ID SERIAL PRIMARY KEY,
    Code VARCHAR(255) UNIQUE COMMENT 'Unique category code',
    Title VARCHAR(255) NOT NULL COMMENT 'Category name',
    Description TEXT COMMENT 'Category description',
    ParentID INTEGER REFERENCES CorrectiveTaskCategories(ID) ON DELETE SET NULL COMMENT 'Parent category for hierarchy',
    Notes TEXT COMMENT 'Additional notes (HTML supported)',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE CorrectiveTaskCategories IS 'Hierarchical categories for corrective tasks';
CREATE INDEX idx_correctivetaskcategories_code ON CorrectiveTaskCategories(Code) WHERE Code IS NOT NULL;
CREATE INDEX idx_correctivetaskcategories_parent ON CorrectiveTaskCategories(ParentID);
CREATE INDEX idx_correctivetaskcategories_active ON CorrectiveTaskCategories(Active);

-- Preventive Task Categories (Hierarchical)
CREATE TABLE PreventiveTaskCategories (
    ID SERIAL PRIMARY KEY,
    Code VARCHAR(255) UNIQUE COMMENT 'Unique category code',
    Title VARCHAR(255) NOT NULL COMMENT 'Category name',
    Description TEXT COMMENT 'Category description',
    ParentID INTEGER REFERENCES PreventiveTaskCategories(ID) ON DELETE SET NULL COMMENT 'Parent category for hierarchy',
    Notes TEXT COMMENT 'Additional notes (HTML supported)',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE PreventiveTaskCategories IS 'Hierarchical categories for preventive tasks';
CREATE INDEX idx_preventivetaskcategories_code ON PreventiveTaskCategories(Code) WHERE Code IS NOT NULL;
CREATE INDEX idx_preventivetaskcategories_parent ON PreventiveTaskCategories(ParentID);
CREATE INDEX idx_preventivetaskcategories_active ON PreventiveTaskCategories(Active);

-- O&M Categories (Hierarchical)
CREATE TABLE OMCategories (
    ID SERIAL PRIMARY KEY,
    Code VARCHAR(255) UNIQUE COMMENT 'Unique category code',
    Title VARCHAR(255) NOT NULL COMMENT 'Category name',
    Description TEXT COMMENT 'Category description',
    CategoryParentID INTEGER REFERENCES OMCategories(ID) ON DELETE SET NULL COMMENT 'Parent category for hierarchy',
    Notes TEXT COMMENT 'Additional notes (HTML supported)',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE OMCategories IS 'Hierarchical O&M (Operations & Maintenance) categories';
CREATE INDEX idx_omcategories_code ON OMCategories(Code) WHERE Code IS NOT NULL;
CREATE INDEX idx_omcategories_parent ON OMCategories(CategoryParentID);
CREATE INDEX idx_omcategories_active ON OMCategories(Active);

-- Maintenance Team Categories (Hierarchical)
CREATE TABLE MaintenanceTeamCategories (
    ID SERIAL PRIMARY KEY,
    Code VARCHAR(255) UNIQUE COMMENT 'Unique category code',
    Title VARCHAR(255) NOT NULL COMMENT 'Category name',
    Description VARCHAR(255) COMMENT 'Category description',
    ParentID INTEGER REFERENCES MaintenanceTeamCategories(ID) ON DELETE SET NULL COMMENT 'Parent category for hierarchy',
    Notes TEXT COMMENT 'Additional notes (HTML supported)',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE MaintenanceTeamCategories IS 'Hierarchical categories for maintenance teams';
CREATE INDEX idx_maintenanceteamcategories_code ON MaintenanceTeamCategories(Code) WHERE Code IS NOT NULL;
CREATE INDEX idx_maintenanceteamcategories_parent ON MaintenanceTeamCategories(ParentID);
CREATE INDEX idx_maintenanceteamcategories_active ON MaintenanceTeamCategories(Active);

-- Preventive Plan Categories (Hierarchical)
CREATE TABLE PreventivePlanCategories (
    ID SERIAL PRIMARY KEY,
    Code VARCHAR(255) UNIQUE COMMENT 'Unique category code',
    Title VARCHAR(255) NOT NULL COMMENT 'Category name',
    Description TEXT COMMENT 'Category description (HTML supported)',
    Level VARCHAR(50) DEFAULT 'Category Level #1' COMMENT 'Category level' CHECK (Level IN ('Category Level #1', 'Category Level #2', 'Category Level #3')),
    ParentID INTEGER REFERENCES PreventivePlanCategories(ID) ON DELETE SET NULL COMMENT 'Parent category for hierarchy',
    Notes TEXT COMMENT 'Additional notes (HTML supported)',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE PreventivePlanCategories IS 'Hierarchical categories for preventive plans';
CREATE INDEX idx_preventiveplancategories_code ON PreventivePlanCategories(Code) WHERE Code IS NOT NULL;
CREATE INDEX idx_preventiveplancategories_parent ON PreventivePlanCategories(ParentID);
CREATE INDEX idx_preventiveplancategories_level ON PreventivePlanCategories(Level);
CREATE INDEX idx_preventiveplancategories_active ON PreventivePlanCategories(Active);

-- =====================================================================================
-- ACCOUNT & LOCATION TABLES (Wave 2)
-- =====================================================================================

-- Accounts Table
CREATE TABLE Accounts (
    ID SERIAL PRIMARY KEY,
    Code VARCHAR(255) UNIQUE COMMENT 'Unique account code',
    Title VARCHAR(255) NOT NULL COMMENT 'Account name',
    DistinctiveTitle VARCHAR(255) COMMENT 'Alternative account name',
    Description TEXT COMMENT 'Account description (HTML supported)',
    AddressDescription TEXT COMMENT 'Address details (HTML supported)',
    Street VARCHAR(255) COMMENT 'Street address',
    ZipOrPostalCode VARCHAR(255) COMMENT 'Zip/Postal code',
    City VARCHAR(255) COMMENT 'City',
    StateOrProvince VARCHAR(255) COMMENT 'State or Province',
    CountryID INTEGER REFERENCES Countries(ID) ON DELETE SET NULL COMMENT 'Country reference',
    Telephone VARCHAR(255) COMMENT 'Contact telephone',
    Email VARCHAR(255) COMMENT 'Contact email',
    Manager VARCHAR(255) COMMENT 'Account manager (email/username)',
    Notes TEXT COMMENT 'Additional notes (HTML supported)',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE Accounts IS 'Customer/Client account master data';
CREATE INDEX idx_accounts_code ON Accounts(Code) WHERE Code IS NOT NULL;
CREATE INDEX idx_accounts_country ON Accounts(CountryID);

-- Locations Table (Most comprehensive - 73 columns)
CREATE TABLE Locations (
    ID SERIAL PRIMARY KEY,
    Code VARCHAR(255) UNIQUE COMMENT 'Unique location code',
    Title VARCHAR(255) NOT NULL COMMENT 'Location name',
    OpenDate DATE COMMENT 'Location opening date',
    CloseDate DATE COMMENT 'Location closing date',
    Stage VARCHAR(50) DEFAULT 'Oem' COMMENT 'Project stage' CHECK (Stage IN ('Construction', 'Oem', 'Repower')),
    CapacityMW NUMERIC(10,2) COMMENT 'Capacity in megawatts',
    AnnualOutputGWh NUMERIC(10,2) COMMENT 'Annual output in gigawatt-hours',
    StockManagement BOOLEAN DEFAULT TRUE COMMENT 'Enable stock management',
    AccountID INTEGER COMMENT 'Account reference',
    ContainsSections BOOLEAN DEFAULT TRUE COMMENT 'Location has sections',
    Manager VARCHAR(255) COMMENT 'Location manager (email/username)',
    Description TEXT COMMENT 'Location description (HTML supported)',
    
    -- Land Information
    LandSizeHectares NUMERIC(10,2) COMMENT 'Land size in hectares',
    AddressDescription TEXT COMMENT 'Address details (HTML supported)',
    Street VARCHAR(255) COMMENT 'Street address',
    ZipOrPostalCode VARCHAR(255) COMMENT 'Zip/Postal code',
    StateOrProvince VARCHAR(255) COMMENT 'State or Province',
    CountryID INTEGER REFERENCES Countries(ID) ON DELETE SET NULL COMMENT 'Country reference',
    Latitude NUMERIC(10,6) COMMENT 'GPS Latitude',
    Longtitude NUMERIC(10,6) COMMENT 'GPS Longitude',
    GoogleEarth VARCHAR(2083) COMMENT 'Google Earth link',
    EmbedMap TEXT COMMENT 'Embedded map HTML',
    What3Words VARCHAR(255) COMMENT 'What3Words location code',
    Grazed BOOLEAN COMMENT 'Land is grazed',
    LandOwnerFarmerDetails TEXT COMMENT 'Land owner/farmer information',
    
    -- Inverter Specifications
    InverterManufacturer VARCHAR(255) COMMENT 'Inverter manufacturer',
    InverterType VARCHAR(255) COMMENT 'Inverter type',
    InverterModel VARCHAR(255) COMMENT 'Inverter model',
    InverterQuantity INTEGER COMMENT 'Number of inverters',
    InverterTotal INTEGER COMMENT 'Total inverter count',
    InverterLVVoltage INTEGER COMMENT 'Inverter LV voltage',
    InverterPower NUMERIC(10,2) COMMENT 'Inverter power rating',
    AssumedWarrantyPeriod INTEGER COMMENT 'Warranty period (years)',
    WarrantyExpiry DATE COMMENT 'Warranty expiration date',
    EstimatedExpiry DATE COMMENT 'Estimated expiry date',
    
    -- Module Specifications
    ModuleManufacturer VARCHAR(255) COMMENT 'Solar module manufacturer',
    ModuleModel VARCHAR(255) COMMENT 'Module model',
    ModuleQuantity INTEGER COMMENT 'Number of modules',
    ModulePower NUMERIC(10,2) COMMENT 'Module power rating (W)',
    ModuleVoc NUMERIC(10,2) COMMENT 'Module open-circuit voltage',
    ModuleIsc NUMERIC(10,2) COMMENT 'Module short-circuit current',
    ModuleLength NUMERIC(10,2) COMMENT 'Module length (mm)',
    ModuleWidth NUMERIC(10,2) COMMENT 'Module width (mm)',
    ModuleDepth NUMERIC(10,2) COMMENT 'Module depth (mm)',
    ModuleStructure VARCHAR(255) COMMENT 'Mounting structure type',
    
    -- Network & Monitoring
    Satellite3G4G VARCHAR(255) COMMENT 'Satellite/3G/4G connectivity',
    LANNetwork VARCHAR(255) COMMENT 'LAN network details',
    SCADAProvider VARCHAR(255) COMMENT 'SCADA system provider',
    ADASInstalled BOOLEAN COMMENT 'ADAS installed flag',
    DataLoggers VARCHAR(255) COMMENT 'Data logger information',
    
    -- DNO & Grid Connection
    DNOGridOperatorID INTEGER REFERENCES DNO(ID) ON DELETE SET NULL COMMENT 'DNO reference',
    DNOSizeKV VARCHAR(255) COMMENT 'DNO connection size (kV)',
    DNOContact VARCHAR(255) COMMENT 'Primary DNO contact',
    DNOContact2 VARCHAR(255) COMMENT 'Secondary DNO contact',
    DNOContact3 VARCHAR(255) COMMENT 'Tertiary DNO contact',
    SiteReferenceNumber VARCHAR(255) COMMENT 'Site reference number',
    HVContractor VARCHAR(255) COMMENT 'HV contractor',
    
    -- Transformer Information
    TBootSub VARCHAR(255) COMMENT 'T-Boot/substation info',
    TransformerQuantity INTEGER COMMENT 'Number of transformers',
    TransformerMake VARCHAR(255) COMMENT 'Transformer manufacturer',
    TransformerModel VARCHAR(255) COMMENT 'Transformer model',
    TransformerRatingKVA INTEGER COMMENT 'Transformer rating (kVA)',
    
    -- Security & Access
    Security VARCHAR(255) COMMENT 'Security system info',
    SecurityCodes TEXT COMMENT 'Security codes',
    SiteAccessDetails TEXT COMMENT 'Site access instructions',
    AccessGateCodes TEXT COMMENT 'Gate access codes',
    ExportMeterLocation VARCHAR(255) COMMENT 'Export meter location',
    ExportMeterAccessDetails TEXT COMMENT 'Export meter access details',
    
    -- Additional
    Supervisor VARCHAR(255) COMMENT 'Site supervisor (email/username)',
    OtherInformation TEXT COMMENT 'Other information',
    Notes TEXT COMMENT 'Additional notes (HTML supported)',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE Locations IS 'Solar plant locations with comprehensive specifications';
CREATE INDEX idx_locations_code ON Locations(Code) WHERE Code IS NOT NULL;
CREATE INDEX idx_locations_account ON Locations(AccountID);
CREATE INDEX idx_locations_country ON Locations(CountryID);
CREATE INDEX idx_locations_dno ON Locations(DNOGridOperatorID);
CREATE INDEX idx_locations_stage ON Locations(Stage);
CREATE INDEX idx_locations_active ON Locations(Active);

-- Location Zones (Multi-Value Relationship Table)
CREATE TABLE LocationZones (
    LocationID INTEGER NOT NULL REFERENCES Locations(ID) ON DELETE CASCADE,
    ZoneID INTEGER NOT NULL REFERENCES Locations(ID) ON DELETE CASCADE,
    PRIMARY KEY (LocationID, ZoneID)
);
COMMENT ON TABLE LocationZones IS 'Many-to-many relationship for location zones';
CREATE INDEX idx_locationzones_location ON LocationZones(LocationID);
CREATE INDEX idx_locationzones_zone ON LocationZones(ZoneID);

-- Sections Table
CREATE TABLE Sections (
    ID SERIAL PRIMARY KEY,
    Title VARCHAR(255) NOT NULL COMMENT 'Section name',
    LocationID INTEGER REFERENCES Locations(ID) ON DELETE CASCADE COMMENT 'Parent location',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE Sections IS 'Sub-sections within locations';
CREATE INDEX idx_sections_location ON Sections(LocationID);
CREATE INDEX idx_sections_active ON Sections(Active);

-- Warehouses Table
CREATE TABLE Warehouses (
    ID SERIAL PRIMARY KEY,
    Title VARCHAR(255) NOT NULL COMMENT 'Warehouse name',
    LocationID INTEGER REFERENCES Locations(ID) ON DELETE SET NULL COMMENT 'Warehouse location',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE Warehouses IS 'Warehouse/storage locations';
CREATE INDEX idx_warehouses_location ON Warehouses(LocationID);

-- =====================================================================================
-- INVENTORY TABLES (Wave 2)
-- =====================================================================================

-- Equipment Table
CREATE TABLE Equipment (
    ID SERIAL PRIMARY KEY,
    Code VARCHAR(255) UNIQUE COMMENT 'Unique equipment code',
    Title VARCHAR(255) NOT NULL COMMENT 'Equipment name',
    CategoryID INTEGER REFERENCES EquipmentCategories(ID) ON DELETE SET NULL COMMENT 'Equipment category',
    Description TEXT COMMENT 'Equipment description (HTML supported)',
    ManufacturerID VARCHAR(255) COMMENT 'Manufacturer part number',
    ManufacturerOrBrandID INTEGER REFERENCES ManufacturerBrands(ID) ON DELETE SET NULL COMMENT 'Manufacturer reference',
    SupplierID INTEGER REFERENCES Suppliers(ID) ON DELETE SET NULL COMMENT 'Supplier reference',
    StockManagement BOOLEAN DEFAULT TRUE COMMENT 'Enable stock management',
    Photo VARCHAR(255) COMMENT 'Photo file reference',
    URL VARCHAR(2083) COMMENT 'Equipment URL/datasheet',
    Notes TEXT COMMENT 'Additional notes (HTML supported)',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    CategoryType VARCHAR(255) COMMENT 'Calculated category type',
    Serial BOOLEAN DEFAULT FALSE COMMENT 'Serial number tracking enabled',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE Equipment IS 'Equipment master data (non-consumable items)';
CREATE INDEX idx_equipment_code ON Equipment(Code) WHERE Code IS NOT NULL;
CREATE INDEX idx_equipment_category ON Equipment(CategoryID);
CREATE INDEX idx_equipment_manufacturer ON Equipment(ManufacturerOrBrandID);
CREATE INDEX idx_equipment_supplier ON Equipment(SupplierID);
CREATE INDEX idx_equipment_active ON Equipment(Active);
CREATE INDEX idx_equipment_serial ON Equipment(Serial);

-- Parts Table
CREATE TABLE Parts (
    ID SERIAL PRIMARY KEY,
    Code VARCHAR(255) UNIQUE COMMENT 'Unique part code',
    Title VARCHAR(255) NOT NULL COMMENT 'Part name',
    CategoryID INTEGER REFERENCES PartsCategories(ID) ON DELETE SET NULL COMMENT 'Part category',
    Description TEXT COMMENT 'Part description (HTML supported)',
    Barcode VARCHAR(255) UNIQUE COMMENT 'Barcode',
    UPC VARCHAR(255) UNIQUE COMMENT 'UPC code',
    ManufacturerID VARCHAR(255) COMMENT 'Manufacturer part number',
    ManufacturerOrBrandID INTEGER REFERENCES ManufacturerBrands(ID) ON DELETE SET NULL COMMENT 'Manufacturer reference',
    SupplierID INTEGER REFERENCES Suppliers(ID) ON DELETE SET NULL COMMENT 'Supplier reference',
    StockManagement BOOLEAN DEFAULT TRUE COMMENT 'Enable stock management',
    Consumable BOOLEAN DEFAULT TRUE COMMENT 'Consumable item flag',
    Photo VARCHAR(255) COMMENT 'Photo file reference',
    URL VARCHAR(2083) COMMENT 'Part URL/datasheet',
    MinQTY NUMERIC(10,0) COMMENT 'Minimum quantity threshold',
    Notes TEXT COMMENT 'Additional notes',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE Parts IS 'Parts master data (consumable items)';
CREATE INDEX idx_parts_code ON Parts(Code) WHERE Code IS NOT NULL;
CREATE INDEX idx_parts_barcode ON Parts(Barcode) WHERE Barcode IS NOT NULL;
CREATE INDEX idx_parts_upc ON Parts(UPC) WHERE UPC IS NOT NULL;
CREATE INDEX idx_parts_category ON Parts(CategoryID);
CREATE INDEX idx_parts_manufacturer ON Parts(ManufacturerOrBrandID);
CREATE INDEX idx_parts_supplier ON Parts(SupplierID);
CREATE INDEX idx_parts_active ON Parts(Active);

-- Assets Table
CREATE TABLE Assets (
    ID SERIAL PRIMARY KEY,
    Code VARCHAR(255) UNIQUE COMMENT 'Unique asset code',
    Title VARCHAR(255) NOT NULL COMMENT 'Asset name',
    CategoryID INTEGER REFERENCES AssetsCategories(ID) ON DELETE SET NULL COMMENT 'Asset category',
    Description TEXT COMMENT 'Asset description (HTML supported)',
    LocationID INTEGER REFERENCES Locations(ID) ON DELETE SET NULL COMMENT 'Asset location',
    SectionID INTEGER REFERENCES Sections(ID) ON DELETE SET NULL COMMENT 'Asset section',
    SerialNumber VARCHAR(255) COMMENT 'Serial number',
    ManufacturerOrBrandID INTEGER REFERENCES ManufacturerBrands(ID) ON DELETE SET NULL COMMENT 'Manufacturer reference',
    InstallationDate DATE COMMENT 'Installation date',
    WarrantyExpiry DATE COMMENT 'Warranty expiration date',
    Notes TEXT COMMENT 'Additional notes (HTML supported)',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE Assets IS 'Asset tracking (installed equipment)';
CREATE INDEX idx_assets_code ON Assets(Code) WHERE Code IS NOT NULL;
CREATE INDEX idx_assets_category ON Assets(CategoryID);
CREATE INDEX idx_assets_location ON Assets(LocationID);
CREATE INDEX idx_assets_section ON Assets(SectionID);
CREATE INDEX idx_assets_manufacturer ON Assets(ManufacturerOrBrandID);
CREATE INDEX idx_assets_active ON Assets(Active);

-- Equipment Serial Tracking
CREATE TABLE EquipmentSerial (
    ID SERIAL PRIMARY KEY,
    Title VARCHAR(255) UNIQUE NOT NULL COMMENT 'Serial number',
    EquipmentID INTEGER REFERENCES Equipment(ID) ON DELETE CASCADE COMMENT 'Equipment reference',
    LocationID INTEGER REFERENCES Locations(ID) ON DELETE SET NULL COMMENT 'Current location',
    SectionID INTEGER REFERENCES Sections(ID) ON DELETE SET NULL COMMENT 'Current section',
    InstallationDate DATE COMMENT 'Installation date',
    Status VARCHAR(50) DEFAULT 'Active' COMMENT 'Serial status' CHECK (Status IN ('Active', 'Inactive', 'Maintenance', 'Retired')),
    Notes TEXT COMMENT 'Additional notes',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE EquipmentSerial IS 'Serial number tracking for equipment';
CREATE INDEX idx_equipmentserial_equipment ON EquipmentSerial(EquipmentID);
CREATE INDEX idx_equipmentserial_location ON EquipmentSerial(LocationID);
CREATE INDEX idx_equipmentserial_section ON EquipmentSerial(SectionID);
CREATE INDEX idx_equipmentserial_status ON EquipmentSerial(Status);

-- =====================================================================================
-- WAREHOUSE & STOCK MANAGEMENT TABLES (Wave 3)
-- =====================================================================================

-- Equipment to Warehouse (Stock Levels)
CREATE TABLE EquipmentToWarehouse (
    ID SERIAL PRIMARY KEY,
    Title VARCHAR(255) NOT NULL COMMENT 'Reference title',
    EquipmentID INTEGER REFERENCES Equipment(ID) ON DELETE CASCADE COMMENT 'Equipment reference',
    WarehouseID INTEGER REFERENCES Warehouses(ID) ON DELETE CASCADE COMMENT 'Warehouse reference',
    Quantity NUMERIC(10,0) COMMENT 'Current quantity',
    MinQuantity NUMERIC(10,0) COMMENT 'Minimum quantity threshold',
    Notes TEXT COMMENT 'Additional notes',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE EquipmentToWarehouse IS 'Equipment stock levels by warehouse';
CREATE INDEX idx_equipmenttowarehouse_equipment ON EquipmentToWarehouse(EquipmentID);
CREATE INDEX idx_equipmenttowarehouse_warehouse ON EquipmentToWarehouse(WarehouseID);

-- Warehouse Equipment Serial
CREATE TABLE WarehouseEquipmentSerial (
    ID SERIAL PRIMARY KEY,
    Title VARCHAR(255) NOT NULL COMMENT 'Reference title',
    EquipmentID INTEGER REFERENCES Equipment(ID) ON DELETE CASCADE COMMENT 'Equipment reference',
    WarehouseID INTEGER REFERENCES Warehouses(ID) ON DELETE CASCADE COMMENT 'Warehouse reference',
    SerialNumber VARCHAR(255) UNIQUE COMMENT 'Serial number',
    Status VARCHAR(50) DEFAULT 'In Stock' COMMENT 'Status' CHECK (Status IN ('In Stock', 'In Use', 'Maintenance', 'Disposed')),
    Notes TEXT COMMENT 'Additional notes',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE WarehouseEquipmentSerial IS 'Serial number tracking in warehouses';
CREATE INDEX idx_warehouseequipmentserial_equipment ON WarehouseEquipmentSerial(EquipmentID);
CREATE INDEX idx_warehouseequipmentserial_warehouse ON WarehouseEquipmentSerial(WarehouseID);
CREATE INDEX idx_warehouseequipmentserial_serial ON WarehouseEquipmentSerial(SerialNumber) WHERE SerialNumber IS NOT NULL;
CREATE INDEX idx_warehouseequipmentserial_status ON WarehouseEquipmentSerial(Status);

-- Warehouse To Location Mapping
CREATE TABLE WarehouseToLocation (
    ID SERIAL PRIMARY KEY,
    Title VARCHAR(255) NOT NULL COMMENT 'Mapping title',
    WarehouseID INTEGER REFERENCES Warehouses(ID) ON DELETE CASCADE COMMENT 'Warehouse reference',
    LocationID INTEGER REFERENCES Locations(ID) ON DELETE CASCADE COMMENT 'Location reference',
    Description TEXT COMMENT 'Mapping description',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE WarehouseToLocation IS 'Warehouse-to-location relationships';
CREATE INDEX idx_warehousetolocation_warehouse ON WarehouseToLocation(WarehouseID);
CREATE INDEX idx_warehousetolocation_location ON WarehouseToLocation(LocationID);

-- Parts Transaction
CREATE TABLE PartsTransaction (
    ID SERIAL PRIMARY KEY,
    Title VARCHAR(255) NOT NULL COMMENT 'Transaction title',
    PartID INTEGER REFERENCES Parts(ID) ON DELETE CASCADE COMMENT 'Part reference',
    TransactionType VARCHAR(50) COMMENT 'Transaction type' CHECK (TransactionType IN ('In', 'Out', 'Transfer', 'Adjustment')),
    Quantity NUMERIC(10,0) COMMENT 'Transaction quantity',
    FromWarehouseID INTEGER REFERENCES Warehouses(ID) ON DELETE SET NULL COMMENT 'Source warehouse',
    ToWarehouseID INTEGER REFERENCES Warehouses(ID) ON DELETE SET NULL COMMENT 'Destination warehouse',
    TransactionDate DATE DEFAULT CURRENT_DATE COMMENT 'Transaction date',
    Notes TEXT COMMENT 'Transaction notes',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE PartsTransaction IS 'Parts inventory transactions';
CREATE INDEX idx_partstransaction_part ON PartsTransaction(PartID);
CREATE INDEX idx_partstransaction_fromwarehouse ON PartsTransaction(FromWarehouseID);
CREATE INDEX idx_partstransaction_towarehouse ON PartsTransaction(ToWarehouseID);
CREATE INDEX idx_partstransaction_date ON PartsTransaction(TransactionDate);
CREATE INDEX idx_partstransaction_type ON PartsTransaction(TransactionType);

-- Stock Adjustments
CREATE TABLE StockAdjustments (
    ID SERIAL PRIMARY KEY,
    Title VARCHAR(255) NOT NULL COMMENT 'Adjustment title',
    ItemType VARCHAR(50) COMMENT 'Item type' CHECK (ItemType IN ('Part', 'Equipment')),
    PartID INTEGER REFERENCES Parts(ID) ON DELETE SET NULL COMMENT 'Part reference (if applicable)',
    EquipmentID INTEGER REFERENCES Equipment(ID) ON DELETE SET NULL COMMENT 'Equipment reference (if applicable)',
    WarehouseID INTEGER REFERENCES Warehouses(ID) ON DELETE CASCADE COMMENT 'Warehouse reference',
    AdjustmentType VARCHAR(50) COMMENT 'Adjustment type' CHECK (AdjustmentType IN ('Increase', 'Decrease', 'Recount')),
    Quantity NUMERIC(10,0) COMMENT 'Adjustment quantity',
    AdjustmentDate DATE DEFAULT CURRENT_DATE COMMENT 'Adjustment date',
    Reason TEXT COMMENT 'Adjustment reason',
    Notes TEXT COMMENT 'Additional notes',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE StockAdjustments IS 'Inventory adjustments (corrections, recounts)';
CREATE INDEX idx_stockadjustments_itemtype ON StockAdjustments(ItemType);
CREATE INDEX idx_stockadjustments_part ON StockAdjustments(PartID);
CREATE INDEX idx_stockadjustments_equipment ON StockAdjustments(EquipmentID);
CREATE INDEX idx_stockadjustments_warehouse ON StockAdjustments(WarehouseID);
CREATE INDEX idx_stockadjustments_date ON StockAdjustments(AdjustmentDate);

-- Equipment Transaction (Complex - 22 columns)
CREATE TABLE EquipmentTransaction (
    ID SERIAL PRIMARY KEY,
    Title VARCHAR(255) NOT NULL COMMENT 'Transaction title',
    Warehouse VARCHAR(255) COMMENT 'Warehouse name (legacy)',
    TaskType VARCHAR(50) COMMENT 'Task type' CHECK (TaskType IN ('Choice', 'Corrective', 'Preventative', 'Repower', 'Service')),
    JobID VARCHAR(255) COMMENT 'Job identifier',
    HandlingDate DATE DEFAULT CURRENT_DATE COMMENT 'Handling date',
    RecordType VARCHAR(50) DEFAULT 'In' COMMENT 'Record type' CHECK (RecordType IN ('In', 'Out')),
    Reason VARCHAR(50) COMMENT 'Transaction reason' CHECK (Reason IN ('Failure', 'Move', 'Install', 'Uninstall', 'Service', 'Other')),
    ToWarehouse VARCHAR(255) COMMENT 'Destination warehouse (legacy)',
    Quantity NUMERIC(10,2) NOT NULL COMMENT 'Transaction quantity',
    CurrentQuantity NUMERIC(10,2) COMMENT 'Current quantity after transaction',
    EquipmentId VARCHAR(255) COMMENT 'Equipment identifier',
    LocationID INTEGER REFERENCES Locations(ID) ON DELETE SET NULL COMMENT 'Location reference',
    CategoryID INTEGER REFERENCES EquipmentCategories(ID) ON DELETE SET NULL COMMENT 'Category reference',
    WarehouseLocationID VARCHAR(255) COMMENT 'Warehouse location ID (legacy)',
    LocationId VARCHAR(255) COMMENT 'Location ID (legacy)',
    toWarehouseLocationID VARCHAR(255) COMMENT 'To warehouse location ID (legacy)',
    WarehouseID VARCHAR(255) COMMENT 'Warehouse ID (legacy)',
    toWarehouseID VARCHAR(255) COMMENT 'To warehouse ID (legacy)',
    EquipmentWarehouseID VARCHAR(255) COMMENT 'Equipment warehouse ID (legacy)',
    quid VARCHAR(255) COMMENT 'Unique identifier',
    Serial BOOLEAN DEFAULT FALSE COMMENT 'Serial tracking flag',
    SerialNotes VARCHAR(255) COMMENT 'Serial number notes',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE EquipmentTransaction IS 'Equipment movement and transaction tracking';
CREATE INDEX idx_equipmenttransaction_location ON EquipmentTransaction(LocationID);
CREATE INDEX idx_equipmenttransaction_category ON EquipmentTransaction(CategoryID);
CREATE INDEX idx_equipmenttransaction_date ON EquipmentTransaction(HandlingDate);
CREATE INDEX idx_equipmenttransaction_type ON EquipmentTransaction(TaskType);
CREATE INDEX idx_equipmenttransaction_recordtype ON EquipmentTransaction(RecordType);

-- Tracking Serial
CREATE TABLE TrackingSerial (
    ID SERIAL PRIMARY KEY,
    TRID VARCHAR(255) COMMENT 'Tracking ID',
    EID VARCHAR(255) COMMENT 'Equipment ID',
    Guid VARCHAR(255) COMMENT 'Global unique identifier',
    WID VARCHAR(255) COMMENT 'Warehouse ID',
    WarehouseID INTEGER REFERENCES Warehouses(ID) ON DELETE SET NULL COMMENT 'Warehouse reference',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE TrackingSerial IS 'Serial number tracking records';
CREATE INDEX idx_trackingserial_warehouse ON TrackingSerial(WarehouseID);
CREATE INDEX idx_trackingserial_guid ON TrackingSerial(Guid);

-- =====================================================================================
-- LOCATION CONFIGURATION TABLES (Wave 3)
-- =====================================================================================

-- Location Configuration
CREATE TABLE LocationConfiguration (
    ID SERIAL PRIMARY KEY,
    Title VARCHAR(255) NOT NULL COMMENT 'Configuration title',
    LocationID INTEGER REFERENCES Locations(ID) ON DELETE CASCADE COMMENT 'Location reference',
    ItemTypeID INTEGER REFERENCES LocationConfigurationItemTypes(ID) ON DELETE SET NULL COMMENT 'Item type reference',
    Quantity NUMERIC(10,0) COMMENT 'Item quantity',
    Description TEXT COMMENT 'Configuration description',
    Notes TEXT COMMENT 'Additional notes (HTML supported)',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE LocationConfiguration IS 'Location-specific configuration items';
CREATE INDEX idx_locationconfiguration_location ON LocationConfiguration(LocationID);
CREATE INDEX idx_locationconfiguration_itemtype ON LocationConfiguration(ItemTypeID);
CREATE INDEX idx_locationconfiguration_active ON LocationConfiguration(Active);

-- =====================================================================================
-- MAINTENANCE & TASK TABLES (Wave 3)
-- =====================================================================================

-- Corrective Tasks (Template)
CREATE TABLE CorrectiveTasks (
    ID SERIAL PRIMARY KEY,
    Code VARCHAR(255) UNIQUE COMMENT 'Unique task code',
    Title VARCHAR(255) NOT NULL COMMENT 'Task name',
    Description VARCHAR(255) COMMENT 'Task description',
    CategoryID INTEGER REFERENCES CorrectiveTaskCategories(ID) ON DELETE SET NULL COMMENT 'Task category',
    OMCategoryID INTEGER REFERENCES OMCategories(ID) ON DELETE SET NULL COMMENT 'O&M category',
    Frequency VARCHAR(50) DEFAULT 'As needed' COMMENT 'Task frequency' CHECK (Frequency IN ('As needed', '2 years')),
    MaintenanceTeamCategoryID INTEGER REFERENCES MaintenanceTeamCategories(ID) ON DELETE SET NULL COMMENT 'Team category',
    WarrantyType VARCHAR(50) DEFAULT 'N/A' COMMENT 'Warranty type' CHECK (WarrantyType IN ('N/A', 'EPC', 'Inverter', 'Module (Product)', 'Monitoring')),
    ApplicableUnit VARCHAR(50) COMMENT 'Applicable unit' CHECK (ApplicableUnit IN ('Acres', 'Block', 'Combiner Box', 'Inverter', 'Module', 'MW', 'Site', 'String', 'Tracker', 'Transformer')),
    Notes TEXT COMMENT 'Additional notes (HTML supported)',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE CorrectiveTasks IS 'Corrective task templates';
CREATE INDEX idx_correctivetasks_code ON CorrectiveTasks(Code) WHERE Code IS NOT NULL;
CREATE INDEX idx_correctivetasks_category ON CorrectiveTasks(CategoryID);
CREATE INDEX idx_correctivetasks_omcategory ON CorrectiveTasks(OMCategoryID);
CREATE INDEX idx_correctivetasks_teamcategory ON CorrectiveTasks(MaintenanceTeamCategoryID);
CREATE INDEX idx_correctivetasks_active ON CorrectiveTasks(Active);

-- Corrective Events
CREATE TABLE CorrectiveEvents (
    ID SERIAL PRIMARY KEY,
    Code VARCHAR(255) UNIQUE COMMENT 'Unique event code',
    Title VARCHAR(255) NOT NULL COMMENT 'Event title',
    LocationID INTEGER REFERENCES Locations(ID) ON DELETE SET NULL COMMENT 'Location reference',
    CategoryID INTEGER REFERENCES CorrectiveTaskCategories(ID) ON DELETE SET NULL COMMENT 'Event category',
    Description TEXT COMMENT 'Event description (HTML supported)',
    Priority VARCHAR(50) DEFAULT 'Normal' COMMENT 'Priority' CHECK (Priority IN ('Critical', 'High', 'Normal', 'Low')),
    Status VARCHAR(50) DEFAULT 'Reported' COMMENT 'Event status' CHECK (Status IN ('Reported', 'In Progress', 'Completed', 'Cancelled')),
    ReportedDate DATE DEFAULT CURRENT_DATE COMMENT 'Reported date',
    DueDate DATE COMMENT 'Due date',
    AssignedTeamID INTEGER REFERENCES MaintenanceTeams(ID) ON DELETE SET NULL COMMENT 'Assigned team',
    AssignedTo TEXT COMMENT 'Assigned persons (email/username - multi-value)',
    Notes TEXT COMMENT 'Additional notes (HTML supported)',
    CompletedDate DATE COMMENT 'Completion date',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE CorrectiveEvents IS 'Corrective maintenance events (work orders)';
CREATE INDEX idx_correctiveevents_code ON CorrectiveEvents(Code) WHERE Code IS NOT NULL;
CREATE INDEX idx_correctiveevents_location ON CorrectiveEvents(LocationID);
CREATE INDEX idx_correctiveevents_category ON CorrectiveEvents(CategoryID);
CREATE INDEX idx_correctiveevents_priority ON CorrectiveEvents(Priority);
CREATE INDEX idx_correctiveevents_status ON CorrectiveEvents(Status);
CREATE INDEX idx_correctiveevents_team ON CorrectiveEvents(AssignedTeamID);
CREATE INDEX idx_correctiveevents_reported ON CorrectiveEvents(ReportedDate);
CREATE INDEX idx_correctiveevents_due ON CorrectiveEvents(DueDate);

-- Sub Corrective Event
CREATE TABLE SubCorrectiveEvent (
    ID SERIAL PRIMARY KEY,
    Title VARCHAR(255) NOT NULL COMMENT 'Subtask title',
    CorrectiveEventID INTEGER REFERENCES CorrectiveEvents(ID) ON DELETE CASCADE COMMENT 'Parent event',
    CategoryID INTEGER REFERENCES CorrectiveTaskCategories(ID) ON DELETE SET NULL COMMENT 'Subtask category',
    Description TEXT COMMENT 'Subtask description (HTML supported)',
    Priority VARCHAR(50) DEFAULT 'Normal' COMMENT 'Priority' CHECK (Priority IN ('High', 'Normal', 'Low')),
    Status VARCHAR(50) DEFAULT 'Open' COMMENT 'Subtask status' CHECK (Status IN ('Open', 'In Progress', 'Completed', 'Cancelled')),
    AssignedTo TEXT COMMENT 'Assigned persons (email/username - multi-value)',
    DueDate DATE COMMENT 'Due date',
    Notes TEXT COMMENT 'Additional notes (HTML supported)',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE SubCorrectiveEvent IS 'Sub-tasks for corrective events';
CREATE INDEX idx_subcorrectiveevent_parent ON SubCorrectiveEvent(CorrectiveEventID);
CREATE INDEX idx_subcorrectiveevent_category ON SubCorrectiveEvent(CategoryID);
CREATE INDEX idx_subcorrectiveevent_status ON SubCorrectiveEvent(Status);
CREATE INDEX idx_subcorrectiveevent_due ON SubCorrectiveEvent(DueDate);

-- Preventive Plan
CREATE TABLE PreventivePlan (
    ID SERIAL PRIMARY KEY,
    Code VARCHAR(255) UNIQUE COMMENT 'Unique plan code',
    Title VARCHAR(255) NOT NULL COMMENT 'Plan name',
    LocationID INTEGER REFERENCES Locations(ID) ON DELETE SET NULL COMMENT 'Location reference',
    Description TEXT COMMENT 'Plan description (HTML supported)',
    Frequency VARCHAR(50) COMMENT 'Maintenance frequency' CHECK (Frequency IN ('Daily', 'Weekly', 'Monthly', 'Quarterly', 'Semi-Annual', 'Annual')),
    StartDate DATE COMMENT 'Plan start date',
    NextDueDate DATE COMMENT 'Next scheduled date',
    AssignedTeamID INTEGER REFERENCES MaintenanceTeams(ID) ON DELETE SET NULL COMMENT 'Assigned team',
    Notes TEXT COMMENT 'Additional notes (HTML supported)',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE PreventivePlan IS 'Preventive maintenance plans';
CREATE INDEX idx_preventiveplan_code ON PreventivePlan(Code) WHERE Code IS NOT NULL;
CREATE INDEX idx_preventiveplan_location ON PreventivePlan(LocationID);
CREATE INDEX idx_preventiveplan_team ON PreventivePlan(AssignedTeamID);
CREATE INDEX idx_preventiveplan_frequency ON PreventivePlan(Frequency);
CREATE INDEX idx_preventiveplan_nextdue ON PreventivePlan(NextDueDate);
CREATE INDEX idx_preventiveplan_active ON PreventivePlan(Active);

-- Preventive Tasks
CREATE TABLE PreventiveTasks (
    ID SERIAL PRIMARY KEY,
    Code VARCHAR(255) UNIQUE COMMENT 'Unique task code',
    Title VARCHAR(255) NOT NULL COMMENT 'Task name',
    PlanID INTEGER REFERENCES PreventivePlan(ID) ON DELETE CASCADE COMMENT 'Parent plan',
    CategoryID INTEGER REFERENCES PreventiveTaskCategories(ID) ON DELETE SET NULL COMMENT 'Task category',
    Description TEXT COMMENT 'Task description (HTML supported)',
    Status VARCHAR(50) DEFAULT 'Scheduled' COMMENT 'Task status' CHECK (Status IN ('Scheduled', 'In Progress', 'Completed', 'Skipped')),
    ScheduledDate DATE COMMENT 'Scheduled date',
    CompletedDate DATE COMMENT 'Completion date',
    AssignedTo TEXT COMMENT 'Assigned persons (email/username - multi-value)',
    Notes TEXT COMMENT 'Additional notes (HTML supported)',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE PreventiveTasks IS 'Individual preventive maintenance tasks';
CREATE INDEX idx_preventivetasks_code ON PreventiveTasks(Code) WHERE Code IS NOT NULL;
CREATE INDEX idx_preventivetasks_plan ON PreventiveTasks(PlanID);
CREATE INDEX idx_preventivetasks_category ON PreventiveTasks(CategoryID);
CREATE INDEX idx_preventivetasks_status ON PreventiveTasks(Status);
CREATE INDEX idx_preventivetasks_scheduled ON PreventiveTasks(ScheduledDate);

-- Tasks (General - with dependencies)
CREATE TABLE Tasks (
    ID SERIAL PRIMARY KEY,
    Title VARCHAR(255) NOT NULL COMMENT 'Task name',
    Priority VARCHAR(50) DEFAULT 'Normal' COMMENT 'Priority' CHECK (Priority IN ('High', 'Normal', 'Low')),
    Status VARCHAR(50) DEFAULT 'Not Started' COMMENT 'Task status' CHECK (Status IN ('Not Started', 'In Progress', 'Completed', 'Deferred', 'Waiting')),
    PercentComplete NUMERIC(5,2) DEFAULT 0 COMMENT 'Completion percentage' CHECK (PercentComplete >= 0 AND PercentComplete <= 100),
    AssignedTo TEXT COMMENT 'Assigned persons (email/username - multi-value)',
    TaskGroup VARCHAR(255) COMMENT 'Task group (email/username)',
    Description TEXT COMMENT 'Task description (HTML supported)',
    StartDate DATE DEFAULT CURRENT_DATE COMMENT 'Start date',
    DueDate DATE COMMENT 'Due date',
    RelatedItems VARCHAR(255) COMMENT 'Related items reference',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE Tasks IS 'General task management with dependencies';
CREATE INDEX idx_tasks_status ON Tasks(Status);
CREATE INDEX idx_tasks_priority ON Tasks(Priority);
CREATE INDEX idx_tasks_start ON Tasks(StartDate);
CREATE INDEX idx_tasks_due ON Tasks(DueDate);

-- Task Predecessors (Multi-Value Relationship Table)
CREATE TABLE TaskPredecessors (
    TaskID INTEGER NOT NULL REFERENCES Tasks(ID) ON DELETE CASCADE,
    PredecessorID INTEGER NOT NULL REFERENCES Tasks(ID) ON DELETE CASCADE,
    PRIMARY KEY (TaskID, PredecessorID),
    CHECK (TaskID != PredecessorID)
);
COMMENT ON TABLE TaskPredecessors IS 'Task dependency relationships';
CREATE INDEX idx_taskpredecessors_task ON TaskPredecessors(TaskID);
CREATE INDEX idx_taskpredecessors_predecessor ON TaskPredecessors(PredecessorID);

-- =====================================================================================
-- SERVICE & TEAM MANAGEMENT TABLES (Wave 3)
-- =====================================================================================

-- Service
CREATE TABLE Service (
    ID SERIAL PRIMARY KEY,
    Code VARCHAR(255) UNIQUE COMMENT 'Unique service code',
    Title VARCHAR(255) NOT NULL COMMENT 'Service name',
    Description TEXT COMMENT 'Service description (HTML supported)',
    CategoryID INTEGER REFERENCES OMCategories(ID) ON DELETE SET NULL COMMENT 'Service category',
    DefaultServiceCompanyID INTEGER REFERENCES ServiceCompanys(ID) ON DELETE SET NULL COMMENT 'Default service provider',
    UnitCost NUMERIC(10,2) COMMENT 'Unit cost',
    Notes TEXT COMMENT 'Additional notes (HTML supported)',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE Service IS 'Service catalog';
CREATE INDEX idx_service_code ON Service(Code) WHERE Code IS NOT NULL;
CREATE INDEX idx_service_category ON Service(CategoryID);
CREATE INDEX idx_service_servicecompany ON Service(DefaultServiceCompanyID);
CREATE INDEX idx_service_active ON Service(Active);

-- Service Order
CREATE TABLE ServiceOrder (
    ID SERIAL PRIMARY KEY,
    Title VARCHAR(255) UNIQUE NOT NULL COMMENT 'Order number',
    ServiceCompanyID INTEGER REFERENCES ServiceCompanys(ID) ON DELETE SET NULL COMMENT 'Service company',
    LocationID INTEGER REFERENCES Locations(ID) ON DELETE SET NULL COMMENT 'Service location',
    Description TEXT COMMENT 'Order description (HTML supported)',
    OrderDate DATE DEFAULT CURRENT_DATE COMMENT 'Order date',
    ScheduledDate DATE COMMENT 'Scheduled service date',
    Status VARCHAR(50) DEFAULT 'Draft' COMMENT 'Order status' CHECK (Status IN ('Draft', 'Ordered', 'In Progress', 'Completed', 'Cancelled')),
    Priority VARCHAR(50) DEFAULT 'Normal' COMMENT 'Priority' CHECK (Priority IN ('High', 'Normal', 'Low')),
    Notes TEXT COMMENT 'Additional notes (HTML supported)',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE ServiceOrder IS 'Service orders for external service providers';
CREATE INDEX idx_serviceorder_servicecompany ON ServiceOrder(ServiceCompanyID);
CREATE INDEX idx_serviceorder_location ON ServiceOrder(LocationID);
CREATE INDEX idx_serviceorder_status ON ServiceOrder(Status);
CREATE INDEX idx_serviceorder_orderdate ON ServiceOrder(OrderDate);
CREATE INDEX idx_serviceorder_scheduled ON ServiceOrder(ScheduledDate);

-- Maintenance Team Members
CREATE TABLE MaintenanceTeamMembers (
    ID SERIAL PRIMARY KEY,
    Title VARCHAR(255) NOT NULL COMMENT 'Member reference title',
    MaintenanceTeamID INTEGER REFERENCES MaintenanceTeams(ID) ON DELETE CASCADE COMMENT 'Team reference',
    Member VARCHAR(255) COMMENT 'Member (email/username)',
    Role VARCHAR(50) COMMENT 'Member role' CHECK (Role IN ('Team Leader', 'Technician', 'Helper', 'Supervisor')),
    StartDate DATE COMMENT 'Membership start date',
    EndDate DATE COMMENT 'Membership end date',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE MaintenanceTeamMembers IS 'Team membership records';
CREATE INDEX idx_maintenanceteammembers_team ON MaintenanceTeamMembers(MaintenanceTeamID);
CREATE INDEX idx_maintenanceteammembers_role ON MaintenanceTeamMembers(Role);
CREATE INDEX idx_maintenanceteammembers_active ON MaintenanceTeamMembers(Active);

-- Maintenance Team Per Location
CREATE TABLE MaintenanceTeamPerLocation (
    ID SERIAL PRIMARY KEY,
    Title VARCHAR(255) NOT NULL COMMENT 'Assignment reference title',
    MaintenanceTeamID INTEGER REFERENCES MaintenanceTeams(ID) ON DELETE CASCADE COMMENT 'Team reference',
    LocationID INTEGER REFERENCES Locations(ID) ON DELETE CASCADE COMMENT 'Location reference',
    StartDate DATE COMMENT 'Assignment start date',
    EndDate DATE COMMENT 'Assignment end date',
    Active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE MaintenanceTeamPerLocation IS 'Team-to-location assignments';
CREATE INDEX idx_maintenanceteamperlocation_team ON MaintenanceTeamPerLocation(MaintenanceTeamID);
CREATE INDEX idx_maintenanceteamperlocation_location ON MaintenanceTeamPerLocation(LocationID);
CREATE INDEX idx_maintenanceteamperlocation_active ON MaintenanceTeamPerLocation(Active);

-- =====================================================================================
-- DOCUMENT & MISCELLANEOUS TABLES (Wave 4)
-- =====================================================================================

-- Document Sets
CREATE TABLE DocumentSets (
    ID SERIAL PRIMARY KEY,
    Title VARCHAR(255) NOT NULL COMMENT 'Document set name',
    CategoryID INTEGER REFERENCES DocumentSetCategories(ID) ON DELETE SET NULL COMMENT 'Document category',
    Comments TEXT COMMENT 'Comments (HTML supported)',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE DocumentSets IS 'Document set management';
CREATE INDEX idx_documentsets_category ON DocumentSets(CategoryID);

-- Published Feed
CREATE TABLE PublishedFeed (
    ID SERIAL PRIMARY KEY,
    Title VARCHAR(255) NOT NULL COMMENT 'Feed title',
    Body TEXT COMMENT 'Feed body (HTML supported)',
    PublishedDate TIMESTAMP COMMENT 'Publication date',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE PublishedFeed IS 'Published news feed items';
CREATE INDEX idx_publishedfeed_published ON PublishedFeed(PublishedDate);

-- Site Collection Documents
CREATE TABLE SiteCollectionDocuments (
    ID SERIAL PRIMARY KEY,
    FileLeafRef VARCHAR(255) NOT NULL COMMENT 'File name',
    Title VARCHAR(255) COMMENT 'Document title',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE SiteCollectionDocuments IS 'Site-wide document library';

-- =====================================================================================
-- CREATE VIEWS FOR COMMON QUERIES
-- =====================================================================================

-- View: Current Equipment Stock Levels
CREATE VIEW vw_EquipmentStockLevels AS
SELECT 
    e.ID AS EquipmentID,
    e.Code AS EquipmentCode,
    e.Title AS EquipmentName,
    ec.Title AS CategoryName,
    w.Title AS WarehouseName,
    etw.Quantity,
    etw.MinQuantity,
    CASE WHEN etw.Quantity <= etw.MinQuantity THEN TRUE ELSE FALSE END AS BelowMinimum
FROM Equipment e
LEFT JOIN EquipmentCategories ec ON e.CategoryID = ec.ID
LEFT JOIN EquipmentToWarehouse etw ON e.ID = etw.EquipmentID
LEFT JOIN Warehouses w ON etw.WarehouseID = w.ID
WHERE e.Active = TRUE AND e.StockManagement = TRUE;

-- View: Active Corrective Events Summary
CREATE VIEW vw_ActiveCorrectiveEvents AS
SELECT 
    ce.ID,
    ce.Code,
    ce.Title,
    l.Title AS LocationName,
    ctc.Title AS CategoryName,
    ce.Priority,
    ce.Status,
    ce.ReportedDate,
    ce.DueDate,
    mt.Title AS AssignedTeam,
    CASE 
        WHEN ce.DueDate < CURRENT_DATE AND ce.Status NOT IN ('Completed', 'Cancelled') THEN TRUE 
        ELSE FALSE 
    END AS Overdue
FROM CorrectiveEvents ce
LEFT JOIN Locations l ON ce.LocationID = l.ID
LEFT JOIN CorrectiveTaskCategories ctc ON ce.CategoryID = ctc.ID
LEFT JOIN MaintenanceTeams mt ON ce.AssignedTeamID = mt.ID
WHERE ce.Status NOT IN ('Completed', 'Cancelled');

-- View: Location Summary
CREATE VIEW vw_LocationSummary AS
SELECT 
    l.ID,
    l.Code,
    l.Title,
    l.Stage,
    l.CapacityMW,
    a.Title AS AccountName,
    c.Title AS CountryName,
    l.Active,
    (SELECT COUNT(*) FROM Sections s WHERE s.LocationID = l.ID AND s.Active = TRUE) AS SectionCount,
    (SELECT COUNT(*) FROM Assets ast WHERE ast.LocationID = l.ID AND ast.Active = TRUE) AS AssetCount
FROM Locations l
LEFT JOIN Accounts a ON l.AccountID = a.ID
LEFT JOIN Countries c ON l.CountryID = c.ID;

-- =====================================================================================
-- GRANT PERMISSIONS (Adjust based on your role structure)
-- =====================================================================================

-- Example: Grant read-only access to reporting role
-- GRANT SELECT ON ALL TABLES IN SCHEMA public TO reporting_role;

-- Example: Grant full access to application role
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_role;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_role;

-- =====================================================================================
-- END OF SCHEMA
-- =====================================================================================
