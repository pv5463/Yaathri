import { useQuery } from 'react-query';
import axios from 'axios';

interface TravelData {
  totalTrips: number;
  activeUsers: number;
  totalDistance: number;
  dataPoints: number;
  trendData: Array<{
    date: string;
    trips: number;
    users: number;
    distance: number;
  }>;
}

const fetchTravelData = async (): Promise<TravelData> => {
  // In a real application, this would fetch from your API
  // For demo purposes, returning mock data
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve({
        totalTrips: 1247,
        activeUsers: 892,
        totalDistance: 15678,
        dataPoints: 45632,
        trendData: [
          { date: '2024-01-01', trips: 45, users: 32, distance: 567 },
          { date: '2024-01-02', trips: 52, users: 38, distance: 634 },
          { date: '2024-01-03', trips: 48, users: 35, distance: 589 },
          { date: '2024-01-04', trips: 61, users: 42, distance: 723 },
          { date: '2024-01-05', trips: 55, users: 39, distance: 656 },
        ],
      });
    }, 1000);
  });
};

export const useTravelData = () => {
  return useQuery('travelData', fetchTravelData, {
    refetchInterval: 30000, // Refetch every 30 seconds
    staleTime: 10000, // Data is fresh for 10 seconds
  });
};
