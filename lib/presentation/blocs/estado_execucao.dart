import 'package:flutter/material.dart';

class EstadoExecucao extends ChangeNotifier {
  final List<String> mensagens = [];
  final List<Widget> widgets = [];
  final Map<String, dynamic> variaveis = {};

  // Controla se a execução está aguardando a entrada do usuário
  bool aguardandoEntrada = false;

  // Armazena a função de continuação após a entrada do usuário
  void Function(String)? continuarExecucao;

  void adicionarMensagem(String mensagem) {
    print('Adicionando mensagem ao EstadoExecucao: $mensagem');
    mensagens.add(mensagem);
    widgets.add(
      Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          border: Border.all(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          mensagem,
          style: TextStyle(
            color: Colors.blue[900],
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
    notifyListeners();
  }

  void adicionarCampoEntrada(String mensagem, void Function(String) onSubmit) {
    print('Adicionando campo de entrada com a mensagem: $mensagem');
    aguardandoEntrada = true;
    widgets.add(
      Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.green[50],
          border: Border.all(color: Colors.greenAccent),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mensagem,
              style: TextStyle(
                color: Colors.green[900],
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Digite aqui',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              ),
              onSubmitted: (valor) {
                aguardandoEntrada = false;
                // Remover o widget de entrada após o envio
                widgets.removeLast();
                // Adicionar a entrada do usuário na lista de widgets, se desejar
                widgets.add(
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      'Entrada: $valor',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                );
                notifyListeners();
                onSubmit(valor);
              },
            ),
          ],
        ),
      ),
    );
    notifyListeners();
  }


}
