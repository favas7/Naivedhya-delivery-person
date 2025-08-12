class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://plhvaeegrhzvkqlltzyb.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBsaHZhZWVncmh6dmtxbGx0enliIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4MTU3NTEsImV4cCI6MjA2NzM5MTc1MX0.1t4BRB4p_BQWWUBSz0IO6B3wjLHWySuqnhNgLpjE8RY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBsaHZhZWVncmh6dmtxbGx0enliIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4MTU3NTEsImV4cCI6MjA2NzM5MTc1MX0.1t4BRB4p_BQWWUBSz0IO6B3wjLHWySuqnhNgLpjE8RY',
  );
}