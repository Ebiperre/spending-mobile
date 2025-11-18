# Expo Setup Guide

## Quick Start

1. **Install dependencies:**

```bash
npm install
```

2. **Start Expo development server:**

```bash
npm start
# or
expo start
```

3. **Run on your device:**

- Install **Expo Go** app on your phone
- Scan the QR code that appears in the terminal
- The app will load on your device!

## Running on Simulators/Emulators

### iOS Simulator (macOS only)

```bash
npm run ios
```

Requires Xcode to be installed.

### Android Emulator

```bash
npm run android
```

Requires Android Studio and an emulator to be set up.

### Web Browser

```bash
npm run web
```

## Adding Assets

Place your app assets in the `assets/` folder:

- `icon.png` - App icon (1024x1024px)
- `splash.png` - Splash screen (1284x2778px recommended)
- `adaptive-icon.png` - Android adaptive icon (1024x1024px)
- `favicon.png` - Web favicon (48x48px)

## Environment Variables

Create a `.env` file:

```env
API_URL=http://localhost:5000/api
```

To use environment variables, you may need to install `expo-constants`:

```bash
npx expo install expo-constants
```

Then access them:

```typescript
import Constants from 'expo-constants';
const API_URL = Constants.expoConfig?.extra?.apiUrl;
```

## Troubleshooting

### Clear Cache

```bash
expo start -c
# or
npm start -- --reset-cache
```

### Reset Metro Bundler

```bash
npx expo start --clear
```

### Common Issues

1. **"Unable to resolve module"** - Clear cache and reinstall dependencies
2. **QR code not working** - Make sure your phone and computer are on the same network
3. **Build errors** - Check that all dependencies are compatible with Expo SDK version

## Next Steps

1. Set up your backend API URL
2. Create authentication screens
3. Implement the thermometer component
4. Add daily check-in functionality

