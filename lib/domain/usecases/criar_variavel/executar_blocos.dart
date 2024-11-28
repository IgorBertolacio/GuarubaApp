import 'dart:async';
import 'package:flutter/material.dart';
import '../../../domain/entidades/bloco_mostre.dart';
import '../../../domain/entidades/bloco_se.dart';
import '../../../presentation/blocs/estado_execucao.dart';
import '../../entidades/blobo_base.dart';
import '../../entidades/bloco_calculo.dart';
import '../../entidades/bloco_enquanto.dart';
import '../../entidades/bloco_leia.dart';
import '../../entidades/bloco_pare.dart';
import '../../entidades/bloco_variavel.dart';

class StopExecutionException implements Exception {}


class ExecutorDeBlocos {
  final EstadoExecucao estadoExecucao;
  final BuildContext contexto;

  ExecutorDeBlocos({
    required this.estadoExecucao,
    required this.contexto,
  });

  Future<void> executarBlocos(List<BlocoBase> blocos) async {

      for (var bloco in blocos) {
        print('Executando bloco: $bloco');
        if (bloco is BlocoMostre) {
          await executarBlocoMostre(bloco);
        } else if (bloco is BlocoLeia) {
          await executarBlocoLeia(bloco);
        } else if (bloco is BlocoVariavel) {
          await executarBlocoVariavel(bloco);
        } else if (bloco is BlocoCalculo) {
          await executarBlocoCalculo(bloco);
        } else if (bloco is BlocoSe) {
          await executarBlocoSe(bloco);
        } else if (bloco is BlocoEnquanto) {
          await executarBlocoEnquanto(bloco);
        } else if (bloco is BlocoPare) {
          await executarBlocoPare(bloco);
        }
        // Outros tipos de blocos...
      }

  }

  Future<void> executarBlocoPare(BlocoPare blocoPare) async {
    throw StopExecutionException();
  }

  Future<void> executarBlocoMostre(BlocoMostre blocoMostre) async {
    try {
      // Resolver a mensagem substituindo referências de variáveis
      String mensagemProcessada = blocoMostre.mensagem;
      RegExp regExp = RegExp(r'@(\w+)');
      Iterable<Match> matches = regExp.allMatches(blocoMostre.mensagem);
      for (var match in matches) {
        String varName = match.group(1)!;
        if (estadoExecucao.variaveis.containsKey(varName)) {
          String varValue = estadoExecucao.variaveis[varName].toString();
          mensagemProcessada = mensagemProcessada.replaceAll('@$varName', varValue);
        } else {
          throw Exception('Variavel "$varName" Nao encontrada');
        }
      }

      // estadoExecucao.variaveis[blocoMostre.nomeVariavel] = mensagemProcessada;

      // Adicionar a mensagem processada à tela de depuração
      estadoExecucao.adicionarMensagem(mensagemProcessada);
    } catch (e) {
      estadoExecucao.adicionarMensagem('Erro no BlocoMostre: ${e.toString()}');
    }
  }

  Future<void> executarBlocoLeia(BlocoLeia blocoLeia) async {
    try {
      // Resolver a mensagem substituindo referências de variáveis
      String mensagemProcessada = blocoLeia.mensagem;
      RegExp regExp = RegExp(r'@(\w+)');
      Iterable<Match> matches = regExp.allMatches(blocoLeia.mensagem);
      for (var match in matches) {
        String varName = match.group(1)!;
        if (estadoExecucao.variaveis.containsKey(varName)) {
          String varValue = estadoExecucao.variaveis[varName].toString();
          mensagemProcessada =
              mensagemProcessada.replaceAll('@$varName', varValue);
        } else {
          throw Exception('Variavel "$varName" Nao encontrada');
        }
      }

      final completer = Completer<String>();
      estadoExecucao.adicionarCampoEntrada(
        mensagemProcessada,
        (valor) {
          estadoExecucao.variaveis[blocoLeia.nomeVariavel] = valor;
          completer.complete(valor);
        },
      );
      // Aguardar até que o usuário insira o valor
      await completer.future;
    } catch (e) {
      estadoExecucao.adicionarMensagem('Erro no BlocoLeia: ${e.toString()}');
    }
  }

