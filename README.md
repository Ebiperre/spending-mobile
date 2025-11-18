# Spending Thermometer 🌡️ Mobile

> Make your salary reach month end - without the wahala of manual tracking

A React Native mobile app built with Expo, designed specifically for Nigerian salary earners to track spending, visualize their budget using a temperature metaphor, and join a supportive community.

## 🎯 Project Overview

**Problem:** Nigerian salary earners spend their entire salary within 3-7 days, leaving them broke until next payday.

**Solution:** A mobile app with:

- 🌡️ **Temperature-based spending visualization**
- ⚡ **10-second daily check-ins** (no manual logging!)
- 🗣️ **Nigerian Pidgin English** support
- 👥 **Anonymous confession wall** for community support
- 📊 **Smart spending insights** and recommendations

## 📁 Project Structure

```
spending-mobile/
├── src/
│   ├── screens/          # Screen components
│   ├── navigation/        # Navigation setup
│   ├── services/          # API services
│   ├── types/             # TypeScript types
│   └── components/        # Reusable components
├── assets/                # Images, fonts, etc.
├── App.tsx                # Main app component
├── index.js               # Entry point
├── app.json               # Expo configuration
└── package.json
```

## 🚀 Getting Started

### Prerequisites

- Node.js (v18 or higher)
- npm or yarn
- Expo Go app on your phone (for testing)
- Or iOS Simulator / Android Emulator

### Installation

1. **Install dependencies:**

```bash
npm install
# or
yarn install
```

2. **Start the Expo development server:**

```bash
npm start
# or
yarn start
# or
expo start
```

3. **Run on your device:**

- **iOS:** Press `i` in the terminal or scan QR code with Camera app
- **Android:** Press `a` in the terminal or scan QR code with Expo Go app
- **Web:** Press `w` in the terminal

### Running on Physical Device

1. Install **Expo Go** app:
   - [iOS App Store](https://apps.apple.com/app/expo-go/id982107779)
   - [Google Play Store](https://play.google.com/store/apps/details?id=host.exp.exponent)

2. Start the dev server: `npm start`

3. Scan the QR code with:
   - **iOS:** Camera app
   - **Android:** Expo Go app

## 🎨 Tech Stack

### Core

- **Framework:** React Native with Expo SDK 50
- **Language:** TypeScript
- **Navigation:** React Navigation 6
- **Storage:** AsyncStorage

### Features

- **State Management:** React Context (can be upgraded to Zustand/Redux)
- **API Client:** Fetch API
- **Styling:** StyleSheet (can add NativeWind/Tamagui)

### Future Integrations

- **Payments:** Paystack SDK
- **Push Notifications:** Expo Notifications
- **Image Hosting:** Cloudinary
- **Analytics:** Mixpanel
- **Crash Reporting:** Sentry

## 🔐 Environment Variables

Create a `.env` file in the root directory:

```env
API_URL=http://localhost:5000/api
```

For production, update the API_URL to your backend server.

**Note:** To use environment variables in Expo, you may need to install `expo-constants` and configure them properly.

## 📱 Development Workflow

### Start Development Server

```bash
npm start
```

This will open Expo DevTools in your browser and show a QR code.

### Run on Specific Platform

```bash
# iOS Simulator (macOS only)
npm run ios

# Android Emulator
npm run android

# Web browser
npm run web
```

### Building for Production

**Development Build:**

```bash
# iOS
eas build --platform ios --profile development

# Android
eas build --platform android --profile development
```

**Production Build:**

```bash
# iOS
eas build --platform ios --profile production

# Android
eas build --platform android --profile production
```

**Note:** You'll need to set up [Expo Application Services (EAS)](https://docs.expo.dev/build/introduction/) for building.

## 🧪 Testing

```bash
npm test
# or
yarn test
```

## 📝 Code Structure

### Screens

- `HomeScreen` - Welcome/home screen
- `LoginScreen` - User authentication (to be created)
- `RegisterScreen` - User registration (to be created)
- `DashboardScreen` - Main dashboard with thermometer (to be created)
- `CheckinScreen` - Daily check-in flow (to be created)
- `ConfessionsScreen` - Community confession wall (to be created)

### Services

- `api.ts` - API service for backend communication
- `storage.ts` - Local storage utilities (to be created)
- `auth.ts` - Authentication helpers (to be created)

### Types

- `index.ts` - TypeScript type definitions

## 🎯 MVP Features (Phase 1)

- [x] Project setup with Expo
- [ ] User authentication (register/login)
- [ ] Financial profile setup
- [ ] Spending cycle creation
- [ ] Daily check-in system
- [ ] Thermometer visualization
- [ ] Basic dashboard
- [ ] Morning briefing
- [ ] Evening check-in flow

## 📅 Roadmap

### Phase 1: MVP (Months 1-2)

- Core authentication
- Financial setup
- Daily check-ins
- Thermometer display
- Basic notifications

### Phase 2: Enhanced (Months 3-4)

- Confession wall
- Reactions & comments
- Leaderboards
- Streak tracking
- Weekly challenges

### Phase 3: Scale (Months 5-6)

- Premium subscriptions (Paystack)
- Advanced analytics
- Export reports
- Push notifications
- Offline support

## 🤝 Contributing

This is currently a private project. For questions or collaboration:

- Open an issue
- Contact the development team

## 📄 License

Proprietary - All rights reserved

## 👥 Team

- **Product Owner:** [Your Name]
- **Lead Developer:** [Developer Name]
- **UI/UX Designer:** [Designer Name]

## 🆘 Support

For setup issues:

1. Check Node.js version: `node --version` (should be >= 18)
2. Verify Expo CLI: `npx expo --version`
3. Clear cache: `expo start -c` or `npm start -- --reset-cache`
4. Check [Expo Documentation](https://docs.expo.dev/)

## 🔗 Links

- [Expo Documentation](https://docs.expo.dev/)
- [React Native Documentation](https://reactnative.dev/docs/getting-started)
- [React Navigation](https://reactnavigation.org/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)

---

**Built with ❤️ for Nigerian salary earners**

*"Make your salary reach month end!"* 🚀
