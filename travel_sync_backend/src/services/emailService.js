const nodemailer = require('nodemailer');
const { logger } = require('../utils/logger');

// Create transporter
const createTransporter = () => {
  if (process.env.NODE_ENV === 'production') {
    // Production email configuration
    return nodemailer.createTransport({
      service: process.env.EMAIL_SERVICE || 'gmail',
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
    });
  } else {
    // Development - use ethereal email for testing
    return nodemailer.createTransport({
      host: 'smtp.ethereal.email',
      port: 587,
      auth: {
        user: 'ethereal.user@ethereal.email',
        pass: 'ethereal.pass',
      },
    });
  }
};

const transporter = createTransporter();

// Send email verification
const sendVerificationEmail = async (email, verificationToken, firstName) => {
  try {
    const verificationUrl = `${process.env.CLIENT_URL}/verify-email?token=${verificationToken}`;
    
    const mailOptions = {
      from: process.env.EMAIL_FROM || 'noreply@travelsync.com',
      to: email,
      subject: 'Verify Your Email - TravelSync',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2>Welcome to TravelSync, ${firstName}!</h2>
          <p>Thank you for signing up. Please verify your email address by clicking the button below:</p>
          <a href="${verificationUrl}" style="background-color: #007bff; color: white; padding: 12px 24px; text-decoration: none; border-radius: 4px; display: inline-block;">
            Verify Email
          </a>
          <p>If the button doesn't work, you can copy and paste this link into your browser:</p>
          <p>${verificationUrl}</p>
          <p>This link will expire in 24 hours.</p>
          <p>If you didn't create an account with TravelSync, please ignore this email.</p>
        </div>
      `,
    };

    const info = await transporter.sendMail(mailOptions);
    logger.info(`Verification email sent to ${email}: ${info.messageId}`);
    return true;
  } catch (error) {
    logger.error('Error sending verification email:', error);
    return false;
  }
};

// Send password reset email
const sendPasswordResetEmail = async (email, resetToken, firstName) => {
  try {
    const resetUrl = `${process.env.CLIENT_URL}/reset-password?token=${resetToken}`;
    
    const mailOptions = {
      from: process.env.EMAIL_FROM || 'noreply@travelsync.com',
      to: email,
      subject: 'Password Reset - TravelSync',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2>Password Reset Request</h2>
          <p>Hi ${firstName},</p>
          <p>You requested to reset your password. Click the button below to set a new password:</p>
          <a href="${resetUrl}" style="background-color: #dc3545; color: white; padding: 12px 24px; text-decoration: none; border-radius: 4px; display: inline-block;">
            Reset Password
          </a>
          <p>If the button doesn't work, you can copy and paste this link into your browser:</p>
          <p>${resetUrl}</p>
          <p>This link will expire in 1 hour.</p>
          <p>If you didn't request a password reset, please ignore this email.</p>
        </div>
      `,
    };

    const info = await transporter.sendMail(mailOptions);
    logger.info(`Password reset email sent to ${email}: ${info.messageId}`);
    return true;
  } catch (error) {
    logger.error('Error sending password reset email:', error);
    return false;
  }
};

// Send welcome email
const sendWelcomeEmail = async (email, firstName) => {
  try {
    const mailOptions = {
      from: process.env.EMAIL_FROM || 'noreply@travelsync.com',
      to: email,
      subject: 'Welcome to TravelSync!',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2>Welcome to TravelSync, ${firstName}!</h2>
          <p>Your account has been successfully verified. You can now start using TravelSync to:</p>
          <ul>
            <li>Track your trips automatically</li>
            <li>Plan and organize your travels</li>
            <li>Manage expenses and budgets</li>
            <li>Share experiences with fellow travelers</li>
          </ul>
          <p>Get started by downloading our mobile app or visiting our web dashboard.</p>
          <p>Happy travels!</p>
          <p>The TravelSync Team</p>
        </div>
      `,
    };

    const info = await transporter.sendMail(mailOptions);
    logger.info(`Welcome email sent to ${email}: ${info.messageId}`);
    return true;
  } catch (error) {
    logger.error('Error sending welcome email:', error);
    return false;
  }
};

module.exports = {
  sendVerificationEmail,
  sendPasswordResetEmail,
  sendWelcomeEmail,
};
