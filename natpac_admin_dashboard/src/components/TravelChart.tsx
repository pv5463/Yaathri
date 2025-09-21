import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, BarChart, Bar } from 'recharts';
import { useState } from 'react';

interface TravelChartProps {
  timeRange: string;
}

const mockData = {
  '7d': [
    { name: 'Mon', trips: 24, distance: 156, users: 18 },
    { name: 'Tue', trips: 32, distance: 203, users: 24 },
    { name: 'Wed', trips: 28, distance: 178, users: 21 },
    { name: 'Thu', trips: 35, distance: 234, users: 28 },
    { name: 'Fri', trips: 42, distance: 289, users: 32 },
    { name: 'Sat', trips: 38, distance: 267, users: 29 },
    { name: 'Sun', trips: 31, distance: 198, users: 23 },
  ],
  '30d': [
    { name: 'Week 1', trips: 180, distance: 1200, users: 145 },
    { name: 'Week 2', trips: 220, distance: 1450, users: 167 },
    { name: 'Week 3', trips: 195, distance: 1320, users: 152 },
    { name: 'Week 4', trips: 240, distance: 1580, users: 178 },
  ],
  '90d': [
    { name: 'Month 1', trips: 835, distance: 5470, users: 642 },
    { name: 'Month 2', trips: 920, distance: 6120, users: 698 },
    { name: 'Month 3', trips: 1050, distance: 6890, users: 756 },
  ],
  '1y': [
    { name: 'Q1', trips: 2805, distance: 18480, users: 2096 },
    { name: 'Q2', trips: 3240, distance: 21360, users: 2387 },
    { name: 'Q3', trips: 3680, distance: 24280, users: 2654 },
    { name: 'Q4', trips: 3950, distance: 26070, users: 2823 },
  ],
};

export default function TravelChart({ timeRange }: TravelChartProps) {
  const [chartType, setChartType] = useState<'line' | 'bar'>('line');
  const data = mockData[timeRange as keyof typeof mockData] || mockData['7d'];

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <div className="flex space-x-2">
          <button
            onClick={() => setChartType('line')}
            className={`px-3 py-1 text-sm rounded-md ${
              chartType === 'line'
                ? 'bg-indigo-100 text-indigo-700'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            Line Chart
          </button>
          <button
            onClick={() => setChartType('bar')}
            className={`px-3 py-1 text-sm rounded-md ${
              chartType === 'bar'
                ? 'bg-indigo-100 text-indigo-700'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            Bar Chart
          </button>
        </div>
      </div>

      <div className="h-80">
        <ResponsiveContainer width="100%" height="100%">
          {chartType === 'line' ? (
            <LineChart data={data}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="name" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Line
                type="monotone"
                dataKey="trips"
                stroke="#8884d8"
                strokeWidth={2}
                dot={{ fill: '#8884d8' }}
              />
              <Line
                type="monotone"
                dataKey="users"
                stroke="#82ca9d"
                strokeWidth={2}
                dot={{ fill: '#82ca9d' }}
              />
            </LineChart>
          ) : (
            <BarChart data={data}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="name" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Bar dataKey="trips" fill="#8884d8" />
              <Bar dataKey="users" fill="#82ca9d" />
            </BarChart>
          )}
        </ResponsiveContainer>
      </div>

      <div className="grid grid-cols-3 gap-4 text-center">
        <div className="bg-gray-50 rounded-lg p-3">
          <div className="text-2xl font-bold text-gray-900">
            {data.reduce((sum, item) => sum + item.trips, 0)}
          </div>
          <div className="text-sm text-gray-500">Total Trips</div>
        </div>
        <div className="bg-gray-50 rounded-lg p-3">
          <div className="text-2xl font-bold text-gray-900">
            {data.reduce((sum, item) => sum + item.distance, 0)}km
          </div>
          <div className="text-sm text-gray-500">Total Distance</div>
        </div>
        <div className="bg-gray-50 rounded-lg p-3">
          <div className="text-2xl font-bold text-gray-900">
            {data.reduce((sum, item) => sum + item.users, 0)}
          </div>
          <div className="text-sm text-gray-500">Active Users</div>
        </div>
      </div>
    </div>
  );
}
