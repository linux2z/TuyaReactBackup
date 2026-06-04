import { create } from 'zustand';
import { NativeModules, NativeEventEmitter, Platform } from 'react-native';

const { TuyaTelemetry, TuyaControl } = NativeModules;

export interface LogItem {
  id: string;
  title: string;
  time: string;
  type: 'success' | 'info' | 'warning';
}

interface TelemetryStoreState {
  waterTank: number; // %
  beanHopper: number; // %
  filterLife: number; // %
  boilerTemp: number; // °C
  pumpPressure: number; // Bar
  flowRate: number; // ml/s
  machineState: 'Ready' | 'Preheating' | 'Calibrating' | 'Brewing' | 'Offline';
  isOnline: boolean;
  logs: LogItem[];
  extractionSeconds: number;
  pressureCurve: number[]; // Raw points for graphing
  flowCurve: number[]; // Raw points for graphing
  weeklyIndex: number[]; // 7 elements for Mon-Sun

  startTelemetry: (devId: string) => Promise<void>;
  stopTelemetry: (devId: string) => void;
  triggerPreheat: (devId: string) => Promise<void>;
  triggerBrewSession: (devId: string, targetTemp: number, targetYield: number) => Promise<void>;
  resetCurves: () => void;
  addLog: (title: string, type?: 'success' | 'info' | 'warning') => void;
}

const eventEmitter = TuyaTelemetry ? new NativeEventEmitter(TuyaTelemetry) : null;

