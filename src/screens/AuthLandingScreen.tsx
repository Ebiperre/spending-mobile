import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';
import {StackNavigationProp} from '@react-navigation/stack';
import {RootStackParamList} from '../navigation/AppNavigator';
import {LinearGradient} from 'expo-linear-gradient';

type AuthLandingScreenNavigationProp = StackNavigationProp<
  RootStackParamList,
  'AuthLanding'
>;

interface Props {
  navigation: AuthLandingScreenNavigationProp;
}

const AuthLandingScreen: React.FC<Props> = ({navigation}) => {
  return (
    <SafeAreaView style={styles.container} edges={['top']}>
      <LinearGradient
        colors={['#6366f1', '#8b5cf6']}
        start={{x: 0, y: 0}}
        end={{x: 0, y: 1}}
        style={styles.gradient}>
        <ScrollView
          contentContainerStyle={styles.scrollContent}
          showsVerticalScrollIndicator={false}>

          {/* Hero Section */}
          <View style={styles.hero}>
            <Text style={styles.thermometerEmoji}>🌡️</Text>

            <Text style={styles.mainTitle}>
              Spending{'\n'}Thermometer
            </Text>

            <Text style={styles.tagline}>
              Make your salary reach month end
            </Text>
          </View>

          {/* Problem Statement */}
          <View style={styles.problemBox}>
            <Text style={styles.problemEmoji}>😅</Text>
            <Text style={styles.problemText}>
              "My salary don finish before month end!"
            </Text>
            <Text style={styles.solutionText}>
              Track your spending in just 10 seconds daily
            </Text>
          </View>

          {/* Features */}
          <View style={styles.features}>
            <FeatureItem
              emoji="⚡"
              text="Quick daily check-ins"
            />
            <FeatureItem
              emoji="🌡️"
              text="See your spending temperature"
            />
            <FeatureItem
              emoji="💰"
              text="Make your money last longer"
            />
          </View>

        </ScrollView>

        {/* Fixed Bottom Buttons */}
        <View style={styles.buttonsContainer}>
          <TouchableOpacity
            style={styles.primaryButton}
            onPress={() => navigation.navigate('SignUp')}
            activeOpacity={0.8}>
            <Text style={styles.primaryButtonText}>
              Get Started Free
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.secondaryButton}
            onPress={() => navigation.navigate('SignIn')}
            activeOpacity={0.8}>
            <Text style={styles.secondaryButtonText}>
              Sign In
            </Text>
          </TouchableOpacity>
        </View>
      </LinearGradient>
    </SafeAreaView>
  );
};

interface FeatureItemProps {
  emoji: string;
  text: string;
}

const FeatureItem: React.FC<FeatureItemProps> = ({emoji, text}) => (
  <View style={styles.featureItem}>
    <Text style={styles.featureEmoji}>{emoji}</Text>
    <Text style={styles.featureText}>{text}</Text>
  </View>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  gradient: {
    flex: 1,
  },
  scrollContent: {
    paddingHorizontal: 24,
    paddingTop: 60,
    paddingBottom: 180, // Space for fixed buttons
  },
  hero: {
    alignItems: 'center',
    marginBottom: 40,
  },
  thermometerEmoji: {
    fontSize: 80,
    marginBottom: 20,
  },
  mainTitle: {
    fontSize: 42,
    fontWeight: '800',
    color: '#FFFFFF',
    textAlign: 'center',
    marginBottom: 16,
    lineHeight: 48,
    textShadowColor: 'rgba(0, 0, 0, 0.2)',
    textShadowOffset: {width: 0, height: 2},
    textShadowRadius: 4,
  },
  tagline: {
    fontSize: 18,
    color: '#FFFFFF',
    textAlign: 'center',
    lineHeight: 26,
    fontWeight: '500',
    opacity: 0.95,
  },
  problemBox: {
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    borderRadius: 20,
    padding: 24,
    marginBottom: 32,
    alignItems: 'center',
    borderWidth: 2,
    borderColor: 'rgba(255, 255, 255, 0.3)',
  },
  problemEmoji: {
    fontSize: 40,
    marginBottom: 12,
  },
  problemText: {
    fontSize: 20,
    fontWeight: '700',
    color: '#FFFFFF',
    marginBottom: 12,
    textAlign: 'center',
  },
  solutionText: {
    fontSize: 16,
    color: '#FFFFFF',
    textAlign: 'center',
    lineHeight: 22,
    opacity: 0.9,
  },
  features: {
    gap: 16,
    marginBottom: 32,
  },
  featureItem: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.15)',
    borderRadius: 16,
    padding: 20,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.25)',
  },
  featureEmoji: {
    fontSize: 32,
    marginRight: 16,
  },
  featureText: {
    fontSize: 17,
    fontWeight: '600',
    color: '#FFFFFF',
    flex: 1,
  },
  buttonsContainer: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    paddingHorizontal: 24,
    paddingBottom: 32,
    paddingTop: 20,
    backgroundColor: 'rgba(99, 102, 241, 0.95)',
    borderTopWidth: 1,
    borderTopColor: 'rgba(255, 255, 255, 0.2)',
    gap: 12,
  },
  primaryButton: {
    backgroundColor: '#ffffff',
    borderRadius: 16,
    paddingVertical: 18,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  primaryButtonText: {
    color: '#6366f1',
    fontSize: 18,
    fontWeight: '700',
  },
  secondaryButton: {
    paddingVertical: 16,
    alignItems: 'center',
    borderRadius: 16,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    borderWidth: 2,
    borderColor: '#ffffff',
  },
  secondaryButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
});

export default AuthLandingScreen;
