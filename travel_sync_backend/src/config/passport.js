const passport = require('passport');
const JwtStrategy = require('passport-jwt').Strategy;
const ExtractJwt = require('passport-jwt').ExtractJwt;
const GoogleStrategy = require('passport-google-oauth20').Strategy;
const FacebookStrategy = require('passport-facebook').Strategy;
const User = require('../models/User');

const setupPassport = (app) => {
  // Initialize passport
  app.use(passport.initialize());

  // JWT Strategy
  const jwtOptions = {
    jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
    secretOrKey: process.env.JWT_SECRET || 'your-secret-key',
  };

  passport.use(new JwtStrategy(jwtOptions, async (payload, done) => {
    try {
      const user = await User.query().findById(payload.id);
      if (user) {
        return done(null, user);
      }
      return done(null, false);
    } catch (error) {
      return done(error, false);
    }
  }));

  // Google OAuth Strategy
  if (process.env.GOOGLE_CLIENT_ID && process.env.GOOGLE_CLIENT_SECRET) {
    passport.use(new GoogleStrategy({
      clientID: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
      callbackURL: "/api/v1/auth/google/callback"
    }, async (accessToken, refreshToken, profile, done) => {
      try {
        // Check if user already exists with this Google ID
        let user = await User.query().findOne({ googleId: profile.id });
        
        if (user) {
          return done(null, user);
        }

        // Check if user exists with same email
        user = await User.query().findOne({ email: profile.emails[0].value });
        
        if (user) {
          // Link Google account to existing user
          await user.$query().patch({ googleId: profile.id });
          return done(null, user);
        }

        // Create new user
        user = await User.query().insert({
          googleId: profile.id,
          email: profile.emails[0].value,
          firstName: profile.name.givenName,
          lastName: profile.name.familyName,
          profilePicture: profile.photos[0].value,
          isEmailVerified: true,
          authProvider: 'google'
        });

        return done(null, user);
      } catch (error) {
        return done(error, null);
      }
    }));
  }

  // Facebook Strategy
  if (process.env.FACEBOOK_APP_ID && process.env.FACEBOOK_APP_SECRET) {
    passport.use(new FacebookStrategy({
      clientID: process.env.FACEBOOK_APP_ID,
      clientSecret: process.env.FACEBOOK_APP_SECRET,
      callbackURL: "/api/v1/auth/facebook/callback",
      profileFields: ['id', 'emails', 'name', 'picture.type(large)']
    }, async (accessToken, refreshToken, profile, done) => {
      try {
        // Check if user already exists with this Facebook ID
        let user = await User.query().findOne({ facebookId: profile.id });
        
        if (user) {
          return done(null, user);
        }

        // Check if user exists with same email
        if (profile.emails && profile.emails.length > 0) {
          user = await User.query().findOne({ email: profile.emails[0].value });
          
          if (user) {
            // Link Facebook account to existing user
            await user.$query().patch({ facebookId: profile.id });
            return done(null, user);
          }
        }

        // Create new user
        user = await User.query().insert({
          facebookId: profile.id,
          email: profile.emails ? profile.emails[0].value : null,
          firstName: profile.name.givenName,
          lastName: profile.name.familyName,
          profilePicture: profile.photos ? profile.photos[0].value : null,
          isEmailVerified: true,
          authProvider: 'facebook'
        });

        return done(null, user);
      } catch (error) {
        return done(error, null);
      }
    }));
  }

  // Serialize user for session
  passport.serializeUser((user, done) => {
    done(null, user.id);
  });

  // Deserialize user from session
  passport.deserializeUser(async (id, done) => {
    try {
      const user = await User.query().findById(id);
      done(null, user);
    } catch (error) {
      done(error, null);
    }
  });
};

module.exports = { setupPassport };
