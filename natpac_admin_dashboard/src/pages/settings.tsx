import { useState } from 'react';
import { motion } from 'framer-motion';
import {
  Cog6ToothIcon,
  BellIcon,
  ShieldCheckIcon,
  GlobeAltIcon,
  CircleStackIcon as DatabaseIcon,
  KeyIcon,
  UserGroupIcon,
  ChartBarIcon,
} from '@heroicons/react/24/outline';
import Layout from '../components/Layout';

interface SettingsSection {
  id: string;
  name: string;
  icon: any;
  description: string;
}

const settingsSections: SettingsSection[] = [
  {
    id: 'general',
    name: 'General',
    icon: Cog6ToothIcon,
    description: 'Basic system configuration and preferences',
  },
  {
    id: 'notifications',
    name: 'Notifications',
    icon: BellIcon,
    description: 'Configure email and system notifications',
  },
  {
    id: 'security',
    name: 'Security',
    icon: ShieldCheckIcon,
    description: 'Security settings and access controls',
  },
  {
    id: 'api',
    name: 'API Settings',
    icon: GlobeAltIcon,
    description: 'API configuration and integrations',
  },
  {
    id: 'database',
    name: 'Database',
    icon: DatabaseIcon,
    description: 'Database configuration and maintenance',
  },
  {
    id: 'analytics',
    name: 'Analytics',
    icon: ChartBarIcon,
    description: 'Analytics and tracking configuration',
  },
];

