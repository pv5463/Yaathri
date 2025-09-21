// Custom hook for report management
import { useState, useEffect, useCallback } from 'react';
import { reportService, ReportConfig, ReportProgress } from '../services/reportService';
import { apiService } from '../services/apiService';

export const useReports = () => {
  const [reports, setReports] = useState<ReportProgress[]>([]);
  const [isGenerating, setIsGenerating] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Fetch all reports
  const fetchReports = useCallback(async () => {
    try {
      setError(null);
      // In production, this would call apiService.getReports()
      const allReports = reportService.getAllReports();
      setReports(allReports);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to fetch reports');
    }
  }, []);

  // Generate new report
  const generateReport = useCallback(async (config: ReportConfig) => {
    try {
      setIsGenerating(true);
      setError(null);
      
      // In production, this would call apiService.generateReport(config)
      const reportId = await reportService.generateReport(config);
      
      // Start polling for status updates
      const pollInterval = setInterval(async () => {
        const status = reportService.getReportStatus(reportId);
        if (status && (status.status === 'completed' || status.status === 'failed')) {
          clearInterval(pollInterval);
          setIsGenerating(false);
          await fetchReports();
        }
      }, 1000);
      
      return reportId;
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to generate report');
      setIsGenerating(false);
      throw err;
    }
  }, [fetchReports]);

  // Generate quick report from template
  const generateQuickReport = useCallback(async (templateId: string) => {
    try {
      setIsGenerating(true);
      setError(null);
      
      const reportId = await reportService.generateQuickReport(templateId);
      
      // Start polling for status updates
      const pollInterval = setInterval(async () => {
        const status = reportService.getReportStatus(reportId);
        if (status && (status.status === 'completed' || status.status === 'failed')) {
          clearInterval(pollInterval);
          setIsGenerating(false);
          await fetchReports();
        }
      }, 1000);
      
      return reportId;
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to generate quick report');
      setIsGenerating(false);
      throw err;
    }
  }, [fetchReports]);

  // Download report
  const downloadReport = useCallback(async (reportId: string) => {
    try {
      setError(null);
      
      // In production, this would call apiService.downloadReport(reportId)
      const report = reportService.getReportStatus(reportId);
      if (report?.downloadUrl) {
        // Simulate download
        const link = document.createElement('a');
        link.href = report.downloadUrl;
        link.download = `report_${reportId}`;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to download report');
    }
  }, []);

  // Delete report
  const deleteReport = useCallback(async (reportId: string) => {
    try {
      setError(null);
      
      // In production, this would call apiService.deleteReport(reportId)
      reportService.deleteReport(reportId);
      await fetchReports();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to delete report');
    }
  }, [fetchReports]);

  // Get report templates
  const getTemplates = useCallback(() => {
    return reportService.getReportTemplates();
  }, []);

  // Get report status
  const getReportStatus = useCallback((reportId: string) => {
    return reportService.getReportStatus(reportId);
  }, []);

  // Initialize
  useEffect(() => {
    fetchReports();
  }, [fetchReports]);

  return {
    reports,
    isGenerating,
    error,
    generateReport,
    generateQuickReport,
    downloadReport,
    deleteReport,
    getTemplates,
    getReportStatus,
    refreshReports: fetchReports,
  };
};
