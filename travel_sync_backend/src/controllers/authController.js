const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
const User = require('../models/User');
const { sendVerificationEmail, sendPasswordResetEmail, sendWelcomeEmail } = require('../services/emailService');
const { sendSMS } = require('../services/smsService');
const { verifyGoogleToken, verifyFacebookToken, verifyAppleToken } = require('../services/socialAuthService');
const { logger } = require('../utils/logger');
const { ApiResponse } = require('../utils/apiResponse');
const { AppError } = require('../utils/appError');

class AuthController {
  // Register new user
  async register(req, res, next) {
    try {
      const { email, password, fullName, phoneNumber, travelPreferences, consentGiven } = req.body;

      // Check if user already exists
      const existingUser = await User.findByEmail(email);
      if (existingUser) {
        return next(new AppError('User with this email already exists', 409));
      }

      // Check phone number if provided
      if (phoneNumber) {
        const existingPhone = await User.findByPhoneNumber(phoneNumber);
        if (existingPhone) {
          return next(new AppError('User with this phone number already exists', 409));
        }
      }

      // Create new user
      const userData = {
        email,
        password,
        fullName,
        phoneNumber,
        travelPreferences: travelPreferences || [],
        consentGiven,
      };

      const user = await User.createUser(userData);

      // Generate tokens
      const { accessToken, refreshToken } = this.generateTokens(user.id);

      // Send welcome email
      try {
        await sendEmail({
          to: user.email,
          subject: 'Welcome to TravelSync!',
          template: 'welcome',
          data: { fullName: user.fullName },
        });
      } catch (emailError) {
        logger.error('Failed to send welcome email:', emailError);
      }

      logger.info(`New user registered: ${user.email}`);

      res.status(201).json(
        ApiResponse.success({
          user: user.fullProfile,
          tokens: { accessToken, refreshToken },
        }, 'User registered successfully')
      );
    } catch (error) {
      next(error);
    }
  }

  // Login user
  async login(req, res, next) {
    try {
      const { email, password, rememberMe } = req.body;

      // Find user by email
      const user = await User.findByEmail(email);
      if (!user) {
        return next(new AppError('Invalid email or password', 401));
      }

      // Check if user is active
      if (!user.isActive) {
        return next(new AppError('Account has been deactivated', 401));
      }

      // Verify password
      const isPasswordValid = await user.verifyPassword(password);
      if (!isPasswordValid) {
        return next(new AppError('Invalid email or password', 401));
      }

      // Update last login
      await User.updateLastLogin(user.id);

      // Generate tokens
      const tokenExpiry = rememberMe ? '30d' : '24h';
      const { accessToken, refreshToken } = this.generateTokens(user.id, tokenExpiry);

      logger.info(`User logged in: ${user.email}`);

      res.json(
        ApiResponse.success({
          user: user.fullProfile,
          tokens: { accessToken, refreshToken },
        }, 'Login successful')
      );
    } catch (error) {
      next(error);
    }
  }

