import React from 'react';
import { KpiData } from '../types';

export const KpiCard: React.FC<KpiData> = ({ title, value, unit, icon, color, trend }) => {
  return (
    <div className="bg-white p-6 rounded-md shadow-fluent-card hover:shadow-fluent-hover transition-shadow duration-200 border-l-4 border-brand-primary flex flex-col justify-between h-32 relative overflow-hidden group">
      
      {/* Background Decorator */}
      <div className="absolute top-0 right-0 p-4 opacity-5 group-hover:opacity-10 transition-opacity transform group-hover:scale-110 duration-500">
        {icon && React.cloneElement(icon as React.ReactElement, { size: 64 })}
      </div>

      <div className="flex justify-between items-start z-10">
        <h3 className="text-sm font-semibold text-gray-500 uppercase tracking-wide">{title}</h3>
        {icon && <div className="text-brand-primary opacity-80">{icon}</div>}
      </div>
      
      <div className="z-10 mt-2">
        <div className="flex items-baseline gap-2">
            <span className="text-3xl font-bold text-gray-900" style={{ color: color }}>{value}</span>
            {unit && <span className="text-sm font-medium text-gray-500">{unit}</span>}
        </div>
        
        {trend && (
           <div className="mt-1 flex items-center text-xs">
              {trend === 'up' && <span className="text-green-600 font-medium">▲</span>}
              {trend === 'down' && <span className="text-red-600 font-medium">▼</span>}
              {trend === 'neutral' && <span className="text-gray-400 font-medium">●</span>}
           </div>
        )}
      </div>
    </div>
  );
};