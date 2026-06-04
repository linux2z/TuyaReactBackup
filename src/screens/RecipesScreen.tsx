import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Dimensions } from 'react-native';
import { useRecipeStore, Recipe } from 'src/state/recipeStore';
import { ElenzaTheme } from 'src/theme/ElenzaTheme';

const { width } = Dimensions.get('window');

export function RecipesScreen({ navigation }: any) {
  const recipes = useRecipeStore((state) => state.recipes);
  const selectedRecipe = useRecipeStore((state) => state.selectedRecipe);
  const selectRecipe = useRecipeStore((state) => state.selectRecipe);

  const handleSelect = (recipe: Recipe) => {
    selectRecipe(recipe);
  };

  return (
    <View style={styles.container}>
      {/* Top Header */}
      <View style={styles.header}>
        <View style={styles.headerTitleContainer}>
          <Text style={ElenzaTheme.typography.brandSubtitle}>FORMULA DIRECTORY</Text>
          <Text style={styles.brandTitle}>RECIPES</Text>
        </View>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        <Text style={styles.sectionTitle}>ELENZA BLENDS / PRESETS</Text>

        {/* Recipe Cards Carousel Vertical Scroll Grid */}
        <View style={styles.list}>
          {recipes.map((recipe) => {
            const isSelected = selectedRecipe.id === recipe.id;
            return (
              <TouchableOpacity 
                key={recipe.id}
                style={[styles.card, isSelected && styles.selectedCard]}
                onPress={() => handleSelect(recipe)}
              >
                <View style={styles.cardHeader}>
                  <Text style={[styles.coffeeIcon, isSelected && styles.selectedText]}>☕</Text>
                  <View style={styles.ratingRow}>
                    {Array.from({ length: recipe.rating }).map((_, i) => (
                      <Text key={i} style={[styles.star, isSelected && styles.selectedStar]}>★</Text>
                    ))}
                  </View>
                </View>

                <Text style={[styles.cardName, isSelected && styles.selectedText]}>{recipe.name}</Text>

                <View style={styles.gridParams}>
                  <View style={styles.paramItem}>
                    <Text style={styles.paramLabel}>Beans:</Text>
                    <Text style={styles.paramVal}>{recipe.beansWeight}g</Text>
                  </View>
                  <View style={styles.paramItem}>
                    <Text style={styles.paramLabel}>Yield:</Text>
                    <Text style={styles.paramVal}>{recipe.yieldVolume}ml</Text>
                  </View>
                  <View style={styles.paramItem}>
                    <Text style={styles.paramLabel}>Temp:</Text>
                    <Text style={styles.paramVal}>{recipe.temperature}°C</Text>
                  </View>
                  <View style={styles.paramItem}>
                    <Text style={styles.paramLabel}>Time:</Text>
                    <Text style={styles.paramVal}>{recipe.duration}s</Text>
                  </View>
                </View>

                {isSelected && (
                  <View style={styles.activeOverlay}>
                    <Text style={styles.activeOverlayText}>ACTIVE CALIBRATION</Text>
                  </View>
                )}
              </TouchableOpacity>
            );
          })}
        </View>

        {/* Config button linking back to Brew Lab */}
        <TouchableOpacity 
          style={styles.customizeBtn}
          onPress={() => navigation.navigate('BrewLab')}
        >
          <Text style={styles.customizeBtnText}>CUSTOMIZE ACTIVE PROFILE</Text>
        </TouchableOpacity>

      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: ElenzaTheme.colors.background,
  },
  header: {
    paddingHorizontal: 24,
    paddingTop: 50,
    paddingBottom: 16,
    borderBottomWidth: 1,
    borderColor: ElenzaTheme.colors.borderLight,
    backgroundColor: 'rgba(5, 5, 5, 0.85)',
  },
  headerTitleContainer: {
    alignItems: 'center',
  },
  brandTitle: {
    fontFamily: 'Space Grotesk',
    fontSize: 16,
    letterSpacing: 6,
    color: '#fff',
    fontWeight: 'bold',
  },
  scrollContent: {
    padding: 20,
    paddingBottom: 110,
  },
  sectionTitle: {
    fontFamily: 'Inter',
    fontSize: 10,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.textMuted,
    letterSpacing: 1.5,
    marginBottom: 20,
    textTransform: 'uppercase',
  },
  list: {
    width: '100%',
  },
  card: {
    backgroundColor: ElenzaTheme.colors.card,
    borderColor: ElenzaTheme.colors.borderLight,
    borderWidth: 1,
    borderRadius: 24,
    padding: 20,
    marginBottom: 16,
    position: 'relative',
    overflow: 'hidden',
  },
  selectedCard: {
    borderColor: ElenzaTheme.colors.bronze,
    backgroundColor: 'rgba(197, 163, 104, 0.03)',
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  coffeeIcon: {
    fontSize: 22,
    color: 'rgba(255, 255, 255, 0.4)',
  },
  selectedText: {
    color: '#fff',
  },
  ratingRow: {
    flexDirection: 'row',
  },
  star: {
    color: 'rgba(255, 255, 255, 0.2)',
    fontSize: 10,
    marginHorizontal: 1,
  },
  selectedStar: {
    color: ElenzaTheme.colors.bronze,
  },
  cardName: {
    fontFamily: 'Space Grotesk',
    fontSize: 18,
    fontWeight: 'bold',
    color: 'rgba(255,255,255,0.7)',
    marginBottom: 16,
  },
  gridParams: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  paramItem: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  paramLabel: {
    fontFamily: 'Inter',
    fontSize: 10,
    color: ElenzaTheme.colors.textMuted,
    marginRight: 4,
  },
  paramVal: {
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: 'bold',
    color: '#fff',
  },
  activeOverlay: {
    position: 'absolute',
    right: -24,
    top: 14,
    backgroundColor: ElenzaTheme.colors.bronze,
    paddingHorizontal: 24,
    paddingVertical: 4,
    transform: [{ rotate: '45deg' }],
  },
  activeOverlayText: {
    fontFamily: 'Inter',
    fontSize: 6,
    fontWeight: 'bold',
    color: '#000',
    letterSpacing: 0.5,
  },
  customizeBtn: {
    borderColor: ElenzaTheme.colors.borderMedium,
    borderWidth: 1,
    paddingVertical: 18,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 10,
    backgroundColor: ElenzaTheme.colors.surface,
  },
  customizeBtnText: {
    fontFamily: 'Space Grotesk',
    fontSize: 10,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.white,
    letterSpacing: 1.0,
  },
});
