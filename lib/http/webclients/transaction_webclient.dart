import 'dart:convert';

import 'package:bytebank2/http/webclient.dart';
import 'package:bytebank2/models/transaction.dart';
import 'package:http/http.dart';

class TransactionWebClient {
  Future<List<Transaction>> findAll() async {
    final Response response = await client
        .get(Uri.parse(baseUrl));
        // .timeout(const Duration(seconds: 30));
    // nao consegui testar esse timeout
    // se coloco um IP errado, simplesmente nao tem retorno
    // e nao aguarda os 30 segundos

    // de string pra Json
    final List<dynamic> decodedJson = jsonDecode(response.body);

    // final List<Transaction> transactions = [];
    // for (Map<String, dynamic> transactionJson in decodedJson) {
    //   transactions.add(Transaction.fromJson(transactionJson));
    // }
    // return transactions;

    // Refactored:
    return decodedJson.map((dynamic json) => Transaction.fromJson(json)).toList();

    // print('decoded json $decodedJson');
    // debugPrint(response.body);
  }

  Future<Transaction> save(Transaction transaction, String password) async {
    final String transactionJson = jsonEncode(transaction.toJson());

    // usado para testar multiplas transacoes
    await Future.delayed(Duration(seconds: 15));

    // {} Map no dart
    final Response response = await client.post(Uri.parse(baseUrl),
        headers: {
          'Content-type': 'application/json',
          'password': password,
        },
        body: transactionJson);

    // throw Exception(); // pra testar a mensagem de erro genérico (desconhecido)

    if(response.statusCode == 200) {
      return Transaction.fromJson(jsonDecode(response.body));
    }

    throw HttpException(_getMessage(response.statusCode));
  }

  String _getMessage(int statusCode) {
    if(_statusCodeResponses.containsKey(statusCode)) { // Erros tratados no Map
      return _statusCodeResponses[statusCode] ?? 'Erro não informado';
    }
    return 'Erro desconhecido!';
  }

  static final Map<int, String> _statusCodeResponses = {
    400 : 'Ocorreu um erro ao enviar a transação',
    401 : 'Senha inválida',
    409 : 'Transação já existe'
  };

// Map<String, dynamic> _toMap(Transaction transaction) {
//   final Map<String, dynamic> transactionMap = {
//     'value' : transaction.value,
//     'contact' : {
//       'name' : transaction.contact.name,
//       'accountNumber' : transaction.contact.accountNumber
//     }
//   };
//   return transactionMap;
// }

}

class HttpException implements Exception {
  final String message;

  HttpException(this.message);
}
