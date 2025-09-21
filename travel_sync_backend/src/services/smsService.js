const twilio = require('twilio');
const { logger } = require('../utils/logger');

// Initialize Twilio client
let twilioClient = null;
if (process.env.TWILIO_ACCOUNT_SID && 
    process.env.TWILIO_AUTH_TOKEN && 
    process.env.TWILIO_ACCOUNT_SID.startsWith('AC')) {
  try {
    twilioClient = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);
  } catch (error) {
    logger.warn('Failed to initialize Twilio client:', error.message);
  }
}

// Send SMS verification code
const sendSMS = async (phoneNumber, message) => {
  try {
    if (!twilioClient) {
      logger.warn('Twilio not configured, SMS not sent');
      return { success: false, error: 'SMS service not configured' };
    }

    const result = await twilioClient.messages.create({
      body: message,
      from: process.env.TWILIO_PHONE_NUMBER,
      to: phoneNumber,
    });

    logger.info(`SMS sent to ${phoneNumber}: ${result.sid}`);
    return { success: true, messageId: result.sid };
  } catch (error) {
    logger.error('Error sending SMS:', error);
    return { success: false, error: error.message };
  }
};

// Send phone verification code
const sendPhoneVerification = async (phoneNumber, verificationCode) => {
  const message = `Your TravelSync verification code is: ${verificationCode}. This code will expire in 10 minutes.`;
  return await sendSMS(phoneNumber, message);
};

// Send password reset code via SMS
const sendPasswordResetSMS = async (phoneNumber, resetCode) => {
  const message = `Your TravelSync password reset code is: ${resetCode}. This code will expire in 10 minutes.`;
  return await sendSMS(phoneNumber, message);
};

module.exports = {
  sendSMS,
  sendPhoneVerification,
  sendPasswordResetSMS,
};
