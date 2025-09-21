import { useState } from 'react';
import Head from 'next/head';
import { motion } from 'framer-motion';
import {
  ChartBarIcon,
  MapIcon,
  ClockIcon,
  CurrencyDollarIcon,
  ArrowDownTrayIcon,
  CalendarIcon,
  FunnelIcon,
} from '@heroicons/react/24/outline';
import Layout from '../components/Layout';
import {
  LineChart,
  Line,
  AreaChart,
  Area,
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  ScatterChart,
  Scatter,
} from 'recharts';

// Mock data for analytics
const trendData = [
  { month: 'Jan', trips: 1200, users: 850, distance: 15600, revenue: 45000 },
  { month: 'Feb', trips: 1350, users: 920, distance: 17200, revenue: 52000 },
  { month: 'Mar', trips: 1580, users: 1100, distance: 19800, revenue: 61000 },
  { month: 'Apr', trips: 1420, users: 980, distance: 18200, revenue: 55000 },
  { month: 'May', trips: 1680, users: 1250, distance: 21500, revenue: 68000 },
  { month: 'Jun', trips: 1850, users: 1380, distance: 23800, revenue: 75000 },
];

const transportModeData = [
  { name: 'Car', value: 45, color: '#8884d8' },
  { name: 'Bus', value: 30, color: '#82ca9d' },
  { name: 'Train', value: 15, color: '#ffc658' },
  { name: 'Bike', value: 8, color: '#ff7c7c' },
  { name: 'Walk', value: 2, color: '#8dd1e1' },
];

const hourlyData = [
  { hour: '00', trips: 12 }, { hour: '01', trips: 8 }, { hour: '02', trips: 5 },
  { hour: '03', trips: 3 }, { hour: '04', trips: 4 }, { hour: '05', trips: 15 },
  { hour: '06', trips: 45 }, { hour: '07', trips: 120 }, { hour: '08', trips: 180 },
  { hour: '09', trips: 150 }, { hour: '10', trips: 95 }, { hour: '11', trips: 85 },
  { hour: '12', trips: 110 }, { hour: '13', trips: 95 }, { hour: '14', trips: 75 },
  { hour: '15', trips: 85 }, { hour: '16', trips: 105 }, { hour: '17', trips: 140 },
  { hour: '18', trips: 160 }, { hour: '19', trips: 95 }, { hour: '20', trips: 65 },
  { hour: '21', trips: 45 }, { hour: '22', trips: 35 }, { hour: '23', trips: 20 },
];

const distanceVsTimeData = [
  { distance: 5, time: 15, trips: 45 }, { distance: 10, time: 25, trips: 38 },
  { distance: 15, time: 35, trips: 52 }, { distance: 20, time: 45, trips: 41 },
  { distance: 25, time: 55, trips: 35 }, { distance: 30, time: 65, trips: 28 },
  { distance: 35, time: 75, trips: 22 }, { distance: 40, time: 85, trips: 18 },
  { distance: 45, time: 95, trips: 15 }, { distance: 50, time: 105, trips: 12 },
];

const routeAnalysisData = [
  { route: 'Kochi → Thiruvananthapuram', trips: 245, avgTime: 180, avgDistance: 195, efficiency: 85 },
  { route: 'Kochi → Kozhikode', trips: 198, avgTime: 240, avgDistance: 195, efficiency: 78 },
  { route: 'Kottayam → Munnar', trips: 156, avgTime: 120, avgDistance: 86, efficiency: 92 },
  { route: 'Thrissur → Palakkad', trips: 134, avgTime: 90, avgDistance: 78, efficiency: 88 },
  { route: 'Kollam → Alappuzha', trips: 112, avgTime: 75, avgDistance: 67, efficiency: 90 },
];

