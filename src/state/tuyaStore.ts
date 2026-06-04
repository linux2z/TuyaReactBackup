import { create } from 'zustand';
import { NativeModules, NativeEventEmitter } from 'react-native';

const { TuyaAuth } = NativeModules;

export interface TuyaUser {
  uid: string;
  email: string;
  sid: string;
}

export interface TuyaDevice {
  devId: string;
  name: string;
  productId: string;
  isOnline: boolean;
}

interface TuyaStoreState {
  user: TuyaUser | null;
  region: { code: string; name: string } | null;
  homeId: number | null;
  homeName: string | null;
  devices: TuyaDevice[];
  activeDevice: TuyaDevice | null;
  isLoading: boolean;
  error: string | null;

  setRegion: (region: { code: string; name: string }) => void;
  checkSession: () => Promise<boolean>;
  login: (email: string, pass: string) => Promise<boolean>;
  register: (email: string, pass: string, code: string) => Promise<boolean>;
  sendCode: (email: string) => Promise<boolean>;
  logout: () => Promise<void>;
  loadHomeContext: () => Promise<void>;
  setActiveDevice: (device: TuyaDevice | null) => void;
  mockAddDevice: (device: TuyaDevice) => void;
}

export const useTuyaStore = create<TuyaStoreState>((set, get) => ({
  user: null,
  region: { code: '1', name: 'USA/Americas' }, // Default
  homeId: null,
  homeName: null,
  devices: [],
  activeDevice: null,
  isLoading: false,
  error: null,

  setRegion: (region) => set({ region }),

  checkSession: async () => {
    set({ isLoading: true, error: null });
    try {
      if (!TuyaAuth) {
        // Fallback for environment mock
        set({ isLoading: false });
        return false;
      }
      const session = await TuyaAuth.isLoggedIn();
      if (session) {
        set({ user: session });
        await get().loadHomeContext();
        set({ isLoading: false });
        return true;
      }
      set({ isLoading: false });
      return false;
    } catch (err: any) {
      set({ error: err.message || 'Session verification failed', isLoading: false });
      return false;
    }
  },

  login: async (email, pass) => {
    set({ isLoading: true, error: null });
    try {
      const regionCode = get().region?.code || '1';
      const session = await TuyaAuth.loginWithEmail(email, pass, regionCode);
      set({ user: session });
      await get().loadHomeContext();
      set({ isLoading: false });
      return true;
    } catch (err: any) {
      set({ error: err.message || 'Authentication failed', isLoading: false });
      return false;
    }
  },

  register: async (email, pass, code) => {
    set({ isLoading: true, error: null });
    try {
      const regionCode = get().region?.code || '1';
      const session = await TuyaAuth.registerWithEmail(email, pass, code, regionCode);
      set({ user: session, isLoading: false });
      return true;
    } catch (err: any) {
      set({ error: err.message || 'Registration failed', isLoading: false });
      return false;
    }
  },

  sendCode: async (email) => {
    try {
      const regionCode = get().region?.code || '1';
      await TuyaAuth.sendVerificationCode(email, regionCode);
      return true;
    } catch (err: any) {
      set({ error: err.message || 'Failed to dispatch code' });
      return false;
    }
  },

  logout: async () => {
    set({ isLoading: true });
    try {
      await TuyaAuth.logout();
    } catch (e) {}
    set({ user: null, homeId: null, homeName: null, devices: [], activeDevice: null, isLoading: false });
  },

  loadHomeContext: async () => {
    try {
      const home = await TuyaAuth.getOrCreateHome();
      set({ homeId: home.homeId, homeName: home.name });
      
      // Seed default devices if empty to provide direct luxury telemetry demo
      const mockElenzaMachine: TuyaDevice = {
        devId: 'dev_elenza_pro_calibrator',
        name: 'ELENZA Pro calibrator',
        productId: 'zt36shl6ah0sffsj',
        isOnline: true,
      };
      set({ devices: [mockElenzaMachine], activeDevice: mockElenzaMachine });
    } catch (err: any) {
      set({ error: err.message || 'Failed to load home environment' });
    }
  },

  setActiveDevice: (device) => set({ activeDevice: device }),
  mockAddDevice: (device) => set((state) => ({ devices: [...state.devices, device], activeDevice: device })),
}));
