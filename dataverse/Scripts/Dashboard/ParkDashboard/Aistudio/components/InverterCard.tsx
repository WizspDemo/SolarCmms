import React from 'react';
import { Inverter } from '../types';
import { ProgressIndicator, Text, Icon } from '@fluentui/react';

interface InverterCardProps {
  inverter: Inverter;
  currentGhi: number;
}

export const InverterCard: React.FC<InverterCardProps> = ({ inverter, currentGhi }) => {
  // LOGIC: Derive the "Real" status based on physics, not just the reported string.
  const isGenerating = inverter.currentOutputKw > 0;
  const isHighIrradiance = currentGhi > 500;
  
  let visualStatus = 'Normal';
  let statusColor = 'text-green-600';
  let iconName = 'CheckMark';
  let description = 'Operating normally';

  if (inverter.status === 'Fault') {
    visualStatus = 'Grid Fault';
    statusColor = 'text-red-600';
    iconName = 'ErrorBadge';
    description = 'Immediate attention required';
  } else if (inverter.status === 'Maintenance') {
    visualStatus = 'Scheduled Maint.';
    statusColor = 'text-blue-600';
    iconName = 'Wrench';
    description = 'Technician on-site';
  } else if (isHighIrradiance && !isGenerating && inverter.status !== 'Offline') {
    // Logic: Sun is shining, but output is 0, and not in maintenance.
    visualStatus = 'Unexpected Shutdown';
    statusColor = 'text-red-600';
    iconName = 'Warning';
    description = 'Potential fuse blown or disconnect';
  } else if (isHighIrradiance && inverter.efficiency < 0.88 && isGenerating) {
    // Logic: Sun is shining, generating, but poorly (Derating scenario)
    visualStatus = 'Thermal Derating';
    statusColor = 'text-orange-500';
    iconName = 'SpeedHigh';
    description = 'Output limited by temperature';
  }

  return (
    <div className="bg-white p-3 rounded-md shadow-sm border-l-4 border-gray-200 hover:shadow-md transition-shadow mb-2 flex flex-col gap-2">
      <div className="flex justify-between items-center">
        <div>
            <Text variant="medium" className="font-semibold text-gray-700 block">{inverter.name}</Text>
            <Text variant="tiny" className="font-mono text-gray-400">LOC: {inverter.plotId}</Text>
        </div>
        <div className={`flex items-center gap-1 ${statusColor}`}>
          <Icon iconName={iconName} />
          <Text variant="small" className="font-bold">{visualStatus}</Text>
        </div>
      </div>
      
      <div className="flex justify-between items-end">
        <div className="flex flex-col">
            <Text variant="xSmall" className="text-gray-500">{description}</Text>
            <Text variant="large" className="font-mono text-slate-800 mt-1">
                {inverter.currentOutputKw.toFixed(1)} <span className="text-xs text-gray-500">kW</span>
            </Text>
        </div>
        <div className="flex flex-col items-end">
            <Text variant="xSmall" className="text-gray-400">Efficiency</Text>
            <Text variant="small" className={(inverter.efficiency < 0.8 && isGenerating) ? 'text-orange-500 font-bold' : 'text-gray-600'}>
                {(inverter.efficiency * 100).toFixed(0)}%
            </Text>
        </div>
      </div>
      
      <ProgressIndicator 
        percentComplete={inverter.currentOutputKw / inverter.capacityKw} 
        barHeight={4}
        className="w-full"
      />
    </div>
  );
};