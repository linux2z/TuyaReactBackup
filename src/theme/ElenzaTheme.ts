export const ElenzaTheme = {
  colors: {
    background: '#050505',     // Matte Black - Dark Screen background
    surface: '#121212',        // Graphite Layer 1 - Secondary surfaces
    card: '#1a1a1a',           // Graphite Layer 2 - Floating panels and metric boxes
    graphite: '#2a2a2a',       // Graphite border/button background
    bronze: '#c5a368',         // Luxury Brushed Bronze - Primary indicators & buttons
    bronzeSoft: 'rgba(197, 163, 104, 0.1)',
    green: '#00df81',          // Calibrated / Success / Online state
    greenSoft: 'rgba(0, 223, 129, 0.15)',
    cyan: '#00d2ff',           // Thermodynamic Water System / Metric active state
    cyanSoft: 'rgba(0, 210, 255, 0.15)',
    white: '#ffffff',
    textPrimary: '#ffffff',
    textSecondary: 'rgba(255, 255, 255, 0.6)',
    textMuted: 'rgba(255, 255, 255, 0.3)',
    borderLight: 'rgba(255, 255, 255, 0.05)',
    borderMedium: 'rgba(255, 255, 255, 0.1)',
    glassBackground: 'rgba(255, 255, 255, 0.03)',
  },
  fonts: {
    sans: 'Inter',
    display: 'Space Grotesk',
  },
  typography: {
    brandSubtitle: {
      fontFamily: 'Space Grotesk',
      fontSize: 10,
      letterSpacing: 3.0,
      color: 'rgba(255, 255, 255, 0.4)',
      textTransform: 'uppercase' as const,
      fontWeight: '500' as const,
    },
    brandTitle: {
      fontFamily: 'Space Grotesk',
      fontSize: 18,
      letterSpacing: 4.0,
      color: '#ffffff',
      fontWeight: 'bold' as const,
    },
    sectionTitle: {
      fontFamily: 'Inter',
      fontSize: 10,
      letterSpacing: 1.5,
      color: 'rgba(255, 255, 255, 0.4)',
      textTransform: 'uppercase' as const,
      fontWeight: 'bold' as const,
    },
    metricLabel: {
      fontFamily: 'Inter',
      fontSize: 8,
      letterSpacing: 1.0,
      color: 'rgba(255, 255, 255, 0.4)',
      textTransform: 'uppercase' as const,
      fontWeight: 'bold' as const,
    },
    metricValue: {
      fontFamily: 'Space Grotesk',
      fontSize: 20,
      fontWeight: 'bold' as const,
      color: '#ffffff',
    },
  },
  shadows: {
    bronzeGlow: {
      shadowColor: '#c5a368',
      shadowOffset: { width: 0, height: 0 },
      shadowOpacity: 0.8,
      shadowRadius: 8,
      elevation: 4,
    },
    greenGlow: {
      shadowColor: '#00df81',
      shadowOffset: { width: 0, height: 0 },
      shadowOpacity: 0.6,
      shadowRadius: 8,
      elevation: 4,
    },
    cyanGlow: {
      shadowColor: '#00d2ff',
      shadowOffset: { width: 0, height: 0 },
      shadowOpacity: 0.6,
      shadowRadius: 8,
      elevation: 4,
    },
  },
};
