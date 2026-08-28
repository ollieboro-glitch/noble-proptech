/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./src/**/*.{html,js}'],
  // Classes composed dynamically at runtime (e.g. `border-l-${x ? 'red-500' : 'neon-500'}`)
  // can't be discovered by Tailwind's scanner, so force-generate them here.
  safelist: [
    'border-l-red-500',
    'border-l-green-500',
    'border-l-neon-500',
    'border-l-transparent',
    'bg-red-500',
    'bg-neon-500',
    'text-red-500',
    'text-neon-500',
    'border-red-500',
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', '-apple-system', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
      colors: {
        carbon: { 900: '#09090b', 800: '#111113', 700: '#18181b', 600: '#27272a' },
        neon: { 400: '#FF6A00', 500: '#FF4D00', 600: '#E63E00' },
        brand: { 400: '#FF6A00', 500: '#FF4D00', 600: '#E63E00', 800: '#7A2600', 900: '#4A1700' },
        pureblack: '#09090b',
        purewhite: '#fafafa',
      },
      borderRadius: {
        DEFAULT: '8px',
      },
      boxShadow: {
        'neon': '0 1px 3px rgba(255, 77, 0, 0.15)',
        'neon-hover': '0 4px 12px rgba(0,0,0,0.3)',
        'cinematic': '0 4px 24px rgba(0,0,0,0.4)',
        'sharp': '0 1px 3px rgba(0,0,0,0.3)',
        'sharp-dark': '0 4px 16px rgba(0,0,0,0.4)',
      },
    },
  },
};
