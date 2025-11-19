import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';

const HistoryScreen = () => {
  // Mock data
  const recentActivity = [
    {id: '1', date: 'Today', amount: 2500, category: 'Food', time: '2:30 PM'},
    {id: '2', date: 'Today', amount: 1200, category: 'Transport', time: '10:00 AM'},
    {id: '3', date: 'Yesterday', amount: 5000, category: 'Shopping', time: '6:45 PM'},
    {id: '4', date: 'Yesterday', amount: 800, category: 'Food', time: '1:15 PM'},
    {id: '5', date: '2 days ago', amount: 3500, category: 'Bills', time: '9:00 AM'},
  ];

  const getCategoryEmoji = (category: string) => {
    const emojis: {[key: string]: string} = {
      'Food': '🍽️',
      'Transport': '🚗',
      'Shopping': '🛍️',
      'Bills': '💡',
      'Entertainment': '🎮',
      'Other': '📝',
    };
    return emojis[category] || '📝';
  };

  return (
    <SafeAreaView style={styles.container} edges={['top', 'bottom']}>
      <View style={styles.header}>
        <Text style={styles.title}>Activity History</Text>
        <Text style={styles.subtitle}>Track your spending journey</Text>
      </View>

      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}>

        {recentActivity.map((item, index) => (
          <View key={item.id}>
            {(index === 0 || recentActivity[index - 1].date !== item.date) && (
              <Text style={styles.dateHeader}>{item.date}</Text>
            )}

            <TouchableOpacity style={styles.activityCard} activeOpacity={0.7}>
              <View style={styles.activityIcon}>
                <Text style={styles.activityEmoji}>{getCategoryEmoji(item.category)}</Text>
              </View>

              <View style={styles.activityDetails}>
                <Text style={styles.activityCategory}>{item.category}</Text>
                <Text style={styles.activityTime}>{item.time}</Text>
              </View>

              <Text style={styles.activityAmount}>₦{item.amount.toLocaleString()}</Text>
            </TouchableOpacity>
          </View>
        ))}

        <View style={styles.emptyState}>
          <Text style={styles.emptyEmoji}>📊</Text>
          <Text style={styles.emptyText}>
            Keep checking in daily to see your spending patterns!
          </Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  header: {
    padding: 20,
    paddingBottom: 12,
  },
  title: {
    fontSize: 28,
    fontWeight: '800',
    color: '#1f2937',
    marginBottom: 4,
  },
  subtitle: {
    fontSize: 15,
    color: '#6b7280',
  },
  scrollContent: {
    padding: 20,
    paddingTop: 8,
    paddingBottom: 40,
  },
  dateHeader: {
    fontSize: 14,
    fontWeight: '700',
    color: '#6b7280',
    marginTop: 16,
    marginBottom: 12,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  activityCard: {
    backgroundColor: '#ffffff',
    borderRadius: 16,
    padding: 16,
    marginBottom: 12,
    flexDirection: 'row',
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
  activityIcon: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: '#f3f4f6',
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 12,
  },
  activityEmoji: {
    fontSize: 24,
  },
  activityDetails: {
    flex: 1,
  },
  activityCategory: {
    fontSize: 16,
    fontWeight: '700',
    color: '#1f2937',
    marginBottom: 2,
  },
  activityTime: {
    fontSize: 13,
    color: '#9ca3af',
    fontWeight: '500',
  },
  activityAmount: {
    fontSize: 18,
    fontWeight: '800',
    color: '#6366f1',
  },
  emptyState: {
    alignItems: 'center',
    marginTop: 40,
    paddingHorizontal: 20,
  },
  emptyEmoji: {
    fontSize: 48,
    marginBottom: 12,
  },
  emptyText: {
    fontSize: 15,
    color: '#9ca3af',
    textAlign: 'center',
    lineHeight: 22,
  },
});

export default HistoryScreen;
