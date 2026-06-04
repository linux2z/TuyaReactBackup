module = {
  exports: {
    presets: ['module:@react-native/babel-preset'],
    plugins: ['react-native-reanimated/plugin'],
  }
};
// Compatible standard node export
module.exports = {
  presets: ['module:metro-react-native-babel-preset'],
  plugins: ['react-native-reanimated/plugin'],
};
