import 'package:flutter/material.dart';
import 'package:cafeteriamaldonado_app_2/services/firebase_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _controller = TextEditingController();
  late Future<List<Category>> categories;

  @override
  void initState() {
    super.initState();
    categories = FirebaseService().getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'Nueva Categoría'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_controller.text.isNotEmpty) {
                await FirebaseService().addCategory(
                  Category(id: '', name: _controller.text),
                );
                setState(() {
                  categories = FirebaseService().getCategories();
                });
                _controller.clear();
              }
            },
            child: const Text('Agregar Categoría'),
          ),
          Expanded(
            child: FutureBuilder<List<Category>>(
              future: categories,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Error al cargar las categorías');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No hay categorías disponibles');
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final category = snapshot.data![index];
                      return ListTile(
                        title: Text(category.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                String? newName = await showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    String tempName = category.name;
                                    return AlertDialog(
                                      title: const Text('Editar Categoría'),
                                      content: TextField(
                                        onChanged: (value) => tempName = value,
                                        controller: TextEditingController(text: category.name),
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text('Cancelar'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('Guardar'),
                                          onPressed: () {
                                            Navigator.of(context).pop(tempName);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (newName != null && newName.isNotEmpty) {
                                  await FirebaseService().updateCategory(
                                    Category(id: category.id, name: newName),
                                  );
                                  setState(() {
                                    categories = FirebaseService().getCategories();
                                  });
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await FirebaseService().deleteCategory(category.id);
                                setState(() {
                                  categories = FirebaseService().getCategories();
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
