// Arquivo centralizado para Constantes Imutáveis (Strings, Números, Chaves)

class AppConstants {
  // --- IDENTIDADE E MARCA ---
  static const String appName = 'AntiBet Mobile';
  static const String slogan = 'IA mudando vidas.';

  // --- PERSONA DA IA ---
  static const String iaName = 'AntiBet Coach';
  
  // --- CHAVES DE PERSISTÊNCIA (SharedPreferences) ---
  static const String userProfileKey = 'user_profile_data';
  static const String authTokenKey = 'auth_token_key';
  static const String consentKey = 'user_accepted_consent';
  static const String darkModeKey = 'app_dark_mode';
  static const String lockdownKey = 'isLockdownActive';
  
  // --- LIMITES E THRESHOLDS ---
  // Limite de escore a partir do qual o risco é considerado ALTO (0.0 a 1.0)
  static const double highRiskThreshold = 0.70; 
  
  // Duração mínima do modo de pânico (24 horas)
  static const Duration minLockdownDuration = Duration(hours: 24); 

  // --- COMPLIANCE E LINKS (simulação) ---
  static const String policyUrl = 'https://inovexa.com/antibet/privacy-policy';
  static const String ethicalStatement = 'O AntiBet NÃO é um substituto para terapia clínica. Nosso objetivo é fornecer apoio e educação baseada em evidências, em estrita conformidade com a LGPD.';
  
  // --- ROTAS (Simulação para contexto) ---
  static const String homeRoute = '/home';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String assessmentRoute = '/assessment';
}