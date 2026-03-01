import React from 'react';

export interface SolarPark {
  id: string;
  name: string;
  location: {
    country: string;
    flag: string;
  };
  capacityMW: number;
  preventiveCount: number; // Open Preventive Tasks
  correctiveCount: number; // Active Corrective Tasks
  criticalDefects: number; // For Health Score calculation
}

export interface KpiData {
  title: string;
  value: string | number;
  unit?: string;
  icon?: React.ReactNode;
  trend?: 'up' | 'down' | 'neutral';
  trendValue?: string;
  color?: string; // Hex override for value
}