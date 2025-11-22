import 'package:antibet/features/auth/providers/user_provider.dart';
import 'package:antibet/features/journal/models/journal_entry_model.dart';
import 'package:antibet/features/journal/presentation/add_entry_screen.dart'; // NOVO: Importa AddEntryScreen
import 'package:antibet/features/journal/presentation/edit_entry_screen.dart'; // NOVO: Importa EditEntryScreen
import 'package:antibet/features/journal/presentation/widgets/journal_entry_item.dart'; // NOVO: Importa Item
import 'package:antibet/features/journal/presentation/widgets/journal_stats.dart';
import 'package:antibet/features/journal/providers/journal_provider.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Ao iniciar a tela, busca o diário para a data de hoje.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchJournal(_selectedDate);
    });
  }

  /// Helper para formatar a data e chamar o provider.
  void _fetchJournal(DateTime date) {
    // Formato esperado pela API (YYYY-MM-DD)
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    ref.read(journalProvider.notifier).getJournal(formattedDate);
  }

  /// Callback para quando uma nova data é selecionada.
  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _fetchJournal(date);
  }

  /// Navega para a tela de Adicionar Entrada.
  void _navigateToAddEntry() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddEntryScreen()),
    );
  }

  /// Navega para a tela de Editar Entrada.
  void _navigateToEditEntry(JournalEntryModel entry) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => EditEntryScreen(entry: entry)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Escuta o estado do Journal para exibir SnackBar em caso de erro.
    ref.listen<JournalState>(journalProvider, (previous, next) {
      next.whenOrNull(
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        },
      );
    });

    // Assiste aos estados de usuário e journal.
    final journalState = ref.watch(journalProvider);
    final userState = ref.watch(userProvider);
    final userName =
        userState.whenOrNull(loaded: (user) => user.name) ?? 'Usuário';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Olá, $userName',
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Botão de Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(userProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Componente de Calendário
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CalendarTimeline(
              key: const ValueKey('journalDatePicker'),
              initialDate: _selectedDate,
              firstDate: DateTime(2024, 1, 1),
              lastDate: DateTime.now(),
              onDateSelected: _onDateSelected,
              leftMargin: 20,
              monthColor: Colors.white70,
              dayColor: Colors.white54,
              dayNameColor: Colors.white54,
              activeDayColor: Colors.white,
              activeBackgroundDayColor: theme.colorScheme.primary,
              dotsColor: Colors.white,
              selectableDayPredicate: (date) => date.day != 23,
              locale: 'pt_BR',
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),

          // 2. Área de Conteúdo (Estado do Diário)
          Expanded(
            child: _buildJournalContent(journalState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // ATUALIZADO: Navega para a tela de adicionar entrada
        onPressed: _navigateToAddEntry,
        backgroundColor: theme.colorScheme.primary, 
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Constrói o widget de conteúdo com base no [JournalState].
  Widget _buildJournalContent(JournalState state) {
    return state.when(
      initial: () => const Center(
        child: Text('Selecione uma data para ver o diário.'),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      loaded: (journal) {
        // Se o diário foi carregado, exibe os status.
        return JournalStats(
          journal: journal,
          // Propriedade para lidar com o tap nas entradas
          onEntryTap: _navigateToEditEntry, 
        );
      },
      error: (message) {
        // Se deu erro, exibe uma mensagem
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Não foi possível carregar o diário. $message',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        );
      },
    );
  }
}