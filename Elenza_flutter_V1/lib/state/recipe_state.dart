import 'package:flutter/material.dart';

class Recipe {
  final String id;
  final String name;
  final double beansWeight; // grams
  final double yieldVolume; // ml
  final double temperature; // °C
  final int duration; // seconds
  final int grindSize; // 1-30
  final double rating; // 1-5 stars

  Recipe({
    required this.id,
    required this.name,
    required this.beansWeight,
    required this.yieldVolume,
    required this.temperature,
    required this.duration,
    required this.grindSize,
    required this.rating,
  });

  Recipe copyWith({
    String? id,
    String? name,
    double? beansWeight,
    double? yieldVolume,
    double? temperature,
    int? duration,
    int? grindSize,
    double? rating,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      beansWeight: beansWeight ?? this.beansWeight,
      yieldVolume: yieldVolume ?? this.yieldVolume,
      temperature: temperature ?? this.temperature,
      duration: duration ?? this.duration,
      grindSize: grindSize ?? this.grindSize,
      rating: rating ?? this.rating,
    );
  }
}

class RecipeState extends ChangeNotifier {
  final List<Recipe> _recipes = [
    Recipe(id: 'esp_1', name: 'Double Espresso', beansWeight: 18, yieldVolume: 36, temperature: 93, duration: 28, grindSize: 12, rating: 5),
    Recipe(id: 'flt_2', name: 'Flat White', beansWeight: 18, yieldVolume: 150, temperature: 91, duration: 25, grindSize: 15, rating: 4),
    Recipe(id: 'crt_3', name: 'Cortado', beansWeight: 18, yieldVolume: 60, temperature: 92, duration: 22, grindSize: 14, rating: 5),
    Recipe(id: 'amr_4', name: 'Calibrated Americano', beansWeight: 18, yieldVolume: 200, temperature: 94, duration: 30, grindSize: 18, rating: 4),
  ];

  final List<Recipe> _customRecipes = [];
  late Recipe _selectedRecipe;

  int _grindSize = 12;
  double _grindWeight = 18.0;
  double _targetYield = 36.0;
  double _targetTemp = 93.0;
  int _preinfusionSeconds = 3;

  RecipeState() {
    _selectedRecipe = _recipes[0];
    _grindSize = _selectedRecipe.grindSize;
    _grindWeight = _selectedRecipe.beansWeight;
    _targetYield = _selectedRecipe.yieldVolume;
    _targetTemp = _selectedRecipe.temperature;
  }

  List<Recipe> get recipes => _recipes;
  List<Recipe> get customRecipes => _customRecipes;
  Recipe get selectedRecipe => _selectedRecipe;

  int get grindSize => _grindSize;
  double get grindWeight => _grindWeight;
  double get targetYield => _targetYield;
  double get targetTemp => _targetTemp;
  int get preinfusionSeconds => _preinfusionSeconds;

  void selectRecipe(Recipe recipe) {
    _selectedRecipe = recipe;
    _grindSize = recipe.grindSize;
    _grindWeight = recipe.beansWeight;
    _targetYield = recipe.yieldVolume;
    _targetTemp = recipe.temperature;
    notifyListeners();
  }

  void updateGrindSize(int size) {
    _grindSize = size;
    notifyListeners();
  }

  void updateGrindWeight(double weight) {
    _grindWeight = weight;
    notifyListeners();
  }

  void updateTargetYield(double yieldVol) {
    _targetYield = yieldVol;
    notifyListeners();
  }

  void updateTargetTemp(double temp) {
    _targetTemp = temp;
    notifyListeners();
  }

  void updatePreinfusion(int seconds) {
    _preinfusionSeconds = seconds;
    notifyListeners();
  }

  void saveAsCustom(String name) {
    final newRecipe = Recipe(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      beansWeight: _grindWeight,
      yieldVolume: _targetYield,
      temperature: _targetTemp,
      duration: 25,
      grindSize: _grindSize,
      rating: 5,
    );
    _customRecipes.add(newRecipe);
    _recipes.add(newRecipe);
    _selectedRecipe = newRecipe;
    notifyListeners();
  }
}
