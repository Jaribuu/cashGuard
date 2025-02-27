import 'dart:convert';

class UserSettings {
  final String currency;
  final String themeMode;
  final bool notificationsEnabled;
  final bool budgetAlertsEnabled;
  final int budgetAlertThreshold; // Percentage threshold for budget alerts
  final bool savingsReminderEnabled;
  final int savingsReminderDay; // Day of month for reminder

  const UserSettings({
    this.currency = 'USD',
    this.themeMode = 'system',
    this.notificationsEnabled = true,
    this.budgetAlertsEnabled = true,
    this.budgetAlertThreshold = 80, // Default alert at 80% of budget
    this.savingsReminderEnabled = true,
    this.savingsReminderDay = 1, // Default to 1st of month
  });

  UserSettings copyWith({
    String? currency,
    String? themeMode,
    bool? notificationsEnabled,
    bool? budgetAlertsEnabled,
    int? budgetAlertThreshold,
    bool? savingsReminderEnabled,
    int? savingsReminderDay,
  }) {
    return UserSettings(
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      budgetAlertsEnabled: budgetAlertsEnabled ?? this.budgetAlertsEnabled,
      budgetAlertThreshold: budgetAlertThreshold ?? this.budgetAlertThreshold,
      savingsReminderEnabled: savingsReminderEnabled ?? this.savingsReminderEnabled,
      savingsReminderDay: savingsReminderDay ?? this.savingsReminderDay,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currency': currency,
      'themeMode': themeMode,
      'notificationsEnabled': notificationsEnabled,
      'budgetAlertsEnabled': budgetAlertsEnabled,
      'budgetAlertThreshold': budgetAlertThreshold,
      'savingsReminderEnabled': savingsReminderEnabled,
      'savingsReminderDay': savingsReminderDay,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      currency: map['currency'] ?? 'USD',
      themeMode: map['themeMode'] ?? 'system',
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      budgetAlertsEnabled: map['budgetAlertsEnabled'] ?? true,
      budgetAlertThreshold: map['budgetAlertThreshold'] ?? 80,
      savingsReminderEnabled: map['savingsReminderEnabled'] ?? true,
      savingsReminderDay: map['savingsReminderDay'] ?? 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserSettings.fromJson(String source) => UserSettings.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserSettings(currency: $currency, themeMode: $themeMode, notificationsEnabled: $notificationsEnabled, budgetAlertsEnabled: $budgetAlertsEnabled, budgetAlertThreshold: $budgetAlertThreshold, savingsReminderEnabled: $savingsReminderEnabled, savingsReminderDay: $savingsReminderDay)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserSettings &&
        other.currency == currency &&
        other.themeMode == themeMode &&
        other.notificationsEnabled == notificationsEnabled &&
        other.budgetAlertsEnabled == budgetAlertsEnabled &&
        other.budgetAlertThreshold == budgetAlertThreshold &&
        other.savingsReminderEnabled == savingsReminderEnabled &&
        other.savingsReminderDay == savingsReminderDay;
  }

  @override
  int get hashCode {
    return currency.hashCode ^
    themeMode.hashCode ^
    notificationsEnabled.hashCode ^
    budgetAlertsEnabled.hashCode ^
    budgetAlertThreshold.hashCode ^
    savingsReminderEnabled.hashCode ^
    savingsReminderDay.hashCode;
  }
}