export default function Analytics() {
  const [selectedTimeRange, setSelectedTimeRange] = useState('6m');
  const [selectedMetric, setSelectedMetric] = useState('trips');

  const exportAnalytics = () => {
    const data = {
      trends: trendData,
      transportModes: transportModeData,
      hourlyPatterns: hourlyData,
      routeAnalysis: routeAnalysisData,
      generatedAt: new Date().toISOString(),
    };

    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `yaathri-analytics-${new Date().toISOString().split('T')[0]}.json`;
    a.click();
    window.URL.revokeObjectURL(url);
  };

  return (
    <Layout>
      <Head>
        <title>Analytics - Yaathri Dashboard</title>
        <meta name="description" content="Advanced analytics and insights for travel data" />
      </Head>

      <div className="space-y-8">
        {/* Header */}
        <div className="md:flex md:items-center md:justify-between">
          <div className="min-w-0 flex-1">
            <motion.h2
              initial={{ opacity: 0, y: -20 }}
              animate={{ opacity: 1, y: 0 }}
              className="text-2xl font-bold leading-7 text-gray-900 sm:truncate sm:text-3xl sm:tracking-tight"
            >
              Advanced Analytics
            </motion.h2>
            <div className="mt-1 flex flex-col sm:mt-0 sm:flex-row sm:flex-wrap sm:space-x-6">
              <div className="mt-2 flex items-center text-sm text-gray-500">
                <ChartBarIcon className="mr-1.5 h-5 w-5 flex-shrink-0 text-gray-400" />
                Deep insights into travel patterns and behavior
              </div>
            </div>
          </div>
          <div className="mt-4 flex space-x-3 md:ml-4 md:mt-0">
            <select
              value={selectedTimeRange}
              onChange={(e) => setSelectedTimeRange(e.target.value)}
              className="rounded-md border-gray-300 py-2 pl-3 pr-10 text-base focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm"
            >
              <option value="1m">Last Month</option>
              <option value="3m">Last 3 Months</option>
              <option value="6m">Last 6 Months</option>
              <option value="1y">Last Year</option>
            </select>
            <button
              onClick={exportAnalytics}
              className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
            >
              <ArrowDownTrayIcon className="-ml-1 mr-2 h-5 w-5" />
              Export Analytics
            </button>
          </div>
        </div>

        {/* Key Metrics */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4"
        >
          <div className="bg-white overflow-hidden shadow rounded-lg">
            <div className="p-5">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <MapIcon className="h-6 w-6 text-gray-400" />
                </div>
                <div className="ml-5 w-0 flex-1">
                  <dl>
                    <dt className="text-sm font-medium text-gray-500 truncate">Total Distance</dt>
                    <dd className="text-lg font-medium text-gray-900">125,800 km</dd>
                  </dl>
                </div>
              </div>
            </div>
            <div className="bg-gray-50 px-5 py-3">
              <div className="text-sm">
                <span className="font-medium text-green-600">+12%</span>
                <span className="text-gray-500"> from last period</span>
              </div>
            </div>
          </div>

          <div className="bg-white overflow-hidden shadow rounded-lg">
            <div className="p-5">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <ClockIcon className="h-6 w-6 text-gray-400" />
                </div>
                <div className="ml-5 w-0 flex-1">
                  <dl>
                    <dt className="text-sm font-medium text-gray-500 truncate">Avg Trip Time</dt>
                    <dd className="text-lg font-medium text-gray-900">45 min</dd>
                  </dl>
                </div>
              </div>
            </div>
            <div className="bg-gray-50 px-5 py-3">
              <div className="text-sm">
                <span className="font-medium text-red-600">-5%</span>
                <span className="text-gray-500"> from last period</span>
              </div>
            </div>
          </div>

          <div className="bg-white overflow-hidden shadow rounded-lg">
            <div className="p-5">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <CurrencyDollarIcon className="h-6 w-6 text-gray-400" />
                </div>
                <div className="ml-5 w-0 flex-1">
                  <dl>
                    <dt className="text-sm font-medium text-gray-500 truncate">Avg Trip Cost</dt>
                    <dd className="text-lg font-medium text-gray-900">₹285</dd>
                  </dl>
                </div>
              </div>
            </div>
            <div className="bg-gray-50 px-5 py-3">
              <div className="text-sm">
                <span className="font-medium text-green-600">+8%</span>
                <span className="text-gray-500"> from last period</span>
              </div>
            </div>
          </div>

          <div className="bg-white overflow-hidden shadow rounded-lg">
            <div className="p-5">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <ChartBarIcon className="h-6 w-6 text-gray-400" />
                </div>
                <div className="ml-5 w-0 flex-1">
                  <dl>
                    <dt className="text-sm font-medium text-gray-500 truncate">Efficiency Score</dt>
                    <dd className="text-lg font-medium text-gray-900">87%</dd>
                  </dl>
                </div>
              </div>
            </div>
            <div className="bg-gray-50 px-5 py-3">
              <div className="text-sm">
                <span className="font-medium text-green-600">+15%</span>
                <span className="text-gray-500"> from last period</span>
              </div>
            </div>
          </div>
        </motion.div>

        {/* Charts Grid */}
        <div className="grid grid-cols-1 gap-8 lg:grid-cols-2">
          {/* Trend Analysis */}
          <motion.div
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.2 }}
            className="bg-white overflow-hidden shadow rounded-lg"
          >
            <div className="p-6">
              <h3 className="text-lg font-medium leading-6 text-gray-900 mb-4">
                Travel Trends Over Time
              </h3>
              <div className="mb-4">
                <select
                  value={selectedMetric}
                  onChange={(e) => setSelectedMetric(e.target.value)}
                  className="rounded-md border-gray-300 py-1 pl-3 pr-8 text-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500"
                >
                  <option value="trips">Trips</option>
                  <option value="users">Users</option>
                  <option value="distance">Distance</option>
                  <option value="revenue">Revenue</option>
                </select>
              </div>
              <div className="h-80">
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={trendData}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="month" />
                    <YAxis />
                    <Tooltip />
                    <Area
                      type="monotone"
                      dataKey={selectedMetric}
                      stroke="#8884d8"
                      fill="#8884d8"
                      fillOpacity={0.6}
                    />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            </div>
          </motion.div>

          {/* Transport Mode Distribution */}
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.3 }}
            className="bg-white overflow-hidden shadow rounded-lg"
          >
            <div className="p-6">
              <h3 className="text-lg font-medium leading-6 text-gray-900 mb-4">
                Transport Mode Distribution
              </h3>
              <div className="h-80">
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={transportModeData}
                      cx="50%"
                      cy="50%"
                      labelLine={false}
                      label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                      outerRadius={80}
                      fill="#8884d8"
                      dataKey="value"
                    >
                      {transportModeData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.color} />
                      ))}
                    </Pie>
                    <Tooltip />
                  </PieChart>
                </ResponsiveContainer>
              </div>
            </div>
          </motion.div>

          {/* Hourly Trip Patterns */}
          <motion.div
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.4 }}
            className="bg-white overflow-hidden shadow rounded-lg"
          >
            <div className="p-6">
              <h3 className="text-lg font-medium leading-6 text-gray-900 mb-4">
                Hourly Trip Patterns
              </h3>
              <div className="h-80">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={hourlyData}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="hour" />
                    <YAxis />
                    <Tooltip />
                    <Bar dataKey="trips" fill="#82ca9d" />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </div>
          </motion.div>

          {/* Distance vs Time Analysis */}
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.5 }}
            className="bg-white overflow-hidden shadow rounded-lg"
          >
            <div className="p-6">
              <h3 className="text-lg font-medium leading-6 text-gray-900 mb-4">
                Distance vs Time Correlation
              </h3>
              <div className="h-80">
                <ResponsiveContainer width="100%" height="100%">
                  <ScatterChart data={distanceVsTimeData}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="distance" name="Distance (km)" />
                    <YAxis dataKey="time" name="Time (min)" />
                    <Tooltip cursor={{ strokeDasharray: '3 3' }} />
                    <Scatter name="Trips" dataKey="trips" fill="#8884d8" />
                  </ScatterChart>
                </ResponsiveContainer>
              </div>
            </div>
          </motion.div>
        </div>

        {/* Route Analysis Table */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6 }}
          className="bg-white shadow rounded-lg"
        >
          <div className="px-6 py-4 border-b border-gray-200">
            <h3 className="text-lg font-medium leading-6 text-gray-900">
              Route Efficiency Analysis
            </h3>
            <p className="mt-1 text-sm text-gray-500">
              Performance metrics for popular travel routes
            </p>
          </div>
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Route
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Total Trips
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Avg Time (min)
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Avg Distance (km)
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Efficiency Score
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {routeAnalysisData.map((route, index) => (
                  <tr key={index} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {route.route}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {route.trips}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {route.avgTime}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {route.avgDistance}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className="flex-1 bg-gray-200 rounded-full h-2 mr-2">
                          <div
                            className={`h-2 rounded-full ${
                              route.efficiency >= 90 ? 'bg-green-500' :
                              route.efficiency >= 80 ? 'bg-yellow-500' : 'bg-red-500'
                            }`}
                            style={{ width: `${route.efficiency}%` }}
                          />
                        </div>
                        <span className="text-sm font-medium text-gray-900">
                          {route.efficiency}%
                        </span>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </motion.div>
      </div>
    </Layout>
  );
}
