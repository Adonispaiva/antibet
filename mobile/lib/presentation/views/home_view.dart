import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; 

// Importação dos Notifiers, Modelo de Usuário e Rotas
import '../../notifiers/auth_notifier.dart';
import '../../notifiers/dashboard_notifier.dart'; 
import '../../notifiers/lockdown_notifier.dart'; 
import '../../notifiers/help_and_alerts_notifier.dart'; 
import '../../notifiers/behavioral_analytics_notifier.dart'; 
import '../../core/domain/user_model.dart'; 
import '../../core/domain/dashboard_content_model.dart'; 
import '../../core/domain/behavioral_analytics_model.dart'; 
import '../../core/navigation/app_router.dart'; 
import '../widgets/risk_intervention_widget.dart'; // Novo

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  /// Manipulador de Logout
  Future<void> _handleLogout(BuildContext context) async {
    // ... (Código de Logout)
    final authNotifier = context.read<AuthNotifier>();
    try {
      await authNotifier.logout();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao sair. Tente novamente.')),
      );
    }
  }

  /// Manipulador do Botão de Pânico (Missão Anti-Vício)
  Future<void> _handlePanicButton(BuildContext context) async {
    // ... (Código do Botão de Pânico)
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, 
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ ATIVAR BLOQUEIO DE EMERGÊNCIA?'),
        content: const Text(
          'Você está prestes a ativar o bloqueio de emergência (Modo Pânico) por 24 horas.\n\n'
          'O acesso às áreas de controle será bloqueado e você será direcionado para a tela de ajuda.\n\n'
          'Esta ação não pode ser desfeita.'
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true), 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ATIVAR BLOQUEIO', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (confirmed) {
      try {
        await context.read<HelpAndAlertsNotifier>().triggerAlert('Botão de Pânico (SOS) Ativado');
        await context.read<LockdownNotifier>().activateLockdown(const Duration(hours: 24));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao ativar o bloqueio. Tente novamente.')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // Escuta o AuthNotifier para obter informações do usuário
    final UserModel? user = context.watch<AuthNotifier>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen - AntiBet Mobile'),
        automaticallyImplyLeading: false, 
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Título de Boas-Vindas
              Text(
                'Bem-vindo, ${user?.email.split('@').first ?? 'Convidado'}!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // ÁREA DO DASHBOARD (Combinação de Notifiers)
              Consumer2<DashboardNotifier, BehavioralAnalyticsNotifier>(
                builder: (context, dashboardNotifier, analyticsNotifier, child) {
                  
                  // Espera ambos os notifiers carregarem
                  if (dashboardNotifier.state == DashboardState.loading || 
                      analyticsNotifier.state == AnalyticsState.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Trata erro de qualquer um dos notifiers
                  if (dashboardNotifier.state == DashboardState.error) {
                    return _buildErrorWidget(context, dashboardNotifier);
                  }
                  if (analyticsNotifier.state == AnalyticsState.error) {
                    return _buildAnalyticsErrorWidget(context, analyticsNotifier);
                  }

                  // Se ambos estiverem carregados
                  if (dashboardNotifier.state == DashboardState.loaded && 
                      analyticsNotifier.state == AnalyticsState.loaded) {
                    
                    return Column(
                      children: [
                        // NOVO: Widget de Intervenção Ativa (SOS)
                        const RiskInterventionWidget(), 

                        _buildContentWidget(
                          context, 
                          dashboardNotifier.content!,
                          analyticsNotifier.model, // Passa o modelo de análise
                        ),
                      ],
                    );
                  }
                  
                  return const SizedBox.shrink(); // Fallback para o caso de estado inicial ou outro estado não coberto
                },
              ),

              const SizedBox(height: 40), 

              // BOTÕES DE NAVEGAÇÃO E LOGOUT
              _buildNavigationButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets de Erro ---
  Widget _buildErrorWidget(BuildContext context, DashboardNotifier notifier) {
    return Column(
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 50),
        const SizedBox(height: 10),
        Text(
          'Falha ao carregar métricas: ${notifier.errorMessage}', 
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: notifier.fetchDashboardContent,
          child: const Text('Tentar Novamente'),
        ),
      ],
    );
  }
  
  Widget _buildAnalyticsErrorWidget(BuildContext context, BehavioralAnalyticsNotifier notifier) {
    return Column(
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 50),
        const SizedBox(height: 10),
        Text(
          'Falha ao calcular Escore de Risco: ${notifier.errorMessage}', 
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: notifier.calculateAnalytics,
          child: const Text('Tentar Novamente'),
        ),
      ],
    );
  }


  // --- Widget de Conteúdo ---
  Widget _buildContentWidget(BuildContext context, DashboardContentModel content, BehavioralAnalyticsModel analytics) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    // Determina a cor do Escore de Risco (Missão Anti-Vício)
    final double riskScore = analytics.riskScore;
    Color riskColor;
    String riskText;

    if (riskScore < 0.3) {
      riskColor = Colors.green;
      riskText = "Baixo Risco";
    } else if (riskScore < 0.7) {
      riskColor = Colors.orange;
      riskText = "Risco Moderado";
    } else {
      riskColor = Colors.red;
      riskText = "Alto Risco";
    }

    return Column(
      children: [
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('Seu Resumo de Controle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const Divider(),
                
                // ESCORE DE RISCO
                _buildMetricRow(
                  'Seu Escore de Risco:', 
                  riskText, 
                  Icons.shield,
                  valueColor: riskColor,
                ),
                const Divider(),

                _buildMetricRow('Total de Análises:', '${content.totalBetsAnalyzed}', Icons.analytics),
                _buildMetricRow('Saldo (Simulado):', currencyFormatter.format(content.currentBalance), Icons.account_balance_wallet),
                const SizedBox(height: 10),
                Text(
                  content.recentActivityTitle ?? 'Nenhuma atividade recente.',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(String title, String value, IconData icon, {Color? valueColor}) {
     return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16)),
            ],
          ),
          Text(
            value, 
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.w600,
              color: valueColor, 
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Column(
      children: [
        // Botão 1: Navegar para o Perfil
        ElevatedButton.icon(
          onPressed: () => context.goNamed(AppRoute.profile.name),
          icon: const Icon(Icons.person),
          label: const Text('Acessar Meu Perfil', style: TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
        ),
        const SizedBox(height: 15),

        // Botão 2: Navegar para Estratégias (Regras de Controle)
        ElevatedButton.icon(
          onPressed: () => context.goNamed(AppRoute.strategies.name), 
          icon: const Icon(Icons.psychology),
          label: const Text('Minhas Regras de Controle', style: TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
        ),
        const SizedBox(height: 15),

        // Botão 3: Navegar para Configurações
        ElevatedButton.icon(
          onPressed: () => context.goNamed(AppRoute.settings.name), 
          icon: const Icon(Icons.settings),
          label: const Text('Configurações', style: TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
        ),
        const SizedBox(height: 20),
        
        // Botão 4: Botão de Ajuda (Recursos)
        ElevatedButton.icon(
          onPressed: () => context.goNamed(AppRoute.help.name), 
          icon: const Icon(Icons.support_agent), 
          label: const Text('Precisa de Ajuda?', style: TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            backgroundColor: Colors.orange[700], 
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 20),

        // Botão 5: Botão de Pânico (SOS)
        ElevatedButton.icon(
          onPressed: () => _handlePanicButton(context),
          icon: const Icon(Icons.lock_clock), 
          label: const Text('BLOQUEIO DE PÂNICO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20), 
            backgroundColor: Colors.red[800], 
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 20),

        // Botão 6: Logout
        ElevatedButton.icon(
          onPressed: () => _handleLogout(context),
          icon: const Icon(Icons.logout),
          label: const Text('Logout', style: TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            backgroundColor: Colors.red[400],
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}