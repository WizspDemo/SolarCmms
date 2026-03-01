import React from 'react';
import { SolarPark } from '../types';
import { StatusBadge } from './StatusBadge';
import { ChevronRight, ExternalLink } from 'lucide-react';

interface PortfolioGridProps {
  data: SolarPark[];
}

export const PortfolioGrid: React.FC<PortfolioGridProps> = ({ data }) => {
  const handleOpenDashboard = (name: string) => {
    console.log(`Navigating to dashboard for: ${name}`);
    alert(`Opening detailed dashboard for ${name}...`);
  };

  return (
    <div className="bg-white rounded-md shadow-fluent-card border border-brand-border">
      <div className="p-4 border-b border-brand-border bg-gray-50 flex justify-between items-center">
        <h2 className="text-lg font-semibold text-brand-dark">Portfolio Assets</h2>
        <span className="text-xs text-gray-500 font-medium bg-white px-2 py-1 rounded border border-gray-200">
            Total Assets: {data.length}
        </span>
      </div>
      
      {/* Mobile View: Cards */}
      <div className="md:hidden divide-y divide-brand-border">
        {data.map((park) => (
          <div key={park.id} className="p-4 hover:bg-gray-50 transition-colors">
            <div className="flex justify-between items-start mb-3">
              <div>
                 <div 
                    className="font-bold text-brand-primary text-lg cursor-pointer" 
                    onClick={() => handleOpenDashboard(park.name)}
                 >
                    {park.name}
                 </div>
                 <div className="text-sm text-gray-600 flex items-center mt-1">
                    <span className="mr-2 text-base">{park.location.flag}</span>
                    {park.location.country}
                 </div>
              </div>
              <StatusBadge criticalDefects={park.criticalDefects} />
            </div>

            <div className="grid grid-cols-2 gap-4 mb-4 text-sm">
                <div className="bg-gray-50 p-2 rounded border border-gray-100">
                    <div className="text-gray-500 text-xs uppercase tracking-wide">Capacity</div>
                    <div className="font-mono font-medium">{park.capacityMW} MW</div>
                </div>
                <div className="bg-gray-50 p-2 rounded border border-gray-100">
                     <div className="text-gray-500 text-xs uppercase tracking-wide">Corrective</div>
                     {park.correctiveCount > 0 ? (
                        <div className="text-orange-700 font-semibold">{park.correctiveCount} Active</div>
                     ) : (
                        <div className="text-gray-400">-</div>
                     )}
                </div>
            </div>

            <div className="flex items-center justify-between">
                 <span className="inline-block px-2 py-1 text-xs font-semibold text-blue-700 bg-blue-50 rounded border border-blue-100">
                     {park.preventiveCount} Preventive Tasks
                 </span>
                 <button 
                    onClick={() => handleOpenDashboard(park.name)}
                    className="flex items-center text-sm font-medium text-brand-primary hover:text-brand-dark"
                 >
                    Dashboard <ChevronRight size={16} />
                 </button>
            </div>
          </div>
        ))}
      </div>

      {/* Desktop/Tablet View: Table */}
      <div className="hidden md:block overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="bg-white border-b border-brand-border text-sm text-gray-500">
              <th className="py-3 px-4 font-semibold w-1/4">Park Name</th>
              <th className="py-3 px-4 font-semibold">Location</th>
              <th className="py-3 px-4 font-semibold text-right">Capacity</th>
              <th className="py-3 px-4 font-semibold text-center">Prev. Tasks</th>
              <th className="py-3 px-4 font-semibold text-center">Crit. Tasks</th>
              <th className="py-3 px-4 font-semibold">Health Score</th>
              <th className="py-3 px-4 font-semibold text-right">Action</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-brand-border">
            {data.map((park) => (
              <tr 
                key={park.id} 
                className="hover:bg-gray-50 transition-colors duration-150 group cursor-default"
              >
                <td className="py-3 px-4">
                    <div className="font-bold text-brand-primary group-hover:underline cursor-pointer" onClick={() => handleOpenDashboard(park.name)}>
                        {park.name}
                    </div>
                </td>
                <td className="py-3 px-4 text-sm text-gray-700">
                  <span className="mr-2 text-lg">{park.location.flag}</span>
                  {park.location.country}
                </td>
                <td className="py-3 px-4 text-sm text-gray-900 font-medium text-right font-mono">
                  {park.capacityMW} <span className="text-gray-500 text-xs">MW</span>
                </td>
                <td className="py-3 px-4 text-center">
                    <span className="inline-block px-2 py-1 text-xs font-semibold text-blue-700 bg-blue-50 rounded border border-blue-100">
                        {park.preventiveCount} Open
                    </span>
                </td>
                <td className="py-3 px-4 text-center">
                    {park.correctiveCount > 0 ? (
                        <span className="inline-block px-2 py-1 text-xs font-semibold text-orange-700 bg-orange-50 rounded border border-orange-100">
                            {park.correctiveCount} Active
                        </span>
                    ) : (
                        <span className="text-xs text-gray-400">-</span>
                    )}
                </td>
                <td className="py-3 px-4">
                  <StatusBadge criticalDefects={park.criticalDefects} />
                </td>
                <td className="py-3 px-4 text-right">
                  <button 
                    onClick={() => handleOpenDashboard(park.name)}
                    className="inline-flex items-center gap-1 px-3 py-1.5 text-sm font-medium text-brand-primary hover:text-white hover:bg-brand-primary border border-brand-primary rounded transition-all duration-200"
                  >
                    <span>Dashboard</span>
                    <ExternalLink size={14} />
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};