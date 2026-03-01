import React, { useMemo } from 'react';
import { MOCK_PORTFOLIO } from './constants';
import { KpiCard } from './components/KpiCard';
import { PortfolioGrid } from './components/PortfolioGrid';
import { 
  Activity, 
  AlertTriangle, 
  CheckCircle2, 
  Zap,
  LayoutDashboard
} from 'lucide-react';

const App: React.FC = () => {
  // --- Calculate Aggregates ---
  const aggregates = useMemo(() => {
    return MOCK_PORTFOLIO.reduce(
      (acc, park) => ({
        totalPreventive: acc.totalPreventive + park.preventiveCount,
        totalCorrective: acc.totalCorrective + park.correctiveCount,
        totalCritical: acc.totalCritical + park.criticalDefects,
      }),
      { totalPreventive: 0, totalCorrective: 0, totalCritical: 0 }
    );
  }, []);

  return (
    <div className="min-h-screen bg-[#faf9f8] text-[#201f1e] font-sans pb-12">
      
      {/* --- Top Navigation Bar --- */}
      <header className="bg-brand-primary text-white shadow-md sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-14 md:h-12 flex items-center justify-between">
            <div className="flex items-center gap-3 overflow-hidden">
                <LayoutDashboard className="h-5 w-5 text-brand-accent flex-shrink-0" />
                <span className="font-semibold text-lg tracking-tight truncate">Global Solar Portfolio</span>
            </div>
            <div className="flex items-center gap-4 text-sm flex-shrink-0">
                <span className="hidden sm:inline opacity-80 hover:opacity-100 cursor-pointer transition-opacity">Settings</span>
                <span className="opacity-80 hover:opacity-100 cursor-pointer transition-opacity">
                    <span className="hidden sm:inline">User Profile</span>
                    <span className="sm:hidden">Profile</span>
                </span>
            </div>
        </div>
      </header>

      {/* --- Main Content Area --- */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 md:py-8 space-y-6 md:space-y-8">
        
        {/* --- KPI Cards Section --- */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-6">
            <KpiCard 
                title="Preventive Workflow" 
                value={aggregates.totalPreventive} 
                unit="Open Tasks"
                icon={<CheckCircle2 />}
                color="#059669" // Greenish
            />
            <KpiCard 
                title="Critical Defects" 
                value={aggregates.totalCritical} 
                unit="Alerts"
                icon={<AlertTriangle />}
                color="#DC2626" // Red
            />
            <KpiCard 
                title="Corrective Workflow" 
                value={aggregates.totalCorrective} 
                unit="Active"
                icon={<Activity />}
                color="#ffaa44" // Solar Orange
            />
        </div>

        {/* --- Portfolio Grid Section --- */}
        <section>
             <PortfolioGrid data={MOCK_PORTFOLIO} />
        </section>

      </main>
    </div>
  );
};

export default App;