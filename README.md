# Swimming (Playdate C)

Progetto riscritto da Lua a C per Playdate SDK.

## TODO Ottimizzazioni

- [ ] Ridurre draw call totali (soprattutto griglia superficie acqua e particelle).
- [ ] Introdurre LOD per la griglia acqua (meno segmenti quando lontani).
- [ ] Limitare/cap delle particelle renderizzate per frame.
- [ ] Aggiungere culling più aggressivo prima della proiezione (frustum + distanza massima).
- [ ] Applicare early-out con bounding sphere per fish fuori vista.
- [ ] Separare meglio frequenza update/render (AI/onde a 10–20 Hz, rendering a 50 Hz).
- [ ] Interpolare solo la posizione visiva tra update lenti e render veloce.
- [ ] Ridurre uso di `drawScaledBitmap` runtime per fish.
- [ ] Pre-generare 2–3 varianti di scala sprite fish (small/medium/large).
- [ ] Cache frame-level di `sin/cos` usati più volte nello stesso frame.
- [ ] Evitare normalizzazioni non necessarie nei loop di update.
- [ ] Usare distanza quadrata al posto di `sqrt` dove possibile.
- [ ] Mantenere zero allocazioni in update/render (solo pool/array statici).
- [ ] Quantizzare angoli/onde quando possibile per riuso risultati.
- [ ] Ordinamento profondità fish approssimato solo quando necessario (non ogni frame).
