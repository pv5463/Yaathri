// Custom hook for data export functionality
import { useState, useCallback } from 'react';
import { exportData, ExportData, formatTripDataForExport, formatUserDataForExport, formatAnalyticsDataForExport } from '../utils/exportUtils';
import { apiService } from '../services/apiService';

export const useExport = () => {
  const [isExporting, setIsExporting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Export trips data
  const exportTrips = useCallback(async (
    format: 'csv' | 'excel' | 'pdf',
    filters?: any
  ) => {
    try {
      setIsExporting(true);
      setError(null);

      // In production, fetch from API
      // const tripsData = await apiService.getTrips(filters);
      
      // Mock data for now
      const mockTrips = [
        {
          id: '1',
          userId: 'user1',
          userName: 'John Doe',
          startLocation: 'Mumbai, Maharashtra',
          endLocation: 'Pune, Maharashtra',
          startTime: '2024-01-15T09:00:00Z',
          endTime: '2024-01-15T12:30:00Z',
          distance: 148.5,
          duration: 210,
          mode: 'Car',
          status: 'completed',
          expenses: 2500,
        },
        {
          id: '2',
          userId: 'user2',
          userName: 'Jane Smith',
          startLocation: 'Delhi, Delhi',
          endLocation: 'Agra, Uttar Pradesh',
          startTime: '2024-01-16T06:00:00Z',
          endTime: '2024-01-16T09:45:00Z',
          distance: 233.2,
          duration: 225,
          mode: 'Train',
          status: 'completed',
          expenses: 1200,
        },
        {
          id: '3',
          userId: 'user3',
          userName: 'Raj Patel',
          startLocation: 'Bangalore, Karnataka',
          endLocation: 'Mysore, Karnataka',
          startTime: '2024-01-17T14:00:00Z',
          endTime: '2024-01-17T17:30:00Z',
          distance: 156.8,
          duration: 210,
          mode: 'Bus',
          status: 'completed',
          expenses: 800,
        },
      ];

      const exportData = formatTripDataForExport(mockTrips);
      await exportDataFile(exportData, format);
      
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to export trips');
    } finally {
      setIsExporting(false);
    }
  }, []);

  // Export users data
  const exportUsers = useCallback(async (
    format: 'csv' | 'excel' | 'pdf',
    filters?: any
  ) => {
    try {
      setIsExporting(true);
      setError(null);

      // Mock data for now
      const mockUsers = [
        {
          id: '1',
          name: 'John Doe',
          email: 'john.doe@example.com',
          phone: '+91 9876543210',
          location: 'Mumbai, Maharashtra',
          joinDate: '2023-12-15',
          lastActive: '2024-01-20T10:30:00Z',
          status: 'active',
          tripCount: 25,
          totalDistance: 3420.5,
        },
        {
          id: '2',
          name: 'Jane Smith',
          email: 'jane.smith@example.com',
          phone: '+91 9876543211',
          location: 'Delhi, Delhi',
          joinDate: '2023-11-20',
          lastActive: '2024-01-19T15:45:00Z',
          status: 'active',
          tripCount: 18,
          totalDistance: 2890.2,
        },
        {
          id: '3',
          name: 'Raj Patel',
          email: 'raj.patel@example.com',
          phone: '+91 9876543212',
          location: 'Bangalore, Karnataka',
          joinDate: '2023-10-10',
          lastActive: '2024-01-18T09:20:00Z',
          status: 'inactive',
          tripCount: 32,
          totalDistance: 4567.8,
        },
      ];

      const exportData = formatUserDataForExport(mockUsers);
      await exportDataFile(exportData, format);
      
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to export users');
    } finally {
      setIsExporting(false);
    }
  }, []);

  // Export analytics data
  const exportAnalytics = useCallback(async (
    format: 'csv' | 'excel' | 'pdf'
  ) => {
    try {
      setIsExporting(true);
      setError(null);

      // Mock analytics data
      const mockAnalytics = {
        totalUsers: 1250,
        activeUsers: 890,
        totalTrips: 15420,
        totalDistance: 234567.8,
        avgTripDistance: 15.2,
        popularMode: 'Car',
        peakTime: '9:00 AM - 10:00 AM',
        totalRevenue: 1250000,
      };

      const exportData = formatAnalyticsDataForExport(mockAnalytics);
      await exportDataFile(exportData, format);
      
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to export analytics');
    } finally {
      setIsExporting(false);
    }
  }, []);

  // Generic export function
  const exportDataFile = useCallback(async (
    data: ExportData,
    format: 'csv' | 'excel' | 'pdf'
  ) => {
    try {
      // Add a small delay to show loading state
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      exportData(data, format);
      
      // Show success notification (you can implement this)
      console.log(`${format.toUpperCase()} export completed successfully`);
      
    } catch (err) {
      throw new Error(`Failed to export ${format.toUpperCase()} file`);
    }
  }, []);

  // Export custom data
  const exportCustomData = useCallback(async (
    data: any[],
    headers: string[],
    filename: string,
    format: 'csv' | 'excel' | 'pdf',
    title?: string
  ) => {
    try {
      setIsExporting(true);
      setError(null);

      const rows = data.map(item => 
        headers.map(header => item[header] || '')
      );

      const exportData: ExportData = {
        headers,
        rows,
        filename,
        title
      };

      await exportDataFile(exportData, format);
      
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to export custom data');
    } finally {
      setIsExporting(false);
    }
  }, [exportDataFile]);

  // Clear error
  const clearError = useCallback(() => {
    setError(null);
  }, []);

  return {
    isExporting,
    error,
    exportTrips,
    exportUsers,
    exportAnalytics,
    exportCustomData,
    clearError,
  };
};
