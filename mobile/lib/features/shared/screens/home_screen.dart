import 'package.flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:antibet/features/user/providers/user_provider.dart';
import 'package:antibet/features/journal/providers/journal_provider.dart'; // Para P&L
import 'package:antibet/features/shared/widgets/app_layout.dart';
import 'package:antibet/features/shared/widgets/metric_display_card.dart';
import 'package:antibet/features/shared/widgets/dashboard_item_card.dart';
import 'package:antibet/core/routing/app_router.dart';
import 'package:antibet/core/styles/app_colors.dart';


// O decorator @RoutePage é exigido pelo auto_route
@RoutePage() 
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  
  // Acessa os providers via GetIt
  final UserProvider _userProvider = GetIt.I<UserProvider>();
  final JournalProvider _journalProvider = GetIt.I<JournalProvider>();

  @override
  Widget build(BuildContext context) {
    // Usamos ListenableBuilder múltiplos para reagir a ambos os providers
    return ListenableBuilder(
      listenable: Listenable.merge([_userProvider, _journalProvider]),
      builder: (context, child) {
        
        final userName = _userProvider.currentUser?.name ?? 'Usuário';
        
        // Lógica de placeholder para P&L (em um app real, isso viria do JournalProvider)
        final totalPnl = _journalProvider.entries.fold(0.0, (sum, entry) => sum + entry.pnl);

        return AppLayout(
          appBar: null, // O AppBar é fornecido pela MainShellScreen
          isLoading: _userProvider.isLoading || (_journalProvider.isLoading && _journalProvider.entries.isEmpty),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                
                // --- Cabeçalho de Boas-vindas ---
                Text(
                  'Bem-vindo(a), $userName!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                
                // --- Métrica Principal (P&L) ---
                MetricDisplayCard(
                  title: 'Resultado Acumulado (P&L)',
                  value: totalPnl,
                  unit: 'R\$',
                  showSign: true,
                ),
                const SizedBox(height: 24),
                
                // --- Atalhos de Navegação ---
                Text(
                  'Acesso Rápido',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                DashboardItemCard(
                  icon: const Icon(Icons.book),
                  title: 'Diário de Trades',
                  subtitle: 'Ver e registrar seus lançamentos',
                  color: AppColors.primaryBlue,
                  onTap: () {
                    // Navega para a aba do Diário
                    AutoTabsRouter.of(context).setActiveIndex(1);
                  },
                ),
                const SizedBox(height: 12),

                DashboardItemCard(
                  icon: const Icon(Icons.track_changes),
                  title: 'Metas',
                  subtitle: 'Definir e acompanhar seus objetivos',
                  color: AppColors.accentGreen,
                  onTap: () {
                    // Navega para a aba de Metas
                    AutoTabsRouter.of(context).setActiveIndex(2);
                  },
                ),
                const SizedBox(height: 12),
                
                DashboardItemCard(
                  icon: const Icon(Icons.psychology),
                  title: 'Minhas Estratégias',
                  subtitle: 'Gerenciar suas regras operacionais',
                  color: AppColors.warning,
                  onTap: () {
                    context.router.push(const StrategyListRoute());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}