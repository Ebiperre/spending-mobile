// User types
export interface User {
  id: string;
  full_name: string;
  email: string;
  phone: string;
  gender?: 'male' | 'female' | 'other';
  avatar_url?: string;
  created_at?: string;
}

// Auth types
export interface RegisterData {
  full_name: string;
  email: string;
  phone: string;
  password: string;
  gender?: 'male' | 'female' | 'other';
}

export interface LoginData {
  email: string;
  password: string;
}

export interface AuthResponse {
  user: User;
  token: string;
  refreshToken: string;
}

// API Response types
export interface ApiResponse<T> {
  success: boolean;
  message?: string;
  data?: T;
  errors?: any[];
}

// Financial Profile types
export interface FinancialProfile {
  id: string;
  user_id: string;
  monthly_income: number;
  currency: string;
  fixed_expenses: number;
  savings_goal: number;
  payday_day: number;
  payday_frequency: 'monthly' | 'bi-weekly' | 'weekly';
}

// Spending Cycle types
export interface SpendingCycle {
  id: string;
  user_id: string;
  financial_profile_id: string;
  cycle_start_date: string;
  cycle_end_date: string;
  budget_amount: number;
  spent_amount: number;
  temperature: number; // 0-100
  status: 'active' | 'completed' | 'cancelled';
}

// Daily Check-in types
export interface DailyCheckin {
  id: string;
  user_id: string;
  spending_cycle_id: string;
  checkin_date: string;
  amount_spent: number;
  mood?: 'happy' | 'neutral' | 'stressed' | 'worried' | 'excited';
  notes?: string;
}

