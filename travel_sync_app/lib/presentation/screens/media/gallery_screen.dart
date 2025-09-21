import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String _selectedFilter = 'all';
  bool _isSelectionMode = false;
  final Set<int> _selectedItems = {};

  final List<String> _filters = [
    'all',
    'photos',
    'videos',
    'trips',
    'favorites',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelectionMode ? '${_selectedItems.length} selected' : 'Gallery'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            if (_isSelectionMode) {
              setState(() {
                _isSelectionMode = false;
                _selectedItems.clear();
              });
            } else {
              context.pop();
            }
          },
          icon: Icon(_isSelectionMode ? Icons.close : Icons.arrow_back),
        ),
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              onPressed: _shareSelected,
              icon: const Icon(Icons.share),
            ),
            IconButton(
              onPressed: _deleteSelected,
              icon: const Icon(Icons.delete),
            ),
          ] else ...[
            IconButton(
              onPressed: () => context.push('/camera'),
              icon: const Icon(Icons.camera_alt),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'select':
                    setState(() {
                      _isSelectionMode = true;
                    });
                    break;
                  case 'sort':
                    _showSortDialog();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'select',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline),
                      SizedBox(width: 8),
                      Text('Select'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'sort',
                  child: Row(
                    children: [
                      Icon(Icons.sort),
                      SizedBox(width: 8),
                      Text('Sort'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: _buildGalleryGrid(),
          ),
        ],
      ),
      floatingActionButton: !_isSelectionMode
          ? FloatingActionButton(
              onPressed: () => context.push('/camera'),
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.camera_alt, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              label: Text(
                filter.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selectedColor: AppTheme.primaryColor,
              backgroundColor: AppTheme.surfaceColor,
              side: BorderSide(
                color: isSelected 
                    ? AppTheme.primaryColor 
                    : AppTheme.textSecondary.withOpacity(0.3),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGalleryGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 20, // Mock data
      itemBuilder: (context, index) {
        final isSelected = _selectedItems.contains(index);
        
        return GestureDetector(
          onTap: () {
            if (_isSelectionMode) {
              setState(() {
                if (isSelected) {
                  _selectedItems.remove(index);
                } else {
                  _selectedItems.add(index);
                }
              });
            } else {
              _showMediaViewer(index);
            }
          },
          onLongPress: () {
            if (!_isSelectionMode) {
              setState(() {
                _isSelectionMode = true;
                _selectedItems.add(index);
              });
            }
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: AppTheme.primaryColor, width: 3)
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildMediaItem(index),
                ),
              ),
              if (_isSelectionMode)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryColor : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              if (index % 4 == 0) // Mock video indicator
                const Positioned(
                  bottom: 8,
                  right: 8,
                  child: Icon(
                    Icons.play_circle_filled,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMediaItem(int index) {
    // Mock different types of media
    final colors = [
      Colors.blue[200],
      Colors.green[200],
      Colors.orange[200],
      Colors.purple[200],
      Colors.red[200],
    ];
    
    return Container(
      color: colors[index % colors.length],
      child: const Center(
        child: Icon(
          Icons.photo,
          size: 40,
          color: Colors.white70,
        ),
      ),
    );
  }

  void _showMediaViewer(int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  // Share media
                },
                icon: const Icon(Icons.share),
              ),
              IconButton(
                onPressed: () {
                  // Add to favorites
                },
                icon: const Icon(Icons.favorite_border),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      // Edit media
                      break;
                    case 'info':
                      _showMediaInfo(index);
                      break;
                    case 'delete':
                      _deleteMedia(index);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'info',
                    child: Row(
                      children: [
                        Icon(Icons.info),
                        SizedBox(width: 8),
                        Text('Info'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: AppTheme.errorColor),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Center(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const AspectRatio(
                aspectRatio: 1,
                child: Center(
                  child: Icon(
                    Icons.photo,
                    size: 100,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMediaInfo(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Media Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Date', 'Dec 15, 2023 at 2:30 PM'),
            _buildInfoRow('Size', '2.4 MB'),
            _buildInfoRow('Resolution', '1920 x 1080'),
            _buildInfoRow('Location', 'Mumbai, Maharashtra'),
            _buildInfoRow('Trip', 'Weekend Getaway to Goa'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareSelected() {
    // Share selected media
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${_selectedItems.length} items'),
      ),
    );
  }

  void _deleteSelected() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Media'),
        content: Text('Are you sure you want to delete ${_selectedItems.length} items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _selectedItems.clear();
                _isSelectionMode = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Media deleted successfully'),
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteMedia(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Media'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Close media viewer
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Media deleted successfully'),
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort by'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Date (Newest first)'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              title: const Text('Date (Oldest first)'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              title: const Text('Name (A-Z)'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              title: const Text('Size (Largest first)'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
