import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import {
  DocumentArrowDownIcon,
  CalendarIcon,
  ChartBarIcon,
  MapIcon,
  UsersIcon,
  ClockIcon,
  ArrowDownTrayIcon,
  EyeIcon,
  ExclamationTriangleIcon,
} from '@heroicons/react/24/outline';
import Layout from '../components/Layout';
import { useReports } from '../hooks/useReports';
import { useExport } from '../hooks/useExport';
import { ReportConfig } from '../services/reportService';

interface Report {
  id: string;
  name: string;
  description: string;
  type: 'trip' | 'user' | 'analytics' | 'custom';
  format: 'csv' | 'excel' | 'pdf';
  lastGenerated: string;
  size: string;
  status: 'ready' | 'generating' | 'failed';
}

const predefinedReports: Report[] = [
  {
    id: '1',
    name: 'Trip Data Export',
    description: 'Complete trip data with routes, timings, and expenses',
    type: 'trip',
    format: 'csv',
    lastGenerated: '2024-01-20T10:30:00Z',
    size: '2.4 MB',
    status: 'ready',
  },
  {
    id: '2',
    name: 'User Analytics Report',
    description: 'User behavior patterns and travel statistics',
    type: 'user',
    format: 'excel',
    lastGenerated: '2024-01-19T15:45:00Z',
    size: '1.8 MB',
    status: 'ready',
  },
  {
    id: '3',
    name: 'Monthly Travel Summary',
    description: 'Monthly aggregated travel data and trends',
    type: 'analytics',
    format: 'pdf',
    lastGenerated: '2024-01-18T09:20:00Z',
    size: '856 KB',
    status: 'ready',
  },
  {
    id: '4',
    name: 'Route Analysis Report',
    description: 'Popular routes and traffic pattern analysis',
    type: 'analytics',
    format: 'excel',
    lastGenerated: '2024-01-17T14:15:00Z',
    size: '3.2 MB',
    status: 'generating',
  },
];

