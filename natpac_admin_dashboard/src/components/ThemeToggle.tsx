import { useEffect, useState } from 'react';

export default function ThemeToggle() {
  const [mounted, setMounted] = useState(false);
  const [theme, setTheme] = useState<'light' | 'dark'>(() => {
    if (typeof window === 'undefined') return 'light';
    return (localStorage.getItem('theme') as 'light' | 'dark') || 'light';
  });

  useEffect(() => {
    setMounted(true);
  }, []);

  useEffect(() => {
    const root = window.document.documentElement;
    if (theme === 'dark') {
      root.classList.add('dark');
    } else {
      root.classList.remove('dark');
    }
    localStorage.setItem('theme', theme);
  }, [theme]);

  if (!mounted) return null;

  return (
    <button
      onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
      className="inline-flex items-center rounded-md border border-gray-200 dark:border-gray-700 px-3 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700"
      aria-label="Toggle theme"
      title="Toggle theme"
    >
      {theme === 'dark' ? (
        <svg className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
          <path d="M17.293 13.293A8 8 0 016.707 2.707 8.001 8.001 0 1017.293 13.293z" />
        </svg>
      ) : (
        <svg className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
          <path fillRule="evenodd" d="M10 2a1 1 0 011 1v1a1 1 0 11-2 0V3a1 1 0 011-1zm4.22 1.47a1 1 0 011.415 0l.707.708a1 1 0 01-1.414 1.414l-.708-.707a1 1 0 010-1.415zM17 9a1 1 0 110 2h-1a1 1 0 110-2h1zM4 10a1 1 0 100-2H3a1 1 0 100 2h1zm1.05-5.525a1 1 0 010 1.415l-.707.707A1 1 0 112.93 5.182l.707-.707a1 1 0 011.414 0zM10 16a1 1 0 011 1v1a1 1 0 11-2 0v-1a1 1 0 011-1zm6.364-2.95a1 1 0 010 1.414l-.707.708a1 1 0 01-1.414-1.415l.707-.707a1 1 0 011.414 0zM6.757 15.536a1 1 0 010 1.415l-.708.707a1 1 0 11-1.414-1.414l.707-.708a1 1 0 011.415 0z" clipRule="evenodd" />
        </svg>
      )}
    </button>
  );
}