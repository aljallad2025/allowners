/// إعدادات الاتصال بمشروع Supabase الخاص بتطبيق All Owners
///
/// هذه القيم عامة (Public) وآمنة للاستخدام داخل التطبيق طالما
/// تم تفعيل Row Level Security (RLS) على كل الجداول في قاعدة البيانات
/// (وهو مفعّل فعلاً حسب ملف schema.sql).
class SupabaseConfig {
  static const String url = 'https://swlpqgampxqidfrefvxy.supabase.co';

  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN3bHBxZ2FtcHhxaWRmcmVmdnh5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMwMjc5ODcsImV4cCI6MjA5ODYwMzk4N30.iZb77dkcXeBcdOO6SGfZJuHm9KAbEuSS_Ov719a_3ok';
}
