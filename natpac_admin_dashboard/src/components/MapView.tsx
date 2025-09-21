import { useEffect, useState } from 'react';
import dynamic from 'next/dynamic';
import { LatLngExpression } from 'leaflet';

// Dynamically import map components to avoid SSR issues
const MapContainer = dynamic(
  () => import('react-leaflet').then((mod) => mod.MapContainer),
  { ssr: false }
);
const TileLayer = dynamic(
  () => import('react-leaflet').then((mod) => mod.TileLayer),
  { ssr: false }
);
const Marker = dynamic(
  () => import('react-leaflet').then((mod) => mod.Marker),
  { ssr: false }
);
const Popup = dynamic(
  () => import('react-leaflet').then((mod) => mod.Popup),
  { ssr: false }
);
const Polyline = dynamic(
  () => import('react-leaflet').then((mod) => mod.Polyline),
  { ssr: false }
);

// Mock trip data for Kerala
const mockTripData = [
  {
    id: '1',
    origin: { lat: 9.9312, lng: 76.2673, name: 'Kochi' },
    destination: { lat: 8.5241, lng: 76.9366, name: 'Thiruvananthapuram' },
    count: 45,
    route: [
      [9.9312, 76.2673] as LatLngExpression,
      [9.5916, 76.5222] as LatLngExpression,
      [9.2648, 76.6413] as LatLngExpression,
      [8.8932, 76.6141] as LatLngExpression,
      [8.5241, 76.9366] as LatLngExpression,
    ],
  },
  {
    id: '2',
    origin: { lat: 9.9312, lng: 76.2673, name: 'Kochi' },
    destination: { lat: 11.2588, lng: 75.7804, name: 'Kozhikode' },
    count: 32,
    route: [
      [9.9312, 76.2673] as LatLngExpression,
      [10.5276, 76.2144] as LatLngExpression,
      [10.7905, 76.6552] as LatLngExpression,
      [11.2588, 75.7804] as LatLngExpression,
    ],
  },
  {
    id: '3',
    origin: { lat: 9.5916, lng: 76.5222, name: 'Kottayam' },
    destination: { lat: 10.0889, lng: 77.0595, name: 'Munnar' },
    count: 28,
    route: [
      [9.5916, 76.5222] as LatLngExpression,
      [9.6615, 76.7358] as LatLngExpression,
      [9.8312, 76.8811] as LatLngExpression,
      [10.0889, 77.0595] as LatLngExpression,
    ],
  },
  {
    id: '4',
    origin: { lat: 10.5276, lng: 76.2144, name: 'Thrissur' },
    destination: { lat: 10.7867, lng: 76.6548, name: 'Palakkad' },
    count: 21,
    route: [
      [10.5276, 76.2144] as LatLngExpression,
      [10.6615, 76.4358] as LatLngExpression,
      [10.7867, 76.6548] as LatLngExpression,
    ],
  },
];

const heatmapData = [
  { lat: 9.9312, lng: 76.2673, intensity: 0.8, name: 'Kochi', trips: 156 },
  { lat: 8.5241, lng: 76.9366, intensity: 0.6, name: 'Thiruvananthapuram', trips: 98 },
  { lat: 11.2588, lng: 75.7804, intensity: 0.5, name: 'Kozhikode', trips: 76 },
  { lat: 9.5916, lng: 76.5222, intensity: 0.4, name: 'Kottayam', trips: 54 },
  { lat: 10.5276, lng: 76.2144, intensity: 0.4, name: 'Thrissur', trips: 52 },
  { lat: 10.7867, lng: 76.6548, intensity: 0.3, name: 'Palakkad', trips: 43 },
  { lat: 10.0889, lng: 77.0595, intensity: 0.3, name: 'Munnar', trips: 38 },
];

