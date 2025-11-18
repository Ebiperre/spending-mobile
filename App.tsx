/**
 * Spending Thermometer Mobile App
 * Main entry point for Expo
 */

import React from 'react';
import {StatusBar} from 'expo-status-bar';
import AppNavigator from './src/navigation/AppNavigator';

export default function App() {
  return (
    <>
      <AppNavigator />
      <StatusBar style="auto" />
    </>
  );
}