export default function Reports() {
  const {
    reports: reportsList,
    isGenerating,
    error: reportError,
    generateReport,
    generateQuickReport,
    downloadReport,
    deleteReport,
    getTemplates,
  } = useReports();
  
  const {
    isExporting,
    error: exportError,
    exportTrips,
    exportUsers,
    exportAnalytics,
  } = useExport();

  const [selectedDateRange, setSelectedDateRange] = useState('last30days');
  const [selectedFormat, setSelectedFormat] = useState<'csv' | 'excel' | 'pdf'>('csv');
  const [selectedReportType, setSelectedReportType] = useState<'trip' | 'user' | 'analytics' | 'custom'>('trip');
  const [showNotification, setShowNotification] = useState(false);
  const [notificationMessage, setNotificationMessage] = useState('');

  const getTypeIcon = (type: string) => {
    switch (type) {
      case 'trip':
        return MapIcon;
      case 'user':
        return UsersIcon;
      case 'analytics':
        return ChartBarIcon;
      default:
        return DocumentArrowDownIcon;
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed':
        return 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200';
      case 'processing':
        return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200';
      case 'failed':
        return 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200';
      case 'queued':
        return 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200';
      default:
        return 'bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-200';
    }
  };

  const showNotificationMessage = (message: string) => {
    setNotificationMessage(message);
    setShowNotification(true);
    setTimeout(() => setShowNotification(false), 3000);
  };

  const getDateRange = (range: string) => {
    const now = new Date();
    const start = new Date();
    
    switch (range) {
      case 'last7days':
        start.setDate(now.getDate() - 7);
        break;
      case 'last30days':
        start.setDate(now.getDate() - 30);
        break;
      case 'last3months':
        start.setMonth(now.getMonth() - 3);
        break;
      case 'last6months':
        start.setMonth(now.getMonth() - 6);
        break;
      case 'lastyear':
        start.setFullYear(now.getFullYear() - 1);
        break;
      default:
        start.setDate(now.getDate() - 30);
    }
    
    return { start, end: now };
  };

  const handleGenerateReport = async () => {
    try {
      const dateRange = getDateRange(selectedDateRange);
      const config: ReportConfig = {
        type: selectedReportType,
        dateRange,
        format: selectedFormat,
        anonymize: true,
      };
      
      const reportId = await generateReport(config);
      showNotificationMessage(`Report generation started. ID: ${reportId}`);
    } catch (error) {
      showNotificationMessage('Failed to generate report');
    }
  };

  const handleQuickExport = async (type: 'trip' | 'user' | 'analytics') => {
    try {
      switch (type) {
        case 'trip':
          await exportTrips('csv');
          showNotificationMessage('Trip data exported successfully');
          break;
        case 'user':
          await exportUsers('csv');
          showNotificationMessage('User data exported successfully');
          break;
        case 'analytics':
          await exportAnalytics('csv');
          showNotificationMessage('Analytics data exported successfully');
          break;
      }
    } catch (error) {
      showNotificationMessage(`Failed to export ${type} data`);
    }
  };

  const handleDownload = async (reportId: string) => {
    try {
      await downloadReport(reportId);
      showNotificationMessage('Report downloaded successfully');
    } catch (error) {
      showNotificationMessage('Failed to download report');
    }
  };

  const handleDeleteReport = async (reportId: string) => {
    try {
      await deleteReport(reportId);
      showNotificationMessage('Report deleted successfully');
    } catch (error) {
      showNotificationMessage('Failed to delete report');
    }
  };

  return (
    <Layout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">
              Reports & Data Export
            </h1>
            <p className="text-gray-600 dark:text-gray-400">
              Generate and download comprehensive travel data reports
            </p>
          </div>
        </div>

        {/* Quick Stats */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          <div className="bg-white dark:bg-gray-800 overflow-hidden shadow rounded-lg">
            <div className="p-5">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <DocumentArrowDownIcon className="h-6 w-6 text-gray-400" />
                </div>
                <div className="ml-5 w-0 flex-1">
                  <dl>
                    <dt className="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">
                      Total Reports
                    </dt>
                    <dd className="text-lg font-medium text-gray-900 dark:text-gray-100">
                      {reportsList.length}
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>
          <div className="bg-white dark:bg-gray-800 overflow-hidden shadow rounded-lg">
            <div className="p-5">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <div className="h-2 w-2 bg-green-400 rounded-full"></div>
                </div>
                <div className="ml-5 w-0 flex-1">
                  <dl>
                    <dt className="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">
                      Ready
                    </dt>
                    <dd className="text-lg font-medium text-gray-900 dark:text-gray-100">
                      {reportsList.filter(r => r.status === 'completed').length}
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>
          <div className="bg-white dark:bg-gray-800 overflow-hidden shadow rounded-lg">
            <div className="p-5">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <div className="h-2 w-2 bg-yellow-400 rounded-full"></div>
                </div>
                <div className="ml-5 w-0 flex-1">
                  <dl>
                    <dt className="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">
                      Generating
                    </dt>
                    <dd className="text-lg font-medium text-gray-900 dark:text-gray-100">
                      {reportsList.filter(r => r.status === 'processing').length}
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>
          <div className="bg-white dark:bg-gray-800 overflow-hidden shadow rounded-lg">
            <div className="p-5">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <ClockIcon className="h-6 w-6 text-gray-400" />
                </div>
                <div className="ml-5 w-0 flex-1">
                  <dl>
                    <dt className="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">
                      Last Generated
                    </dt>
                    <dd className="text-sm font-medium text-gray-900 dark:text-gray-100">
                      Today
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Generate New Report */}
        <div className="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
          <h3 className="text-lg font-medium text-gray-900 dark:text-gray-100 mb-4">
            Generate New Report
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Report Type
              </label>
              <select
                value={selectedReportType}
                onChange={(e) => setSelectedReportType(e.target.value as 'trip' | 'user' | 'analytics' | 'custom')}
                className="w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-100 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              >
                <option value="trip">Trip Data</option>
                <option value="user">User Analytics</option>
                <option value="analytics">Travel Analytics</option>
                <option value="custom">Custom Report</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Date Range
              </label>
              <select
                value={selectedDateRange}
                onChange={(e) => setSelectedDateRange(e.target.value)}
                className="w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-100 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              >
                <option value="last7days">Last 7 Days</option>
                <option value="last30days">Last 30 Days</option>
                <option value="last3months">Last 3 Months</option>
                <option value="last6months">Last 6 Months</option>
                <option value="lastyear">Last Year</option>
                <option value="custom">Custom Range</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Format
              </label>
              <select
                value={selectedFormat}
                onChange={(e) => setSelectedFormat(e.target.value as 'csv' | 'excel' | 'pdf')}
                className="w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-100 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              >
                <option value="csv">CSV</option>
                <option value="excel">Excel</option>
                <option value="pdf">PDF</option>
              </select>
            </div>
            <div className="flex items-end">
              <button
                onClick={handleGenerateReport}
                disabled={isGenerating}
                className="w-full inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {isGenerating ? (
                  <>
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                    Generating...
                  </>
                ) : (
                  <>
                    <DocumentArrowDownIcon className="h-4 w-4 mr-2" />
                    Generate
                  </>
                )}
              </button>
            </div>
          </div>
        </div>

        {/* Reports List */}
        <div className="bg-white dark:bg-gray-800 shadow overflow-hidden sm:rounded-md">
          <div className="px-4 py-5 sm:px-6 border-b border-gray-200 dark:border-gray-700">
            <h3 className="text-lg leading-6 font-medium text-gray-900 dark:text-gray-100">
              Available Reports
            </h3>
            <p className="mt-1 max-w-2xl text-sm text-gray-500 dark:text-gray-400">
              Download or view previously generated reports
            </p>
          </div>
          <ul className="divide-y divide-gray-200 dark:divide-gray-700">
            {reportsList.map((report, index) => {
              const IconComponent = DocumentArrowDownIcon; // Default icon since we don't have type info
              return (
                <motion.li
                  key={report.id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.1 }}
                  className="hover:bg-gray-50 dark:hover:bg-gray-700"
                >
                  <div className="px-4 py-4 sm:px-6">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center space-x-4">
                        <div className="flex-shrink-0">
                          <div className="h-10 w-10 bg-indigo-100 dark:bg-indigo-900 rounded-lg flex items-center justify-center">
                            <IconComponent className="h-5 w-5 text-indigo-600 dark:text-indigo-400" />
                          </div>
                        </div>
                        <div className="min-w-0 flex-1">
                          <div className="flex items-center space-x-2">
                            <p className="text-sm font-medium text-gray-900 dark:text-gray-100 truncate">
                              Report {report.id.split('_')[1]}
                            </p>
                            <span
                              className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(
                                report.status
                              )}`}
                            >
                              {report.status}
                            </span>
                          </div>
                          <div className="flex items-center space-x-4 mt-1">
                            <p className="text-sm text-gray-500 dark:text-gray-400">
                              {report.message}
                            </p>
                          </div>
                          <div className="flex items-center space-x-4 mt-1">
                            <div className="flex items-center text-sm text-gray-500 dark:text-gray-400">
                              <CalendarIcon className="h-4 w-4 mr-1" />
                              {new Date().toLocaleDateString()}
                            </div>
                            {report.progress > 0 && (
                              <div className="text-sm text-gray-500 dark:text-gray-400">
                                {report.progress}% complete
                              </div>
                            )}
                          </div>
                        </div>
                      </div>
                      <div className="flex items-center space-x-2">
                        {report.status === 'completed' && (
                          <>
                            <button
                              onClick={() => handleDownload(report.id)}
                              className="inline-flex items-center p-2 border border-transparent rounded-full shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                            >
                              <ArrowDownTrayIcon className="h-4 w-4" />
                            </button>
                            <button
                              onClick={() => handleDeleteReport(report.id)}
                              className="inline-flex items-center p-2 border border-transparent rounded-full shadow-sm text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
                            >
                              ×
                            </button>
                          </>
                        )}
                        {report.status === 'processing' && (
                          <div className="inline-flex items-center p-2">
                            <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-indigo-600"></div>
                          </div>
                        )}
                        {report.status === 'failed' && (
                          <div className="inline-flex items-center p-2">
                            <ExclamationTriangleIcon className="h-4 w-4 text-red-500" />
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                </motion.li>
              );
            })}
          </ul>
        </div>

        {/* Report Templates */}
        <div className="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
          <h3 className="text-lg font-medium text-gray-900 dark:text-gray-100 mb-4">
            Quick Export Templates
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <button
              onClick={() => handleQuickExport('trip')}
              disabled={isExporting}
              className="border border-gray-200 dark:border-gray-700 rounded-lg p-4 hover:border-indigo-500 cursor-pointer transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <div className="flex items-center space-x-3">
                <MapIcon className="h-8 w-8 text-indigo-600" />
                <div className="text-left">
                  <h4 className="text-sm font-medium text-gray-900 dark:text-gray-100">
                    Export Trip Data
                  </h4>
                  <p className="text-xs text-gray-500 dark:text-gray-400">
                    Download all trip data as CSV
                  </p>
                </div>
              </div>
            </button>
            <button
              onClick={() => handleQuickExport('user')}
              disabled={isExporting}
              className="border border-gray-200 dark:border-gray-700 rounded-lg p-4 hover:border-indigo-500 cursor-pointer transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <div className="flex items-center space-x-3">
                <UsersIcon className="h-8 w-8 text-green-600" />
                <div className="text-left">
                  <h4 className="text-sm font-medium text-gray-900 dark:text-gray-100">
                    Export User Data
                  </h4>
                  <p className="text-xs text-gray-500 dark:text-gray-400">
                    Download user information as CSV
                  </p>
                </div>
              </div>
            </button>
            <button
              onClick={() => handleQuickExport('analytics')}
              disabled={isExporting}
              className="border border-gray-200 dark:border-gray-700 rounded-lg p-4 hover:border-indigo-500 cursor-pointer transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <div className="flex items-center space-x-3">
                <ChartBarIcon className="h-8 w-8 text-purple-600" />
                <div className="text-left">
                  <h4 className="text-sm font-medium text-gray-900 dark:text-gray-100">
                    Export Analytics
                  </h4>
                  <p className="text-xs text-gray-500 dark:text-gray-400">
                    Download analytics data as CSV
                  </p>
                </div>
              </div>
            </button>
          </div>
        </div>

        {/* Notification */}
        {showNotification && (
          <div className="fixed bottom-4 right-4 z-50">
            <div className="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg shadow-lg p-4 max-w-sm">
              <div className="flex items-center space-x-3">
                <div className="flex-shrink-0">
                  <div className="h-2 w-2 bg-green-400 rounded-full"></div>
                </div>
                <p className="text-sm text-gray-900 dark:text-gray-100">
                  {notificationMessage}
                </p>
              </div>
            </div>
          </div>
        )}

        {/* Error Display */}
        {(reportError || exportError) && (
          <div className="fixed bottom-4 right-4 z-50">
            <div className="bg-red-50 dark:bg-red-900 border border-red-200 dark:border-red-700 rounded-lg shadow-lg p-4 max-w-sm">
              <div className="flex items-center space-x-3">
                <ExclamationTriangleIcon className="h-5 w-5 text-red-400" />
                <p className="text-sm text-red-800 dark:text-red-200">
                  {reportError || exportError}
                </p>
              </div>
            </div>
          </div>
        )}
      </div>
    </Layout>
  );
}
