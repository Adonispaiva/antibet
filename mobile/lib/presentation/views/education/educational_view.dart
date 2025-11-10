import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// O Módulo Educacional Interativo visa fornecer psicoeducação e reforçar a base científica.

class EducationalView extends StatelessWidget {
  const EducationalView({super.key});

  // Lista de temas principais (Mini-aulas)
  final List<Map<String, dynamic>> _educationalTopics = const [
    {
      'title': 'Neurociência do Vício',
      'subtitle': 'Os efeitos biológicos e psicológicos das apostas no seu cérebro.',
      'icon': Icons.psychology_alt,
      'color': Colors.deepPurple,
      'route': '/education/neuroscience',
    },
    {
      'title': 'RNG, RTP e o Mito do Ganho',
      'subtitle': 'Entenda por que é quase impossível ganhar a longo prazo.', //
      'icon': Icons.functions,
      'color': Colors.orange,
      'route': '/education/rng_rtp',
    },
    {
      'title': 'A Indústria por Trás do Jogo',
      'subtitle': 'Como as casas de aposta lucram com as perdas dos jogadores.', //
      'icon': Icons.business,
      'color': Colors.red,
      'route': '/education/industry',
    },
    {
      'title': 'Estratégias de Saída (TCC/MI)',
      'subtitle': 'Técnicas de Terapia Cognitivo-Comportamental e Entrevista Motivacional.', //
      'icon': Icons.lightbulb,
      'color': Colors.green,
      'route': '/education/strategies',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo Educacional'),
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Aprenda para Vencer',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'O conhecimento é sua melhor defesa. Nossas mini-aulas e materiais são baseados em evidência científica.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),

            // Módulos de Mini-Aulas
            ..._educationalTopics.map((topic) => _buildTopicCard(
                  context,
                  title: topic['title']!,
                  subtitle: topic['subtitle']!,
                  icon: topic['icon']!,
                  color: topic['color']!,
                  route: topic['route']!,
                )),
            
            const SizedBox(height: 40),
            
            const Divider(),
            const SizedBox(height: 20),

            // Quizzes Interativos
            _buildQuizCard(context),
          ],
        ),
      ),
    );
  }

  // Widget para os tópicos de educação
  Widget _buildTopicCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required String route}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => context.go(route),
      ),
    );
  }

  // Widget para o Quiz
  Widget _buildQuizCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blueGrey[200]!),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          const Icon(Icons.quiz, color: Colors.blue, size: 40),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quizzes Interativos: Você conhece os riscos?', //
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 5),
                Text(
                  'Teste seu conhecimento e reforce o aprendizado com desafios rápidos.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => context.go('/education/quiz'),
            child: const Text('Iniciar'),
          ),
        ],
      ),
    );
  }
}