import React, { useState, useMemo } from 'react';
import { 
  ThemeProvider, 
  createTheme, 
  Pivot, 
  PivotItem, 
  Text, 
  CommandBar, 
  ICommandBarItemProps,
  DetailsList,
  DetailsListLayoutMode,
  SelectionMode,
  IColumn,
  MessageBar,
  MessageBarType,
  Icon,
  DefaultButton,
  mergeStyles,
  Persona,
  PersonaSize,
  PersonaPresence,
  Panel,
  PanelType,
  IconButton
} from '@fluentui/react';
import { MOCK_TASKS, MOCK_WEATHER, PLOT_IDS, MOCK_INVERTERS, MOCK_TEAM, MOCK_HOURLY_WEATHER } from './constants';
import { InverterCard } from './components/InverterCard';
import { WorkOrder, PlotStatus, WeatherData, Inverter } from './types';

// 1. Fluent UI Theme - Mission Control Dark Blue/Teal
const appTheme = createTheme({
  palette: {
    themePrimary: '#004E8C',
    themeLighterAlt: '#f1f6fa',
    themeLighter: '#c8dceb',
    themeLight: '#9dc0da',
    themeTertiary: '#4d89b6',
    themeSecondary: '#135e98',
    themeDarkAlt: '#00467e',
    themeDark: '#003b6b',
    themeDarker: '#002c4f',
    neutralLighterAlt: '#faf9f8',
    neutralLighter: '#f3f2f1',
    neutralLight: '#edebe9',
    neutralQuaternaryAlt: '#e1dfdd',
    neutralQuaternary: '#d0d0d0',
    neutralTertiaryAlt: '#c8c6c4',
    neutralTertiary: '#a19f9d',
    neutralSecondary: '#605e5c',
    neutralPrimaryAlt: '#3b3a39',
    neutralPrimary: '#323130',
    neutralDark: '#201f1e',
    black: '#000000',
    white: '#ffffff',
  },
  defaultFontStyle: { fontFamily: 'Segoe UI, sans-serif' },
});

// Styles
const gridContainerClass = mergeStyles({
  display: 'grid',
  gridTemplateColumns: 'repeat(auto-fill, minmax(100px, 1fr))', // Smaller minmax for mobile
  gridGap: '8px',
  marginTop: '16px',
});

const plotCellBaseClass = mergeStyles({
  height: '80px', // Slightly shorter for density
  borderRadius: '6px',
  display: 'flex',
  flexDirection: 'column',
  alignItems: 'center',
  justifyContent: 'center',
  cursor: 'pointer',
  transition: 'all 0.2s ease',
  border: '2px solid transparent',
  selectors: {
    ':hover': { transform: 'scale(1.05)', boxShadow: '0 8px 16px rgba(0,0,0,0.1)' }
  }
});

// --- SUB-COMPONENTS ---

