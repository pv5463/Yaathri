import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import {
  MagnifyingGlassIcon,
  UserIcon,
  EnvelopeIcon,
  PhoneIcon,
  MapPinIcon,
  CalendarIcon,
  EyeIcon,
  PencilIcon,
  TrashIcon,
  ArrowDownTrayIcon,
} from '@heroicons/react/24/outline';
import Layout from '../components/Layout';
import { useExport } from '../hooks/useExport';

interface User {
  id: string;
  name: string;
  email: string;
  phone: string;
  location: string;
  joinDate: string;
  lastActive: string;
  status: 'active' | 'inactive' | 'suspended';
  tripCount: number;
  totalDistance: number;
  avatar?: string;
}

const mockUsers: User[] = [
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
  {
    id: '4',
    name: 'Priya Sharma',
    email: 'priya.sharma@example.com',
    phone: '+91 9876543213',
    location: 'Chennai, Tamil Nadu',
    joinDate: '2024-01-05',
    lastActive: '2024-01-20T14:15:00Z',
    status: 'active',
    tripCount: 8,
    totalDistance: 1234.6,
  },
];

export default function Users() {
  const [users, setUsers] = useState<User[]>(mockUsers);
  const [filteredUsers, setFilteredUsers] = useState<User[]>(mockUsers);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  
  const { exportUsers, isExporting, error: exportError } = useExport();

  useEffect(() => {
    let filtered = users;

    if (searchTerm) {
      filtered = filtered.filter(
        (user) =>
          user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
          user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
          user.location.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }

    if (statusFilter !== 'all') {
      filtered = filtered.filter((user) => user.status === statusFilter);
    }

    setFilteredUsers(filtered);
  }, [users, searchTerm, statusFilter]);

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active':
        return 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200';
      case 'inactive':
        return 'bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-200';
      case 'suspended':
        return 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200';
      default:
        return 'bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-200';
    }
  };

  const getInitials = (name: string) => {
    return name
      .split(' ')
      .map((n) => n[0])
      .join('')
      .toUpperCase();
  };

  const handleStatusChange = (userId: string, newStatus: User['status']) => {
    setUsers(users.map(user => 
      user.id === userId ? { ...user, status: newStatus } : user
    ));
  };

  return (
    <Layout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">
              User Management
            </h1>
            <p className="text-gray-600 dark:text-gray-400">
              Manage registered users and their account status
            </p>
          </div>
          <div className="flex space-x-3">
            <button
              onClick={() => exportUsers('csv')}
              disabled={isExporting}
              className="inline-flex items-center px-4 py-2 border border-gray-300 dark:border-gray-600 text-sm font-medium rounded-md text-gray-700 dark:text-gray-200 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <ArrowDownTrayIcon className="h-4 w-4 mr-2" />
              {isExporting ? 'Exporting...' : 'Export Users'}
            </button>
            <button className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
              Add User
            </button>
          </div>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          <div className="bg-white dark:bg-gray-800 overflow-hidden shadow rounded-lg">
            <div className="p-5">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <UserIcon className="h-6 w-6 text-gray-400" />
                </div>
                <div className="ml-5 w-0 flex-1">
                  <dl>
                    <dt className="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">
                      Total Users
                    </dt>
                    <dd className="text-lg font-medium text-gray-900 dark:text-gray-100">
                      {users.length}
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
                      Active Users
                    </dt>
                    <dd className="text-lg font-medium text-gray-900 dark:text-gray-100">
                      {users.filter(u => u.status === 'active').length}
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
                  <div className="h-2 w-2 bg-gray-400 rounded-full"></div>
                </div>
                <div className="ml-5 w-0 flex-1">
                  <dl>
                    <dt className="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">
                      Inactive Users
                    </dt>
                    <dd className="text-lg font-medium text-gray-900 dark:text-gray-100">
                      {users.filter(u => u.status === 'inactive').length}
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
                  <div className="h-2 w-2 bg-red-400 rounded-full"></div>
                </div>
                <div className="ml-5 w-0 flex-1">
                  <dl>
                    <dt className="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">
                      Suspended
                    </dt>
                    <dd className="text-lg font-medium text-gray-900 dark:text-gray-100">
                      {users.filter(u => u.status === 'suspended').length}
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Filters */}
        <div className="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="relative">
              <MagnifyingGlassIcon className="h-5 w-5 absolute left-3 top-3 text-gray-400" />
              <input
                type="text"
                placeholder="Search users..."
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
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
              <option value="suspended">Suspended</option>
            </select>
          </div>
        </div>

        {/* User List */}
        <div className="bg-white dark:bg-gray-800 shadow overflow-hidden sm:rounded-md">
          <ul className="divide-y divide-gray-200 dark:divide-gray-700">
            {filteredUsers.map((user, index) => (
              <motion.li
                key={user.id}
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
                          <span className="text-sm font-medium text-indigo-600 dark:text-indigo-400">
                            {getInitials(user.name)}
                          </span>
                        </div>
                      </div>
                      <div className="min-w-0 flex-1">
                        <div className="flex items-center space-x-2">
                          <p className="text-sm font-medium text-gray-900 dark:text-gray-100 truncate">
                            {user.name}
                          </p>
                          <span
                            className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(
                              user.status
                            )}`}
                          >
                            {user.status}
                          </span>
                        </div>
                        <div className="flex items-center space-x-4 mt-1">
                          <div className="flex items-center text-sm text-gray-500 dark:text-gray-400">
                            <EnvelopeIcon className="h-4 w-4 mr-1" />
                            {user.email}
                          </div>
                          <div className="flex items-center text-sm text-gray-500 dark:text-gray-400">
                            <MapPinIcon className="h-4 w-4 mr-1" />
                            {user.location}
                          </div>
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center space-x-2">
                      <div className="text-right">
                        <p className="text-sm font-medium text-gray-900 dark:text-gray-100">
                          {user.tripCount} trips
                        </p>
                        <p className="text-sm text-gray-500 dark:text-gray-400">
                          {user.totalDistance.toFixed(1)} km
                        </p>
                      </div>
                      <div className="flex space-x-1">
                        <button
                          onClick={() => setSelectedUser(user)}
                          className="inline-flex items-center p-2 border border-transparent rounded-full shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                        >
                          <EyeIcon className="h-4 w-4" />
                        </button>
                        <button className="inline-flex items-center p-2 border border-transparent rounded-full shadow-sm text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500">
                          <PencilIcon className="h-4 w-4" />
                        </button>
                        <button className="inline-flex items-center p-2 border border-transparent rounded-full shadow-sm text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500">
                          <TrashIcon className="h-4 w-4" />
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </motion.li>
            ))}
          </ul>
        </div>

        {/* User Details Modal */}
        {selectedUser && (
          <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
            <div className="relative top-20 mx-auto p-5 border w-11/12 md:w-3/4 lg:w-1/2 shadow-lg rounded-md bg-white dark:bg-gray-800">
              <div className="mt-3">
                <div className="flex items-center justify-between mb-4">
                  <h3 className="text-lg font-medium text-gray-900 dark:text-gray-100">
                    User Details
                  </h3>
                  <button
                    onClick={() => setSelectedUser(null)}
                    className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-200"
                  >
                    ×
                  </button>
                </div>
                <div className="space-y-4">
                  <div className="flex items-center space-x-4">
                    <div className="h-16 w-16 bg-indigo-100 dark:bg-indigo-900 rounded-full flex items-center justify-center">
                      <span className="text-xl font-medium text-indigo-600 dark:text-indigo-400">
                        {getInitials(selectedUser.name)}
                      </span>
                    </div>
                    <div>
                      <h4 className="text-lg font-medium text-gray-900 dark:text-gray-100">
                        {selectedUser.name}
                      </h4>
                      <p className="text-sm text-gray-500 dark:text-gray-400">
                        Member since {new Date(selectedUser.joinDate).toLocaleDateString()}
                      </p>
                    </div>
                  </div>
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                        Email
                      </label>
                      <p className="text-sm text-gray-900 dark:text-gray-100">
                        {selectedUser.email}
                      </p>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                        Phone
                      </label>
                      <p className="text-sm text-gray-900 dark:text-gray-100">
                        {selectedUser.phone}
                      </p>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                        Location
                      </label>
                      <p className="text-sm text-gray-900 dark:text-gray-100">
                        {selectedUser.location}
                      </p>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                        Status
                      </label>
                      <select
                        value={selectedUser.status}
                        onChange={(e) => handleStatusChange(selectedUser.id, e.target.value as User['status'])}
                        className="mt-1 block w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-100 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                      >
                        <option value="active">Active</option>
                        <option value="inactive">Inactive</option>
                        <option value="suspended">Suspended</option>
                      </select>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                        Total Trips
                      </label>
                      <p className="text-sm text-gray-900 dark:text-gray-100">
                        {selectedUser.tripCount}
                      </p>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                        Total Distance
                      </label>
                      <p className="text-sm text-gray-900 dark:text-gray-100">
                        {selectedUser.totalDistance.toFixed(1)} km
                      </p>
                    </div>
                    <div className="col-span-2">
                      <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                        Last Active
                      </label>
                      <p className="text-sm text-gray-900 dark:text-gray-100">
                        {new Date(selectedUser.lastActive).toLocaleString()}
                      </p>
                    </div>
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
