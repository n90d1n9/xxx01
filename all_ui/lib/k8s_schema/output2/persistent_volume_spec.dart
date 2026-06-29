import 'object_reference.dart';
import 'host_path_volume_source.dart';
import 'nfsvolume_source.dart';
import 'awselastic_block_store_volume_source.dart';
import 'gcepersistent_disk_volume_source.dart';
import 'node_affinity.dart';

class PersistentVolumeSpec {
  final Map<String, String>? capacity;
  final List<String>? accessModes;
  final ObjectReference? claimRef;
  final String? persistentVolumeReclaimPolicy;
  final String? storageClassName;
  final String? volumeMode;
  final List<String>? mountOptions;
  final NodeAffinity? nodeAffinity;
  final HostPathVolumeSource? hostPath;
  final NFSVolumeSource? nfs;
  final AWSElasticBlockStoreVolumeSource? awsElasticBlockStore;
  final GCEPersistentDiskVolumeSource? gcePersistentDisk;
  PersistentVolumeSpec({
    this.capacity,
    this.accessModes,
    this.claimRef,
    this.persistentVolumeReclaimPolicy,
    this.storageClassName,
    this.volumeMode,
    this.mountOptions,
    this.nodeAffinity,
    this.hostPath,
    this.nfs,
    this.awsElasticBlockStore,
    this.gcePersistentDisk,
  });
  factory PersistentVolumeSpec.fromJson(Map<String, dynamic> json) {
    return PersistentVolumeSpec(
      capacity:
          json['capacity'] != null
              ? Map<String, String>.from(json['capacity'])
              : null,
      accessModes:
          json['accessModes'] != null
              ? List<String>.from(json['accessModes'])
              : null,
      claimRef:
          json['claimRef'] != null
              ? ObjectReference.fromJson(json['claimRef'])
              : null,
      persistentVolumeReclaimPolicy: json['persistentVolumeReclaimPolicy'],
      storageClassName: json['storageClassName'],
      volumeMode: json['volumeMode'],
      mountOptions:
          json['mountOptions'] != null
              ? List<String>.from(json['mountOptions'])
              : null,
      nodeAffinity:
          json['nodeAffinity'] != null
              ? NodeAffinity.fromJson(json['nodeAffinity'])
              : null,
      hostPath:
          json['hostPath'] != null
              ? HostPathVolumeSource.fromJson(json['hostPath'])
              : null,
      nfs: json['nfs'] != null ? NFSVolumeSource.fromJson(json['nfs']) : null,
      awsElasticBlockStore:
          json['awsElasticBlockStore'] != null
              ? AWSElasticBlockStoreVolumeSource.fromJson(
                json['awsElasticBlockStore'],
              )
              : null,
      gcePersistentDisk:
          json['gcePersistentDisk'] != null
              ? GCEPersistentDiskVolumeSource.fromJson(
                json['gcePersistentDisk'],
              )
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (capacity != null) 'capacity': capacity,
      if (accessModes != null) 'accessModes': accessModes,
      if (claimRef != null) 'claimRef': claimRef!.toJson(),
      if (persistentVolumeReclaimPolicy != null)
        'persistentVolumeReclaimPolicy': persistentVolumeReclaimPolicy,
      if (storageClassName != null) 'storageClassName': storageClassName,
      if (volumeMode != null) 'volumeMode': volumeMode,
      if (mountOptions != null) 'mountOptions': mountOptions,
      if (nodeAffinity != null) 'nodeAffinity': nodeAffinity!.toJson(),
      if (hostPath != null) 'hostPath': hostPath!.toJson(),
      if (nfs != null) 'nfs': nfs!.toJson(),
      if (awsElasticBlockStore != null)
        'awsElasticBlockStore': awsElasticBlockStore!.toJson(),
      if (gcePersistentDisk != null)
        'gcePersistentDisk': gcePersistentDisk!.toJson(),
    };
  }
}