export default function Settings() {
  const [activeSection, setActiveSection] = useState('general');
  const [settings, setSettings] = useState({
    // General Settings
    systemName: 'Yaathri Admin Dashboard',
    timezone: 'Asia/Kolkata',
    language: 'en',
    dateFormat: 'DD/MM/YYYY',
    
    // Notification Settings
    emailNotifications: true,
    smsNotifications: false,
    pushNotifications: true,
    reportNotifications: true,
    
    // Security Settings
    sessionTimeout: 30,
    passwordPolicy: 'strong',
    twoFactorAuth: false,
    loginAttempts: 5,
    
    // API Settings
    apiRateLimit: 1000,
    apiTimeout: 30,
    webhookUrl: '',
    
    // Database Settings
    backupFrequency: 'daily',
    retentionPeriod: 365,
    
    // Analytics Settings
    trackingEnabled: true,
    anonymizeData: true,
    dataRetention: 730,
  });

  const handleSettingChange = (key: string, value: any) => {
    setSettings(prev => ({
      ...prev,
      [key]: value
    }));
  };

  const [isSaving, setIsSaving] = useState(false);
  const [saveMessage, setSaveMessage] = useState('');
  const [isCreatingBackup, setIsCreatingBackup] = useState(false);

  const handleSave = async () => {
    setIsSaving(true);
    try {
      // Simulate API call to save settings
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // In production, this would call apiService.updateSettings(settings)
      console.log('Saving settings:', settings);
      
      setSaveMessage('Settings saved successfully!');
      setTimeout(() => setSaveMessage(''), 3000);
    } catch (error) {
      setSaveMessage('Failed to save settings');
      setTimeout(() => setSaveMessage(''), 3000);
    } finally {
      setIsSaving(false);
    }
  };

  const handleCreateBackup = async () => {
    setIsCreatingBackup(true);
    try {
      // Simulate backup creation
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      // In production, this would call apiService.createBackup()
      console.log('Creating backup...');
      
      setSaveMessage('Backup created successfully!');
      setTimeout(() => setSaveMessage(''), 3000);
    } catch (error) {
      setSaveMessage('Failed to create backup');
      setTimeout(() => setSaveMessage(''), 3000);
    } finally {
      setIsCreatingBackup(false);
    }
  };

  const renderGeneralSettings = () => (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-medium text-gray-900 dark:text-gray-100 mb-4">
          General Configuration
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              System Name
            </label>
            <input
              type="text"
              value={settings.systemName}
              onChange={(e) => handleSettingChange('systemName', e.target.value)}
              className="w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-100 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Timezone
            </label>
            <select
              value={settings.timezone}
              onChange={(e) => handleSettingChange('timezone', e.target.value)}
              className="w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-100 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
            >
              <option value="Asia/Kolkata">Asia/Kolkata</option>
              <option value="UTC">UTC</option>
              <option value="America/New_York">America/New_York</option>
              <option value="Europe/London">Europe/London</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Language
            </label>
            <select
              value={settings.language}
              onChange={(e) => handleSettingChange('language', e.target.value)}
              className="w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-100 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
            >
              <option value="en">English</option>
              <option value="hi">Hindi</option>
              <option value="mr">Marathi</option>
              <option value="ta">Tamil</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Date Format
            </label>
            <select
              value={settings.dateFormat}
              onChange={(e) => handleSettingChange('dateFormat', e.target.value)}
              className="w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-100 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
            >
              <option value="DD/MM/YYYY">DD/MM/YYYY</option>
              <option value="MM/DD/YYYY">MM/DD/YYYY</option>
              <option value="YYYY-MM-DD">YYYY-MM-DD</option>
            </select>
          </div>
        </div>
      </div>
    </div>
  );

  const renderNotificationSettings = () => (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-medium text-gray-900 dark:text-gray-100 mb-4">
          Notification Preferences
        </h3>
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <h4 className="text-sm font-medium text-gray-900 dark:text-gray-100">
                Email Notifications
              </h4>
              <p className="text-sm text-gray-500 dark:text-gray-400">
                Receive notifications via email
              </p>
            </div>
            <button
              onClick={() => handleSettingChange('emailNotifications', !settings.emailNotifications)}
              className={`relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 ${
                settings.emailNotifications ? 'bg-indigo-600' : 'bg-gray-200 dark:bg-gray-700'
              }`}
            >
              <span
                className={`pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out ${
                  settings.emailNotifications ? 'translate-x-5' : 'translate-x-0'
                }`}
              />
            </button>
          </div>
          <div className="flex items-center justify-between">
            <div>
              <h4 className="text-sm font-medium text-gray-900 dark:text-gray-100">
                SMS Notifications
              </h4>
              <p className="text-sm text-gray-500 dark:text-gray-400">
                Receive notifications via SMS
              </p>
            </div>
            <button
              onClick={() => handleSettingChange('smsNotifications', !settings.smsNotifications)}
              className={`relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 ${
                settings.smsNotifications ? 'bg-indigo-600' : 'bg-gray-200 dark:bg-gray-700'
              }`}
            >
              <span
                className={`pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out ${
                  settings.smsNotifications ? 'translate-x-5' : 'translate-x-0'
                }`}
              />
            </button>
          </div>
          <div className="flex items-center justify-between">
            <div>
              <h4 className="text-sm font-medium text-gray-900 dark:text-gray-100">
                Push Notifications
              </h4>
              <p className="text-sm text-gray-500 dark:text-gray-400">
                Receive browser push notifications
              </p>
            </div>
            <button
              onClick={() => handleSettingChange('pushNotifications', !settings.pushNotifications)}
              className={`relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 ${
                settings.pushNotifications ? 'bg-indigo-600' : 'bg-gray-200 dark:bg-gray-700'
              }`}
            >
              <span
                className={`pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out ${
                  settings.pushNotifications ? 'translate-x-5' : 'translate-x-0'
                }`}
              />
            </button>
          </div>
          <div className="flex items-center justify-between">
            <div>
              <h4 className="text-sm font-medium text-gray-900 dark:text-gray-100">
                Report Notifications
              </h4>
              <p className="text-sm text-gray-500 dark:text-gray-400">
                Get notified when reports are ready
              </p>
            </div>
            <button
              onClick={() => handleSettingChange('reportNotifications', !settings.reportNotifications)}
              className={`relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 ${
                settings.reportNotifications ? 'bg-indigo-600' : 'bg-gray-200 dark:bg-gray-700'
              }`}
            >
              <span
                className={`pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out ${
                  settings.reportNotifications ? 'translate-x-5' : 'translate-x-0'
                }`}
              />
            </button>
          </div>
        </div>
      </div>
    </div>
  );

  const renderSecuritySettings = () => (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-medium text-gray-900 dark:text-gray-100 mb-4">
          Security Configuration
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Session Timeout (minutes)
            </label>
            <input
              type="number"
              value={settings.sessionTimeout}
              onChange={(e) => handleSettingChange('sessionTimeout', parseInt(e.target.value))}
              className="w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-100 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Password Policy
            </label>
            <select
              value={settings.passwordPolicy}
              onChange={(e) => handleSettingChange('passwordPolicy', e.target.value)}
              className="w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-100 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
            >
              <option value="weak">Weak (6+ characters)</option>
              <option value="medium">Medium (8+ characters, mixed case)</option>
              <option value="strong">Strong (12+ characters, mixed case, numbers, symbols)</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Max Login Attempts
            </label>
            <input
              type="number"
              value={settings.loginAttempts}
              onChange={(e) => handleSettingChange('loginAttempts', parseInt(e.target.value))}
              className="w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-100 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
            />
          </div>
          <div className="flex items-center justify-between">
            <div>
              <h4 className="text-sm font-medium text-gray-900 dark:text-gray-100">
                Two-Factor Authentication
              </h4>
              <p className="text-sm text-gray-500 dark:text-gray-400">
                Require 2FA for admin access
              </p>
            </div>
            <button
              onClick={() => handleSettingChange('twoFactorAuth', !settings.twoFactorAuth)}
              className={`relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 ${
                settings.twoFactorAuth ? 'bg-indigo-600' : 'bg-gray-200 dark:bg-gray-700'
              }`}
            >
              <span
                className={`pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out ${
                  settings.twoFactorAuth ? 'translate-x-5' : 'translate-x-0'
                }`}
              />
            </button>
          </div>
        </div>
      </div>
    </div>
  );

  const renderApiSettings = () => (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-medium text-gray-900 dark:text-gray-100 mb-4">
          API Configuration
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Rate Limit (requests/hour)
            </label>
            <input
              type="number"
              value={settings.apiRateLimit}
              onChange={(e) => handleSettingChange('apiRateLimit', parseInt(e.target.value))}
              className="w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-100 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Timeout (seconds)
            </label>
            <input
              type="number"
              value={settings.apiTimeout}
              onChange={(e) => handleSettingChange('apiTimeout', parseInt(e.target.value))}
              className="w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-100 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
            />
          </div>
          <div className="md:col-span-2">
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Webhook URL
            </label>
            <input
              type="url"
              value={settings.webhookUrl}
              onChange={(e) => handleSettingChange('webhookUrl', e.target.value)}
              placeholder="https://your-webhook-url.com/endpoint"
              className="w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-100 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
            />
          </div>
        </div>
      </div>
    </div>
  );

  const renderDatabaseSettings = () => (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-medium text-gray-900 dark:text-gray-100 mb-4">
          Database Configuration
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Backup Frequency
            </label>
            <select
              value={settings.backupFrequency}
              onChange={(e) => handleSettingChange('backupFrequency', e.target.value)}
              className="w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-100 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
            >
              <option value="hourly">Hourly</option>
              <option value="daily">Daily</option>
              <option value="weekly">Weekly</option>
              <option value="monthly">Monthly</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Data Retention (days)
            </label>
            <input
              type="number"
              value={settings.retentionPeriod}
              onChange={(e) => handleSettingChange('retentionPeriod', parseInt(e.target.value))}
              className="w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-100 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
            />
          </div>
        </div>
        <div className="mt-6 flex space-x-4">
          <button
            onClick={handleCreateBackup}
            disabled={isCreatingBackup}
            className="inline-flex items-center px-4 py-2 border border-gray-300 dark:border-gray-600 text-sm font-medium rounded-md text-gray-700 dark:text-gray-200 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isCreatingBackup ? (
              <>
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-gray-600 mr-2"></div>
                Creating Backup...
              </>
            ) : (
              'Create Backup Now'
            )}
          </button>
          <button className="inline-flex items-center px-4 py-2 border border-gray-300 dark:border-gray-600 text-sm font-medium rounded-md text-gray-700 dark:text-gray-200 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
            View Backup History
          </button>
        </div>
      </div>
    </div>
  );

  const renderAnalyticsSettings = () => (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-medium text-gray-900 dark:text-gray-100 mb-4">
          Analytics Configuration
        </h3>
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <h4 className="text-sm font-medium text-gray-900 dark:text-gray-100">
                Enable Tracking
              </h4>
              <p className="text-sm text-gray-500 dark:text-gray-400">
                Track user interactions and system usage
              </p>
            </div>
            <button
              onClick={() => handleSettingChange('trackingEnabled', !settings.trackingEnabled)}
              className={`relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 ${
                settings.trackingEnabled ? 'bg-indigo-600' : 'bg-gray-200 dark:bg-gray-700'
              }`}
            >
              <span
                className={`pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out ${
                  settings.trackingEnabled ? 'translate-x-5' : 'translate-x-0'
                }`}
              />
            </button>
          </div>
          <div className="flex items-center justify-between">
            <div>
              <h4 className="text-sm font-medium text-gray-900 dark:text-gray-100">
                Anonymize Data
              </h4>
              <p className="text-sm text-gray-500 dark:text-gray-400">
                Remove personally identifiable information
              </p>
            </div>
            <button
              onClick={() => handleSettingChange('anonymizeData', !settings.anonymizeData)}
              className={`relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 ${
                settings.anonymizeData ? 'bg-indigo-600' : 'bg-gray-200 dark:bg-gray-700'
              }`}
            >
              <span
                className={`pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out ${
                  settings.anonymizeData ? 'translate-x-5' : 'translate-x-0'
                }`}
              />
            </button>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Data Retention Period (days)
            </label>
            <input
              type="number"
              value={settings.dataRetention}
              onChange={(e) => handleSettingChange('dataRetention', parseInt(e.target.value))}
              className="w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-100 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
            />
          </div>
        </div>
      </div>
    </div>
  );

  const renderContent = () => {
    switch (activeSection) {
      case 'general':
        return renderGeneralSettings();
      case 'notifications':
        return renderNotificationSettings();
      case 'security':
        return renderSecuritySettings();
      case 'api':
        return renderApiSettings();
      case 'database':
        return renderDatabaseSettings();
      case 'analytics':
        return renderAnalyticsSettings();
      default:
        return renderGeneralSettings();
    }
  };

  return (
    <Layout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">
              System Settings
            </h1>
            <p className="text-gray-600 dark:text-gray-400">
              Configure system preferences and administrative settings
            </p>
          </div>
          <button
            onClick={handleSave}
            disabled={isSaving}
            className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isSaving ? (
              <>
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                Saving...
              </>
            ) : (
              'Save Changes'
            )}
          </button>
        </div>

        <div className="flex flex-col lg:flex-row gap-6">
          {/* Settings Navigation */}
          <div className="lg:w-1/4">
            <nav className="space-y-1">
              {settingsSections.map((section, index) => {
                const IconComponent = section.icon;
                return (
                  <motion.button
                    key={section.id}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: index * 0.1 }}
                    onClick={() => setActiveSection(section.id)}
                    className={`w-full text-left group flex items-center px-3 py-2 text-sm font-medium rounded-md transition-colors ${
                      activeSection === section.id
                        ? 'bg-indigo-50 dark:bg-indigo-900 text-indigo-700 dark:text-indigo-200'
                        : 'text-gray-600 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 hover:text-gray-900 dark:hover:text-gray-100'
                    }`}
                  >
                    <IconComponent
                      className={`mr-3 h-5 w-5 ${
                        activeSection === section.id
                          ? 'text-indigo-500 dark:text-indigo-400'
                          : 'text-gray-400 group-hover:text-gray-500'
                      }`}
                    />
                    <div>
                      <div className="font-medium">{section.name}</div>
                      <div className="text-xs text-gray-500 dark:text-gray-400">
                        {section.description}
                      </div>
                    </div>
                  </motion.button>
                );
              })}
            </nav>
          </div>

          {/* Settings Content */}
          <div className="lg:w-3/4">
            <div className="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
              {renderContent()}
            </div>
          </div>
        </div>

        {/* Success/Error Messages */}
        {saveMessage && (
          <div className="fixed bottom-4 right-4 z-50">
            <div className={`border rounded-lg shadow-lg p-4 max-w-sm ${
              saveMessage.includes('success') 
                ? 'bg-green-50 dark:bg-green-900 border-green-200 dark:border-green-700' 
                : 'bg-red-50 dark:bg-red-900 border-red-200 dark:border-red-700'
            }`}>
              <div className="flex items-center space-x-3">
                <div className={`flex-shrink-0 h-2 w-2 rounded-full ${
                  saveMessage.includes('success') ? 'bg-green-400' : 'bg-red-400'
                }`}></div>
                <p className={`text-sm ${
                  saveMessage.includes('success') 
                    ? 'text-green-800 dark:text-green-200' 
                    : 'text-red-800 dark:text-red-200'
                }`}>
                  {saveMessage}
                </p>
              </div>
            </div>
          </div>
        )}
      </div>
    </Layout>
  );
}
