import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/recipe_state.dart';

class RecipesTab extends StatefulWidget {
  final VoidCallback? onCustomizeTriggered;
  final VoidCallback? onBackPressed;

  const RecipesTab({super.key, this.onCustomizeTriggered, this.onBackPressed});

  @override
  State<RecipesTab> createState() => _RecipesTabState();
}

class _RecipesTabState extends State<RecipesTab> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final recipeState = Provider.of<RecipeState>(context);
    var recipes = recipeState.recipes;
    
    if (_selectedTab == 1) {
      recipes = recipes.take(1).toList(); // Fake "My Recipes"
    } else if (_selectedTab == 2) {
      recipes = recipes.skip(1).take(1).toList(); // Fake "Favorites"
    }
    
    final selectedRecipe = recipeState.selectedRecipe;

    return Scaffold(
      backgroundColor: ElenzaTheme.matteBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ElenzaTheme.textPrimary),
          onPressed: widget.onBackPressed ?? () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Recipes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
            // Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _selectedTab = 0),
                  child: _buildTab('All', _selectedTab == 0),
                ),
                GestureDetector(
                  onTap: () => setState(() => _selectedTab = 1),
                  child: _buildTab('My Recipes', _selectedTab == 1),
                ),
                GestureDetector(
                  onTap: () => setState(() => _selectedTab = 2),
                  child: _buildTab('Favorites', _selectedTab == 2),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Recipes List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                final isSelected = selectedRecipe.id == recipe.id;

                return GestureDetector(
                  onTap: () {
                    recipeState.selectRecipe(recipe);
                    if (widget.onCustomizeTriggered != null) {
                      widget.onCustomizeTriggered!();
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: ElenzaTheme.graphiteDark,
                      border: Border.all(
                        color: isSelected ? ElenzaTheme.bronzeAccent : ElenzaTheme.graphiteLight,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.coffee, color: ElenzaTheme.textSecondary, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: ElenzaTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${recipe.beansWeight.toInt()}g | ${recipe.yieldVolume.toInt()}ml | ${recipe.temperature.toInt()}°C | ${recipe.duration}s',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: ElenzaTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: List.generate(
                                  5,
                                  (starIndex) => Icon(
                                    Icons.star,
                                    color: starIndex < recipe.rating.toInt() ? ElenzaTheme.bronzeAccent : ElenzaTheme.graphiteLight,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            right: -24,
                            top: 16,
                            child: Transform.rotate(
                              angle: 45 * 3.14159 / 180,
                              child: Container(
                                color: ElenzaTheme.bronzeAccent,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                child: const Text(
                                  'Daily Default',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Create Recipe Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Create Recipe dialog opened (WIP)')),
                  );
                },
                icon: const Icon(Icons.add, color: ElenzaTheme.matteBlack),
                label: const Text('Create New Recipe'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: ElenzaTheme.bronzeAccent,
                  foregroundColor: ElenzaTheme.matteBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool isSelected) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isSelected ? ElenzaTheme.bronzeAccent : ElenzaTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        if (isSelected)
          Container(
            height: 2,
            width: 32,
            color: ElenzaTheme.bronzeAccent,
          ),
      ],
    );
  }
}
