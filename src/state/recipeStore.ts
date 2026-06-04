import { create } from 'zustand';

export interface Recipe {
  id: string;
  name: string;
  beansWeight: number; // grams
  yieldVolume: number; // ml
  temperature: number; // °C
  duration: number; // seconds
  grindSize: number; // 1-30
  rating: number; // 1-5 stars
}

interface RecipeStoreState {
  recipes: Recipe[];
  customRecipes: Recipe[];
  selectedRecipe: Recipe;
  grindSize: number; // 1 to 30
  grindWeight: number; // 10 to 25 grams
  targetYield: number; // 20 to 250 ml
  targetTemp: number; // 85 to 98 °C
  preinfusionSeconds: number; // 0 to 10s

  selectRecipe: (recipe: Recipe) => void;
  updateGrindSize: (size: number) => void;
  updateGrindWeight: (weight: number) => void;
  updateTargetYield: (yieldVol: number) => void;
  updateTargetTemp: (temp: number) => void;
  updatePreinfusion: (seconds: number) => void;
  saveAsCustom: (name: string) => void;
}

export const useRecipeStore = create<RecipeStoreState>((set, get) => {
  const defaultRecipes: Recipe[] = [
    { id: 'esp_1', name: 'Double Espresso', beansWeight: 18, yieldVolume: 36, temperature: 93, duration: 28, grindSize: 12, rating: 5 },
    { id: 'flt_2', name: 'Flat White', beansWeight: 18, yieldVolume: 150, temperature: 91, duration: 25, grindSize: 15, rating: 4 },
    { id: 'crt_3', name: 'Cortado', beansWeight: 18, yieldVolume: 60, temperature: 92, duration: 22, grindSize: 14, rating: 5 },
    { id: 'amr_4', name: 'Calibrated Americano', beansWeight: 18, yieldVolume: 200, temperature: 94, duration: 30, grindSize: 18, rating: 4 },
  ];

  return {
    recipes: defaultRecipes,
    customRecipes: [],
    selectedRecipe: defaultRecipes[0],
    grindSize: defaultRecipes[0].grindSize,
    grindWeight: defaultRecipes[0].beansWeight,
    targetYield: defaultRecipes[0].yieldVolume,
    targetTemp: defaultRecipes[0].temperature,
    preinfusionSeconds: 3,

    selectRecipe: (recipe) => set({
      selectedRecipe: recipe,
      grindSize: recipe.grindSize,
      grindWeight: recipe.beansWeight,
      targetYield: recipe.yieldVolume,
      targetTemp: recipe.temperature,
    }),

    updateGrindSize: (grindSize) => set({ grindSize }),
    updateGrindWeight: (grindWeight) => set({ grindWeight }),
    updateTargetYield: (targetYield) => set({ targetYield }),
    updateTargetTemp: (targetTemp) => set({ targetTemp }),
    updatePreinfusion: (preinfusionSeconds) => set({ preinfusionSeconds }),

    saveAsCustom: (name) => {
      const state = get();
      const newRecipe: Recipe = {
        id: `custom_${Date.now()}`,
        name,
        beansWeight: state.grindWeight,
        yieldVolume: state.targetYield,
        temperature: state.targetTemp,
        duration: 25,
        grindSize: state.grindSize,
        rating: 5,
      };
      set((state) => ({
        customRecipes: [...state.customRecipes, newRecipe],
        recipes: [...state.recipes, newRecipe],
        selectedRecipe: newRecipe,
      }));
    },
  };
});
