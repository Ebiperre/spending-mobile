import React from 'react';
import {View, Text, StyleSheet} from 'react-native';

const HomeScreen = () => {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>🌡️ Spending Thermometer</Text>
      <Text style={styles.subtitle}>
        Make your salary reach month end - without the wahala of manual tracking
      </Text>
      <Text style={styles.description}>
        A financial wellness app designed specifically for Nigerian salary earners
      </Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 24,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#fff',
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    marginBottom: 16,
    textAlign: 'center',
    color: '#1a1a1a',
  },
  subtitle: {
    fontSize: 18,
    marginBottom: 12,
    textAlign: 'center',
    fontStyle: 'italic',
    color: '#666',
  },
  description: {
    fontSize: 16,
    textAlign: 'center',
    color: '#888',
    paddingHorizontal: 20,
  },
});

export default HomeScreen;