// 1. Advanced Solar Weather Widget (Replaces Basic Weather Card)
const AdvancedSolarWeather: React.FC<{ weather: WeatherData }> = ({ weather }) => {
  // Logic for Soiling Risk based on condition/wind
  const soilingRisk = weather.condition === 'Sandstorm' ? 'High' : weather.windSpeed > 4 ? 'Medium' : 'Low';
  const soilingColor = soilingRisk === 'High' ? 'text-red-600' : soilingRisk === 'Medium' ? 'text-orange-500' : 'text-green-600';
  
  // Cloud cover simulation based on condition
  const cloudCover = weather.condition === 'Cloudy' ? 85 : weather.condition === 'Rain' ? 100 : weather.condition === 'Sunny' ? 5 : 30;

  return (
    <div className="bg-white rounded-lg shadow-md p-4 border border-gray-200">
        {/* Header */}
        <div className="flex justify-between items-center mb-4 pb-2 border-b border-gray-100">
             <div className="flex items-center gap-2">
                <div className="p-2 bg-teal-50 text-teal-700 rounded-full">
                    <Icon iconName={weather.condition === 'Sunny' ? 'Sunny' : 'Cloudy'} className="text-xl" />
                </div>
                <div>
                    <Text variant="medium" className="font-bold text-slate-800 block">Current Conditions</Text>
                    <Text variant="small" className="text-gray-500">Real-time Environmental Data</Text>
                </div>
             </div>
             <div className="text-right">
                <Text variant="xLarge" className="font-bold text-slate-800 block">{weather.ambientTemp}°C</Text>
                <Text variant="tiny" className="text-gray-400">Ambient</Text>
             </div>
        </div>

        {/* Primary Metrics Metrics Grid */}
        <div className="grid grid-cols-2 gap-y-4 gap-x-2 mb-6">
            {/* Irradiance */}
            <div className="p-2 bg-orange-50 rounded border border-orange-100">
                <div className="flex items-center gap-2 mb-1">
                    <Icon iconName="Sunny" className="text-orange-500" />
                    <Text variant="small" className="font-semibold text-gray-600">Irradiance</Text>
                </div>
                <Text variant="large" className="font-bold text-slate-800">{weather.ghi} <span className="text-xs font-normal text-gray-500">W/m²</span></Text>
            </div>

            {/* Module Temp */}
            <div className={`p-2 rounded border ${weather.moduleTemp > 65 ? 'bg-red-50 border-red-100' : 'bg-blue-50 border-blue-100'}`}>
                <div className="flex items-center gap-2 mb-1">
                    <Icon iconName="Thermometer" className={weather.moduleTemp > 65 ? 'text-red-500' : 'text-blue-500'} />
                    <Text variant="small" className="font-semibold text-gray-600">Module Temp</Text>
                </div>
                <Text variant="large" className="font-bold text-slate-800">{weather.moduleTemp}°C</Text>
            </div>

            {/* Wind & Cloud */}
            <div>
                 <Text variant="small" className="text-gray-400 block mb-1">Wind Speed</Text>
                 <div className="flex items-center gap-2">
                    <Icon iconName="WindDirection" className="text-slate-400" />
                    <Text variant="medium" className="font-semibold text-slate-700">{weather.windSpeed} km/h NE</Text>
                 </div>
            </div>

             {/* Soiling */}
            <div>
                 <Text variant="small" className="text-gray-400 block mb-1">Soiling Risk</Text>
                 <div className="flex items-center gap-2">
                    <Icon iconName="Duststorm" className={soilingColor} />
                    <Text variant="medium" className={`font-semibold ${soilingColor}`}>{soilingRisk}</Text>
                 </div>
            </div>
             
             {/* Cloud Cover */}
             <div className="col-span-2 mt-1">
                 <div className="flex justify-between items-center">
                    <Text variant="small" className="text-gray-400">Cloud Cover</Text>
                    <Text variant="small" className={`font-bold ${cloudCover > 50 ? 'text-orange-500' : 'text-slate-600'}`}>{cloudCover}% Scattered</Text>
                 </div>
             </div>
        </div>

        {/* Forecast Section */}
        <div>
            <Text variant="small" className="font-bold text-gray-400 uppercase tracking-wider mb-3 block">4-Hour Forecast</Text>
            <div className="grid grid-cols-4 gap-2">
                {MOCK_HOURLY_WEATHER.map((hour, idx) => (
                    <div key={idx} className="flex flex-col items-center p-2 rounded hover:bg-gray-50 transition-colors cursor-default border border-transparent hover:border-gray-100">
                        <Text variant="tiny" className="text-gray-400 mb-1">{hour.time}</Text>
                        <Icon iconName={hour.icon} className="text-teal-600 text-lg mb-1" />
                        <Text variant="small" className="font-bold text-slate-700">{hour.temp}°</Text>
                        <div className="mt-1 px-1 py-0.5 bg-orange-100 text-orange-800 text-[9px] font-bold rounded">
                            {hour.ghi}
                        </div>
                    </div>
                ))}
            </div>
        </div>
    </div>
  );
};

// 2. Windy Map Widget (New Feature)
const WindyMapWidget: React.FC = () => {
  return (
    <div className="bg-white rounded-lg shadow-xl overflow-hidden h-full flex flex-col border border-gray-200">
       <div className="p-4 border-b border-gray-200 flex justify-between items-center bg-gray-50">
          <div>
            <Text variant="large" className="font-bold text-slate-800 block">Live Atmospheric Conditions</Text>
            <Text variant="small" className="text-gray-500 block">Real-time cloud cover and wind patterns (ECMWF Model)</Text>
          </div>
          <div className="flex gap-2">
              <div className="flex items-center gap-1">
                  <div className="w-2 h-2 rounded-full bg-teal-500"></div>
                  <Text variant="tiny" className="text-gray-500">Live Feed</Text>
              </div>
          </div>
       </div>
       <div className="flex-grow relative bg-gray-100">
         <iframe
            title="Windy Map"
            width="100%"
            height="100%"
            src="https://embed.windy.com/embed2.html?lat=24.456&lon=32.739&detailLat=24.456&detailLon=32.739&width=650&height=450&zoom=8&level=surface&overlay=clouds&product=ecmwf&menu=&message=&marker=&calendar=now&pressure=&type=map&location=coordinates&detail=&metricWind=km%2Fh&metricTemp=%C2%B0C&radarRange=-1"
            frameBorder="0"
            style={{ border: 0, width: '100%', height: '100%', minHeight: '600px' }} 
         ></iframe>
       </div>
    </div>
  );
};


