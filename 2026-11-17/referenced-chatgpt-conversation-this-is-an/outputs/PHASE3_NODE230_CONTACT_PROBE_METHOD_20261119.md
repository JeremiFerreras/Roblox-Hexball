# Instrumentación de la rama de contacto — Node-HaxBall 2.3.0

Copia temporal exacta: `%TEMP%\codex-haxball-oracle-230-20261118\solver-instrumented\src\api.js`; no se editó la instalación original bajo `oracle-install\node_modules\node-haxball`. SHA de copia instrumentada: véase la traza JSON; SHA de API original: `C7214DEF0FAFAB88EAAB8DDC217C28AF322D4D4C176FA3E259E56BA492B656B9`.

La sonda se insertó solamente en `N.prototype.E$`, rama `K.forEach` de planos. Captura `V` índice de disco, `f$` índice de plano, `Q` posición, `y$` velocidad, `t` radio, `o` bCoef de disco, `q.z$` normal, `q.c$` offset y `q.a` bCoef de plano. Un registro se emite al detectar penetración positiva antes de corregir; otro tras corrección y respuesta normal. La expresión física original se mantiene en el mismo orden; la sonda solo construye objetos de salida en un array global del proceso.

Patch original detectado de forma única:
`0<s&&(Q.x+=H*s,Q.y+=W*s,s=y$.x*H+y$.y*W,0>s&&(s*=o*q.a+1,y$.x-=s*H,y$.y-=s*W,h?.wr?.(V,i,f$)))`

En copia se rodeó la rama con snapshots y se conservó el callback `h?.wr?.(V,i,f$)` después de actualizar velocidad. No se altera el retorno de E$ ni sus argumentos.

El harness de copia está en `PHASE3_NODE230_CONTACT_PROBE_HARNESS_20261119.cjs` y usa `./src/index.js`, que resuelve a esa API copiada. La verificación ejecutó baseline y copia en procesos Node separados. Ambas salidas JSON fueron 3,007,628 bytes y SHA-256 `74e7e0f832a6e91d17765f1419199374209c5ebe7156ae26bc80355d67765ca8`; dos corridas instrumentadas también coincidieron byte a byte. El archivo de eventos incluye estados pre/post por tick y callbacks ordenados.
