import React, { useEffect, useRef, useState } from 'react';
import { SimulationEngine } from '../simulation/SimulationEngine';
import { IPLCState } from '../types';

interface SimulationViewProps {
  onPLCUpdate: (state: IPLCState) => void;
}

export const SimulationView: React.FC<SimulationViewProps> = ({ onPLCUpdate }) => {
  const containerRef = useRef<HTMLDivElement>(null);
  const engineRef = useRef<SimulationEngine | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!containerRef.current) return;

    // Initialize Engine
    const engine = new SimulationEngine(containerRef.current, onPLCUpdate);
    engineRef.current = engine;
    
    if (engine.initFailed) {
      setError("WebGL Context Creation Failed");
    } else {
      engine.start();
      // Spawn an initial box
      setTimeout(() => engine.spawnBox(), 1000);
    }

    return () => {
      engine.dispose();
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []); // Run once on mount

  // Expose spawn function globally for the demo button, or better, via context
  useEffect(() => {
    const handleSpawn = () => engineRef.current?.spawnBox();
    window.addEventListener('spawn-box', handleSpawn);
    return () => window.removeEventListener('spawn-box', handleSpawn);
  }, []);

  return (
    <div className="w-full h-full relative">
      <div 
        ref={containerRef} 
        className="w-full h-full bg-neutral-900 rounded-lg overflow-hidden shadow-2xl border border-neutral-700"
      />
      
      {error && (
         <div className="absolute inset-0 flex items-center justify-center bg-black/80 z-50">
           <div className="bg-neutral-800 border border-red-500 p-8 rounded-lg max-w-lg text-center shadow-2xl">
             <h3 className="text-red-500 font-bold text-xl mb-4">Graphics Initialization Error</h3>
             <p className="text-neutral-300 mb-4">{error}</p>
             <div className="text-left bg-neutral-900 p-4 rounded text-sm text-neutral-400 font-mono">
                <p className="mb-2 font-bold text-white">Troubleshooting for Chrome/Mac:</p>
                <ol className="list-decimal pl-5 space-y-2">
                   <li>Open Chrome Settings</li>
                   <li>Go to <strong>System</strong></li>
                   <li>Enable <strong>"Use graphics acceleration when available"</strong></li>
                   <li>Restart Chrome</li>
                </ol>
             </div>
           </div>
         </div>
      )}
    </div>
  );
};