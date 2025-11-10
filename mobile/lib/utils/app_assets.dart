/**
 * Arquivo de Constantes para Assets (Caminhos de Imagens e Ícones).
 * O desenvolvedor deve garantir que as imagens existam nas pastas de assets.
 */
class AppAssets {
  // -----------------------------------------------------------------
  // LOGOS E MARCAS (Baseado na Entidade User.avatarName e Inovexa logo)
  // -----------------------------------------------------------------
  static const String logoAntiBet = 'assets/images/logo_antibet.png';
  static const String logoInovexa = 'assets/images/logo_inovexa.png';

  // -----------------------------------------------------------------
  // AVATARES (Baseado nos arquivos .jpg recebidos)
  // -----------------------------------------------------------------
  // NOTE: Os arquivos jpg devem ser convertidos para PNG ou usados como tal
  static const String avatarBento = 'assets/images/avatar_bento.png';
  static const String avatarLumen = 'assets/images/avatar_lumen.png';
  static const String avatarLuzia = 'assets/images/avatar_luzia.png';
  static const String avatarNara = 'assets/images/avatar_nara.png';
  static const String avatarTheo = 'assets/images/avatar_theo.png';

  // Mapeamento para uso no futuro
  static const Map<String, String> avatarMap = {
    'Bento': avatarBento,
    'Lumen': avatarLumen,
    'Luzia': avatarLuzia,
    'Nara': avatarNara,
    'Theo': avatarTheo,
  };
  
  // -----------------------------------------------------------------
  // ÍCONES DE NAVEGAÇÃO
  // -----------------------------------------------------------------
  static const String iconBrain = 'assets/icons/brain.svg'; // Avaliação
  static const String iconHome = 'assets/icons/home.svg';     // Início
  static const String iconChat = 'assets/icons/chat.svg';     // Chat
  static const String iconSos = 'assets/icons/sos.svg';       // SOS
  static const String iconProgress = 'assets/icons/progress.svg'; // Progresso
}