{
  'includes': ['toolchain.gypi'],
  'targets': [
    {
      'target_name': 'abseil',
      'type': 'none',
      'toolsets': ['host', 'target'],
      'cflags': ['-labsl_synchronization'],
      'ldflags': ['-labsl_synchronization'],
    },  # abseil
  ]
}
