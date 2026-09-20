/// اختصار للنصوص ثنائية اللغة داخل الشاشات: tr(isArabic, 'عربي', 'English')
String tr(bool isArabic, String ar, String en) => isArabic ? ar : en;