  // Social media login
  async socialLogin(req, res, next) {
    try {
      logger.info(`Social login attempt - Provider: ${req.body.provider}, Body:`, JSON.stringify(req.body, null, 2));
      const { provider, token, userData } = req.body;

      let socialUserData;

      // Verify token based on provider
      let verificationResult;
      switch (provider) {
        case 'google':
          verificationResult = await verifyGoogleToken(token);
          break;
        case 'facebook':
          verificationResult = await verifyFacebookToken(token);
          break;
        case 'apple':
          verificationResult = await verifyAppleToken(token);
          break;
        default:
          return next(new AppError('Invalid social provider', 400));
      }

      if (!verificationResult || !verificationResult.success) {
        logger.error(`${provider} token verification failed:`, verificationResult?.error);
        return next(new AppError(`Invalid ${provider} token`, 400));
      }

      socialUserData = verificationResult.user;

      // Check if user exists
      let user = await User.findByEmail(socialUserData.email);

      if (user) {
        // Update social provider info
        const socialProviders = user.socialProviders || {};
        socialProviders[provider] = {
          id: socialUserData.id,
          connectedAt: new Date().toISOString(),
        };

        await user.$query().patch({ socialProviders });
      } else {
        // Create new user from social data
        const fullName = socialUserData.name || 
                        `${socialUserData.firstName || ''} ${socialUserData.lastName || ''}`.trim() ||
                        socialUserData.email?.split('@')[0] || 'User';
        
        const newUserData = {
          email: socialUserData.email,
          fullName: fullName,
          profileImageUrl: socialUserData.picture || socialUserData.profilePicture,
          isVerified: true,
          consentGiven: true, // Assumed for social login
          socialProviders: {
            [provider]: {
              id: socialUserData.id,
              connectedAt: new Date().toISOString(),
            },
          },
        };

        user = await User.createUser(newUserData);
      }

      // Update last login
      await User.updateLastLogin(user.id);

      // Generate tokens
      const { accessToken, refreshToken } = this.generateTokens(user.id);

      logger.info(`User logged in via ${provider}: ${user.email}`);

      res.json(
        ApiResponse.success({
          user: user.fullProfile,
          tokens: { accessToken, refreshToken },
        }, 'Social login successful')
      );
    } catch (error) {
      next(error);
    }
  }

  // Phone number login
  async phoneLogin(req, res, next) {
    try {
      const { phoneNumber } = req.body;

      // Generate OTP
      const otp = Math.floor(100000 + Math.random() * 900000).toString();
      const verificationId = uuidv4();

      // Store OTP in cache/database (implement caching mechanism)
      // For now, we'll use a simple in-memory store (not production-ready)
      global.otpStore = global.otpStore || {};
      global.otpStore[verificationId] = {
        phoneNumber,
        otp,
        expiresAt: new Date(Date.now() + 5 * 60 * 1000), // 5 minutes
      };

      // Send OTP via SMS
      try {
        await sendSMS({
          to: phoneNumber,
          message: `Your TravelSync verification code is: ${otp}. Valid for 5 minutes.`,
        });
      } catch (smsError) {
        logger.error('Failed to send OTP SMS:', smsError);
        return next(new AppError('Failed to send verification code', 500));
      }

      logger.info(`OTP sent to phone: ${phoneNumber}`);

      res.json(
        ApiResponse.success({
          verificationId,
          message: 'Verification code sent to your phone',
        })
      );
    } catch (error) {
      next(error);
    }
  }

  // Verify OTP
  async verifyOtp(req, res, next) {
    try {
      const { phoneNumber, otp, verificationId } = req.body;

      // Retrieve stored OTP
      const storedOtpData = global.otpStore?.[verificationId];
      if (!storedOtpData) {
        return next(new AppError('Invalid verification ID', 400));
      }

      // Check expiration
      if (new Date() > storedOtpData.expiresAt) {
        delete global.otpStore[verificationId];
        return next(new AppError('Verification code has expired', 400));
      }

      // Verify OTP and phone number
      if (storedOtpData.otp !== otp || storedOtpData.phoneNumber !== phoneNumber) {
        return next(new AppError('Invalid verification code', 400));
      }

      // Clean up OTP
      delete global.otpStore[verificationId];

      // Find or create user
      let user = await User.findByPhoneNumber(phoneNumber);
      if (!user) {
        // Create new user with phone number
        const userData = {
          email: `${phoneNumber}@phone.travelsync.com`, // Temporary email
          phoneNumber,
          fullName: 'Phone User',
          isVerified: true,
          consentGiven: true,
        };
        user = await User.createUser(userData);
      }

      // Update last login
      await User.updateLastLogin(user.id);

      // Generate tokens
      const { accessToken, refreshToken } = this.generateTokens(user.id);

      logger.info(`User verified via phone: ${phoneNumber}`);

      res.json(
        ApiResponse.success({
          user: user.fullProfile,
          tokens: { accessToken, refreshToken },
        }, 'Phone verification successful')
      );
    } catch (error) {
      next(error);
    }
  }

