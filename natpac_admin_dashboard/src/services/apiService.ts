// API service for backend communication
class ApiService {
  private baseURL: string;
  private token: string | null = null;

  constructor() {
    this.baseURL = process.env.NEXT_PUBLIC_API_URL || 'https://yaathri.onrender.com/api';
    
    // Get token from localStorage if available
    if (typeof window !== 'undefined') {
      this.token = localStorage.getItem('admin_token');
    }
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const url = `${this.baseURL}${endpoint}`;
    
    const config: RequestInit = {
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
      ...options,
    };

    // Add auth token if available
    const token = localStorage.getItem('admin_token');
    if (token) {
      config.headers = {
        ...config.headers,
        Authorization: `Bearer ${token}`,
      };
    }

    try {
      const response = await fetch(url, config);
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      return await response.json();
    } catch (error) {
      console.error('API request failed:', error);
      throw error;
    }
  }

  // Trip-related API calls
  async getTrips(params?: {
    page?: number;
    limit?: number;
    status?: string;
    mode?: string;
    search?: string;
    startDate?: string;
    endDate?: string;
  }) {
    const queryParams = new URLSearchParams();
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined) {
          queryParams.append(key, value.toString());
        }
      });
    }
    
    return this.request(`/trips?${queryParams.toString()}`);
  }

  async getTripById(id: string) {
    return this.request(`/trips/${id}`);
  }

  async updateTrip(id: string, data: any) {
    return this.request(`/trips/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }

  async deleteTrip(id: string) {
    return this.request(`/trips/${id}`, {
      method: 'DELETE',
    });
  }

  // User-related API calls
  async getUsers(params?: {
    page?: number;
    limit?: number;
    status?: string;
    search?: string;
  }) {
    const queryParams = new URLSearchParams();
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined) {
          queryParams.append(key, value.toString());
        }
      });
    }
    
    return this.request(`/users?${queryParams.toString()}`);
  }

  async getUserById(id: string) {
    return this.request(`/users/${id}`);
  }

  async updateUser(id: string, data: any) {
    return this.request(`/users/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }

  async deleteUser(id: string) {
    return this.request(`/users/${id}`, {
      method: 'DELETE',
    });
  }

  async updateUserStatus(id: string, status: string) {
    return this.request(`/users/${id}/status`, {
      method: 'PATCH',
      body: JSON.stringify({ status }),
    });
  }

  // Analytics API calls
  async getDashboardStats() {
    return this.request('/analytics/dashboard');
  }

  async getTravelAnalytics(params?: {
    period?: string;
    groupBy?: string;
  }) {
    const queryParams = new URLSearchParams();
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined) {
          queryParams.append(key, value.toString());
        }
      });
    }
    
    return this.request(`/analytics/travel?${queryParams.toString()}`);
  }

  async getUserAnalytics() {
    return this.request('/analytics/users');
  }

  async getRouteAnalytics() {
    return this.request('/analytics/routes');
  }

  // Report API calls
  async generateReport(config: any) {
    return this.request('/reports/generate', {
      method: 'POST',
      body: JSON.stringify(config),
    });
  }

  async getReportStatus(reportId: string) {
    return this.request(`/reports/${reportId}/status`);
  }

  async downloadReport(reportId: string) {
    const token = localStorage.getItem('admin_token');
    const url = `${this.baseURL}/reports/${reportId}/download`;
    
    const response = await fetch(url, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });
    
    if (!response.ok) {
      throw new Error('Failed to download report');
    }
    
    return response.blob();
  }

  async getReports() {
    return this.request('/reports');
  }

  async deleteReport(reportId: string) {
    return this.request(`/reports/${reportId}`, {
      method: 'DELETE',
    });
  }

  // Settings API calls
  async getSettings() {
    return this.request('/settings');
  }

  async updateSettings(settings: any) {
    return this.request('/settings', {
      method: 'PUT',
      body: JSON.stringify(settings),
    });
  }

  async createBackup() {
    return this.request('/settings/backup', {
      method: 'POST',
    });
  }

  async getBackupHistory() {
    return this.request('/settings/backups');
  }

  // Export API calls
  async exportData(type: string, format: string, filters?: any) {
    const token = localStorage.getItem('admin_token');
    const url = `${this.baseURL}/export/${type}`;
    
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({ format, filters }),
    });
    
    if (!response.ok) {
      throw new Error('Failed to export data');
    }
    
    return response.blob();
  }

  // Real-time data subscription
  subscribeToUpdates(callback: (data: any) => void) {
    // In a real implementation, this would use WebSocket or Server-Sent Events
    const eventSource = new EventSource(`${this.baseURL}/stream`);
    
    eventSource.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        callback(data);
      } catch (error) {
        console.error('Failed to parse SSE data:', error);
      }
    };
    
    return () => {
      eventSource.close();
    };
  }

  // Authentication
  async login(credentials: { email: string; password: string }) {
    const response = await this.request<{ token?: string; user?: any }>('/auth/login', {
      method: 'POST',
      body: JSON.stringify(credentials),
    });
    
    if (response.token) {
      localStorage.setItem('admin_token', response.token);
    }
    
    return response;
  }

  async logout() {
    localStorage.removeItem('admin_token');
    return this.request('/auth/logout', {
      method: 'POST',
    });
  }

  async refreshToken() {
    return this.request('/auth/refresh', {
      method: 'POST',
    });
  }

  // Health check
  async healthCheck() {
    return this.request('/health');
  }
}

export const apiService = new ApiService();