  Future<void> executarBlocoSe(BlocoSe blocoSe) async {
    dynamic valorEsquerda = await resolverExpressao(blocoSe.expressaoEsquerda);
    dynamic valorDireita = await resolverExpressao(blocoSe.expressaoDireita);

    bool condicao = false;

    switch (blocoSe.operador) {
      case '==':
        condicao = valorEsquerda == valorDireita;
        break;
      case '!=':
        condicao = valorEsquerda != valorDireita;
        break;
      case '>':
        condicao = valorEsquerda > valorDireita;
        break;
      case '<':
        condicao = valorEsquerda < valorDireita;
        break;
      case '>=':
        condicao = valorEsquerda >= valorDireita;
        break;
      case '<=':
        condicao = valorEsquerda <= valorDireita;
        break;
    }

    if (condicao) {
      await executarBlocos(blocoSe.blocosEntao);
    } else {
      await executarBlocos(blocoSe.blocosSenao);
    }
  }

  Future<dynamic> resolverExpressao(String expressao) async {
    if (expressao.startsWith('@')) {
      String nomeVariavel = expressao.substring(1);
      if (estadoExecucao.variaveis.containsKey(nomeVariavel)) {
        return estadoExecucao.variaveis[nomeVariavel];
      } else {
        throw Exception('Variável "$nomeVariavel" não encontrada.');
      }
    } else {
      // Tentar converter para número
      num? numero = num.tryParse(expressao);
      if (numero != null) {
        return numero;
      } else {
        // Retornar a expressão como está se não for número nem variável
        return expressao;
      }
    }
  }

  Future<void> executarBlocoVariavel(BlocoVariavel blocoVariavel) async {
    try {
      // Resolver todas as ocorrências de @variavel no valor
      String valorResolvido = blocoVariavel.valor.replaceAllMapped(
        RegExp(r'@(\w+)'),
            (match) {
          String varName = match.group(1)!;
          return estadoExecucao.variaveis[varName]?.toString() ?? '@$varName';
        },
      );

      // Tentar converter valorResolvido para número
      dynamic valorFinal;
      num? numero = num.tryParse(valorResolvido);
      if (numero != null) {
        valorFinal = numero;
      } else {
        valorFinal = valorResolvido;
      }

      // Armazenar a variável no EstadoExecucao com o tipo apropriado
      estadoExecucao.variaveis[blocoVariavel.nomeVariavel] = valorFinal;
    } catch (e) {
      estadoExecucao.adicionarMensagem('Erro no BlocoVariavel: ${e.toString()}');
    }
  }

  Future<void> executarBlocoCalculo(BlocoCalculo blocoCalculo) async {
    try {
      List<double> valoresNumeros = [];
      for (var numero in blocoCalculo.numeros) {
        String numeroResolvido = await resolverExpressao(numero);
        if (numeroResolvido.isEmpty) {
          throw Exception('Número inválido na expressão.');
        }
        double? valorNumerico = double.tryParse(numeroResolvido);
        if (valorNumerico == null) {
          throw Exception('Não foi possível converter "$numeroResolvido" em número.');
        }
        valoresNumeros.add(valorNumerico);
      }

      double resultado = valoresNumeros[0];
      for (int i = 1; i < valoresNumeros.length; i++) {
        String operador = blocoCalculo.operadores[i - 1];
        double valor = valoresNumeros[i];

        switch (operador) {
          case '+':
            resultado += valor;
            break;
          case '-':
            resultado -= valor;
            break;
          case '*':
            resultado *= valor;
            break;
          case '/':
            if (valor == 0) {
              throw Exception('Divisão por zero');
            }
            resultado /= valor;
            break;
          default:
            throw Exception('Operador inválido');
        }
      }

      // Armazenar o resultado na variável
      estadoExecucao.variaveis[blocoCalculo.nomeVariavel] = resultado;
    } catch (e) {
      estadoExecucao.adicionarMensagem('Erro no BlocoCalculo: ${e.toString()}');
    }
  }