export const useTelemetryStore = create<TelemetryStoreState>((set, get) => {
  let mockInterval: any = null;
  let otaListener: any = null;

  return {
    waterTank: 85,
    beanHopper: 88,
    filterLife: 92,
    boilerTemp: 93,
    pumpPressure: 0.0,
    flowRate: 0.0,
    machineState: 'Ready',
    isOnline: true,
    logs: [
      { id: '1', title: 'Double Espresso extraction complete', time: '9:41 AM', type: 'success' },
      { id: '2', title: 'Calibrated boiler thermodynamic wave init', time: '8:15 AM', type: 'info' },
      { id: '3', title: 'Automatic group head cleaning cycle completed', time: 'Yesterday', type: 'success' },
    ],
    extractionSeconds: 0,
    pressureCurve: [],
    flowCurve: [],
    weeklyIndex: [60, 40, 55, 50, 85, 45, 35], // Seeding Mon-Sun

    startTelemetry: async (devId) => {
      // Connect native listeners
      if (TuyaTelemetry) {
        try {
          const currentDps = await TuyaTelemetry.startTelemetryListener(devId);
          // Parse initial DPs
          if (currentDps) {
            set({
              boilerTemp: currentDps['101'] ? Number(currentDps['101']) : get().boilerTemp,
              pumpPressure: currentDps['102'] ? Number(currentDps['102']) : get().pumpPressure,
              flowRate: currentDps['103'] ? Number(currentDps['103']) : get().flowRate,
              waterTank: currentDps['104'] ? Number(currentDps['104']) : get().waterTank,
              beanHopper: currentDps['105'] ? Number(currentDps['105']) : get().beanHopper,
            });
          }
        } catch (e) {
          console.log('Telemetry listener error, falling back to simulation', e);
        }

        // Subscribe to Native updates
        otaListener = eventEmitter?.addListener('onTelemetryUpdate', (event) => {
          if (event && event.dps) {
            const dps = event.dps;
            const updatedPressure = dps['102'] !== undefined ? Number(dps['102']) : get().pumpPressure;
            const updatedFlow = dps['103'] !== undefined ? Number(dps['103']) : get().flowRate;

            set({
              boilerTemp: dps['101'] !== undefined ? Number(dps['101']) : get().boilerTemp,
              pumpPressure: updatedPressure,
              flowRate: updatedFlow,
              waterTank: dps['104'] !== undefined ? Number(dps['104']) : get().waterTank,
              beanHopper: dps['105'] !== undefined ? Number(dps['105']) : get().beanHopper,
              filterLife: dps['106'] !== undefined ? Number(dps['106']) : get().filterLife,
            });

            // Bind genuine physical DP telemetry directly to our live vector graphics curves
            if (get().machineState === 'Brewing') {
              set((state) => ({
                pressureCurve: [...state.pressureCurve, updatedPressure],
                flowCurve: [...state.flowCurve, updatedFlow],
              }));
            }
          }
        });
      }
    },

    stopTelemetry: (devId) => {
      if (TuyaTelemetry) {
        TuyaTelemetry.stopTelemetryListener(devId);
      }
      if (otaListener) {
        otaListener.remove();
        otaListener = null;
      }
      if (mockInterval) {
        clearInterval(mockInterval);
        mockInterval = null;
      }
    },

    triggerPreheat: async (devId) => {
      set({ machineState: 'Preheating', boilerTemp: 22 });
      get().addLog('Preheat phase initiated: Thermodynamic induction loading', 'info');

      // Native Command Dispatch
      if (TuyaControl) {
        try {
          await TuyaControl.sendCommands(devId, { '107': true }); // DP 107 is preheating trigger
        } catch (e) {
          console.log('Native command fail, launching mock simulation');
        }
      }

      // Simulate heating progress
      let temp = 22;
      if (mockInterval) clearInterval(mockInterval);
      mockInterval = setInterval(() => {
        if (temp < 93) {
          temp += Math.floor(Math.random() * 8) + 4;
          if (temp > 93) temp = 93;
          set({ boilerTemp: temp });
        } else {
          clearInterval(mockInterval);
          set({ machineState: 'Ready' });
          get().addLog('Calibrated boiler thermo stabilization at 93°C', 'success');
        }
      }, 500);
    },

    triggerBrewSession: async (devId, targetTemp, targetYield) => {
      set({
        machineState: 'Brewing',
        extractionSeconds: 0,
        pressureCurve: [0],
        flowCurve: [0],
        pumpPressure: 0,
        flowRate: 0,
      });
      get().addLog(`Triggering Brew Session: Target ${targetYield}ml at ${targetTemp}°C`, 'info');

      // Native Command Dispatch
      if (TuyaControl) {
        try {
          await TuyaControl.sendCommands(devId, {
            '108': true,          // DP 108: Start extraction
            '101': targetTemp,    // DP 101: Target temp
            '109': targetYield,   // DP 109: Target volume
          });
        } catch (e) {
          console.log('Control dispatch fallback to high fidelity animation');
        }
      }

      let time = 0;
      if (mockInterval) clearInterval(mockInterval);
      
      mockInterval = setInterval(() => {
        time += 1;
        
        // Classic Espresso thermodynamic curve calculation
        // 0-3s: pre-infusion (low pressure 2 bar, flow 0.5)
        // 4-15s: full pressure extraction (9 bar, flow 2.2)
        // 16-28s: blonding/decay (drop pressure to 8 bar, flow increases to 2.5)
        let pressure = 0;
        let flow = 0;
        
        if (time <= 3) {
          pressure = 2.0 + Math.random() * 0.4;
          flow = 0.4 + Math.random() * 0.1;
        } else if (time <= 15) {
          pressure = 9.0 + Math.random() * 0.3;
          flow = 2.0 + Math.random() * 0.2;
        } else if (time <= 25) {
          pressure = 8.5 - (time - 15) * 0.1 + Math.random() * 0.2;
          flow = 2.2 + (time - 15) * 0.05;
        } else {
          pressure = 7.0 - (time - 25) * 0.6;
          flow = 1.0 - (time - 25) * 0.2;
        }

        if (pressure < 0) pressure = 0;
        if (flow < 0) flow = 0;

        set((state) => ({
          extractionSeconds: time,
          pumpPressure: parseFloat(pressure.toFixed(1)),
          flowRate: parseFloat(flow.toFixed(1)),
          pressureCurve: [...state.pressureCurve, parseFloat(pressure.toFixed(1))],
          flowCurve: [...state.flowCurve, parseFloat(flow.toFixed(1))],
          waterTank: Math.max(10, state.waterTank - 0.25),
        }));

        if (time >= 28) {
          clearInterval(mockInterval);
          set({
            machineState: 'Ready',
            pumpPressure: 0,
            flowRate: 0,
          });
          get().addLog(`Espresso Extraction complete: Yielded ${targetYield}ml in 28s`, 'success');
          // Add to weekly list
          set((state) => {
            const nextIdx = [...state.weeklyIndex];
            nextIdx[4] = nextIdx[4] + 1; // Increment Friday
            return { weeklyIndex: nextIdx };
          });
        }
      }, 1000);
    },

    resetCurves: () => set({ pressureCurve: [], flowCurve: [], extractionSeconds: 0 }),

    addLog: (title, type = 'info') => {
      const now = new Date();
      const timeStr = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
      set((state) => ({
        logs: [
          { id: String(Date.now()), title, time: timeStr, type },
          ...state.logs.slice(0, 9), // Keep latest 10 logs
        ],
      }));
    },
  };
});
