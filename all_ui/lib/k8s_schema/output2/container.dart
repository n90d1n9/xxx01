import 'container_port.dart';
import 'env_var.dart';
import 'env_from_source.dart';
import 'resource_requirements.dart';
import 'volume_mount.dart';
import 'probe.dart';
import 'lifecycle.dart';
import 'security_context.dart';

class Container {
  final String name;
  final String image;
  final List<String>? command;
  final List<String>? args;
  final String? workingDir;
  final List<ContainerPort>? ports;
  final List<EnvVar>? env;
  final List<EnvFromSource>? envFrom;
  final ResourceRequirements? resources;
  final List<VolumeMount>? volumeMounts;
  final Probe? livenessProbe;
  final Probe? readinessProbe;
  final Probe? startupProbe;
  final Lifecycle? lifecycle;
  final String? terminationMessagePath;
  final String? terminationMessagePolicy;
  final String? imagePullPolicy;
  final SecurityContext? securityContext;
  final bool? stdin;
  final bool? stdinOnce;
  final bool? tty;
  Container({
    required this.name,
    required this.image,
    this.command,
    this.args,
    this.workingDir,
    this.ports,
    this.env,
    this.envFrom,
    this.resources,
    this.volumeMounts,
    this.livenessProbe,
    this.readinessProbe,
    this.startupProbe,
    this.lifecycle,
    this.terminationMessagePath,
    this.terminationMessagePolicy,
    this.imagePullPolicy,
    this.securityContext,
    this.stdin,
    this.stdinOnce,
    this.tty,
  });
  factory Container.fromJson(Map<String, dynamic> json) {
    return Container(
      name: json['name'],
      image: json['image'],
      command:
          json['command'] != null ? List<String>.from(json['command']) : null,
      args: json['args'] != null ? List<String>.from(json['args']) : null,
      workingDir: json['workingDir'],
      ports:
          json['ports'] != null
              ? (json['ports'] as List)
                  .map((e) => ContainerPort.fromJson(e))
                  .toList()
              : null,
      env:
          json['env'] != null
              ? (json['env'] as List).map((e) => EnvVar.fromJson(e)).toList()
              : null,
      envFrom:
          json['envFrom'] != null
              ? (json['envFrom'] as List)
                  .map((e) => EnvFromSource.fromJson(e))
                  .toList()
              : null,
      resources:
          json['resources'] != null
              ? ResourceRequirements.fromJson(json['resources'])
              : null,
      volumeMounts:
          json['volumeMounts'] != null
              ? (json['volumeMounts'] as List)
                  .map((e) => VolumeMount.fromJson(e))
                  .toList()
              : null,
      livenessProbe:
          json['livenessProbe'] != null
              ? Probe.fromJson(json['livenessProbe'])
              : null,
      readinessProbe:
          json['readinessProbe'] != null
              ? Probe.fromJson(json['readinessProbe'])
              : null,
      startupProbe:
          json['startupProbe'] != null
              ? Probe.fromJson(json['startupProbe'])
              : null,
      lifecycle:
          json['lifecycle'] != null
              ? Lifecycle.fromJson(json['lifecycle'])
              : null,
      terminationMessagePath: json['terminationMessagePath'],
      terminationMessagePolicy: json['terminationMessagePolicy'],
      imagePullPolicy: json['imagePullPolicy'],
      securityContext:
          json['securityContext'] != null
              ? SecurityContext.fromJson(json['securityContext'])
              : null,
      stdin: json['stdin'],
      stdinOnce: json['stdinOnce'],
      tty: json['tty'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      if (command != null) 'command': command,
      if (args != null) 'args': args,
      if (workingDir != null) 'workingDir': workingDir,
      if (ports != null) 'ports': ports!.map((e) => e.toJson()).toList(),
      if (env != null) 'env': env!.map((e) => e.toJson()).toList(),
      if (envFrom != null) 'envFrom': envFrom!.map((e) => e.toJson()).toList(),
      if (resources != null) 'resources': resources!.toJson(),
      if (volumeMounts != null)
        'volumeMounts': volumeMounts!.map((e) => e.toJson()).toList(),
      if (livenessProbe != null) 'livenessProbe': livenessProbe!.toJson(),
      if (readinessProbe != null) 'readinessProbe': readinessProbe!.toJson(),
      if (startupProbe != null) 'startupProbe': startupProbe!.toJson(),
      if (lifecycle != null) 'lifecycle': lifecycle!.toJson(),
      if (terminationMessagePath != null)
        'terminationMessagePath': terminationMessagePath,
      if (terminationMessagePolicy != null)
        'terminationMessagePolicy': terminationMessagePolicy,
      if (imagePullPolicy != null) 'imagePullPolicy': imagePullPolicy,
      if (securityContext != null) 'securityContext': securityContext!.toJson(),
      if (stdin != null) 'stdin': stdin,
      if (stdinOnce != null) 'stdinOnce': stdinOnce,
      if (tty != null) 'tty': tty,
    };
  }
}
