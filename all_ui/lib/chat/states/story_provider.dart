import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/story.dart';

final storiesProvider = StateNotifierProvider<StoriesNotifier, List<Story>>((
  ref,
) {
  return StoriesNotifier();
});

class StoriesNotifier extends StateNotifier<List<Story>> {
  StoriesNotifier() : super(_mockStories);

  static final List<Story> _mockStories = [
    Story(
      id: '1',
      userId: 'user1',
      userName: 'John Doe',
      userAvatar: 'https://via.placeholder.com/60',
      mediaUrl: 'https://via.placeholder.com/300x400',
      type: StoryType.image,
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      isViewed: false,
      viewers: ['user2', 'user3'],
    ),
    Story(
      id: '2',
      userId: 'user2',
      userName: 'Sarah Johnson',
      userAvatar: 'https://via.placeholder.com/60',
      mediaUrl: 'https://via.placeholder.com/300x400',
      type: StoryType.video,
      timestamp: DateTime.now().subtract(Duration(hours: 4)),
      isViewed: true,
      viewers: ['user1', 'user3'],
    ),
    Story(
      id: '3',
      userId: 'user3',
      userName: 'Mike Wilson',
      userAvatar: 'https://via.placeholder.com/60',
      mediaUrl: 'https://via.placeholder.com/300x400',
      type: StoryType.image,
      timestamp: DateTime.now().subtract(Duration(hours: 6)),
      isViewed: false,
      viewers: ['user1'],
    ),
  ];

  void addStory(Story story) {
    state = [story, ...state];
  }

  void markAsViewed(String storyId) {
    state =
        state.map((story) {
          if (story.id == storyId) {
            return Story(
              id: story.id,
              userId: story.userId,
              userName: story.userName,
              userAvatar: story.userAvatar,
              mediaUrl: story.mediaUrl,
              type: story.type,
              timestamp: story.timestamp,
              isViewed: true,
              viewers: story.viewers,
            );
          }
          return story;
        }).toList();
  }
}
