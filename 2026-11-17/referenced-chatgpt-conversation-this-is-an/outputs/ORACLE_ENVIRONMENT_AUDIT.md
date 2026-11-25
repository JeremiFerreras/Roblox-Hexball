# Auditoría de entorno

Fecha: 2026-11-18.

Node.js v24.22.3 estaba instalado, pero npm no estaba en PATH. Se encontró pnpm 11.25.0; no había npm/npx, Yarn, Bun ni Corepack disponibles. Se preparó el ZIP oficial portable de Node.js 24.22.3 x64 en `%TEMP%\codex-haxball-oracle-230-20261118`; incluye npm 11.19.1. SHA-256 del ZIP: `e612af99f626ab415ea225af6bce5c971feb448cb5cae250bb1c3fa50c5f7d9f`, verificado contra la suma oficial de [Node.js 24.22.3](https://nodejs.org/en/blog/release/v24.22.3).

PowerShell y curl.exe fallaron con TLS/Schannel `SEC_E_NO_CREDENTIALS (0x8009030E)`. Node `fetch` accedió al ZIP oficial y su hash coincidió. No se modificaron PATH, Registro ni instalaciones globales.

Se copió el manifiesto y lockfile locales de HaxballGym a un directorio temporal independiente y se ejecutó `npm ci --ignore-scripts --no-audit --no-fund`. El único hook de instalación era node-datachannel@0.25.0. Se revisó su script y se ejecutó solo `prebuild-install -r napi`; no se ejecutó compilación de respaldo. El binario quedó presente.

El paquete `node-haxball@2.3.0` se verificó en tiempo de ejecución; SRI del registro y lockfile coincide. SHA-256 del tarball: `d37c62e81f3f3c932eb5bb3b760e7d1e39347c686a4d9212c2f30633fc3183d9`. Detalles en [ORACLE_230_INSTALLATION.json](ORACLE_230_INSTALLATION.json).

El commit de HaxballGym `1781914b79ccad18a65367d66de4645412405bce` es la referencia indicada. El ZIP local no contiene metadatos Git: no puedo certificar que el árbol del ZIP sea idéntico al commit. Sí comprobé el lockfile incluido y su resolución exacta a 2.3.0. Fuentes: [nh_oracle.js](https://github.com/HaxballGym/HaxballGym/blob/1781914b79ccad18a65367d66de4645412405bce/headless-bot/nh_oracle.js), [package-lock.json](https://github.com/HaxballGym/HaxballGym/blob/1781914b79ccad18a65367d66de4645412405bce/headless-bot/package-lock.json).

Todo quedó en Temp; ningún archivo del proyecto Roblox se modificó.
