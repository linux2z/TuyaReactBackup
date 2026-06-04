import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/recipe_state.dart';

class RecipesTab extends StatelessWidget {
  final VoidCallback? onCustomizeTriggered;

  const RecipesTab({super.key, this.onCustomizeTriggered});

  @override
  Widget build(BuildContext context) {
    final recipeState = Provider.of<RecipeState>(context);
    final recipes = recipeState.recipes;
    final selectedRecipe = recipeState.selectedRecipe;

    return Scaffold(
      backgroundColor: ElenzaTheme.matteBlack,
      appBar: AppBar(
        title: Column(
          children: const [
            Text(
              'FORMULA DIRECTORY',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Color(0xA8FFFFFF),
                letterSpacing: 2.0,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'RECIPES',
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 16,
                letterSpacing: 6,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ELENZA BLENDS / PRESETS',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: ElenzaTheme.textMuted,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // Carousel/List of Recipes
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                final isSelected = selectedRecipe.id == recipe.id;

                return GestureDetector(
                  onTap: () => recipeState.selectRecipe(recipe),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ElenzaTheme.graphiteDark,
                      border: Border.all(
                        color: isSelected ? ElenzaTheme.bronzeAccent : ElenzaTheme.graphiteLight,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '☕',
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
                                  ),
                                ),
                                Row(
                                  children: List.generate(
                                    recipe.rating.toInt(),
                                    (index) => Icon(
                                      Icons.star,
                                      color: isSelected ? ElenzaTheme.bronzeAccent : Colors.white.withOpacity(0.2),
                                      size: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              recipe.name,
                              style: TextStyle(
                                fontFamily: 'Space Grotesk',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // parameters Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildParamItem('Beans', '${recipe.beansWeight.toInt()}g'),
                                _buildParamItem('Yield', '${recipe.yieldVolume.toInt()}ml'),
                                _buildParamItem('Temp', '${recipe.temperature.toInt()}°C'),
                                _buildParamItem('Time', '${recipe.duration}s'),
                              ],
                            ),
                          ],
                        ),
                        if (isSelected)
                          Positioned(
                            right: -32,
                            top: 10,
                            child: Transform.rotate(
                              angle: 45 * 3.14159 / 180,
                              child: Container(
                                color: ElenzaTheme.bronzeAccent,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                child: const Text(
                                  'ACTIVE CALIBRATION',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 6,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    letterSpacing: 0.5,
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

            const SizedBox(height: 10),

            // Customize Active Profile Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: ElenzaTheme.graphiteDark,
                ),
                onPressed: onCustomizeTriggered,
                child: const Text('CUSTOMIZE ACTIVE PROFILE'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParamItem(String label, String val) {
    return Row(
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            color: ElenzaTheme.textMuted,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          val,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
