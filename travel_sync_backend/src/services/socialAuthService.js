const { OAuth2Client } = require('google-auth-library');
const axios = require('axios');
const { logger } = require('../utils/logger');

// Google OAuth client
const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// Verify Google token
const verifyGoogleToken = async (token) => {
  try {
    const ticket = await googleClient.verifyIdToken({
      idToken: token,
      audience: process.env.GOOGLE_CLIENT_ID,
    });
    
    const payload = ticket.getPayload();
    return {
      success: true,
      user: {
        id: payload.sub,
        email: payload.email,
        name: payload.name,
        firstName: payload.given_name,
        lastName: payload.family_name,
        picture: payload.picture,
        profilePicture: payload.picture,
        emailVerified: payload.email_verified,
      },
    };
  } catch (error) {
    logger.error('Google token verification failed:', error);
    return { success: false, error: error.message };
  }
};

// Verify Facebook token
const verifyFacebookToken = async (token) => {
  try {
    const response = await axios.get(`https://graph.facebook.com/me`, {
      params: {
        access_token: token,
        fields: 'id,email,first_name,last_name,picture',
      },
    });

    const userData = response.data;
    return {
      success: true,
      user: {
        id: userData.id,
        email: userData.email,
        firstName: userData.first_name,
        lastName: userData.last_name,
        profilePicture: userData.picture?.data?.url,
      },
    };
  } catch (error) {
    logger.error('Facebook token verification failed:', error);
    return { success: false, error: error.message };
  }
};

// Verify Apple token (simplified - in production you'd verify the JWT signature)
const verifyAppleToken = async (token) => {
  try {
    // This is a simplified implementation
    // In production, you should verify the JWT signature with Apple's public keys
    const payload = JSON.parse(Buffer.from(token.split('.')[1], 'base64').toString());
    
    return {
      success: true,
      user: {
        id: payload.sub,
        email: payload.email,
        firstName: payload.given_name,
        lastName: payload.family_name,
        emailVerified: payload.email_verified === 'true',
      },
    };
  } catch (error) {
    logger.error('Apple token verification failed:', error);
    return { success: false, error: error.message };
  }
};

module.exports = {
  verifyGoogleToken,
  verifyFacebookToken,
  verifyAppleToken,
};
