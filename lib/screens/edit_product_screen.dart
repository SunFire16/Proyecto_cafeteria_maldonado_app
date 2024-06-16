import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cafeteriamaldonado_app_2/models/product_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cafeteriamaldonado_app_2/services/firebase_service.dart';

class EditProductScreen extends StatefulWidget {
  final DocumentSnapshot product;

  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late Product product;
  TextEditingController nameController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController costController = TextEditingController();
  TextEditingController inventoryController = TextEditingController();
  bool isVisible = true;
  List<Variant> variants = [];
  List<TextEditingController> variantNameControllers = [];
  List<TextEditingController> variantPriceControllers = [];
  File? _imageFile;
  List<ModifierGroup> modifierGroups = [];
  List<String> selectedModifierGroups = [];

  @override
  void initState() {
    super.initState();
    _initializeProduct();
    _loadModifierGroups();
  }

  void _initializeProduct() {
    product = Product.fromFirestore(widget.product);
    nameController.text = product.name;
    categoryController.text = product.category;
    detailsController.text = product.details;
    priceController.text = product.price.toString();
    costController.text = product.cost.toString();
    inventoryController.text = product.inventory.toString();
    isVisible = product.isVisible;
    variants = product.variants;
    selectedModifierGroups = product.modifierGroups.map((group) => group.name).toList();

    variantNameControllers = variants
        .map((variant) => TextEditingController(text: variant.name))
        .toList();
    variantPriceControllers = variants
        .map((variant) =>
            TextEditingController(text: variant.price.toString()))
        .toList();
  }

  Future<void> _loadModifierGroups() async {
    List<ModifierGroup> loadedModifierGroups = await FirebaseService().getModifierGroups();
    setState(() {
      modifierGroups = loadedModifierGroups;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
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
        if (croppedFile != null) {
          _imageFile = File(croppedFile.path);
        }
      });
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    String fileName = 'products/${DateTime.now().millisecondsSinceEpoch}.png';
    Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      product.name = nameController.text;
      product.category = categoryController.text;
      product.details = detailsController.text;
      product.price = double.tryParse(priceController.text) ?? 0.0;
      product.cost = double.tryParse(costController.text) ?? 0.0;
      product.inventory = int.tryParse(inventoryController.text) ?? 0;
      product.isVisible = isVisible;
      product.variants = List.generate(
        variants.length,
        (index) => Variant(
          name: variantNameControllers[index].text,
          price: double.tryParse(variantPriceControllers[index].text) ?? 0.0,
        ),
      );
      product.modifierGroups = selectedModifierGroups.map((name) => modifierGroups.firstWhere((group) => group.name == name)).toList();

      if (_imageFile != null) {
        product.imageUrl = await _uploadImage(_imageFile!);
      }

      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .update(product.toJson());
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
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
              ),
              TextFormField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Categoría'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese una categoría';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: detailsController,
                decoration: const InputDecoration(labelText: 'Detalles'),
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
              ),
              TextFormField(
                controller: costController,
                decoration: const InputDecoration(labelText: 'Coste (L.)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: inventoryController,
                decoration: const InputDecoration(labelText: 'Inventario'),
                keyboardType: TextInputType.number,
              ),
              SwitchListTile(
                title: const Text('Mostrar al Público'),
                value: isVisible,
                onChanged: (bool value) {
                  setState(() {
                    isVisible = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Seleccionar Imagen'),
              ),
              _imageFile == null
                  ? product.imageUrl.isEmpty
                      ? const Text('No se ha seleccionado una imagen.')
                      : Image.network(product.imageUrl)
                  : Image.file(_imageFile!),
              const SizedBox(height: 20),
              const Text('Variantes', style: TextStyle(fontSize: 16)),
              ...List.generate(variants.length, (index) {
                return Column(
                  children: [
                    TextFormField(
                      controller: variantNameControllers[index],
                      decoration:
                          const InputDecoration(labelText: 'Nombre de la Variante'),
                    ),
                    TextFormField(
                      controller: variantPriceControllers[index],
                      decoration:
                          const InputDecoration(labelText: 'Precio de la Variante'),
                      keyboardType: TextInputType.number,
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              variants[index] = Variant(
                                name: variantNameControllers[index].text,
                                price: double.tryParse(
                                        variantPriceControllers[index].text) ??
                                    0.0,
                              );
                            });
                          },
                          child: const Text('Actualizar Variante'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              variants.removeAt(index);
                              variantNameControllers.removeAt(index);
                              variantPriceControllers.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                  ],
                );
              }),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre de la Variante'),
                onFieldSubmitted: (value) {
                  setState(() {
                    variants.add(Variant(name: value, price: 0.0));
                    variantNameControllers.add(TextEditingController(text: value));
                    variantPriceControllers.add(TextEditingController(text: '0.0'));
                  });
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
                onPressed: _updateProduct,
                child: const Text('Actualizar Producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
