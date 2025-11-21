import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:antibet/features/notification/providers/notification_provider.dart';
import 'package:antibet/features/shared/widgets/app_layout.dart'; // Importação do AppLayout
import 'package:antibet/features/shared/widgets/empty_state_widget.dart'; // Importação do EmptyStateWidget
import 'package:antibet/core/styles/app_colors.dart';


// O decorator @RoutePage é exigido pelo auto_route
@RoutePage()
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationProvider _notificationProvider = GetIt.I<NotificationProvider>();

  @override
  void initState() {
    super.initState();
    // Dispara o carregamento inicial dos dados após o widget ser montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationProvider.fetchNotifications();
    });
  }

  /// Marca a notificação como lida ao ser tocada.
  void _onNotificationTap(String notificationId, bool isRead) {
    if (!isRead) {
      _notificationProvider.markNotificationAsRead(notificationId);
    }
    // Adicionar lógica de navegação para o conteúdo relacionado
  }

  /// Deleta a notificação quando o item é arrastado.
  Future<void> _onDismissed(String notificationId) async {
     try {
       await _notificationProvider.deleteNotification(notificationId);
     } catch (e) {
       // O erro é tratado no provider, mas a mensagem pode ser exibida
       if(mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Falha ao deletar: ${e.toString()}')),
         );
       }
     }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _notificationProvider,
      builder: (context, child) {
        
        final bool isLoading = _notificationProvider.isLoading && _notificationProvider.notifications.isEmpty;

        Widget content;

        // 2. Error State
        if (_notificationProvider.errorMessage != null && _notificationProvider.notifications.isEmpty) {
          content = EmptyStateWidget.error(
            title: 'Erro ao Carregar',
            subtitle: _notificationProvider.errorMessage,
            action: ElevatedButton.icon(
              onPressed: _notificationProvider.fetchNotifications,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          );
        }
        
        // 3. Empty State
        else if (_notificationProvider.notifications.isEmpty && !_notificationProvider.isLoading) {
          content = EmptyStateWidget.noData(
            title: 'Caixa de Entrada Vazia',
            subtitle: 'Suas notificações do sistema e de trades aparecerão aqui.',
          );
        }
        
        // 4. Data Display
        else {
          content = ListView.builder(
            itemCount: _notificationProvider.notifications.length,
            itemBuilder: (context, index) {
              final notification = _notificationProvider.notifications[index];
              
              return Dismissible(
                key: ValueKey(notification.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: AppColors.failure,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(Icons.delete, color: AppColors.textLight),
                ),
                onDismissed: (direction) {
                  _onDismissed(notification.id);
                },
                child: ListTile(
                  tileColor: notification.isRead ? AppColors.surfaceLight : AppColors.primaryBlue.withOpacity(0.05),
                  leading: Icon(
                    notification.isRead ? Icons.email_outlined : Icons.email,
                    color: notification.isRead ? AppColors.textSecondary : AppColors.primaryBlue,
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold),
                  ),
                  subtitle: Text(notification.body),
                  onTap: () => _onNotificationTap(notification.id, notification.isRead),
                ),
              );
            },
          );
        }
        
        // Estrutura principal com AppLayout
        return AppLayout(
          appBar: AppBar(
            title: const Text('Notificações'),
            actions: [
              // Botão opcional para marcar todas como lidas
              IconButton(
                icon: const Icon(Icons.mark_email_read),
                onPressed: isLoading ? null : () {
                  // _notificationProvider.markAllAsRead(); // Funcionalidade futura
                },
              ),
            ],
          ),
          isLoading: isLoading,
          child: Padding(
            padding: EdgeInsets.zero, // Remove o padding horizontal para a lista
            child: content,
          ),
        );
      },
    );
  }
}