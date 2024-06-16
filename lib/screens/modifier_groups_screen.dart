import 'package:flutter/material.dart';
import 'package:cafeteriamaldonado_app_2/services/firebase_service.dart';
import 'package:cafeteriamaldonado_app_2/models/product_model.dart';

class ModifierGroupsScreen extends StatefulWidget {
  const ModifierGroupsScreen({Key? key}) : super(key: key);

  @override
  _ModifierGroupsScreenState createState() => _ModifierGroupsScreenState();
}

class _ModifierGroupsScreenState extends State<ModifierGroupsScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _modifierNameController = TextEditingController();
  final TextEditingController _modifierPriceController = TextEditingController();
  late Future<List<ModifierGroup>> modifierGroups;

  @override
  void initState() {
    super.initState();
    modifierGroups = FirebaseService().getModifierGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Modificadores'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _groupNameController,
            decoration: const InputDecoration(labelText: 'Nuevo Grupo de Modificadores'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_groupNameController.text.isNotEmpty) {
                await FirebaseService().addModifierGroup(ModifierGroup(name: _groupNameController.text, modifiers: []));
                setState(() {
                  modifierGroups = FirebaseService().getModifierGroups();
                });
                _groupNameController.clear();
              }
            },
            child: const Text('Agregar Grupo'),
          ),
          Expanded(
            child: FutureBuilder<List<ModifierGroup>>(
              future: modifierGroups,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Error al cargar los grupos de modificadores');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No hay grupos de modificadores disponibles');
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      ModifierGroup group = snapshot.data![index];
                      return ExpansionTile(
                        title: Text(group.name),
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: group.modifiers.length,
                            itemBuilder: (context, modIndex) {
                              Modifier modifier = group.modifiers[modIndex];
                              return ListTile(
                                title: Text(modifier.name),
                                subtitle: Text('L. ${modifier.price.toStringAsFixed(2)}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    group.modifiers.removeAt(modIndex);
                                    await FirebaseService().updateModifierGroup(group);
                                    setState(() {
                                      modifierGroups = FirebaseService().getModifierGroups();
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _modifierNameController,
                                  decoration: const InputDecoration(labelText: 'Nombre del Modificador'),
                                ),
                                TextField(
                                  controller: _modifierPriceController,
                                  decoration: const InputDecoration(labelText: 'Precio del Modificador'),
                                  keyboardType: TextInputType.number,
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (_modifierNameController.text.isNotEmpty &&
                                        _modifierPriceController.text.isNotEmpty) {
                                      Modifier newModifier = Modifier(
                                        name: _modifierNameController.text,
                                        price: double.tryParse(_modifierPriceController.text) ?? 0.0,
                                      );
                                      group.modifiers.add(newModifier);
                                      await FirebaseService().updateModifierGroup(group);
                                      setState(() {
                                        modifierGroups = FirebaseService().getModifierGroups();
                                      });
                                      _modifierNameController.clear();
                                      _modifierPriceController.clear();
                                    }
                                  },
                                  child: const Text('Agregar Modificador'),
                                ),
                              ],
                            ),
                          ),
                        ],
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