  Future<void> executarBlocoEnquanto(BlocoEnquanto blocoEnquanto) async {
    try {
      // Inicializar a variável de controle se não estiver no contexto
      if (!estadoExecucao.variaveis.containsKey(blocoEnquanto.variavel)) {
        estadoExecucao.variaveis[blocoEnquanto.variavel] = 0;
      }

      int maxIterations = 1000; // Limite máximo de iterações para evitar loops infinitos
      int iteration = 0;

      while (await avaliarCondicao(blocoEnquanto)) {
        if (iteration >= maxIterations) {
          estadoExecucao.adicionarMensagem('Limite de iterações excedido no BlocoEnquanto.');
          break;
        }
        iteration++;

        // Atualizar a variável de controle antes de executar os blocos internos
        await atualizarVariavelControle(blocoEnquanto);

        // Executar blocos internos
        await executarBlocos(blocoEnquanto.blocosInternos);
      }
    } catch (e) {
      estadoExecucao.adicionarMensagem('Erro no BlocoEnquanto: ${e.toString()}');
    }
  }


  Future<bool> avaliarCondicao(BlocoEnquanto blocoEnquanto) async {
    try {
      // Resolver a variável da esquerda
      dynamic valorEsquerda = await resolverExpressao('@${blocoEnquanto.variavel}');

      // Resolver o valor de comparação
      dynamic valorDireita = await resolverExpressao(blocoEnquanto.valorComparacao);

      // Converter para números
      double numEsquerda;
      double numDireita;

      if (valorEsquerda is num) {
        numEsquerda = valorEsquerda.toDouble();
      } else {
        numEsquerda = double.tryParse(valorEsquerda.toString()) ?? 0;
      }

      if (valorDireita is num) {
        numDireita = valorDireita.toDouble();
      } else {
        numDireita = double.tryParse(valorDireita.toString()) ?? 0;
      }

      switch (blocoEnquanto.operadorComparacao) {
        case '==':
          return numEsquerda == numDireita;
        case '!=':
          return numEsquerda != numDireita;
        case '>':
          return numEsquerda > numDireita;
        case '<':
          return numEsquerda < numDireita;
        case '>=':
          return numEsquerda >= numDireita;
        case '<=':
          return numEsquerda <= numDireita;
        default:
          throw Exception('Operador de comparação inválido.');
      }
    } catch (e) {
      estadoExecucao.adicionarMensagem(
          'Erro ao avaliar a condição no BlocoEnquanto: ${e.toString()}');
      return false;
    }
  }

  Future<void> atualizarVariavelControle(BlocoEnquanto blocoEnquanto) async {
    try {
      // Resolver o valor atual da variável
      dynamic valorAtual = await resolverExpressao('@${blocoEnquanto.variavel}');

      // Resolver o valor de incremento
      dynamic incremento = await resolverExpressao(blocoEnquanto.valorIncremento);

      // Converter para números
      double numAtual;
      double numIncremento;

      if (valorAtual is num) {
        numAtual = valorAtual.toDouble();
      } else {
        numAtual = double.tryParse(valorAtual.toString()) ?? 0;
      }

      if (incremento is num) {
        numIncremento = incremento.toDouble();
      } else {
        numIncremento = double.tryParse(incremento.toString()) ?? 0;
      }

      double novoValor;
      switch (blocoEnquanto.operadorIncremento) {
        case '+':
          novoValor = numAtual + numIncremento;
          break;
        case '-':
          novoValor = numAtual - numIncremento;
          break;
        case '*':
          novoValor = numAtual * numIncremento;
          break;
        case '/':
          if (numIncremento == 0) {
            throw Exception('Divisão por zero');
          }
          novoValor = numAtual / numIncremento;
          break;
        default:
          throw Exception('Operador de incremento inválido.');
      }

      // Atualizar a variável no EstadoExecucao com o tipo numérico
      estadoExecucao.variaveis[blocoEnquanto.variavel] = novoValor;
    } catch (e) {
      estadoExecucao.adicionarMensagem(
          'Erro ao atualizar a variável de controle no BlocoEnquanto: ${e.toString()}');
    }
  }


}
