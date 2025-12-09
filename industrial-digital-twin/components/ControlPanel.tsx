import React, { useState } from 'react';
import { IPLCState } from '../types';

interface ControlPanelProps {
  plcState: IPLCState;
}

export const ControlPanel: React.FC<ControlPanelProps> = ({ plcState }) => {
  const [minimized, setMinimized] = useState(false);

  const triggerSpawn = () => {
    window.dispatchEvent(new Event('spawn-box'));
  };

  if (minimized) {
    return (
      <button 
        onClick={() => setMinimized(false)}
        className="absolute top-4 left-4 bg-neutral-800 text-white p-3 rounded-full shadow-xl border border-neutral-700 hover:bg-neutral-700 transition"
      >
        <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
        </svg>
      </button>
    );
  }

  return (
    <div className="absolute top-4 left-4 w-96 bg-neutral-900/90 backdrop-blur-md text-white p-5 rounded-xl shadow-2xl border border-neutral-700 transition-all">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-xl font-bold text-white flex items-center gap-2">
          <span className="w-3 h-3 bg-blue-500 rounded-full animate-pulse shadow-[0_0_10px_#3b82f6]"></span>
          Sorting Controller
        </h2>
        <div className="flex items-center gap-2">
           <span className="text-xs bg-neutral-800 px-2 py-1 rounded text-neutral-400 font-mono">PLC_RUNNING</span>
           <button onClick={() => setMinimized(true)} className="text-neutral-400 hover:text-white">
             <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
               <path fillRule="evenodd" d="M3 5a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" clipRule="evenodd" />
             </svg>
           </button>
        </div>
      </div>

      <div className="space-y-6">
        {/* Manual Controls */}
        <div className="border-b border-neutral-700 pb-5">
          <button 
            onClick={triggerSpawn}
            className="w-full bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 text-white font-semibold py-3 px-4 rounded-lg transition-all active:scale-[0.98] shadow-lg flex items-center justify-center gap-2"
          >
            <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path fillRule="evenodd" d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z" clipRule="evenodd" />
            </svg>
            Feed Random Product
          </button>
        </div>

        {/* Station Monitors */}
        <div className="space-y-3">
          <h3 className="text-xs font-bold text-neutral-500 uppercase tracking-widest mb-2">Station Status</h3>
          
          <StationRow 
            label="Red Diverter" 
            color="text-red-500"
            sensor={plcState.inputs['sensor_red']}
            diverter={plcState.outputs['pusher_red']}
            timer={plcState.timers['timer_red']}
          />
          <StationRow 
            label="White Diverter" 
            color="text-slate-200"
            sensor={plcState.inputs['sensor_white']}
            diverter={plcState.outputs['pusher_white']}
            timer={plcState.timers['timer_white']}
          />
          <StationRow 
            label="Blue Diverter" 
            color="text-blue-500"
            sensor={plcState.inputs['sensor_blue']}
            diverter={plcState.outputs['pusher_blue']}
            timer={plcState.timers['timer_blue']}
          />
        </div>
      </div>

      <div className="mt-6 pt-4 border-t border-neutral-800 text-[10px] text-neutral-500 font-mono leading-relaxed">
        <p>LOGIC SEQUENCE:</p>
        <p>1. SENSOR DETECTS COLOR</p>
        <p>2. TIMER START (TRAVEL DELAY)</p>
        <p>3. DIVERTER CLOSES (ACTIVATE ARM)</p>
        <p>4. WAIT FOR SORT & RESET</p>
      </div>
    </div>
  );
};

const StationRow: React.FC<{ 
  label: string; 
  color: string; 
  sensor: boolean; 
  diverter: boolean;
  timer: number;
}> = ({ label, color, sensor, diverter, timer }) => (
  <div className="bg-neutral-800/50 p-3 rounded-lg flex items-center justify-between border border-neutral-800">
    <div className="flex flex-col">
      <span className={`text-sm font-bold ${color}`}>{label}</span>
      <span className="text-[10px] text-neutral-500 font-mono">
        T: {timer > 0 ? timer.toFixed(2) : '0.00'}s
      </span>
    </div>
    
    <div className="flex items-center gap-4">
      <div className="flex flex-col items-center gap-1">
        <StatusLight active={sensor} color="amber" />
        <span className="text-[9px] text-neutral-600 font-bold">SENS</span>
      </div>
      
      <div className="w-8 h-[1px] bg-neutral-700"></div>

      <div className="flex flex-col items-center gap-1">
        <StatusLight active={diverter} color="green" />
        <span className="text-[9px] text-neutral-600 font-bold">ARM</span>
      </div>
    </div>
  </div>
);

const StatusLight: React.FC<{ active: boolean; color?: 'red' | 'green' | 'amber' }> = ({ active, color = 'red' }) => {
  let colorClasses = 'bg-neutral-700';
  if (active) {
    if (color === 'red') colorClasses = 'bg-red-500 shadow-[0_0_8px_rgba(239,68,68,0.8)]';
    if (color === 'green') colorClasses = 'bg-emerald-500 shadow-[0_0_8px_rgba(16,185,129,0.8)]';
    if (color === 'amber') colorClasses = 'bg-amber-500 shadow-[0_0_8px_rgba(245,158,11,0.8)]';
  }
  
  return (
    <div className={`w-3 h-3 rounded-full transition-all duration-200 ${colorClasses}`} />
  );
};