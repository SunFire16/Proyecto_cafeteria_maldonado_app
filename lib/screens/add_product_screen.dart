import 'package:flutter/material.dart';
import 'package:cafeteriamaldonado_app_2/models/product_model.dart';
import 'package:cafeteriamaldonado_app_2/services/firebase_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _formKey = GlobalKey<FormState>();
  Product product = Product(
    id: '',
    name: '',
    category: '',
    price: 0.0,
    variants: [],
    modifierGroups: [],
  );

  TextEditingController variantNameController = TextEditingController();
  TextEditingController variantPriceController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController costController = TextEditingController();
  TextEditingController inventoryController = TextEditingController();

  String selectedCategory = '';
  CroppedFile? _imageFile;
  final picker = ImagePicker();
  List<Category> categories = [];
  List<ModifierGroup> modifierGroups = [];
  List<String> selectedModifierGroups = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadModifierGroups();
  }

  Future<void> _loadCategories() async {
    List<Category> loadedCategories = await FirebaseService().getCategories();
    setState(() {
      categories = loadedCategories;
    });
  }

  Future<void> _loadModifierGroups() async {
    List<ModifierGroup> loadedModifierGroups = await FirebaseService().getModifierGroups();
    setState(() {
      modifierGroups = loadedModifierGroups;
    });
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        var cropper = ImageCropper();
        CroppedFile? croppedFile = await cropper.cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Recortar Imagen',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              aspectRatioPresets: [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
              ],
            ),
            IOSUiSettings(
              title: 'Recortar Imagen',
              aspectRatioPresets: [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
              ],
            ),
            WebUiSettings(
              context: context,
            ),
          ],
        );

        setState(() {
          _imageFile = croppedFile;
        });
      }
    } catch (e) {
      print('Error al seleccionar o recortar la imagen: $e');
    }
  }

  Future<String> _uploadImage(CroppedFile imageFile) async {
    File file = File(imageFile.path);
    String fileName = 'products/${DateTime.now().millisecondsSinceEpoch}.png';
    Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = storageRef.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un nombre';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    product.name = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Categoría'),
                value: selectedCategory.isEmpty ? null : selectedCategory,
                items: categories.map((Category category) {
                  return DropdownMenuItem<String>(
                    value: category.name,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                    product.category = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, seleccione una categoría';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: detailsController,
                decoration: const InputDecoration(labelText: 'Detalles'),
                onChanged: (value) {
                  setState(() {
                    product.details = value;
                  });
                },
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Precio (L.)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un precio';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    product.price = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
              TextFormField(
                controller: costController,
                decoration: const InputDecoration(labelText: 'Coste (L.)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    product.cost = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
              TextFormField(
                controller: inventoryController,
                decoration: const InputDecoration(labelText: 'Inventario'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    product.inventory = int.tryParse(value) ?? 0;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Mostrar al Público'),
                value: product.isVisible,
                onChanged: (bool value) {
                  setState(() {
                    product.isVisible = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Seleccionar Imagen'),
              ),
              _imageFile == null
                  ? const Text('No se ha seleccionado una imagen.')
                  : Image.file(File(_imageFile!.path)),
              const SizedBox(height: 20),
              TextFormField(
                controller: variantNameController,
                decoration: const InputDecoration(labelText: 'Nombre de la Variante'),
              ),
              TextFormField(
                controller: variantPriceController,
                decoration: const InputDecoration(labelText: 'Precio de la Variante'),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: () {
                  if (variantNameController.text.isNotEmpty &&
                      variantPriceController.text.isNotEmpty) {
                    setState(() {
                      product.variants.add(Variant(
                        name: variantNameController.text,
                        price: double.tryParse(variantPriceController.text) ?? 0.0,
                      ));
                      variantNameController.clear();
                      variantPriceController.clear();
                    });
                  }
                },
                child: const Text('Agregar Variante'),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: product.variants.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Variante ${index + 1}: ${product.variants[index].name}'),
                    subtitle: Text('L. ${product.variants[index].price.toStringAsFixed(2)}'),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text('Grupos de Modificadores', style: TextStyle(fontSize: 16)),
              Column(
                children: modifierGroups.map((group) {
                  return CheckboxListTile(
                    title: Text(group.name),
                    value: selectedModifierGroups.contains(group.name),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedModifierGroups.add(group.name);
                        } else {
                          selectedModifierGroups.remove(group.name);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Agregar Producto'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (_imageFile != null) {
                      product.imageUrl = await _uploadImage(_imageFile!);
                    }
                    product.modifierGroups = modifierGroups
                        .where((group) => selectedModifierGroups.contains(group.name))
                        .toList();
                    await FirebaseService().addProduct(product);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
