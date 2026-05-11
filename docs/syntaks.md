## Kommandoer

| Kommando | funksjon |
| --- | --- |
| `debug`| Sjekk tilkobling og konfigurasjon |
| `run` | Kjør en eller flere modeller |
| `test`| Test en eller flere modeller |
| `build`| Kjør og test en eller flere modeller |
| `docs` | Kommandoer knyttet til dokumentasjon (`generate` og `serve`)
| `seed` | Last opp seed-filer til database

## Viktige filer og mapper
| navn | funksjon |
| ---  | --- |
| `profiles.yml` | Definerer tilkobling og authentisering mot databasen/databasene |
| `dbt_project.yml` | Definerer konfigurasjon og struktur for selve prosjektet |
| `manifest.json` | Inneholder generert definisjon av prosjektet; tabeller, lineage, tester, relasjoner osv |
| `models/` | Alle modellene som er definert (views, tables)
| `seeds/` | Referansedata i CSV-format, som kan lastes til databasen |
| `analyses/` | Ad-hoc spørringer
| `macros/` | Gjenbrukbare funksjoner
| `target/`| Generert kode fra kjøring av modellene

## Ønskede egenskaper
- Idempotens: En operasjon kan gjenomføres 1, 2 eller 100 ganger uten at det påvirker resultatet utover første
- Deklarativ: Man beskriver ønsket tilstand, systemet tar seg av hvordan man kommer dit
  - Motsatt av Imperativ: Man beskriver nøyaktig prosedyre, steg for steg
- Lesbare endringer og enkel triage: "det gikk til h.. på mandag kl 14, hvilken endring ble gjort?"
- Enkelt å forstå hva som påvirkes
- Trygt samarbeid
- Enkel tilbakerulling
- Standardisering
- Automatisering
- Testbarhet
- Dokumentasjon

## Vanlig støttefunksjonalitet
- Versjonskontroll: Alle datamodeller definert som kode, hvor alle versjoner er lagret i et repo
- CICD: Automatiserer prosessen med å ta modeller fra `utvikling` -> `test` -> `prod`
  - Isolerte miljøer
  - Testing
  - Linting
  - Opprydding
- Orkestrering: Hva skal kjøre når, starte jobber
