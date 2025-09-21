import { useState } from 'react';
import { ChevronDownIcon, ArrowDownTrayIcon } from '@heroicons/react/20/solid';
import { motion } from 'framer-motion';

const mockTrips = [
  {
    id: '1',
    userId: 'user_123',
    origin: 'Kochi, Kerala',
    destination: 'Thiruvananthapuram, Kerala',
    distance: 195.2,
    duration: 180,
    mode: 'Car',
    startTime: '2024-01-15T09:30:00Z',
    endTime: '2024-01-15T12:30:00Z',
    status: 'completed',
  },
  {
    id: '2',
    userId: 'user_456',
    origin: 'Ernakulam, Kerala',
    destination: 'Kozhikode, Kerala',
    distance: 194.8,
    duration: 240,
    mode: 'Bus',
    startTime: '2024-01-15T08:00:00Z',
    endTime: '2024-01-15T12:00:00Z',
    status: 'completed',
  },
  {
    id: '3',
    userId: 'user_789',
    origin: 'Kottayam, Kerala',
    destination: 'Munnar, Kerala',
    distance: 85.6,
    duration: 120,
    mode: 'Car',
    startTime: '2024-01-15T07:15:00Z',
    endTime: '2024-01-15T09:15:00Z',
    status: 'completed',
  },
  {
    id: '4',
    userId: 'user_101',
    origin: 'Thrissur, Kerala',
    destination: 'Palakkad, Kerala',
    distance: 78.3,
    duration: 90,
    mode: 'Train',
    startTime: '2024-01-15T06:45:00Z',
    endTime: '2024-01-15T08:15:00Z',
    status: 'completed',
  },
  {
    id: '5',
    userId: 'user_202',
    origin: 'Kollam, Kerala',
    destination: 'Alappuzha, Kerala',
    distance: 67.4,
    duration: 75,
    mode: 'Car',
    startTime: '2024-01-15T10:00:00Z',
    endTime: '2024-01-15T11:15:00Z',
    status: 'in_progress',
  },
];

export default function RecentTrips() {
  const [sortBy, setSortBy] = useState('startTime');
  const [filterBy, setFilterBy] = useState('all');

  const filteredTrips = mockTrips.filter(trip => {
    if (filterBy === 'all') return true;
    return trip.status === filterBy;
  });

  const sortedTrips = [...filteredTrips].sort((a, b) => {
    if (sortBy === 'startTime') {
      return new Date(b.startTime).getTime() - new Date(a.startTime).getTime();
    }
    if (sortBy === 'distance') {
      return b.distance - a.distance;
    }
    if (sortBy === 'duration') {
      return b.duration - a.duration;
    }
    return 0;
  });

  const exportData = () => {
    const csvContent = [
      ['Trip ID', 'User ID', 'Origin', 'Destination', 'Distance (km)', 'Duration (min)', 'Mode', 'Start Time', 'End Time', 'Status'],
      ...sortedTrips.map(trip => [
        trip.id,
        trip.userId,
        trip.origin,
        trip.destination,
        trip.distance,
        trip.duration,
        trip.mode,
        trip.startTime,
        trip.endTime || '',
        trip.status,
      ])
    ].map(row => row.join(',')).join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'recent_trips.csv';
    a.click();
    window.URL.revokeObjectURL(url);
  };

  const formatTime = (timeString: string) => {
    return new Date(timeString).toLocaleString();
  };

  const formatDuration = (minutes: number) => {
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;
    return hours > 0 ? `${hours}h ${mins}m` : `${mins}m`;
  };

  const getStatusBadge = (status: string) => {
    const baseClasses = 'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium';
    
    switch (status) {
      case 'completed':
        return `${baseClasses} bg-green-100 text-green-800`;
      case 'in_progress':
        return `${baseClasses} bg-blue-100 text-blue-800`;
      case 'cancelled':
        return `${baseClasses} bg-red-100 text-red-800`;
      default:
        return `${baseClasses} bg-gray-100 text-gray-800`;
    }
  };

  return (
    <div className="space-y-4">
      {/* Filters and Export */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-3 sm:space-y-0">
        <div className="flex space-x-3">
          <select
            value={sortBy}
            onChange={(e) => setSortBy(e.target.value)}
            className="rounded-md border-gray-300 py-2 pl-3 pr-10 text-base focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm"
          >
            <option value="startTime">Sort by Time</option>
            <option value="distance">Sort by Distance</option>
            <option value="duration">Sort by Duration</option>
          </select>
          
          <select
            value={filterBy}
            onChange={(e) => setFilterBy(e.target.value)}
            className="rounded-md border-gray-300 py-2 pl-3 pr-10 text-base focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm"
          >
            <option value="all">All Status</option>
            <option value="completed">Completed</option>
            <option value="in_progress">In Progress</option>
            <option value="cancelled">Cancelled</option>
          </select>
        </div>
        
        <button
          onClick={exportData}
          className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        >
          <ArrowDownTrayIcon className="-ml-1 mr-2 h-5 w-5" aria-hidden="true" />
          Export CSV
        </button>
      </div>

      {/* Table */}
      <div className="overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg">
        <table className="min-w-full divide-y divide-gray-300">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Trip Details
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Route
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Metrics
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Time
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Status
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {sortedTrips.map((trip, index) => (
              <motion.tr
                key={trip.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.05 }}
                className="hover:bg-gray-50"
              >
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="flex items-center">
                    <div>
                      <div className="text-sm font-medium text-gray-900">
                        {trip.id}
                      </div>
                      <div className="text-sm text-gray-500">
                        User: {trip.userId}
                      </div>
                      <div className="text-sm text-gray-500">
                        Mode: {trip.mode}
                      </div>
                    </div>
                  </div>
                </td>
                <td className="px-6 py-4">
                  <div className="text-sm text-gray-900">
                    <div className="font-medium">{trip.origin}</div>
                    <div className="text-gray-500">↓</div>
                    <div className="font-medium">{trip.destination}</div>
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="text-sm text-gray-900">
                    <div>{trip.distance.toFixed(1)} km</div>
                    <div className="text-gray-500">{formatDuration(trip.duration)}</div>
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  <div>{formatTime(trip.startTime)}</div>
                  {trip.endTime && (
                    <div className="text-xs">{formatTime(trip.endTime)}</div>
                  )}
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={getStatusBadge(trip.status)}>
                    {trip.status.replace('_', ' ')}
                  </span>
                </td>
              </motion.tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      <div className="flex items-center justify-between">
        <div className="flex-1 flex justify-between sm:hidden">
          <button className="relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50">
            Previous
          </button>
          <button className="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50">
            Next
          </button>
        </div>
        <div className="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
          <div>
            <p className="text-sm text-gray-700">
              Showing <span className="font-medium">1</span> to <span className="font-medium">{sortedTrips.length}</span> of{' '}
              <span className="font-medium">{mockTrips.length}</span> results
            </p>
          </div>
          <div>
            <nav className="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
              <button className="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50">
                Previous
              </button>
              <button className="relative inline-flex items-center px-4 py-2 border border-gray-300 bg-white text-sm font-medium text-gray-700 hover:bg-gray-50">
                1
              </button>
              <button className="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50">
                Next
              </button>
            </nav>
          </div>
        </div>
      </div>
    </div>
  );
}
