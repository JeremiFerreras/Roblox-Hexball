# Auditoría de `bCoef` en Node-HaxBall 2.3.0 y HBS

## Alcance y procedencia

Inspección estática del paquete aislado `node-haxball@2.3.0` en `%TEMP%\codex-haxball-oracle-230-20261118\oracle-install\node_modules\node-haxball`. El `package.json` declara `2.3.0`, `main=src/index.js`; el manifiesto de instalación registra el proceso verificado 2.3.0, el tarball SHA-256 `d37c62e81f3f3c932eb5bb3b760e7d1e39347c686a4d9212c2f30633fc3183d9` y SRI `sha512-fSxZFWuDSckKK1JBKVRATXcnXR5lZV4ae3Jf6yr+FxxKE86Yore/xidVR1Sq+ZgrERtHSe0rtcgWo3uauJKlgw==`.

El código de la implementación física está distribuido como bundle en `src/api.js`, de una línea. SHA-256 del archivo inspeccionado: `C7214DEF0FAFAB88EAAB8DDC217C28AF322D4D4C176FA3E259E56BA492B656B9`. No se editó ni parcheó Node. La inspección no ejecutó nuevas colisiones en Node; las conclusiones de abajo son sobre el código 2.3.0 del paquete fijado.

## Regla de combinación observada en la respuesta normal

En el bucle de física `E$` del mundo de discos (`U` en el bundle), las rutinas que responden a contactos multiplican el coeficiente del disco por el coeficiente de la otra superficie y aplican `1 + producto` a la componente de velocidad de cierre. Para la convención de la auditoría —normal admisible `n`, `g=n·v<0` al cerrar— la operación equivale a:

`g⁺ = −(1 + b₁·b₂) g⁻`

cuando se ejecuta esa respuesta individual del motor. Esto demuestra una regla **multiplicativa por pareja** en los caminos inspeccionados. No demuestra que esta ley secuencial individual sea una restitución conjunta pasiva para cualquier manifold.

| Pareja de contacto en `E$` | Evidencia del camino de respuesta | Regla demostrada |
|---|---|---|
| Disco–disco | Corrección de velocidad relativa usa `o*B.a+1`; `o` y `B.a` son los campos `bCoef` de cada disco. | `1 + discA.bCoef * discB.bCoef` |
| Disco–plano | La pasada `K.forEach` calcula la velocidad normal y multiplica su inversión por `o*q.a+1`. | `1 + disc.bCoef * plane.bCoef` |
| Disco–segmento | La pasada `R.forEach` usa el campo `q.a` del segmento en la modificación normal `T*=o*q.a+1`. | `1 + disc.bCoef * segment.bCoef` |
| Disco–vértice | La pasada `k.forEach` usa `I*=o*q.a+1`. | `1 + disc.bCoef * vertex.bCoef` |

Los nombres `a` y `q` son campos minificados; el bundle registra las correspondencias públicas en las listas de propiedades de las clases: plano `bCoef/dist/normal`, segmento `bCoef/...`, vértice `bCoef`, disco `bCoef/...`. La misma rutina `E$` realiza corrección geométrica de posición y luego refleja la componente normal solo si está cerrándose. El producto de `bCoef` se aplica a la respuesta de velocidad, no a la corrección posicional.

## Defaults y campos omitidos en HBS

El parser de planos del bundle (`v.Qs`) construye primero una instancia cuyo campo interno `a` tiene default `1`; solo sobrescribe ese campo si `$.bCoef != null`. El exportador (`v.Rg`) serializa `bCoef` con default `1`, por lo que lo omite cuando vale uno. Por tanto, para este parser 2.3.0, **un `bCoef` omitido en una entrada plane HBS se normaliza a 1**; la ausencia en el JSON exportado no significa cero ni desconocido una vez demostrada la ruta de parseo/exportación.

En el fixture Classic aislado, el HBS serializado contiene seis planos:

| Índice HBS | Normal | `dist` | `bCoef` serializado | `cMask` |
|---:|---|---:|---:|---|
| 0 | `(0,1)` | `-200` | `0` | omitido |
| 1 | `(0,-1)` | `-200` | `0` | omitido |
| 2 | `(1,0)` | `-420` | `0` | omitido |
| 3 | `(-1,0)` | `-420` | `0` | omitido |
| 4 | `(0,1)` | `-170` | omitido → default parser `1` | `ball` |
| 5 | `(0,-1)` | `-170` | omitido → default parser `1` | `ball` |

La fila superior del área de balón (`normal=(0,-1), dist=-170`) usa, según la conversión del parser, `plane.bCoef=1`. Con el disco balón de `bCoef=0.5` registrado en el mismo fixture, la multiplicación de pareja entrega un coeficiente efectivo de velocidad `e_pair=0.5` para ese contacto disco–plano. Esto solo describe la propiedad y la operación de ese camino; no atribuye por sí solo el resultado `vy=0` de S3 al material.

Los cuatro planos exteriores serializados declaran explícitamente `bCoef=0`; no se les aplica el default. Esto confirma que el HBS de referencia difiere del perfil Studio previamente auditado en exteriores (`0` HBS frente a `0.1` activo), mientras el área de balón omitida se interpreta como `1` en Node.

## Qué no queda demostrado

- No se deriva una combinación universal para una respuesta colectiva PGS-D: Node resuelve contactos secuencialmente en su bucle de discos, no proporciona un coeficiente escalar de manifold para reutilizar.
- La regla de producto está comprobada para los caminos disco–disco, disco–plano, disco–segmento y disco–vértice vistos en `E$`; no se extiende por analogía a joints u otras restricciones que no son estos contactos.
- El cálculo de `e_pair` no prueba qué plano concreto produjo `planeId=1` del callback del fixture S3.
- No se volvió a ejecutar el fixture Node ni se instrumentó el solver en esta auditoría de materiales.

## Identificadores reproducibles del paquete

- Versión declarada y verificada previamente: `node-haxball 2.3.0`.
- Ruta de API del paquete: `src/index.js` → bundle `src/api.js`.
- SHA-256 `src/api.js`: `c7214def0fafab88eaab8ddc217c28af322d4d4c176fa3e259e56ba492b656b9` (no se alteró el archivo).
- SHA-256 `package.json`: `2395F5AFDDC025A4852BB6A8A7DEB6D4D6C0984EBE7EBF768403B888A6AB2CB9`.
- SHA-256 del `baseline.json` del wrapper de referencia: `74E7E0F832A6E91D17765F1419199374209C5EBE7156AE26BC80355D67765CA8`.
