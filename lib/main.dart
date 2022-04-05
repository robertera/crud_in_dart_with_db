import 'package:flutter/material.dart';
import 'sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        //remove o debug banner
        debugShowCheckedModeBanner: false,
        //titulo no app
        title: 'Cadastro de Pessoa',
        //cor primaria do app
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _journals = [];

  bool _isLoading = true;
  void _refreshJournals() async {
    final data = await SQLHelper.getPessoas();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals(); //<--- Carrega a lista quando liga o app
  }

  final TextEditingController _controllerNome = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerTelefone = TextEditingController();
  final TextEditingController _controllerIdade = TextEditingController();

  void _mostrarPessoas(int id) async {
    if (id != null) {
      // id == null -> cria novo cadastro
      //id != null -> atualiza cadastro
      final existingJournal = _journals.firstWhere((element) => element['id'] == id);
      _controllerNome.text = existingJournal['nome'];
      _controllerEmail.text = existingJournal['email'];
      _controllerTelefone.text = existingJournal['telefone'];
      _controllerIdade.text = existingJournal['idade'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _controllerNome,
                    decoration: const InputDecoration(hintText: 'Nome'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _controllerEmail,
                    decoration: const InputDecoration(hintText: 'Email'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _controllerTelefone,
                    decoration: const InputDecoration(hintText: 'Telefone'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _controllerIdade,
                    decoration: const InputDecoration(hintText: 'Idade'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      //salva nova pessoa
                      if (id == null) {
                        await _cadastraPessoa();
                      }

                      if (id != null) {
                        await _atualizaPessoa(id);
                      }

                      //Limpa caixas de texto
                      _controllerNome.text = '';
                      _controllerEmail.text = '';
                      _controllerTelefone.text = '';
                      _controllerIdade.text = '';

                      //fecha o cadastro
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Create New' : 'Update'),
                  )
                ],
              ),
            ));
  }

  //cadastra uma nova pessoa ao banco
  Future<void> _cadastraPessoa() async {
    await SQLHelper.cadastrarPessoa(_controllerNome.text, _controllerEmail.text, _controllerTelefone.text, _controllerIdade.text);
    _refreshJournals();
  }

  //atualiza o cadastro
  Future<void> _atualizaPessoa(int id) async {
    await SQLHelper.atualizarPessoa(id, _controllerNome.text, _controllerEmail.text, _controllerTelefone.text, _controllerIdade.text);
    _refreshJournals();
  }

  //Excluir cadastro
  void _excluirPessoa(int id) async {
    await SQLHelper.deletarPessoa(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Pessoa excluida com sucesso!!'),
    ));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD em DART'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _journals.length,
              itemBuilder: (context, index) => Card(
                color: Colors.green[200],
                margin: const EdgeInsets.all(15),
                child: ListTile(
                    title: Text(_journals[index]['nome']),
                    subtitle: Text(_journals[index]['email']),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _mostrarPessoas(_journals[index]['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _excluirPessoa(_journals[index]['id']),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _mostrarPessoas(null),
      ),
    );
  }
}
