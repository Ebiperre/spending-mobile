import React, {useState} from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  TextInput,
  Alert,
} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';

const DashboardScreen = () => {
  const [todaySpending, setTodaySpending] = useState('');
  const [showCheckIn, setShowCheckIn] = useState(false);

  // Mock data - will be replaced with actual data from API
  const currentCycle = {
    budget: 50000,
    spent: 15000,
    daysLeft: 18,
    temperature: 30, // 0-100
  };

  const getTemperatureColor = (temp: number) => {
    if (temp < 30) return '#10b981'; // Green - Cool
    if (temp < 60) return '#f59e0b'; // Yellow - Warm
    if (temp < 80) return '#f97316'; // Orange - Hot
    return '#ef4444'; // Red - Very Hot
  };

  const getTemperatureStatus = (temp: number) => {
    if (temp < 30) return {label: 'Cool', emoji: '😎', message: 'You dey do well!'};
    if (temp < 60) return {label: 'Warm', emoji: '🙂', message: 'Manage am well o'};
    if (temp < 80) return {label: 'Hot', emoji: '😰', message: 'Easy with the spending!'};
    return {label: 'Very Hot', emoji: '🔥', message: 'Abeg stop spending!'};
  };

  const handleQuickCheckIn = () => {
    if (!todaySpending.trim()) {
      Alert.alert('Oya!', 'Enter how much you spent today');
      return;
    }

    const amount = parseFloat(todaySpending);
    if (isNaN(amount) || amount < 0) {
      Alert.alert('Oya!', 'Enter a valid amount');
      return;
    }

    // TODO: Save to API
    Alert.alert(
      'Checked In! 🎉',
      `₦${amount.toLocaleString()} added to today's spending`,
      [{text: 'OK', onPress: () => {
        setTodaySpending('');
        setShowCheckIn(false);
      }}]
    );
  };

  const temperature = currentCycle.temperature;
  const temperatureColor = getTemperatureColor(temperature);
  const tempStatus = getTemperatureStatus(temperature);
  const percentSpent = (currentCycle.spent / currentCycle.budget) * 100;
  const remaining = currentCycle.budget - currentCycle.spent;
  const dailyBudget = Math.round(remaining / currentCycle.daysLeft);

  return (
    <SafeAreaView style={styles.container} edges={['top', 'bottom']}>
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}>

        {/* Header */}
        <View style={styles.header}>
          <View>
            <Text style={styles.greeting}>Hello! 👋</Text>
            <Text style={styles.date}>
              {new Date().toLocaleDateString('en-NG', {
                weekday: 'long',
                month: 'long',
                day: 'numeric'
              })}
            </Text>
          </View>
        </View>

        {/* Main Thermometer Card */}
        <View style={styles.mainCard}>
          <View style={styles.thermometerSection}>
            <View style={styles.thermometerWrapper}>
              {/* Thermometer */}
              <View style={styles.thermometerContainer}>
                <View style={styles.thermometerBulb}>
                  <View style={[styles.thermometerBulbInner, {backgroundColor: temperatureColor}]} />
                </View>
                <View style={styles.thermometerTube}>
                  <View
                    style={[
                      styles.thermometerFill,
                      {
                        height: `${temperature}%`,
                        backgroundColor: temperatureColor,
                      }
                    ]}
                  />
                  {/* Scale Markers */}
                  <View style={styles.scaleMarkers}>
                    {[100, 75, 50, 25, 0].map((mark) => (
                      <View key={mark} style={styles.scaleMarker}>
                        <View style={styles.markerLine} />
                        <Text style={styles.markerText}>{mark}</Text>
                      </View>
                    ))}
                  </View>
                </View>
              </View>

              {/* Temperature Display */}
              <View style={styles.temperatureDisplay}>
                <Text style={styles.statusEmoji}>{tempStatus.emoji}</Text>
                <Text style={[styles.temperatureValue, {color: temperatureColor}]}>
                  {temperature}°
                </Text>
                <Text style={styles.temperatureLabel}>{tempStatus.label}</Text>
                <Text style={styles.statusMessage}>{tempStatus.message}</Text>
              </View>
            </View>
          </View>

          {/* Spending Summary */}
          <View style={styles.summarySection}>
            <View style={styles.summaryRow}>
              <Text style={styles.summaryLabel}>Spent</Text>
              <Text style={styles.summaryValue}>
                ₦{currentCycle.spent.toLocaleString()}
              </Text>
            </View>
            <View style={styles.progressBarContainer}>
              <View style={styles.progressBar}>
                <View
                  style={[
                    styles.progressFill,
                    {
                      width: `${percentSpent}%`,
                      backgroundColor: temperatureColor,
                    }
                  ]}
                />
              </View>
            </View>
            <View style={styles.summaryRow}>
              <Text style={styles.summaryLabel}>Budget</Text>
              <Text style={styles.summaryValue}>
                ₦{currentCycle.budget.toLocaleString()}
              </Text>
            </View>
          </View>
        </View>

        {/* Stats Cards */}
        <View style={styles.statsContainer}>
          <View style={[styles.statCard, styles.statCardPrimary]}>
            <Text style={styles.statIcon}>💰</Text>
            <Text style={[styles.statValue, {color: '#ffffff'}]}>₦{remaining.toLocaleString()}</Text>
            <Text style={[styles.statLabel, {color: 'rgba(255, 255, 255, 0.9)'}]}>Left to spend</Text>
          </View>

          <View style={styles.statCard}>
            <Text style={styles.statIcon}>📅</Text>
            <Text style={styles.statValue}>{currentCycle.daysLeft}</Text>
            <Text style={styles.statLabel}>Days remaining</Text>
          </View>

          <View style={styles.statCard}>
            <Text style={styles.statIcon}>📊</Text>
            <Text style={styles.statValue}>₦{dailyBudget.toLocaleString()}</Text>
            <Text style={styles.statLabel}>Daily budget</Text>
          </View>
        </View>

        {/* Quick Check-In Button */}
        {!showCheckIn ? (
          <TouchableOpacity
            style={styles.checkInButton}
            onPress={() => setShowCheckIn(true)}
            activeOpacity={0.8}>
            <Text style={styles.checkInButtonIcon}>⚡</Text>
            <Text style={styles.checkInButtonText}>Quick Check-In</Text>
          </TouchableOpacity>
        ) : (
          <View style={styles.checkInCard}>
            <Text style={styles.checkInTitle}>How much did you spend today?</Text>

            <View style={styles.inputContainer}>
              <Text style={styles.currencySymbol}>₦</Text>
              <TextInput
                style={styles.input}
                placeholder="0"
                placeholderTextColor="#999"
                value={todaySpending}
                onChangeText={setTodaySpending}
                keyboardType="numeric"
                autoFocus
              />
            </View>

            <View style={styles.checkInActions}>
              <TouchableOpacity
                style={styles.cancelButton}
                onPress={() => {
                  setShowCheckIn(false);
                  setTodaySpending('');
                }}
                activeOpacity={0.8}>
                <Text style={styles.cancelButtonText}>Cancel</Text>
              </TouchableOpacity>

              <TouchableOpacity
                style={styles.submitButton}
                onPress={handleQuickCheckIn}
                activeOpacity={0.8}>
                <Text style={styles.submitButtonText}>Submit</Text>
              </TouchableOpacity>
            </View>
          </View>
        )}

      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  scrollContent: {
    padding: 20,
    paddingBottom: 40,
  },
  header: {
    marginBottom: 24,
  },
  greeting: {
    fontSize: 32,
    fontWeight: '800',
    color: '#1f2937',
    marginBottom: 4,
  },
  date: {
    fontSize: 15,
    color: '#6b7280',
    fontWeight: '500',
  },
  mainCard: {
    backgroundColor: '#ffffff',
    borderRadius: 24,
    padding: 24,
    marginBottom: 20,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 4,
  },
  thermometerSection: {
    marginBottom: 24,
  },
  thermometerWrapper: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  thermometerContainer: {
    alignItems: 'center',
  },
  thermometerBulb: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: '#f3f4f6',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: -15,
    zIndex: 2,
    borderWidth: 3,
    borderColor: '#ffffff',
  },
  thermometerBulbInner: {
    width: 36,
    height: 36,
    borderRadius: 18,
  },
  thermometerTube: {
    width: 32,
    height: 220,
    backgroundColor: '#f3f4f6',
    borderRadius: 16,
    overflow: 'hidden',
    position: 'relative',
  },
  thermometerFill: {
    width: '100%',
    position: 'absolute',
    bottom: 0,
    borderRadius: 16,
  },
  scaleMarkers: {
    position: 'absolute',
    right: -30,
    top: 0,
    height: '100%',
    justifyContent: 'space-between',
    paddingVertical: 5,
  },
  scaleMarker: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  markerLine: {
    width: 8,
    height: 1,
    backgroundColor: '#d1d5db',
    marginRight: 4,
  },
  markerText: {
    fontSize: 10,
    color: '#9ca3af',
    fontWeight: '600',
  },
  temperatureDisplay: {
    alignItems: 'center',
    flex: 1,
  },
  statusEmoji: {
    fontSize: 48,
    marginBottom: 12,
  },
  temperatureValue: {
    fontSize: 56,
    fontWeight: '800',
    marginBottom: 4,
  },
  temperatureLabel: {
    fontSize: 20,
    fontWeight: '700',
    color: '#4b5563',
    marginBottom: 8,
  },
  statusMessage: {
    fontSize: 15,
    color: '#6b7280',
    fontWeight: '500',
  },
  summarySection: {
    gap: 12,
  },
  summaryRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  summaryLabel: {
    fontSize: 15,
    color: '#6b7280',
    fontWeight: '600',
  },
  summaryValue: {
    fontSize: 17,
    fontWeight: '700',
    color: '#1f2937',
  },
  progressBarContainer: {
    paddingVertical: 4,
  },
  progressBar: {
    height: 8,
    backgroundColor: '#f3f4f6',
    borderRadius: 4,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    borderRadius: 4,
  },
  statsContainer: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 20,
  },
  statCard: {
    flex: 1,
    backgroundColor: '#ffffff',
    borderRadius: 16,
    padding: 16,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 1,
    },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  statCardPrimary: {
    backgroundColor: '#6366f1',
  },
  statIcon: {
    fontSize: 24,
    marginBottom: 8,
  },
  statValue: {
    fontSize: 18,
    fontWeight: '800',
    color: '#1f2937',
    marginBottom: 4,
  },
  statLabel: {
    fontSize: 11,
    color: '#6b7280',
    fontWeight: '600',
    textAlign: 'center',
  },
  checkInButton: {
    backgroundColor: '#6366f1',
    borderRadius: 20,
    paddingVertical: 18,
    paddingHorizontal: 24,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#6366f1',
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 6,
  },
  checkInButtonIcon: {
    fontSize: 20,
    marginRight: 8,
  },
  checkInButtonText: {
    color: '#ffffff',
    fontSize: 18,
    fontWeight: '700',
  },
  checkInCard: {
    backgroundColor: '#ffffff',
    borderRadius: 20,
    padding: 24,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 4,
  },
  checkInTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#1f2937',
    marginBottom: 16,
    textAlign: 'center',
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#f9fafb',
    borderRadius: 16,
    borderWidth: 2,
    borderColor: '#e5e7eb',
    paddingHorizontal: 20,
    marginBottom: 16,
  },
  currencySymbol: {
    fontSize: 24,
    fontWeight: '700',
    color: '#6b7280',
    marginRight: 8,
  },
  input: {
    flex: 1,
    fontSize: 28,
    fontWeight: '700',
    color: '#1f2937',
    paddingVertical: 16,
  },
  checkInActions: {
    flexDirection: 'row',
    gap: 12,
  },
  cancelButton: {
    flex: 1,
    backgroundColor: '#f3f4f6',
    borderRadius: 14,
    paddingVertical: 14,
    alignItems: 'center',
  },
  cancelButtonText: {
    color: '#6b7280',
    fontSize: 16,
    fontWeight: '700',
  },
  submitButton: {
    flex: 1,
    backgroundColor: '#6366f1',
    borderRadius: 14,
    paddingVertical: 14,
    alignItems: 'center',
  },
  submitButtonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '700',
  },
});

export default DashboardScreen;
