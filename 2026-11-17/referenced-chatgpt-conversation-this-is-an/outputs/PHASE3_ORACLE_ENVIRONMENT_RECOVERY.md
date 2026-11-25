# Recuperación del entorno Oracle

Estado: **RECUPERADO Y EJECUTADO** desde `C:\Users\User\AppData\Local\Temp\codex-haxball-oracle-230-20261118`.

Ejecutable portable: `portable-node\node-v24.22.3-win-x64\node.exe` (Node v24.22.3; npm portable 11.19.1). Aislado: `oracle-install\node_modules\node-haxball`; `require.resolve` desde ese directorio resolvió `node_modules\node-haxball\src\index.js`. `package.json` declara 2.3.0; el proceso produjo salida con el harness `nh_oracle.js` en el cwd aislado. Lockfile SHA-256 `25a0592f990abf94340600078074f32b2ff6fd95b1794a7b3ec939f2a95288f3`. SRI y tarball previos: `sha512-fSxZFWuDSckKK1JBKVRATXcnXR5lZV4ae3Jf6yr+FxxKE86Yore/xidVR1Sq+ZgrERtHSe0rtcgWo3uauJKlgw==`; tarball SHA-256 `d37c62e81f3f3c932eb5bb3b760e7d1e39347c686a4d9212c2f30633fc3183d9` (registro previo). Dependencias se resolvieron desde el node_modules aislado con el lockfile referido en ORACLE_230_INSTALLATION.json.

Se ejecutó `run-oracle-twice.mjs`, que lanza `nh_oracle.js` dos veces. Ambas terminaron exit code 0, generaron 38,693 bytes, igualaron byte por byte, SHA-256 `7d612957764a076d506f53c4dd8d7fd39381e3db261cb399a812f6eb7d110e37`. Cada salida tiene 3 Classic × 180 ticks = 540. La telemetría histórica verificada aporta los callbacks por tick 1..180, 0 faltantes/duplicados; no se regeneró la telemetría instrumentada en esta recuperación. No sustituí por 2.3.1.

La ejecución simple volvió a reproducir el fixture de trayectorias. Las pruebas A–F requieren el instrumentador extendido de ambos motores; el runner encontrado es el harness básico de trayectorias y no mide estado instantáneo del solver. Se detuvo la experimentación antes de producir datos físicos no comparables.