  // Forgot password
  async forgotPassword(req, res, next) {
    try {
      const { email } = req.body;

      const user = await User.findByEmail(email);
      if (!user) {
        // Don't reveal if user exists or not
        return res.json(
          ApiResponse.success(null, 'If an account with that email exists, a password reset link has been sent')
        );
      }

      // Generate reset token
      const resetToken = jwt.sign(
        { userId: user.id, type: 'password_reset' },
        process.env.JWT_SECRET,
        { expiresIn: '1h' }
      );

      // Send password reset email
      try {
        await sendEmail({
          to: user.email,
          subject: 'Password Reset - TravelSync',
          template: 'password-reset',
          data: {
            fullName: user.fullName,
            resetToken,
            resetUrl: `${process.env.CLIENT_URL}/reset-password?token=${resetToken}`,
          },
        });
      } catch (emailError) {
        logger.error('Failed to send password reset email:', emailError);
        return next(new AppError('Failed to send password reset email', 500));
      }

      logger.info(`Password reset requested for: ${user.email}`);

      res.json(
        ApiResponse.success(null, 'Password reset link has been sent to your email')
      );
    } catch (error) {
      next(error);
    }
  }

  // Reset password
  async resetPassword(req, res, next) {
    try {
      const { token, newPassword } = req.body;

      // Verify reset token
      let decoded;
      try {
        decoded = jwt.verify(token, process.env.JWT_SECRET);
      } catch (jwtError) {
        return next(new AppError('Invalid or expired reset token', 400));
      }

      if (decoded.type !== 'password_reset') {
        return next(new AppError('Invalid token type', 400));
      }

      // Find user
      const user = await User.query().findById(decoded.userId);
      if (!user) {
        return next(new AppError('User not found', 404));
      }

      // Update password
      await user.$query().patch({ password: newPassword });

      logger.info(`Password reset completed for: ${user.email}`);

      res.json(
        ApiResponse.success(null, 'Password has been reset successfully')
      );
    } catch (error) {
      next(error);
    }
  }

  // Logout
  async logout(req, res, next) {
    try {
      // In a production app, you might want to blacklist the token
      // For now, we'll just return success
      
      logger.info(`User logged out: ${req.user.id}`);

      res.json(
        ApiResponse.success(null, 'Logout successful')
      );
    } catch (error) {
      next(error);
    }
  }

  // Get current user
  async getCurrentUser(req, res, next) {
    try {
      const user = await User.query()
        .findById(req.user.id)
        .modify('defaultSelects');

      if (!user) {
        return next(new AppError('User not found', 404));
      }

      res.json(
        ApiResponse.success(user.fullProfile, 'User profile retrieved successfully')
      );
    } catch (error) {
      next(error);
    }
  }

  // Refresh token
  async refreshToken(req, res, next) {
    try {
      const { refreshToken } = req.body;

      // Verify refresh token
      let decoded;
      try {
        decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET);
      } catch (jwtError) {
        return next(new AppError('Invalid refresh token', 401));
      }

      // Generate new tokens
      const { accessToken, refreshToken: newRefreshToken } = this.generateTokens(decoded.userId);

      res.json(
        ApiResponse.success({
          accessToken,
          refreshToken: newRefreshToken,
        }, 'Token refreshed successfully')
      );
    } catch (error) {
      next(error);
    }
  }

  // Helper method to generate JWT tokens
  generateTokens(userId, accessTokenExpiry = '24h') {
    const accessToken = jwt.sign(
      { userId, type: 'access' },
      process.env.JWT_SECRET,
      { expiresIn: accessTokenExpiry }
    );

    const refreshToken = jwt.sign(
      { userId, type: 'refresh' },
      process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    return { accessToken, refreshToken };
  }
}

module.exports = new AuthController();