export default function MapView() {
  const [isClient, setIsClient] = useState(false);
  const [selectedTrip, setSelectedTrip] = useState<string | null>(null);

  useEffect(() => {
    setIsClient(true);
  }, []);

  if (!isClient) {
    return (
      <div className="h-96 bg-gray-100 rounded-lg flex items-center justify-center">
        <div className="text-gray-500">Loading map...</div>
      </div>
    );
  }

  const getRouteColor = (count: number) => {
    if (count > 40) return '#ef4444'; // red
    if (count > 30) return '#f97316'; // orange
    if (count > 20) return '#eab308'; // yellow
    return '#22c55e'; // green
  };

  const getMarkerSize = (intensity: number) => {
    return Math.max(10, intensity * 30);
  };

  return (
    <div className="space-y-4">
      {/* Legend */}
      <div className="flex flex-wrap items-center justify-between text-sm">
        <div className="flex items-center space-x-4">
          <div className="flex items-center space-x-2">
            <div className="w-3 h-3 bg-red-500 rounded-full"></div>
            <span>High Traffic (40+ trips)</span>
          </div>
          <div className="flex items-center space-x-2">
            <div className="w-3 h-3 bg-orange-500 rounded-full"></div>
            <span>Medium Traffic (30-40 trips)</span>
          </div>
          <div className="flex items-center space-x-2">
            <div className="w-3 h-3 bg-yellow-500 rounded-full"></div>
            <span>Low Traffic (20-30 trips)</span>
          </div>
          <div className="flex items-center space-x-2">
            <div className="w-3 h-3 bg-green-500 rounded-full"></div>
            <span>Minimal Traffic (&lt;20 trips)</span>
          </div>
        </div>
      </div>

      {/* Map */}
      <div className="h-96 rounded-lg overflow-hidden border border-gray-200">
        <MapContainer
          center={[10.0, 76.5]}
          zoom={8}
          style={{ height: '100%', width: '100%' }}
        >
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />
          
          {/* Heatmap markers */}
          {heatmapData.map((point) => (
            <Marker
              key={point.name}
              position={[point.lat, point.lng]}
            >
              <Popup>
                <div className="text-center">
                  <h3 className="font-semibold">{point.name}</h3>
                  <p className="text-sm text-gray-600">{point.trips} trips</p>
                </div>
              </Popup>
            </Marker>
          ))}

          {/* Route lines */}
          {mockTripData.map((trip) => (
            <Polyline
              key={trip.id}
              positions={trip.route}
              color={getRouteColor(trip.count)}
              weight={Math.max(2, trip.count / 10)}
              opacity={selectedTrip === trip.id ? 1 : 0.7}
              eventHandlers={{
                click: () => setSelectedTrip(trip.id),
              }}
            >
              <Popup>
                <div className="text-center">
                  <h3 className="font-semibold">
                    {trip.origin.name} → {trip.destination.name}
                  </h3>
                  <p className="text-sm text-gray-600">{trip.count} trips</p>
                </div>
              </Popup>
            </Polyline>
          ))}
        </MapContainer>
      </div>

      {/* Route Statistics */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="bg-gray-50 rounded-lg p-4">
          <h4 className="font-medium text-gray-900 mb-3">Popular Routes</h4>
          <div className="space-y-2">
            {mockTripData
              .sort((a, b) => b.count - a.count)
              .slice(0, 3)
              .map((trip) => (
                <div
                  key={trip.id}
                  className="flex justify-between items-center text-sm"
                >
                  <span className="text-gray-600">
                    {trip.origin.name} → {trip.destination.name}
                  </span>
                  <span className="font-medium">{trip.count} trips</span>
                </div>
              ))}
          </div>
        </div>

        <div className="bg-gray-50 rounded-lg p-4">
          <h4 className="font-medium text-gray-900 mb-3">Activity Hotspots</h4>
          <div className="space-y-2">
            {heatmapData
              .sort((a, b) => b.trips - a.trips)
              .slice(0, 3)
              .map((point) => (
                <div
                  key={point.name}
                  className="flex justify-between items-center text-sm"
                >
                  <span className="text-gray-600">{point.name}</span>
                  <span className="font-medium">{point.trips} trips</span>
                </div>
              ))}
          </div>
        </div>
      </div>
    </div>
  );
}
