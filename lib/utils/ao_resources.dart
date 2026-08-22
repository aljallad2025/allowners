/// نفس قائمة الموارد والإجراءات المعرّفة بالسيرفر (includes/permissions.php)
/// لازم تبقى مطابقة تماماً عشان الصلاحيات تشتغل صح بين التطبيق والموقع
const Map<String, List<String>> aoResources = {
  'units': ['view', 'create', 'edit', 'delete', 'approve'],
  'bookings': ['view', 'create', 'edit', 'delete', 'approve'],
  'guests': ['view', 'create', 'edit'],
  'pricing': ['view', 'create', 'edit', 'approve'],
  'revenue': ['view', 'approve'],
  'expenses': ['view', 'create', 'edit', 'approve'],
  'reports': ['view'],
  'contracts': ['view', 'create', 'edit', 'approve'],
  'maintenance': ['view', 'create', 'edit', 'approve'],
  'housekeeping': ['view', 'create', 'edit'],
  'meals': ['view', 'create', 'edit', 'approve'],
};

String aoResourceLabel(String resource, bool isArabic) {
  const labels = {
    'units': {'ar': 'الوحدات', 'en': 'Units'},
    'bookings': {'ar': 'الحجوزات', 'en': 'Bookings'},
    'guests': {'ar': 'الضيوف', 'en': 'Guests'},
    'pricing': {'ar': 'الأسعار', 'en': 'Pricing'},
    'revenue': {'ar': 'الإيرادات', 'en': 'Revenue'},
    'expenses': {'ar': 'المصروفات', 'en': 'Expenses'},
    'reports': {'ar': 'التقارير', 'en': 'Reports'},
    'contracts': {'ar': 'العقود', 'en': 'Contracts'},
    'maintenance': {'ar': 'الصيانة', 'en': 'Maintenance'},
    'housekeeping': {'ar': 'التنظيف', 'en': 'Housekeeping'},
    'meals': {'ar': 'الوجبات', 'en': 'Meals'},
  };
  return labels[resource]?[isArabic ? 'ar' : 'en'] ?? resource;
}

String aoActionLabel(String action, bool isArabic) {
  const labels = {
    'view': {'ar': 'مشاهدة', 'en': 'View'},
    'create': {'ar': 'إضافة', 'en': 'Create'},
    'edit': {'ar': 'تعديل', 'en': 'Edit'},
    'delete': {'ar': 'حذف', 'en': 'Delete'},
    'approve': {'ar': 'موافقة', 'en': 'Approve'},
  };
  return labels[action]?[isArabic ? 'ar' : 'en'] ?? action;
}
