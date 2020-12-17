import 'dart:mirrors';

/// Created by ipcjs on 2020/12/17.
extension FunctionExt on Function {
  String get name {
    final name = (reflect(this) as ClosureMirror).function.simpleName;
    return MirrorSystem.getName(name);
  }
}
