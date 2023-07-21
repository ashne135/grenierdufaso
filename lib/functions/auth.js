const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.setCustomClaims = functions.auth.user().onCreate(async (user) => {
  if (user.email) {
    const customClaims = {
      role: 'user', // Vous pouvez utiliser 'admin' ou tout autre nom de rôle pour les administrateurs.
    };
    try {
      await admin.auth().setCustomUserClaims(user.uid, customClaims);
      return true;
    } catch (error) {
      console.error(error);
      return false;
    }
  }
  return false;
});
