import React, { useState, useCallback } from 'react';
import { SimulationView } from './components/SimulationView';
import { ControlPanel } from './components/ControlPanel';
import { IPLCState } from './types';

const App: React.FC = () => {
  // We lift the simulation state up to React to drive the UI.
  // Note: The simulation loop runs independently for performance, 
  // but calls a callback to update this state.
  const [plcState, setPlcState] = useState<IPLCState>({
    inputs: {},
    outputs: {},
    timers: {},
  });

  // Wrap in useCallback to ensure reference stability if passed down
  const handlePLCUpdate = useCallback((newState: IPLCState) => {
    // In a high-frequency loop, we might want to debounce this or use a ref,
    // but for this demo, standard state updates work fine.
    setPlcState(newState);
  }, []);

  return (
    <div className="relative w-full h-screen bg-neutral-900 flex flex-col">
      {/* Header */}
      <header className="absolute top-0 w-full p-4 z-10 pointer-events-none">
        <h1 className="text-2xl font-bold text-white tracking-tight drop-shadow-md">
          Industrial<span className="text-blue-500">Sim</span>
          <span className="text-neutral-400 font-light ml-2 text-sm">v1.0.0</span>
        </h1>
      </header>

      {/* 3D Viewport */}
      <main className="flex-1 w-full h-full relative">
        <SimulationView onPLCUpdate={handlePLCUpdate} />
        
        {/* UI Overlay */}
        <ControlPanel plcState={plcState} />
        
        {/* Instructions */}
        <div className="absolute bottom-4 right-4 text-right text-neutral-400 text-sm pointer-events-none select-none">
          <p>Left Click: Rotate Camera</p>
          <p>Right Click: Pan Camera</p>
          <p>Scroll: Zoom</p>
        </div>
      </main>
    </div>
  );
};

export default App;
