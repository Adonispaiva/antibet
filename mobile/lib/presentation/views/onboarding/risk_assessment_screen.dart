import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Constantes de Cores de Risco
const Color _lowRiskColor = Color(0xFF4CAF50);    // Verde (baixo)
const Color _mediumRiskColor = Color(0xFFFFC107); // Amarelo (moderado)
const Color _highRiskColor = Color(0xFFF44336);   // Vermelho (alto)

class RiskAssessmentScreen extends StatefulWidget {
  const RiskAssessmentScreen({super.key});

  @override
  State<RiskAssessmentScreen> createState() => _RiskAssessmentScreenState();
}

class _RiskAssessmentScreenState extends State<RiskAssessmentScreen> {
  // Perguntas do DSM-5 simplificado (Escala Likert 0-4)
  final List<String> _questions = const [
    "Você sente necessidade de apostar quantias cada vez maiores para alcançar a mesma emoção?", //
    "Já tentou parar de apostar e não conseguiu?", //
    "Já mentiu para pessoas próximas sobre o quanto gastou com apostas?", //
    "Você aposta para fugir de sentimentos como ansiedade, solidão ou tristeza?", //
    "As apostas já causaram problemas com amigos, família ou trabalho?", //
  ];

  int _currentStep = 0;
  final List<int> _answers = List<int>.filled(5, 0); // Respostas de 0 a 4

  // Estado para o resultado final
  bool _isAssessmentComplete = false;
  int _totalScore = 0;
  String _riskLevel = '';
  Color _riskColor = Colors.grey;

  // Calcula o risco e define o resultado final
  void _calculateRisk() {
    _totalScore = _answers.reduce((a, b) => a + b); // Soma total (máx: 20)

    if (_totalScore <= 5) {
      _riskLevel = 'Baixo';
      _riskColor = _lowRiskColor; //
    } else if (_totalScore <= 12) {
      _riskLevel = 'Moderado';
      _riskColor = _mediumRiskColor; //
    } else {
      _riskLevel = 'Alto';
      _riskColor = _highRiskColor; //
    }
    
    // As respostas devem ser salvas em memória local
    // (Simulação: Aqui, chamaria um service para persistir o score)

    setState(() {
      _isAssessmentComplete = true;
    });
  }

  // Avança para o próximo passo
  void _nextStep() {
    if (_currentStep < _questions.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else if (_currentStep == _questions.length - 1) {
      _calculateRisk();
    }
  }

  // Volta para o passo anterior
  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliação de Risco'), //
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 16.0, right: 16.0),
            child: Text(
              _isAssessmentComplete ? 'Resultado da Avaliação' : 'Isso nos ajudará a entender como te apoiar melhor.', //
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isAssessmentComplete ? _buildResultScreen(context) : _buildQuestionStep(context),
        ),
      ),
    );
  }

  // Constrói a tela de perguntas
  Widget _buildQuestionStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LinearProgressIndicator(
          value: (_currentStep + 1) / _questions.length,
          minHeight: 8,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
        const SizedBox(height: 30),
        Text(
          'Pergunta ${_currentStep + 1} de ${_questions.length}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 10),
        Text(
          _questions[_currentStep],
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        
        // Escala Likert (0 a 4)
        for (int i = 0; i <= 4; i++) 
          RadioListTile<int>(
            title: Text(
              _getLikertLabel(i),
              style: TextStyle(fontWeight: _answers[_currentStep] == i ? FontWeight.bold : FontWeight.normal),
            ),
            value: i,
            groupValue: _answers[_currentStep],
            onChanged: (int? value) {
              if (value != null) {
                setState(() {
                  _answers[_currentStep] = value;
                });
              }
            },
          ),

        const Spacer(),
        
        // Botões de Navegação
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _currentStep > 0 ? _prevStep : null,
              child: const Text('Anterior', style: TextStyle(fontSize: 18)),
            ),
            ElevatedButton(
              onPressed: _nextStep,
              child: Text(_currentStep < _questions.length - 1 ? 'Próxima' : 'Finalizar', style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ],
    );
  }

  // Constrói a tela de resultado
  Widget _buildResultScreen(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.psychology_alt_outlined, 
          size: 80, 
          color: _riskColor,
        ),
        const SizedBox(height: 20),
        const Text(
          'Seu nível de risco atual é:', //
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
        ),
        const SizedBox(height: 10),
        Text(
          _riskLevel, // Baixo, Moderado ou Alto
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: _riskColor,
          ),
        ),
        const SizedBox(height: 40),
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: _riskColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(5),
          ),
          width: _riskLevel == 'Baixo' ? 100 : _riskLevel == 'Moderado' ? 200 : 300, // Indicador visual
        ),
        const SizedBox(height: 50),
        ElevatedButton(
          onPressed: () {
            // Continua para o plano de apoio (Home)
            context.go('/home'); 
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _riskColor,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text(
            'Continuar para plano de apoio', //
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }
  
  // Função para dar rótulos descritivos à escala 0-4
  String _getLikertLabel(int value) {
    switch (value) {
      case 0: return 'Nunca ou Quase Nunca';
      case 1: return 'Raramente';
      case 2: return 'Às Vezes';
      case 3: return 'Frequentemente';
      case 4: return 'Quase Sempre ou Sempre';
      default: return '';
    }
  }
}