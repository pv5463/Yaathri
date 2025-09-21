import { useState } from 'react';
import Head from 'next/head';
import { motion } from 'framer-motion';
import {
  ChartBarIcon,
  MapIcon,
  UsersIcon,
  DocumentArrowDownIcon,
  CalendarIcon,
  CurrencyDollarIcon,
  Bars3Icon,
  XMarkIcon,
  BellIcon,
  MagnifyingGlassIcon,
} from '@heroicons/react/24/outline';
import { useTravelData } from '../hooks/useTravelData';
import Layout from '../components/Layout';
import StatsCard from '../components/StatsCard';
import TravelChart from '../components/TravelChart';
import MapView from '../components/MapView';
import RecentTrips from '../components/RecentTrips';

export default function Dashboard() {
  const { data: travelData, isLoading, error } = useTravelData();
  const [selectedTimeRange, setSelectedTimeRange] = useState('7d');

  const stats = [
    {
      name: 'Total Trips',
      value: travelData?.totalTrips || 0,
      change: '+12%',
      changeType: 'positive' as const,
      icon: MapIcon,
    },
    {
      name: 'Active Users',
      value: travelData?.activeUsers || 0,
      change: '+8%',
      changeType: 'positive' as const,
      icon: UsersIcon,
    },
    {
      name: 'Distance Traveled',
      value: `${travelData?.totalDistance || 0} km`,
      change: '+15%',
      changeType: 'positive' as const,
      icon: ChartBarIcon,
    },
    {
      name: 'Data Points',
      value: travelData?.dataPoints || 0,
      change: '+23%',
      changeType: 'positive' as const,
      icon: DocumentArrowDownIcon,
    },
  ];

  if (isLoading) {
    return (
      <Layout>
        <Head>
          <title>Yaathri - Travel Research Dashboard</title>
          <meta name="description" content="Yaathri - Travel behavior analysis and research dashboard" />
        </Head>
        <div className="space-y-8">
          <div className="animate-pulse grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
            {[...Array(4)].map((_, i) => (
              <div key={i} className="rounded-lg bg-gray-100 h-28" />
            ))}
          </div>
          <div className="grid grid-cols-1 gap-8 lg:grid-cols-2">
            <div className="rounded-lg bg-gray-100 h-96" />
            <div className="rounded-lg bg-gray-100 h-96" />
          </div>
          <div className="rounded-lg bg-gray-100 h-80" />
        </div>
      </Layout>
    );
  }

  if (error) {
    return (
      <Layout>
        <Head>
          <title>Yaathri - Travel Research Dashboard</title>
          <meta name="description" content="Yaathri - Travel behavior analysis and research dashboard" />
        </Head>
        <div className="rounded-lg bg-red-50 border border-red-200 p-6 text-red-700">
          Failed to load data. Please try again later.
        </div>
      </Layout>
    );
  }

  return (
    <Layout>
      <Head>
        <title>Yaathri - Travel Research Dashboard</title>
        <meta name="description" content="Yaathri - Travel behavior analysis and research dashboard" />
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
              Yaathri Dashboard
            </motion.h2>
            <div className="mt-1 flex flex-col sm:mt-0 sm:flex-row sm:flex-wrap sm:space-x-6">
              <div className="mt-2 flex items-center text-sm text-gray-500">
                <CalendarIcon className="mr-1.5 h-5 w-5 flex-shrink-0 text-gray-400" />
                Last updated: {new Date().toLocaleDateString()}
              </div>
            </div>
          </div>
          <div className="mt-4 flex md:ml-4 md:mt-0">
            <select
              value={selectedTimeRange}
              onChange={(e) => setSelectedTimeRange(e.target.value)}
              className="rounded-md border-gray-300 py-2 pl-3 pr-10 text-base focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm"
            >
              <option value="7d">Last 7 days</option>
              <option value="30d">Last 30 days</option>
              <option value="90d">Last 90 days</option>
              <option value="1y">Last year</option>
            </select>
          </div>
        </div>

        {/* Stats Grid */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4"
        >
          {stats.map((stat, index) => (
            <motion.div
              key={stat.name}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1 + index * 0.05 }}
            >
              <StatsCard {...stat} />
            </motion.div>
          ))}
        </motion.div>

        {/* Charts and Map */}
        <div className="grid grid-cols-1 gap-8 lg:grid-cols-2">
          {/* Travel Patterns Chart */}
          <motion.div
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.3 }}
            className="bg-white overflow-hidden shadow rounded-lg"
          >
            <div className="p-6">
              <h3 className="text-lg font-medium leading-6 text-gray-900 mb-4">
                Travel Patterns
              </h3>
              <TravelChart timeRange={selectedTimeRange} />
            </div>
          </motion.div>

          {/* Map View */}
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.4 }}
            className="bg-white overflow-hidden shadow rounded-lg"
          >
            <div className="p-6">
              <h3 className="text-lg font-medium leading-6 text-gray-900 mb-4">
                Trip Distribution
              </h3>
              <MapView />
            </div>
          </motion.div>
        </div>

        {/* Recent Trips Table */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5 }}
          className="bg-white shadow rounded-lg"
        >
          <div className="px-6 py-4 border-b border-gray-200">
            <h3 className="text-lg font-medium leading-6 text-gray-900">
              Recent Trips
            </h3>
            <p className="mt-1 text-sm text-gray-500">
              Latest travel data collected from users
            </p>
          </div>
          <RecentTrips />
        </motion.div>

        {/* Quick Actions */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6 }}
          className="bg-white shadow rounded-lg"
        >
          <div className="px-6 py-4 border-b border-gray-200">
            <h3 className="text-lg font-medium leading-6 text-gray-900">
              Quick Actions
            </h3>
          </div>
          <div className="p-6">
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
              <button className="relative block w-full rounded-lg border-2 border-dashed border-gray-300 p-6 text-center hover:border-gray-400 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2">
                <DocumentArrowDownIcon className="mx-auto h-8 w-8 text-gray-400" />
                <span className="mt-2 block text-sm font-medium text-gray-900">
                  Export Data
                </span>
              </button>
              
              <button className="relative block w-full rounded-lg border-2 border-dashed border-gray-300 p-6 text-center hover:border-gray-400 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2">
                <ChartBarIcon className="mx-auto h-8 w-8 text-gray-400" />
                <span className="mt-2 block text-sm font-medium text-gray-900">
                  Generate Report
                </span>
              </button>
              
              <button className="relative block w-full rounded-lg border-2 border-dashed border-gray-300 p-6 text-center hover:border-gray-400 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2">
                <UsersIcon className="mx-auto h-8 w-8 text-gray-400" />
                <span className="mt-2 block text-sm font-medium text-gray-900">
                  User Analytics
                </span>
              </button>
              
              <button className="relative block w-full rounded-lg border-2 border-dashed border-gray-300 p-6 text-center hover:border-gray-400 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2">
                <MapIcon className="mx-auto h-8 w-8 text-gray-400" />
                <span className="mt-2 block text-sm font-medium text-gray-900">
                  Route Analysis
                </span>
              </button>
            </div>
          </div>
        </motion.div>
      </div>
    </Layout>
  );
}
