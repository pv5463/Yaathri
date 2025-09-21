import { motion } from 'framer-motion';
import { ArrowUpIcon, ArrowDownIcon } from '@heroicons/react/20/solid';
import clsx from 'clsx';

interface StatsCardProps {
  name: string;
  value: string | number;
  change: string;
  changeType: 'positive' | 'negative' | 'neutral';
  icon: React.ComponentType<React.SVGProps<SVGSVGElement>>;
}

export default function StatsCard({ name, value, change, changeType, icon: Icon }: StatsCardProps) {
  return (
    <motion.div
      whileHover={{ scale: 1.02 }}
      className="relative overflow-hidden rounded-xl bg-white px-4 py-5 shadow-sm ring-1 ring-gray-200 sm:px-6 sm:py-6 dark:bg-gray-800 dark:ring-gray-700"
    >
      <dt>
        <div className="absolute rounded-md bg-gradient-to-r from-indigo-500 to-violet-500 p-3 shadow-md">
          <Icon className="h-6 w-6 text-white" aria-hidden="true" />
        </div>
        <p className="ml-16 truncate text-sm font-medium text-gray-500 dark:text-gray-400">{name}</p>
      </dt>
      <dd className="ml-16 flex items-baseline pb-6 sm:pb-7">
        <p className="text-2xl font-semibold text-gray-900 dark:text-gray-100">{value}</p>
        <p
          className={clsx(
            changeType === 'positive' ? 'text-green-600' : changeType === 'negative' ? 'text-red-600' : 'text-gray-600',
            'ml-2 flex items-baseline text-sm font-semibold'
          )}
        >
          {changeType === 'positive' ? (
            <ArrowUpIcon className="h-5 w-5 flex-shrink-0 self-center text-green-500" aria-hidden="true" />
          ) : changeType === 'negative' ? (
            <ArrowDownIcon className="h-5 w-5 flex-shrink-0 self-center text-red-500" aria-hidden="true" />
          ) : null}
          <span className="sr-only"> {changeType === 'positive' ? 'Increased' : 'Decreased'} by </span>
          {change}
        </p>
        <div className="absolute inset-x-0 bottom-0 bg-gray-50 dark:bg-gray-900/40 px-4 py-4 sm:px-6">
          <div className="text-sm">
            <a href="#" className="font-medium text-indigo-600 hover:text-indigo-500">
              View all<span className="sr-only"> {name} stats</span>
            </a>
          </div>
        </div>
      </dd>
    </motion.div>
  );
}
