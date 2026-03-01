export interface WeatherData {
  ghi: number;
  moduleTemp: number;
  ambientTemp: number;
  windSpeed: number;
  condition: 'Sunny' | 'Cloudy' | 'Rain' | 'Snow/Ice' | 'Sandstorm';
}

export interface Inverter {
  id: string;
  name: string;
  plotId: string; // New: Links the hardware to the map sector
  capacityKw: number;
  currentOutputKw: number;
  status: 'Online' | 'Offline' | 'Fault' | 'Maintenance';
  lastHeartbeat: string;
  efficiency: number; 
}

export type Priority = 'Critical' | 'High' | 'Medium' | 'Low';
export type TaskType = 'Preventive' | 'Corrective';
export type TaskStatus = 'Open' | 'Assigned' | 'In Progress' | 'Closed';

export interface WorkOrder {
  id: string;
  title: string;
  priority: Priority;
  type: TaskType;
  plotId: string; // The specific sector in the solar park (e.g., "BN-01")
  assignedTechnician: string;
  status: TaskStatus;
  dueDate: string;
}

export interface PlotStatus {
  id: string;
  hasCritical: boolean;
  hasWarning: boolean;
  taskCount: number;
}

export interface TeamMember {
  id: string;
  name: string;
  role: string;
  phone: string;
  email: string;
  status: 'On Site' | 'Remote' | 'Off Duty' | 'Deployed';
  department: 'Management' | 'Engineering' | 'Operations';
}