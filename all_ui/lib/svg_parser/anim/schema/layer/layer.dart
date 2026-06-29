enum LayerType {
  shape,
  image,
  text,
  group,
  rectangle,
  circle,
  path,
  particle,
  ellipse,
  bone;

  int toLottieType() {
    switch (this) {
      case LayerType.shape:
        return 4;
      case LayerType.image:
        return 2;
      case LayerType.text:
        return 5;
      case LayerType.group:
        return 3;
      case LayerType.rectangle:
        // TODO: Handle this case.
        throw UnimplementedError();
      case LayerType.circle:
        // TODO: Handle this case.
        throw UnimplementedError();
      case LayerType.path:
        // TODO: Handle this case.
        throw UnimplementedError();
      case LayerType.particle:
        // TODO: Handle this case.
        throw UnimplementedError();
      case LayerType.bone:
        // TODO: Handle this case.
        throw UnimplementedError();
      case LayerType.ellipse:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
