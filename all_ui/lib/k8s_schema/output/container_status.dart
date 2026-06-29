import 'container_state.dart';

class ContainerStatus {
  final String name;
  final ContainerState? state;
  final ContainerState? lastState;
  final bool ready;
  final int restartCount;
  final String image;
  final String imageID;
  final String? containerID;
  final bool? started;
  ContainerStatus({
    required this.name,
    this.state,
    this.lastState,
    required this.ready,
    required this.restartCount,
    required this.image,
    required this.imageID,
    this.containerID,
    this.started,
  });
  factory ContainerStatus.fromJson(Map<String, dynamic> json) {
    return ContainerStatus(
      name: json['name'],
      state:
          json['state'] != null ? ContainerState.fromJson(json['state']) : null,
      lastState:
          json['lastState'] != null
              ? ContainerState.fromJson(json['lastState'])
              : null,
      ready: json['ready'],
      restartCount: json['restartCount'],
      image: json['image'],
      imageID: json['imageID'],
      containerID: json['containerID'],
      started: json['started'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (state != null) 'state': state!.toJson(),
      if (lastState != null) 'lastState': lastState!.toJson(),
      'ready': ready,
      'restartCount': restartCount,
      'image': image,
      'imageID': imageID,
      if (containerID != null) 'containerID': containerID,
      if (started != null) 'started': started,
    };
  }
}
