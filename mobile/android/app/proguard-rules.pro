# Regras R8/ProGuard customizadas para o projeto AntiBet.

# --- Regras Padrão Flutter ---
# Mantém classes e métodos usados pelo mecanismo de reflexão do Flutter.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class com.google.firebase.** { *; } # Se Firebase for adicionado

# --- Regras para Bibliotecas Usadas ---

# 1. flutter_secure_storage
# Garante que as classes de criptografia do AndroidX Security sejam mantidas.
-keep class androidx.security.crypto.** { *; }
-keep class androidx.security.** { *; }

# 2. Dio (Networking)
# Garante que os modelos usados pelo Dio para serialização/desserialização
# e classes de reflexão sejam mantidos.
-keepnames class * implements java.io.Serializable
-keepclassmembers class * {
  <fields>;
  <methods>;
}

# 3. Modelos (Mantenha os modelos de dados se eles usarem reflexão)
# Se usarmos JSON serialization manual, isso não é estritamente necessário,
# mas é uma boa prática manter as classes de modelo que podem ser acessadas via reflexão.
-keepnames class com.inovexa.antibet.features.**.models.** { *; }

# Mantém todos os construtores para que o R8 não os remova
-keepclassmembers class * {
  <init>(...);
}