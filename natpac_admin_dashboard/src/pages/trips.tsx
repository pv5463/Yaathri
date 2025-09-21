import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import {
  MagnifyingGlassIcon,
  FunnelIcon,
  MapPinIcon,
  ClockIcon,
  UserIcon,
  EyeIcon,
  ArrowDownTrayIcon,
} from '@heroicons/react/24/outline';
import Layout from '../components/Layout';
import { useExport } from '../hooks/useExport';

interface Trip {
  id: string;
  userId: string;
  userName: string;
  startLocation: string;
  endLocation: string;
  startTime: string;
  endTime: string;
  distance: number;
  duration: number;
  mode: string;
  status: 'completed' | 'ongoing' | 'planned';
  expenses: number;
}

const mockTrips: Trip[] = [
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

export default function Trips() {
  const [trips, setTrips] = useState<Trip[]>(mockTrips);
  const [filteredTrips, setFilteredTrips] = useState<Trip[]>(mockTrips);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [modeFilter, setModeFilter] = useState('all');
  const [selectedTrip, setSelectedTrip] = useState<Trip | null>(null);
  
  const { exportTrips, isExporting, error: exportError } = useExport();

  useEffect(() => {
    let filtered = trips;

    if (searchTerm) {
      filtered = filtered.filter(
        (trip) =>
          trip.userName.toLowerCase().includes(searchTerm.toLowerCase()) ||
          trip.startLocation.toLowerCase().includes(searchTerm.toLowerCase()) ||
          trip.endLocation.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }

    if (statusFilter !== 'all') {
      filtered = filtered.filter((trip) => trip.status === statusFilter);
    }

    if (modeFilter !== 'all') {
      filtered = filtered.filter((trip) => trip.mode.toLowerCase() === modeFilter);
    }

    setFilteredTrips(filtered);
  }, [trips, searchTerm, statusFilter, modeFilter]);

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed':
        return 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200';
      case 'ongoing':
        return 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200';
      case 'planned':
        return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200';
      default:
        return 'bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-200';
    }
  };

  const formatDuration = (minutes: number) => {
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;
    return `${hours}h ${mins}m`;
  };

  return (
    <Layout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">
              Trip Data
            </h1>
            <p className="text-gray-600 dark:text-gray-400">
              Manage and analyze travel data collected from users
            </p>
          </div>
          <div className="flex space-x-2">
            <button
              onClick={() => exportTrips('csv')}
              disabled={isExporting}
              className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <ArrowDownTrayIcon className="h-4 w-4 mr-2" />
              {isExporting ? 'Exporting...' : 'Export CSV'}
            </button>
            <button
              onClick={() => exportTrips('excel')}
              disabled={isExporting}
              className="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md shadow-sm text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <ArrowDownTrayIcon className="h-4 w-4 mr-2" />
              Export Excel
            </button>
          </div>
        </div>

        {/* Filters */}
        <div className="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="relative">
              <MagnifyingGlassIcon className="h-5 w-5 absolute left-3 top-3 text-gray-400" />
              <input
                type="text"
                placeholder="Search trips..."
                className="pl-10 w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-100 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>
            <select
              className="rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-100 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
            >
              <option value="all">All Status</option>
              <option value="completed">Completed</option>
              <option value="ongoing">Ongoing</option>
              <option value="planned">Planned</option>
            </select>
            <select
              className="rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-100 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              value={modeFilter}
              onChange={(e) => setModeFilter(e.target.value)}
            >
              <option value="all">All Modes</option>
              <option value="car">Car</option>
              <option value="train">Train</option>
              <option value="bus">Bus</option>
              <option value="flight">Flight</option>
            </select>
          </div>
        </div>

        {/* Trip List */}
        <div className="bg-white dark:bg-gray-800 shadow overflow-hidden sm:rounded-md">
          <ul className="divide-y divide-gray-200 dark:divide-gray-700">
            {filteredTrips.map((trip, index) => (
              <motion.li
                key={trip.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.1 }}
                className="hover:bg-gray-50 dark:hover:bg-gray-700"
              >
                <div className="px-4 py-4 sm:px-6">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-4">
                      <div className="flex-shrink-0">
                        <div className="h-10 w-10 bg-indigo-100 dark:bg-indigo-900 rounded-full flex items-center justify-center">
                          <MapPinIcon className="h-5 w-5 text-indigo-600 dark:text-indigo-400" />
                        </div>
                      </div>
                      <div className="min-w-0 flex-1">
                        <div className="flex items-center space-x-2">
                          <p className="text-sm font-medium text-gray-900 dark:text-gray-100 truncate">
                            {trip.startLocation} → {trip.endLocation}
                          </p>
                          <span
                            className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(
                              trip.status
                            )}`}
                          >
                            {trip.status}
                          </span>
                        </div>
                        <div className="flex items-center space-x-4 mt-1">
                          <div className="flex items-center text-sm text-gray-500 dark:text-gray-400">
                            <UserIcon className="h-4 w-4 mr-1" />
                            {trip.userName}
                          </div>
                          <div className="flex items-center text-sm text-gray-500 dark:text-gray-400">
                            <ClockIcon className="h-4 w-4 mr-1" />
                            {formatDuration(trip.duration)}
                          </div>
                          <div className="text-sm text-gray-500 dark:text-gray-400">
                            {trip.distance} km
                          </div>
                          <div className="text-sm text-gray-500 dark:text-gray-400">
                            {trip.mode}
                          </div>
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center space-x-2">
                      <div className="text-right">
                        <p className="text-sm font-medium text-gray-900 dark:text-gray-100">
                          ₹{trip.expenses}
                        </p>
                        <p className="text-sm text-gray-500 dark:text-gray-400">
                          {new Date(trip.startTime).toLocaleDateString()}
                        </p>
                      </div>
                      <button
                        onClick={() => setSelectedTrip(trip)}
                        className="inline-flex items-center p-2 border border-transparent rounded-full shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                      >
                        <EyeIcon className="h-4 w-4" />
                      </button>
                    </div>
                  </div>
                </div>
              </motion.li>
            ))}
          </ul>
        </div>

        {/* Trip Details Modal */}
        {selectedTrip && (
          <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
            <div className="relative top-20 mx-auto p-5 border w-11/12 md:w-3/4 lg:w-1/2 shadow-lg rounded-md bg-white dark:bg-gray-800">
              <div className="mt-3">
                <div className="flex items-center justify-between mb-4">
                  <h3 className="text-lg font-medium text-gray-900 dark:text-gray-100">
                    Trip Details
                  </h3>
                  <button
                    onClick={() => setSelectedTrip(null)}
                    className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-200"
                  >
                    ×
                  </button>
                </div>
                <div className="space-y-4">
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                        User
                      </label>
                      <p className="text-sm text-gray-900 dark:text-gray-100">
                        {selectedTrip.userName}
                      </p>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                        Mode
                      </label>
                      <p className="text-sm text-gray-900 dark:text-gray-100">
                        {selectedTrip.mode}
                      </p>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                        Distance
                      </label>
                      <p className="text-sm text-gray-900 dark:text-gray-100">
                        {selectedTrip.distance} km
                      </p>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                        Duration
                      </label>
                      <p className="text-sm text-gray-900 dark:text-gray-100">
                        {formatDuration(selectedTrip.duration)}
                      </p>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                        Start Time
                      </label>
                      <p className="text-sm text-gray-900 dark:text-gray-100">
                        {new Date(selectedTrip.startTime).toLocaleString()}
                      </p>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                        End Time
                      </label>
                      <p className="text-sm text-gray-900 dark:text-gray-100">
                        {new Date(selectedTrip.endTime).toLocaleString()}
                      </p>
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                      Route
                    </label>
                    <p className="text-sm text-gray-900 dark:text-gray-100">
                      {selectedTrip.startLocation} → {selectedTrip.endLocation}
                    </p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                      Total Expenses
                    </label>
                    <p className="text-sm text-gray-900 dark:text-gray-100">
                      ₹{selectedTrip.expenses}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </Layout>
  );
}