// 3. Telemetry Sidebar Content (Reused in Desktop Sidebar and Mobile Panel)
const TelemetryContent: React.FC<{
  weather: WeatherData;
  generation: number;
  pr: number;
  inverters: Inverter[];
}> = ({ weather, generation, pr, inverters }) => (
  <div className="flex flex-col gap-6">
    {/* WEATHER WIDGET (UPDATED) */}
    <AdvancedSolarWeather weather={weather} />

    {/* SITE KPI */}
    <div className="grid grid-cols-2 gap-2">
          <div className="bg-gray-50 border border-gray-100 p-2 rounded text-center">
            <Text variant="tiny" className="text-gray-500 uppercase font-bold block">Production</Text>
            <Text variant="mediumPlus" className="font-bold text-gray-800">{generation.toFixed(0)} kW</Text>
          </div>
          <div className="bg-gray-50 border border-gray-100 p-2 rounded text-center">
            <Text variant="tiny" className="text-gray-500 uppercase font-bold block">PR %</Text>
            <Text variant="mediumPlus" className={`font-bold ${pr < 80 ? 'text-red-600' : 'text-green-600'}`}>{pr.toFixed(1)}%</Text>
          </div>
    </div>

    {/* INVERTER LIST */}
    <div>
        <Text variant="medium" className="font-bold text-gray-800 mb-3 block">Inverter Status</Text>
        <div className="flex flex-col gap-1 pb-4">
            {inverters.map(inv => (
                <InverterCard key={inv.id} inverter={inv} currentGhi={weather.ghi} />
            ))}
        </div>
    </div>
  </div>
);

// 4. Mobile Ticket Card (Replaces Table on Mobile)
const MobileTaskCard: React.FC<{ task: WorkOrder }> = ({ task }) => {
  let statusColor = 'text-gray-500';
  if (task.priority === 'Critical') statusColor = 'text-red-600 border-l-4 border-red-500';
  else if (task.priority === 'High') statusColor = 'text-orange-600 border-l-4 border-orange-500';
  else statusColor = 'text-blue-600 border-l-4 border-blue-500';
  
  return (
    <div className={`bg-white p-3 rounded shadow-sm border border-gray-200 mb-3 ${statusColor}`}>
      <div className="flex justify-between items-start mb-1">
        <span className="text-xs font-mono font-bold text-gray-400">{task.id} • {task.plotId}</span>
        <span className={`text-xs font-bold px-2 py-0.5 rounded-full bg-gray-100 uppercase`}>{task.status}</span>
      </div>
      <Text variant="medium" className="font-bold text-gray-800 block mb-1">{task.title}</Text>
      <div className="flex justify-between items-center text-xs text-gray-500 mt-2">
         <div className="flex items-center gap-1">
            <Icon iconName="Contact" />
            <span>{task.assignedTechnician}</span>
         </div>
         <div className="flex items-center gap-1">
            <Icon iconName="Event" />
            <span>{task.dueDate}</span>
         </div>
      </div>
    </div>
  );
};

