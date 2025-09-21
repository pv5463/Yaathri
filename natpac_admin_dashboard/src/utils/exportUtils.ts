// Export utilities for generating CSV, Excel, and PDF files
import * as XLSX from 'xlsx';
import jsPDF from 'jspdf';
import 'jspdf-autotable';

export interface ExportData {
  headers: string[];
  rows: any[][];
  filename: string;
  title?: string;
}

// CSV Export
export const exportToCSV = (data: ExportData): void => {
  const csvContent = [
    data.headers.join(','),
    ...data.rows.map(row => row.map(cell => `"${cell}"`).join(','))
  ].join('\n');

  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  const url = URL.createObjectURL(blob);
  
  link.setAttribute('href', url);
  link.setAttribute('download', `${data.filename}.csv`);
  link.style.visibility = 'hidden';
  
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
};

// Excel Export
export const exportToExcel = (data: ExportData): void => {
  const worksheet = XLSX.utils.aoa_to_sheet([data.headers, ...data.rows]);
  const workbook = XLSX.utils.book_new();
  
  XLSX.utils.book_append_sheet(workbook, worksheet, 'Data');
  XLSX.writeFile(workbook, `${data.filename}.xlsx`);
};

// PDF Export
export const exportToPDF = (data: ExportData): void => {
  const doc = new jsPDF();
  
  // Add title
  if (data.title) {
    doc.setFontSize(16);
    doc.text(data.title, 14, 22);
  }
  
  // Add table
  (doc as any).autoTable({
    head: [data.headers],
    body: data.rows,
    startY: data.title ? 30 : 20,
    styles: {
      fontSize: 8,
      cellPadding: 2,
    },
    headStyles: {
      fillColor: [79, 70, 229], // Indigo color
      textColor: 255,
    },
  });
  
  doc.save(`${data.filename}.pdf`);
};

// Generic export function
export const exportData = (data: ExportData, format: 'csv' | 'excel' | 'pdf'): void => {
  switch (format) {
    case 'csv':
      exportToCSV(data);
      break;
    case 'excel':
      exportToExcel(data);
      break;
    case 'pdf':
      exportToPDF(data);
      break;
    default:
      throw new Error(`Unsupported export format: ${format}`);
  }
};

// Trip data formatter
export const formatTripDataForExport = (trips: any[]): ExportData => {
  const headers = [
    'Trip ID',
    'User Name',
    'Start Location',
    'End Location',
    'Start Time',
    'End Time',
    'Distance (km)',
    'Duration (min)',
    'Mode',
    'Status',
    'Expenses (₹)'
  ];
  
  const rows = trips.map(trip => [
    trip.id,
    trip.userName,
    trip.startLocation,
    trip.endLocation,
    new Date(trip.startTime).toLocaleString(),
    new Date(trip.endTime).toLocaleString(),
    trip.distance,
    trip.duration,
    trip.mode,
    trip.status,
    trip.expenses
  ]);
  
  return {
    headers,
    rows,
    filename: `trip_data_${new Date().toISOString().split('T')[0]}`,
    title: 'Trip Data Export'
  };
};

// User data formatter
export const formatUserDataForExport = (users: any[]): ExportData => {
  const headers = [
    'User ID',
    'Name',
    'Email',
    'Phone',
    'Location',
    'Join Date',
    'Last Active',
    'Status',
    'Trip Count',
    'Total Distance (km)'
  ];
  
  const rows = users.map(user => [
    user.id,
    user.name,
    user.email,
    user.phone,
    user.location,
    new Date(user.joinDate).toLocaleDateString(),
    new Date(user.lastActive).toLocaleString(),
    user.status,
    user.tripCount,
    user.totalDistance
  ]);
  
  return {
    headers,
    rows,
    filename: `user_data_${new Date().toISOString().split('T')[0]}`,
    title: 'User Data Export'
  };
};

// Analytics data formatter
export const formatAnalyticsDataForExport = (analytics: any): ExportData => {
  const headers = ['Metric', 'Value', 'Period'];
  
  const rows = [
    ['Total Users', analytics.totalUsers, 'All Time'],
    ['Active Users', analytics.activeUsers, 'Current'],
    ['Total Trips', analytics.totalTrips, 'All Time'],
    ['Total Distance', `${analytics.totalDistance} km`, 'All Time'],
    ['Average Trip Distance', `${analytics.avgTripDistance} km`, 'All Time'],
    ['Most Popular Mode', analytics.popularMode, 'All Time'],
    ['Peak Travel Time', analytics.peakTime, 'Daily'],
    ['Total Revenue', `₹${analytics.totalRevenue}`, 'All Time']
  ];
  
  return {
    headers,
    rows,
    filename: `analytics_${new Date().toISOString().split('T')[0]}`,
    title: 'Analytics Report'
  };
};
