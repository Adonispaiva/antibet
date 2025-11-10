/*
 * NOTA DE DIREÇÃO:
 * v1.3 - Ativando a Personalização.
 * O método 'generateResponse' agora aceita um 'systemPrompt' (para contexto)
 * e um 'userPrompt' (para a pergunta do usuário).
 * (v1.2 - Conector OpenAI implementado, Relatório 28/10)
 * (v1.1 - Lógica de Custos/Roteamento, Relatório 27/10)
 */

import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import OpenAI from 'openai';
import { IA_MODELS, AiModel, AiModelName } from './ia-models.config'; // (v1.1)

@Injectable()
export class AiGatewayService {
  private openai: OpenAI;

  constructor(private readonly configService: ConfigService) {
    const apiKey = this.configService.get<string>('GPT_API_KEY'); // (v1.2)
    if (!apiKey) {
      throw new InternalServerErrorException('Chave da API GPT não configurada.');
    }
    this.openai = new OpenAI({ apiKey });
  }

  /**
   * Obtém as especificações de um modelo (custo, nome)
   * (v1.1 - Relatório 27/10)
   */
  getModel(modelName: AiModelName): AiModel {
    const model = IA_MODELS[modelName];
    if (!model) {
      throw new InternalServerErrorException(`Modelo de IA '${modelName}' não encontrado.`);
    }
    return model;
  }

  /**
   * Gera uma resposta de IA usando o modelo especificado (GPT).
   * v1.3: Agora aceita prompts de sistema e usuário.
   */
  async generateResponse(
    modelName: AiModelName,
    systemPrompt: string, // (Novo)
    userPrompt: string, // (Alterado)
  ): Promise<string> {
    const modelConfig = this.getModel(modelName);

    try {
      // (v1.2 - Lógica GPT)
      const completion = await this.openai.chat.completions.create({
        model: modelConfig.apiName, // ex: 'gpt-4-turbo'
        temperature: 0.7, // Um equilíbrio entre criatividade e precisão
        messages: [
          {
            role: 'system',
            content: systemPrompt, // Instruções de contexto
          },
          {
            role: 'user',
            content: userPrompt, // Pergunta do usuário
          },
        ],
      });

      const response = completion.choices[0]?.message?.content;
      if (!response) {
        throw new InternalServerErrorException('Resposta da IA veio vazia.');
      }
      return response;
    } catch (error) {
      // Lidar com erros da API da OpenAI
      throw new InternalServerErrorException(
        `Falha ao comunicar com o Gateway de IA: ${error.message}`,
      );
    }
  }

  // Futuramente, podemos adicionar:
  // private async generateWithClaude(...)
  // private async generateWithGemini(...)
}