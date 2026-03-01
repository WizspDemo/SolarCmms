import { WorkOrder, WeatherData, Inverter, TeamMember } from './types';

// SCENARIO: Benban Solar Park, Egypt. 11:30 AM.
// High Heat (43°C Ambient, 72°C Module) + Recent Sandstorm (Soiling).
// Result: High Irradiance but Lower Efficiency. Overheating faults in Sector 14.

export const MOCK_WEATHER: WeatherData = {
  ghi: 945, // High irradiance (Sun is directly overhead)
  moduleTemp: 72.4, // Extremely hot (efficiency loss)
  ambientTemp: 43.1, // Desert heat
  windSpeed: 4.2, // Low wind, poor cooling
  condition: 'Sunny' // Technically sunny, but atmosphere is dusty
};

export const MOCK_HOURLY_WEATHER = [
  { time: '12:00', icon: 'Sunny', temp: 44, ghi: 960, precip: 0 },
  { time: '13:00', icon: 'PartlyCloudyDay', temp: 45, ghi: 880, precip: 0 },
  { time: '14:00', icon: 'PartlyCloudyDay', temp: 44, ghi: 750, precip: 5 },
  { time: '15:00', icon: 'Cloudy', temp: 42, ghi: 400, precip: 15 },
];

export const MOCK_INVERTERS: Inverter[] = [
  // HEALTHY SECTOR (Reference)
  {
    id: 'INV-01',
    name: 'Inv Block 01-A',
    plotId: 'BN-01',
    capacityKw: 100,
    currentOutputKw: 84.5, // ~85% due to heat/soiling losses (Derating)
    status: 'Online',
    lastHeartbeat: '10s ago',
    efficiency: 0.89 // Degraded from 0.98 standard
  },
  // HEALTHY SECTOR
  {
    id: 'INV-02',
    name: 'Inv Block 02-A',
    plotId: 'BN-02',
    capacityKw: 100,
    currentOutputKw: 83.2,
    status: 'Online',
    lastHeartbeat: '12s ago',
    efficiency: 0.88
  },
  // FAULTY SECTOR (Overheating Cluster)
  {
    id: 'INV-14A',
    name: 'Inv Block 14-A',
    plotId: 'BN-14',
    capacityKw: 125,
    currentOutputKw: 0,
    status: 'Fault', // Correlated with WO-201
    lastHeartbeat: 'Offline',
    efficiency: 0
  },
  {
    id: 'INV-14B',
    name: 'Inv Block 14-B',
    plotId: 'BN-14',
    capacityKw: 125,
    currentOutputKw: 45.0, // Limp mode / Derated heavily
    status: 'Fault', // Correlated with WO-202
    lastHeartbeat: '1 min ago',
    efficiency: 0.36
  },
  // OFFLINE SECTOR (Grid Trip)
  {
    id: 'INV-15A',
    name: 'Inv Block 15-A',
    plotId: 'BN-15',
    capacityKw: 100,
    currentOutputKw: 0,
    status: 'Offline', // Correlated with WO-203
    lastHeartbeat: '5 mins ago',
    efficiency: 0
  },
  // MAINTENANCE SECTOR
  {
    id: 'INV-05A',
    name: 'Inv Block 05-A',
    plotId: 'BN-05',
    capacityKw: 100,
    currentOutputKw: 0,
    status: 'Maintenance',
    lastHeartbeat: 'Manual Stop',
    efficiency: 0
  }
];

export const MOCK_TASKS: WorkOrder[] = [
  // --- CRITICAL CORRECTIVE (Linked to Faulty Inverters) ---
  { 
    id: 'WO-201', 
    title: 'Inverter 14-A Thermal Shutdown', 
    priority: 'Critical', 
    type: 'Corrective', 
    plotId: 'BN-14', // Matches INV-14A
    assignedTechnician: 'Ahmed S.', 
    status: 'In Progress', 
    dueDate: '2024-03-24' 
  },
  { 
    id: 'WO-202', 
    title: 'Inverter 14-B Cooling Fan Fail', 
    priority: 'Critical', 
    type: 'Corrective', 
    plotId: 'BN-14', // Matches INV-14B
    assignedTechnician: 'Ahmed S.', 
    status: 'Open', 
    dueDate: '2024-03-24' 
  },
  { 
    id: 'WO-203', 
    title: 'Sector 15 MV Grid Trip', 
    priority: 'High', 
    type: 'Corrective', 
    plotId: 'BN-15', // Matches INV-15A
    assignedTechnician: 'Sarah J.', 
    status: 'Assigned', 
    dueDate: '2024-03-24' 
  },

  // --- PREVENTIVE (Post-Sandstorm Cleaning Campaign) ---
  { id: 'WO-301', title: 'Module Cleaning: Robot Deployment', priority: 'Medium', type: 'Preventive', plotId: 'BN-01', assignedTechnician: 'Auto-Clean Unit 1', status: 'In Progress', dueDate: '2024-03-25' },
  { id: 'WO-302', title: 'Module Cleaning: Manual', priority: 'Medium', type: 'Preventive', plotId: 'BN-02', assignedTechnician: 'Crew Alpha', status: 'Assigned', dueDate: '2024-03-25' },
  { id: 'WO-303', title: 'Module Cleaning: Manual', priority: 'Medium', type: 'Preventive', plotId: 'BN-03', assignedTechnician: 'Crew Beta', status: 'Open', dueDate: '2024-03-26' },
  { id: 'WO-304', title: 'Sand Removal: Combiner Boxes', priority: 'Low', type: 'Preventive', plotId: 'BN-04', assignedTechnician: 'Grounds', status: 'Open', dueDate: '2024-03-26' },
  
  // --- OTHER TASKS ---
  { id: 'WO-305', title: 'Substation A Filter Check', priority: 'Low', type: 'Preventive', plotId: 'BN-05', assignedTechnician: 'Mike R.', status: 'Closed', dueDate: '2024-03-20' },
  { id: 'WO-306', title: 'Perimeter Fence Inspection', priority: 'Low', type: 'Preventive', plotId: 'BN-19', assignedTechnician: 'Security', status: 'Closed', dueDate: '2024-03-21' },
];

export const MOCK_TEAM: TeamMember[] = [
  { id: 'TM-01', name: 'Dr. Layla Hassan', role: 'Plant Manager', phone: '+20 100 555 001', email: 'lhassan@benban-ops.com', status: 'On Site', department: 'Management' },
  { id: 'TM-02', name: 'Eng. Omar Khaled', role: 'Operations Director', phone: '+20 100 555 002', email: 'okhaled@benban-ops.com', status: 'Remote', department: 'Management' },
  { id: 'TM-03', name: 'Sarah Miller', role: 'Senior Electrical Engineer', phone: '+20 100 555 010', email: 'smiller@benban-ops.com', status: 'On Site', department: 'Engineering' },
  { id: 'TM-04', name: 'Ahmed S.', role: 'HV Technician Lead', phone: '+20 100 555 012', email: 'ahmed.s@benban-ops.com', status: 'Deployed', department: 'Operations' },
  { id: 'TM-05', name: 'Cleaning Crew A', role: 'Field Services', phone: '+20 100 555 050', email: 'dispatch.alpha@benban-ops.com', status: 'Deployed', department: 'Operations' },
];

// Generate Plot IDs for the map (BN-01 to BN-20)
export const PLOT_IDS = Array.from({ length: 20 }, (_, i) => {
  const num = i + 1;
  return `BN-${num < 10 ? '0' + num : num}`;
});