// 5. Site Details Content (New Feature)
const SiteDetailsContent: React.FC = () => {
  const overviewItems = [
    { label: 'Project Name', value: 'Benban Solar Park' },
    { label: 'Location', value: 'Aswan Governorate, Egypt' },
    { label: 'Owner', value: 'NREA (New & Renewable Energy Authority)' },
    { label: 'Capacity', value: '1.65 GW (1,650 MW)' },
    { label: 'Total Area', value: '~37 km² (41 Plots)' },
    { label: 'Status', value: 'Operational (Since 2019)' },
  ];

  return (
    <div className="flex flex-col gap-6 pb-6">
      {/* Top Section: Overview and Stakeholders */}
      <div className="grid grid-cols-1 xl:grid-cols-2 gap-6">
        
        {/* Project Info Card */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
           <div className="flex items-center gap-3 mb-6 border-b border-gray-100 pb-4">
              <div className="p-3 bg-teal-50 rounded-full text-teal-700">
                <Icon iconName="POI" className="text-xl" />
              </div>
              <div>
                <Text variant="xLarge" className="font-bold text-slate-800 block">Benban Solar Park</Text>
                <Text variant="small" className="text-gray-500">World's 4th Largest Solar Power Plant</Text>
              </div>
           </div>
           
           <div className="grid grid-cols-1 md:grid-cols-2 gap-y-6 gap-x-4">
              {overviewItems.map((item) => (
                <div key={item.label}>
                  <Text variant="small" className="text-gray-400 uppercase font-bold block mb-1">{item.label}</Text>
                  <Text variant="mediumPlus" className="text-slate-800 font-semibold">{item.value}</Text>
                </div>
              ))}
              <div className="md:col-span-2 mt-2">
                 <Text variant="small" className="text-gray-400 uppercase font-bold block mb-2">Description</Text>
                 <Text className="text-gray-600 leading-relaxed">
                   A photovoltaic power station with a total capacity of 1.65 GWp which corresponds to an annual production of approximately 3.8 TWh. It is located in Benban (Aswan Governorate) in the western desert of Egypt, approximately 650 km south of Cairo and 40 km north-west of Aswan.
                 </Text>
              </div>
           </div>
        </div>

        {/* Stakeholders Card */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 flex flex-col">
           <div className="flex items-center gap-3 mb-6 border-b border-gray-100 pb-4">
              <div className="p-3 bg-blue-50 rounded-full text-blue-700">
                <Icon iconName="PartyLeader" className="text-xl" />
              </div>
              <div>
                <Text variant="xLarge" className="font-bold text-slate-800 block">Stakeholders</Text>
                <Text variant="small" className="text-gray-500">Key Entities & Points of Contact</Text>
              </div>
           </div>

           <div className="flex flex-col gap-4 flex-grow">
              {/* Person 1 */}
              <div className="flex items-center gap-4 p-3 hover:bg-gray-50 rounded-lg transition-colors border border-transparent hover:border-gray-100">
                 <Persona 
                    text="Ahmed El-Sayed"
                    secondaryText="NREA Project Lead"
                    tertiaryText="Government Oversight"
                    initialsColor={15}
                    size={PersonaSize.size48}
                 />
                 <div className="ml-auto text-right">
                    <div className="text-xs text-gray-500 font-mono mb-1">ops@nrea.gov.eg</div>
                    <span className="px-2 py-0.5 bg-blue-100 text-blue-800 text-[10px] font-bold rounded uppercase">Owner</span>
                 </div>
              </div>

              {/* Entity 2 */}
              <div className="flex items-center gap-4 p-3 hover:bg-gray-50 rounded-lg transition-colors border border-transparent hover:border-gray-100">
                 <Persona 
                    text="Scatec Solar"
                    secondaryText="Lead Developer (6 Plots)"
                    size={PersonaSize.size48}
                    initialsColor={6} // Teal-ish
                 />
                 <div className="ml-auto text-right">
                     <span className="px-2 py-0.5 bg-teal-100 text-teal-800 text-[10px] font-bold rounded uppercase">Developer</span>
                 </div>
              </div>

              {/* Entity 3 */}
               <div className="flex items-center gap-4 p-3 hover:bg-gray-50 rounded-lg transition-colors border border-transparent hover:border-gray-100">
                 <Persona 
                    text="Sterling & Wilson"
                    secondaryText="EPC Contractor"
                    size={PersonaSize.size48}
                    initialsColor={20} // Orange/Red
                 />
                 <div className="ml-auto text-right">
                     <span className="px-2 py-0.5 bg-orange-100 text-orange-800 text-[10px] font-bold rounded uppercase">Contractor</span>
                 </div>
              </div>

               {/* Entity 4 */}
               <div className="flex items-center gap-4 p-3 hover:bg-gray-50 rounded-lg transition-colors border border-transparent hover:border-gray-100">
                 <Persona 
                    text="EETC"
                    secondaryText="Grid Operator"
                    size={PersonaSize.size48}
                    initialsColor={4} 
                 />
                 <div className="ml-auto text-right">
                     <span className="px-2 py-0.5 bg-purple-100 text-purple-800 text-[10px] font-bold rounded uppercase">Grid</span>
                 </div>
              </div>
           </div>
        </div>
      </div>

      {/* Map Card */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-1">
         <div className="relative w-full h-[400px] rounded overflow-hidden bg-gray-100">
            {/* Embedded OpenStreetMap */}
            <iframe 
              width="100%" 
              height="100%" 
              frameBorder="0" 
              scrolling="no" 
              marginHeight={0} 
              marginWidth={0} 
              src="https://www.openstreetmap.org/export/embed.html?bbox=32.72%2C24.44%2C32.76%2C24.47&amp;layer=mapnik&amp;marker=24.456%2C32.739" 
              style={{ border: 0 }}
              title="Benban Solar Park Map"
            ></iframe>
            <div className="absolute bottom-2 right-2 bg-white/90 px-2 py-1 text-xs text-gray-600 rounded shadow-sm backdrop-blur-sm pointer-events-none">
                Coordinates: 24.456° N, 32.739° E
            </div>
         </div>
      </div>
    </div>
  );
};


export default function App() {
  const [selectedTab, setSelectedTab] = useState<string>('workorders');
  const [filterText, setFilterText] = useState('');
  const [isSidebarOpen, setIsSidebarOpen] = useState(false); // Mobile Sidebar State

  // --- LOGIC: KPI CALCULATOR ---
  const stats = useMemo(() => {
    const preventive = MOCK_TASKS.filter(t => t.type === 'Preventive');
    const corrective = MOCK_TASKS.filter(t => t.type === 'Corrective');
    
    // Existing Metrics
    const prevClosed = preventive.filter(t => t.status === 'Closed').length;
    const prevTotal = preventive.length;
    const prevPercent = prevTotal > 0 ? Math.round((prevClosed / prevTotal) * 100) : 0;
    const corrCritical = corrective.filter(t => t.priority === 'Critical' && t.status !== 'Closed').length;
    
    // New Metrics (Assignment Workflow)
    // Assigned = 'Assigned' OR 'In Progress'
    // Pending = 'Open'
    const prevAssigned = preventive.filter(t => t.status === 'Assigned' || t.status === 'In Progress').length;
    const prevPending = preventive.filter(t => t.status === 'Open').length;

    const corrAssigned = corrective.filter(t => t.status === 'Assigned' || t.status === 'In Progress').length;
    const corrPending = corrective.filter(t => t.status === 'Open').length;

    return {
      preventive: { 
        closed: prevClosed, 
        total: prevTotal, 
        percent: prevPercent, 
        assigned: prevAssigned, 
        pending: prevPending 
      },
      corrective: { 
        critical: corrCritical, 
        active: corrective.filter(t => t.status !== 'Closed').length, 
        assigned: corrAssigned, 
        pending: corrPending 
      }
    };
  }, []);

  // --- LOGIC: MAP GRID HEATMAP ---
  const plotData: PlotStatus[] = useMemo(() => {
    return PLOT_IDS.map(plotId => {
      // Find tasks for this plot
      const plotTasks = MOCK_TASKS.filter(t => t.plotId === plotId && t.status !== 'Closed');
      
      // Critical Corrective tasks make the sector RED
      const hasCritical = plotTasks.some(t => (t.priority === 'Critical' || t.priority === 'High') && t.type === 'Corrective');
      
      // Preventive tasks or lower priority corrective make it AMBER
      const hasWarning = plotTasks.length > 0 && !hasCritical; 

      return {
        id: plotId,
        hasCritical,
        hasWarning,
        taskCount: plotTasks.length
      };
    });
  }, []);

  // --- LOGIC: FILTERED TABLE ---
  const filteredTasks = useMemo(() => {
    let result = MOCK_TASKS;
    if (filterText) {
      result = result.filter(t => 
        t.title.toLowerCase().includes(filterText.toLowerCase()) || 
        t.id.toLowerCase().includes(filterText.toLowerCase()) ||
        t.assignedTechnician.toLowerCase().includes(filterText.toLowerCase())
      );
    }
    return result;
  }, [filterText]);

  // Telemetry Calculations
  const totalCapacity = MOCK_INVERTERS.reduce((acc, curr) => acc + curr.capacityKw, 0);
  const totalGeneration = MOCK_INVERTERS.reduce((acc, curr) => acc + curr.currentOutputKw, 0);
  const performanceRatio = (totalGeneration / totalCapacity) * 100;

  // --- DESKTOP TABLE COLUMNS ---
  const renderPriority = (item: WorkOrder) => {
    let bg = 'bg-gray-100 text-gray-600';
    if (item.priority === 'Critical') bg = 'bg-red-100 text-red-800 border border-red-200';
    if (item.priority === 'High') bg = 'bg-orange-100 text-orange-800';
    if (item.priority === 'Medium') bg = 'bg-blue-50 text-blue-700';
    return <span className={`px-2 py-0.5 rounded font-bold text-xs uppercase tracking-wide ${bg}`}>{item.priority}</span>;
  };

  const renderType = (item: WorkOrder) => (
    <div className="flex items-center gap-2">
      <Icon iconName={item.type === 'Preventive' ? 'Calendar' : 'Warning'} className={item.type === 'Preventive' ? 'text-blue-500' : 'text-red-500'} />
      <span className="hidden xl:inline">{item.type}</span> 
    </div>
  );

  const renderStatus = (item: WorkOrder) => {
    const isClosed = item.status === 'Closed';
    return (
      <div className={`flex items-center gap-1 ${isClosed ? 'text-green-600' : 'text-gray-700'}`}>
         {isClosed && <Icon iconName="CheckMark" />}
         <span className="font-semibold text-sm">{item.status}</span>
      </div>
    );
  };

  const columns: IColumn[] = [
    { key: 'id', name: 'ID', fieldName: 'id', minWidth: 60, maxWidth: 80, isResizable: true },
    { key: 'plot', name: 'Loc', fieldName: 'plotId', minWidth: 60, maxWidth: 80, isResizable: true, onRender: (item) => <span className="font-mono font-bold text-slate-700">{item.plotId}</span> },
    { key: 'type', name: 'Type', minWidth: 40, maxWidth: 100, onRender: renderType },
    { key: 'priority', name: 'Priority', minWidth: 80, maxWidth: 100, onRender: renderPriority },
    { key: 'title', name: 'Description', fieldName: 'title', minWidth: 150, isResizable: true },
    { key: 'status', name: 'Status', minWidth: 90, maxWidth: 120, onRender: renderStatus },
    { key: 'tech', name: 'Tech', fieldName: 'assignedTechnician', minWidth: 90, maxWidth: 140 },
  ];

  // Command Bar Config
  const commandBarItems: ICommandBarItemProps[] = [
    { key: 'newItem', text: 'Create', iconProps: { iconName: 'Add' } },
    { key: 'refresh', text: 'Refresh', iconProps: { iconName: 'Refresh' } },
    { key: 'filter', text: 'Filter', iconProps: { iconName: 'Filter' } },
  ];

  return (
    <ThemeProvider theme={appTheme} className="h-screen flex flex-col bg-gray-50 overflow-hidden">
      
      {/* HEADER */}
      <div className="bg-white shadow-sm z-20 border-b border-gray-200">
        <div className="flex items-center justify-between px-4 lg:px-6 py-3">
          <div className="flex items-center gap-3">
             <div className="bg-teal-700 text-white p-2 rounded-md">
                <Icon iconName="Sunny" className="text-xl" />
             </div>
             <div>
                <Text variant="large" className="font-bold text-slate-800 block leading-none">Benban Solar Farm (Egypt)</Text>
                <Text variant="small" className="text-slate-500 tracking-wider font-semibold hidden md:block">O&M COMMAND CENTER</Text>
             </div>
          </div>
          <div className="flex items-center gap-3 lg:gap-6">
             
             {/* Mobile Telemetry Toggle */}
             <div className="lg:hidden">
                <IconButton 
                  iconProps={{ iconName: 'AnalyticsView' }} 
                  title="View Telemetry" 
                  onClick={() => setIsSidebarOpen(true)}
                  className="bg-gray-100 text-teal-700 rounded hover:bg-gray-200"
                />
             </div>

             <div className="text-right hidden lg:block">
                <div className="flex items-center justify-end gap-2 text-red-600 font-bold">
                    <Icon iconName="Warning" />
                    <span>{MOCK_WEATHER.condition.toUpperCase()} ALERT</span>
                </div>
                <Text variant="tiny" className="text-gray-400">Wind: {MOCK_WEATHER.windSpeed} m/s | Temp: {MOCK_WEATHER.ambientTemp}°C</Text>
             </div>
             <div className="h-8 w-8 bg-gray-200 rounded-full flex items-center justify-center text-teal-800 font-bold border border-gray-300">SM</div>
          </div>
        </div>
        <div className="border-t border-gray-100">
           <CommandBar 
              items={commandBarItems} 
              className="pl-2"
              styles={{ root: { padding: 0 } }}
           />
        </div>
      </div>

      {/* ALERT BANNER - HEAT/DUST WARNING */}
      {(MOCK_WEATHER.moduleTemp > 65 || MOCK_WEATHER.condition === 'Sandstorm') && (
        <MessageBar messageBarType={MessageBarType.severeWarning} className="shadow-md">
          <strong>Efficiency Warning:</strong> High module temperature ({MOCK_WEATHER.moduleTemp}°C) and soiling losses detected.
        </MessageBar>
      )}

      {/* MAIN LAYOUT */}
      <div className="flex-grow flex flex-col lg:flex-row overflow-hidden relative">
          
          {/* MAIN CONTENT AREA */}
          <div className="flex-grow flex flex-col min-w-0 bg-gray-50/50 w-full">

             {/* GLOBAL KPI CARDS (MOVED UP) */}
             <div className="px-4 lg:px-6 pt-6 pb-2">
                 <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-4">
                    {/* CARD 1: PREVENTIVE HEALTH */}
                    <div className="bg-white p-4 rounded-lg shadow-sm border-l-4 border-blue-500 flex justify-between items-center transition-all hover:shadow-md">
                        <div>
                            <Text variant="small" className="text-gray-500 font-bold uppercase tracking-wider">PREVENTIVE HEALTH</Text>
                            <div className="flex items-baseline gap-2 mt-1">
                                <Text variant="xLarge" className="font-bold text-slate-800">{stats.preventive.percent}%</Text>
                                <Text variant="small" className="text-gray-400">Compliance</Text>
                            </div>
                            <div className="mt-1 text-xs text-blue-600 font-semibold bg-blue-50 inline-block px-1.5 py-0.5 rounded">
                                {stats.preventive.total - stats.preventive.closed} Pending
                            </div>
                        </div>
                        <div className="p-3 bg-blue-50 rounded-full">
                           <Icon iconName="ClipboardList" className="text-2xl text-blue-600" />
                        </div>
                    </div>

                    {/* CARD 2: PREVENTIVE WORKFLOW */}
                    <div className="bg-white p-4 rounded-lg shadow-sm border-l-4 border-teal-500 flex flex-col justify-between transition-all hover:shadow-md">
                        <Text variant="small" className="text-gray-500 font-bold uppercase tracking-wider mb-2">PREVENTIVE WORKFLOW</Text>
                        <div className="flex items-center justify-between mt-auto">
                             <div className="text-center px-1">
                                <div className="text-2xl font-bold text-teal-700 leading-none mb-1">{stats.preventive.assigned}</div>
                                <div className="text-[10px] text-gray-400 font-bold uppercase">Assigned</div>
                             </div>
                             <div className="h-8 w-px bg-gray-200 mx-2"></div>
                             <div className="text-center px-1">
                                <div className="text-2xl font-bold text-orange-400 leading-none mb-1">{stats.preventive.pending}</div>
                                <div className="text-[10px] text-gray-400 font-bold uppercase">Pending</div>
                             </div>
                             <div className="ml-auto p-2 bg-teal-50 rounded-full">
                                <Icon iconName="People" className="text-xl text-teal-600" />
                             </div>
                        </div>
                    </div>

                    {/* CARD 3: CRITICAL DEFECTS */}
                    <div className="bg-white p-4 rounded-lg shadow-sm border-l-4 border-red-500 flex justify-between items-center transition-all hover:shadow-md">
                        <div>
                            <Text variant="small" className="text-gray-500 font-bold uppercase tracking-wider">CRITICAL DEFECTS</Text>
                            <div className="flex items-baseline gap-2 mt-1">
                                <Text variant="xLarge" className="font-bold text-red-700">{stats.corrective.critical}</Text>
                                <Text variant="small" className="text-gray-400">Open Tickets</Text>
                            </div>
                             <div className="mt-1 text-xs text-red-600 font-semibold bg-red-50 inline-block px-1.5 py-0.5 rounded">
                                {stats.corrective.active} Total
                            </div>
                        </div>
                        <div className="p-3 bg-red-50 rounded-full">
                             <Icon iconName="Health" className="text-2xl text-red-600" />
                        </div>
                    </div>

                    {/* CARD 4: CORRECTIVE WORKFLOW */}
                    <div className="bg-white p-4 rounded-lg shadow-sm border-l-4 border-orange-500 flex flex-col justify-between transition-all hover:shadow-md">
                        <Text variant="small" className="text-gray-500 font-bold uppercase tracking-wider mb-2">CORRECTIVE WORKFLOW</Text>
                        <div className="flex items-center justify-between mt-auto">
                             <div className="text-center px-1">
                                <div className="text-2xl font-bold text-blue-700 leading-none mb-1">{stats.corrective.assigned}</div>
                                <div className="text-[10px] text-gray-400 font-bold uppercase">Assigned</div>
                             </div>
                             <div className="h-8 w-px bg-gray-200 mx-2"></div>
                             <div className="text-center px-1">
                                <div className="text-2xl font-bold text-red-500 leading-none mb-1">{stats.corrective.pending}</div>
                                <div className="text-[10px] text-gray-400 font-bold uppercase">Pending</div>
                             </div>
                             <div className="ml-auto p-2 bg-orange-50 rounded-full">
                                <Icon iconName="Wrench" className="text-xl text-orange-600" />
                             </div>
                        </div>
                    </div>
                 </div>
             </div>
             
             {/* TABS & SEARCH */}
             <div className="px-4 pt-2 bg-white border-b border-gray-200 shadow-sm flex flex-col md:flex-row justify-between items-start md:items-center gap-2">
                <Pivot 
                    aria-label="Operations Views" 
                    selectedKey={selectedTab} 
                    onLinkClick={(item) => item && setSelectedTab(item.props.itemKey!)}
                    headersOnly={true}
                    className="w-full md:w-auto"
                >
                    <PivotItem headerText="Work Orders" itemKey="workorders" itemIcon="TaskList" />
                    <PivotItem headerText="Live Feed" itemKey="livefeed" itemIcon="AnalyticsView" />
                    <PivotItem headerText="Map" itemKey="map" itemIcon="Map" />
                    <PivotItem headerText="Team" itemKey="team" itemIcon="People" />
                    <PivotItem headerText="Site Details" itemKey="sitedetails" itemIcon="Info" />
                    <PivotItem headerText="Live Cloud Map" itemKey="windy" itemIcon="Globe" />
                </Pivot>
                {selectedTab === 'workorders' && (
                    <div className="pb-2 md:pb-0">
                      <DefaultButton 
                          text="View all work orders" 
                          iconProps={{ iconName: 'FabricFolder' }}
                          onClick={() => setFilterText('')}
                      />
                    </div>
                )}
             </div>

             {/* TAB CONTENT CONTAINER */}
             <div className="flex-grow overflow-auto p-4 lg:p-6 scroll-smooth">
                
                {/* TAB 1: WORK ORDERS */}
                {selectedTab === 'workorders' && (
                    <div className="h-full">
                        {/* DESKTOP VIEW: Table */}
                        <div className="hidden md:block bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
                            <DetailsList
                                items={filteredTasks}
                                columns={columns}
                                setKey="set"
                                layoutMode={DetailsListLayoutMode.justified}
                                selectionMode={SelectionMode.none}
                            />
                        </div>

                        {/* MOBILE VIEW: Cards */}
                        <div className="md:hidden">
                            {filteredTasks.map(task => (
                              <MobileTaskCard key={task.id} task={task} />
                            ))}
                        </div>
                    </div>
                )}

                {/* TAB 2: LIVE FEED */}
                {selectedTab === 'livefeed' && (
                    <div className="h-full flex flex-col items-center justify-center text-gray-400 min-h-[300px]">
                        <Icon iconName="LineChart" className="text-6xl mb-4 text-gray-300" />
                        <Text variant="large">Real-time SCADA Telemetry Stream</Text>
                        <Text variant="small">Connecting to WebSocket...</Text>
                    </div>
                )}

                {/* TAB 3: MAP */}
                {selectedTab === 'map' && (
                    <div className="h-full flex flex-col">
                        <div className="mb-4">
                            <Text variant="large" className="font-bold text-slate-700">Sector Heatmap</Text>
                            <Text variant="small" className="text-gray-500 block">Visual distribution of open defects.</Text>
                        </div>
                        <div className={gridContainerClass}>
                             {plotData.map((plot) => {
                                let bgColor = 'bg-emerald-500 hover:bg-emerald-600 text-white'; 
                                if (plot.hasWarning) bgColor = 'bg-amber-400 hover:bg-amber-500 text-slate-800'; 
                                if (plot.hasCritical) bgColor = 'bg-red-600 hover:bg-red-700 text-white'; 
                                
                                return (
                                    <div key={plot.id} className={`${plotCellBaseClass} ${bgColor}`}>
                                        <span className="font-mono font-bold text-lg">{plot.id}</span>
                                        <div className="flex flex-col items-center">
                                            {plot.taskCount > 0 ? (
                                                <span className="text-xs bg-white/30 px-2 rounded-full mt-1 font-semibold">
                                                    {plot.taskCount} Issues
                                                </span>
                                            ) : (
                                                <Icon iconName="CheckMark" className="mt-1" />
                                            )}
                                        </div>
                                    </div>
                                )
                            })}
                        </div>
                    </div>
                )}

                {/* TAB 4: TEAM & CONTACTS */}
                {selectedTab === 'team' && (
                    <div className="h-full flex flex-col">
                         {['Management', 'Engineering', 'Operations'].map((dept) => (
                             <div key={dept} className="mb-8">
                                <Text variant="medium" className="font-bold text-teal-800 uppercase border-b border-gray-200 pb-2 mb-4 block tracking-wider">{dept}</Text>
                                <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
                                    {MOCK_TEAM.filter(m => m.department === dept).map(member => (
                                        <div key={member.id} className="bg-white rounded-lg shadow-sm border border-gray-200 hover:border-teal-400 hover:shadow-md transition-all group overflow-hidden">
                                            <div className="p-4">
                                                <Persona
                                                    text={member.name}
                                                    secondaryText={member.role}
                                                    tertiaryText={member.status}
                                                    size={PersonaSize.size48}
                                                    presence={member.status === 'On Site' || member.status === 'Deployed' ? PersonaPresence.online : member.status === 'Remote' ? PersonaPresence.away : PersonaPresence.offline}
                                                    styles={{ primaryText: { fontWeight: 'bold', color: '#333' } }}
                                                />
                                            </div>
                                            <div className="bg-gray-50 px-4 py-2 border-t border-gray-100 flex flex-col gap-1.5">
                                                <div className="flex items-center gap-3 text-xs text-gray-600 hover:text-teal-700 transition-colors cursor-pointer group/item">
                                                    <Icon iconName="Phone" className="text-gray-400 group-hover/item:text-teal-600" /> 
                                                    <span className="font-mono">{member.phone}</span>
                                                </div>
                                                <div className="flex items-center gap-3 text-xs text-gray-600 hover:text-teal-700 transition-colors cursor-pointer group/item">
                                                    <Icon iconName="Mail" className="text-gray-400 group-hover/item:text-teal-600" /> 
                                                    <span className="truncate">{member.email}</span>
                                                </div>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                             </div>
                         ))}
                    </div>
                )}

                {/* TAB 5: SITE DETAILS */}
                {selectedTab === 'sitedetails' && (
                  <SiteDetailsContent />
                )}

                {/* TAB 6: WINDY MAP (NEW) */}
                {selectedTab === 'windy' && (
                  <div className="h-full p-1">
                      <WindyMapWidget />
                  </div>
                )}

             </div>
          </div>

          {/* DESKTOP SIDEBAR (TELEMETRY) - HIDDEN ON MOBILE */}
          <div className="hidden lg:block w-80 bg-white border-l border-gray-200 overflow-y-auto flex-shrink-0 shadow-[0_0_20px_rgba(0,0,0,0.05)] z-10">
              <div className="p-4">
                 <TelemetryContent 
                    weather={MOCK_WEATHER} 
                    generation={totalGeneration} 
                    pr={performanceRatio} 
                    inverters={MOCK_INVERTERS} 
                 />
              </div>
          </div>

          {/* MOBILE TELEMETRY PANEL (DRAWER) */}
          <Panel
            isOpen={isSidebarOpen}
            onDismiss={() => setIsSidebarOpen(false)}
            type={PanelType.smallFixedFar}
            headerText="Real-time Telemetry"
            closeButtonAriaLabel="Close"
          >
             <div className="py-4">
                <TelemetryContent 
                    weather={MOCK_WEATHER} 
                    generation={totalGeneration} 
                    pr={performanceRatio} 
                    inverters={MOCK_INVERTERS} 
                 />
             </div>
          </Panel>

      </div>
    </ThemeProvider>
  );
}