# Sesjon 1 — Den moderne datastakken og dbt sin rolle

**Varighet:** 3 timer  
**Datasett:** jaffle-shop (`https://github.com/dbt-labs/jaffle-shop`)  
**Mål:** Alle deltakere forlater rommet med dbt installert, `dbt debug` uten feil, og har kjørt sin første modell.

---

## Deltakernotater

- **ETL-utviklere:** Start med deres verden — stored procedures, SSIS, DataStage. Navngi smerten de kjenner. Ikke presenter dbt som en erstatning for kompetansen deres; presenter det som et bedre hjem for den.
- **Tekniske deltakere:** De vil gå raskt gjennom oppsett. Ha øvelse 2 klar til dem.
- **Forretningsbrukere:** De trenger «hvorfor» fra blokk 1. «Hvordan» i blokk 3–4 vil være ukjent — det er greit. Jobben deres i dag er å forstå hva som bygges, ikke å bygge det.

---

## Blokk 1 — Den gamle verden vs. den nye (30 min)

### Åpningsspørsmål

Spør rommet før du presenterer noe som helst:

> «Hvordan fungerer transformasjon der dere jobber i dag?»

Lytt etter: stored procedures, SSIS-pakker, Informatica-arbeidsflyter, Python-skript, manuelle Excel-overføringer. Bruk svarene deres som materiale for de neste 30 minuttene. Du presenterer ikke for dem — du oversetter erfaringene deres til et nytt vokabular.

### ETL-verdenen — hva som er reelt ved den

- Logikk bor i verktøyet (Informatica, SSIS, DataStage) eller i stored procedures i databasen
- Bygget av folk som kjenner dataene godt — den kunnskapen er reell og verdifull
- Ofte stabil i årevis, noe som er en genuin prestasjon
- Men: umulig å versjonere («hva endret seg sist tirsdag klokken 15?»), ingen systematisk måte å teste på, avhengigheter usynlige inntil noe bryter
- «Det fungerer, ikke rør det» er ikke latskap — det er rasjonelt når du ikke trygt kan resonnere om konsekvensene av en endring
- Kunnskapen bor i folk, ikke i filer. Når personen slutter, blir pipelinen arkeologi

### Hvorfor ELT ble levedyktig

- Skylagre (BigQuery, Snowflake, Redshift) er nå billige og raske nok til å kjøre transformasjon inne i lageret
- Det betyr at transformasjonslogikk kan bo i filer, i et repo, under versjonskontroll
- SQL er grensesnittet — ingenting nytt å lære for folk som allerede kan SQL
- dbt er verktøyet som gjør dette disiplinert og produktivt

### Skiftet — tegn dette på tavlen

```
ETL:  Kilde → [Ekstrakt + Transform] → Last → Lager
                  ^
                  logikk bor her, utenfor lageret

ELT:  Kilde → Last (rå) → Lager → [Transformer med dbt] → Marts
                                              ^
                                              logikk bor her, i SQL-filer, i Git
```

### Én-setnings-ankeret

> «I ETL transformerer du data på vei inn. I ELT laster du rå data først og transformerer dem inne i lageret. dbt styrer det transformasjonslaget.»

Skriv dette på tavlen. La det stå der resten av sesjonen.

---

## Blokk 2 — Hva dbt faktisk gjør (30 min)

### Én-linjes definisjonen

> dbt tar SELECT-setninger og gjør dem om til tabeller eller views i lageret ditt — i riktig rekkefølge, med tester og dokumentasjon innebygd.

Bygg videre derfra. Ikke front-load alt — forankre på denne setningen og legg til lag.

### Hva dbt er

- Et transformasjonsrammeverk som kjører SQL SELECT-setninger
- Det finner ut rekkefølgen de skal kjøres i basert på hvordan modeller refererer til hverandre (DAG-en)
- Det pakker inn disse SELECT-ene i CREATE TABLE- eller CREATE VIEW-setninger automatisk
- Det legger til testing, dokumentasjon og lineage oppå det

### Hva dbt ikke er

- Det henter ikke data fra kilder — det er ditt ingestionsverktøy (Fivetran, Airbyte, egne pipelines)
- Det laster ikke data — rå data må allerede ligge i BigQuery før dbt kjøres
- Det er ikke en planlegger — det kjører når du ber det om det, eller når en orkestrator ber det om det

```
                    ┌─────────────────────────────────────────┐
                    │            DIN DATASTAKK               │
                    │                                         │
  Kilder ───────► Ingestionsverktøy ──► BigQuery (rå) ──────► dbt ────► BI-verktøy
  (Postgres,      (Fivetran,            (tabeller lastet      (transformer  (Looker,
   API-er,         Airbyte,              av ingestion)         inne i BQ)    Tableau)
   filer)          egendefinert)                                                  │
                    │                                         │
                    └─────────────────────────────────────────┘
                                   dbt bor her ────────────────►
```

### Programvareutviklingsvinkelen

Dette er det som er nytt for ETL-utviklere — og det som får tekniske deltakere til å nikke:

- Modeller er `.sql`-filer i en mappe. De bor i Git. De blir gjennomgått. De har historikk.
- Du kan bygge hele prosjektet på nytt i et ferskt miljø på noen minutter
- Hvis noe bryter, ser du nøyaktig hva som endret seg, når, og av hvem
- Dette er hvordan programvareteam har jobbet i tiår. dbt bringer det til datatransformasjon.

**For forretningsbrukere:** koble dette til resultater de bryr seg om. «Når en analytiker endrer hvordan omsetning beregnes, går den endringen gjennom en gjennomgang før den når produksjon. Det finnes en logg over det. Det er det versjonskontroll gir deg.»

---

## Blokk 3 — Oppsett (60 min)

> **Merknad for fasilitator:** Du har ikke tilgang til BigQuery-miljøet. Din tekniske partner eier denne blokken praktisk sett — de feilsøker, du forklarer hva som skjer og hvorfor. Orienter dem på forhånd om feilmodusene nedenfor.

### Sjekkliste før sesjonen (bekreft med teknisk partner før sesjon 1)

- [ ] Python 3.9–3.11 tilgjengelig på alle deltakermaskiner
- [ ] BigQuery-prosjektnavn bekreftet
- [ ] Navnekonvensjon for datasett bekreftet (anbefalt: `dbt_<fornavn>` per deltaker)
- [ ] Autentiseringsmetode bekreftet: `gcloud auth application-default login` ELLER service account JSON-nøkkel
- [ ] Deltakere har IAM-roller: `BigQuery Data Editor` + `BigQuery Job User`
- [ ] jaffle-shop-repo kloner rent og `dbt seed` kjører uten feil (testet av partner)
- [ ] Ferdigbygget `profiles.yml`-mal klar til å dele ved behov

### Steg 1 — Installer dbt (10 min)

```bash
pip install dbt-core dbt-bigquery
dbt --version
```

Suksess ser ut som en versjonstreng skrevet ut for både `dbt-core` og `dbt-bigquery`.

**Vanlige feil:**
- Python-versjonsfeil → sjekk `python --version`, trenger 3.9–3.11
- pip ikke funnet på Windows → bruk `py -m pip install ...`
- Tillatelsefeil → legg til `--user`-flagg eller bruk et virtuelt miljø

### Steg 2 — Autentiser med BigQuery (15 min)

```bash
gcloud auth application-default login
```

Dette åpner en nettleser. Deltakeren må logge inn med Google-kontoen som har tilgang til kursprosjektet i BigQuery.

**Hvis gcloud ikke er installert:** bruk service account JSON-nøkkelmetoden. Teknisk partner bør ha denne filen klar.

```yaml
# profiles.yml — reservemetode med service account
jaffle_shop:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account
      project: DITT_PROSJEKT_ID
      dataset: dbt_fornavn
      keyfile: /sti/til/nokkelfil.json
      threads: 4
```

### Steg 3 — Klon kursrepoet og initialiser prosjektet (15 min)

```bash
git clone https://github.com/dbt-labs/jaffle-shop
cd jaffle-shop
```

Gå gjennom prosjektstrukturen sammen:

```
jaffle-shop/
├── dbt_project.yml       # prosjektkonfig — navn, versjon, mappeinnstillinger
├── profiles.yml          # tilkoblingskonfig — bor her eller i ~/.dbt/
├── models/               # SQL-filer — her skjer arbeidet
│   ├── staging/
│   └── marts/
├── seeds/                # CSV-filer lastet som tabeller av dbt seed
├── tests/                # egendefinerte (singulære) test-SQL-filer
└── macros/               # gjenbrukbare Jinja-funksjoner
```

Påpek at `profiles.yml` kan bo i prosjektmappen (praktisk) eller i `~/.dbt/` (standard — legitimasjon havner ikke i Git). For kurset er prosjektnivåfilen greit.

### Steg 4 — dbt debug (10 min)

```bash
dbt debug
```

Alt grønt betyr at prosjektet kan koble til BigQuery og alt er konfigurert riktig. Dette er «er vi klare?»-kommandoen — si til deltakerne at de skal kjøre den når som helst noe føles feil.

**Vanlige feil:**
- Innrykningsfeil i `profiles.yml` — YAML er nådeløs, bruk mellomrom, ikke tabulatorer
- Datasett eksisterer ikke — opprett det i BigQuery-konsollen, eller dbt vil forsøke å opprette det (krever riktige IAM-tillatelser)
- Feil prosjekt-ID — sjekk mot BigQuery-konsollens URL

### Steg 5 — Last inn seed-data (10 min)

```bash
dbt seed
```

Dette laster CSV-filene i `seeds/` som tabeller inn i BigQuery. I jaffle-shop er dette de rå kildetabellene: `customers`, `orders`, `order_items`, `products`, `stores`, `supplies`.

Bekreft i BigQuery-konsollen at tabellene dukket opp i deltakerens datasett.

> **For rommet:** «I et ekte prosjekt ville du aldri laste rå data på denne måten — ingestionsverktøyet ditt gjør det. Vi bruker seeds her fordi det gjør kurset selvforsynt. Vi snakker om det riktige mønsteret i sesjon 2.»

---

## Blokk 4 — Din første modell (60 min)

### Introduser datasettet (10 min)

Åpne seed-tabellene i BigQuery sammen. Bruk noen minutter på å la deltakerne bla gjennom dataene — hvordan ser en ordre ut? Hva er i `order_items`? Hvilke statuser finnes i `orders`?

```
customers:   id, name
orders:      id, customer_id, store_id, ordered_at, subtotal, tax_paid, order_total
order_items: id, order_id, product_id
products:    id, name, price, type
stores:      id, name, opened_at, tax_rate
supplies:    id, product_id, name, cost, perishable
```

Påpek noen ting bevisst: statuser med blandet store/små bokstaver, noen nullverdier, det faktum at `order_items` er broen mellom `orders` og `products`. Dette vil ha betydning når du kommer til testing i sesjon 3.

### Kjør de eksisterende modellene (10 min)

```bash
dbt run
```

dbt vil bygge de eksisterende jaffle-shop-modellene. Gå til BigQuery og finn utdatatabellene i deltakerens datasett. La dette synke inn: de kjørte én kommando og tabeller dukket opp i lageret.

### Åpne en modellfil og les den sammen (10 min)

Åpne `models/staging/stg_orders.sql`. Les gjennom den sammen:

- Den velger fra en seed-tabell ved hjelp av `source()`
- Den gir kolonner nye navn og kaster dem til riktige typer
- Den gjør ingenting annet — ingen joins, ingen forretningslogikk

```sql
with source as (
    select * from {{ source('ecom', 'raw_orders') }}
),

renamed as (
    select
        id as order_id,
        customer as customer_id,
        ordered_at,
        store_id,
        subtotal / 100.0 as subtotal,
        tax_paid / 100.0 as tax_paid,
        (subtotal + tax_paid) / 100.0 as amount
    from source
)

select * from renamed
```

Forklar `source()` kort — det refererer til en rå tabell deklarert i `sources.yml`. Du går i dybden på dette i sesjon 2. For nå: `source()` = rå tabell, `ref()` = dbt-modell.

### Introduser `ref()` — det viktigste enkeltbegrepet i dbt (15 min)

Åpne `models/marts/customers.sql`. Finn hvor det bruker `ref()`:

```sql
with customers as (
    select * from {{ ref('stg_customers') }}
),
orders as (
    select * from {{ ref('stg_orders') }}
),
...
```

Nøkkelpunkter:
- `ref()` er hvordan modeller erklærer avhengigheter til hverandre — ikke hardkodede tabellnavn
- dbt leser disse referansene og bygger kjørerekkefølgen automatisk
- Hvis du kjører `dbt run`, vil `stg_customers` og `stg_orders` alltid kjøres før `customers`
- Hvis du flytter eller gir nytt navn til en modell, holder `ref()` ting koblet

Vis hva `ref()` kompileres til:

```sql
-- du skriver:
select * from {{ ref('stg_orders') }}

-- dbt kompilerer til:
select * from `ditt-prosjekt.dbt_fornavn.stg_orders`
```

Skjemaet (`dbt_fornavn`) injiseres fra profilen. I produksjon ville det vært et annet skjema. Du skriver én SQL-setning som fungerer overalt.

### Vis DAG-en (15 min)

```bash
dbt docs generate
dbt docs serve
```

Åpne lineage-grafen. Avhengighetstreet genereres automatisk fra `ref()`-kallene i modellene. Ingen konfigurasjon — bare referanser.

```
raw_customers ──► stg_customers ──┐
                                  ├──► customers (mart)
raw_orders ──────► stg_orders ────┤
                                  └──► orders (mart)
raw_order_items ─► stg_order_items ─► (brukt i mart-joins)
raw_products ────► stg_products ───► (brukt i mart-joins)
```

For ETL-utviklere: «Dette er avhengighetsgrafen dere alltid har måttet vedlikeholde manuelt eller bære i hodet. dbt genererer den fra koden.»

---

## Øvelser

### Øvelse 1 — Veiledet (gjøres sammen i blokk 4)

Følg gjennomgangen ovenfor. Alle skal fullføre blokk 4 med:
- `dbt seed` fullført
- `dbt run` vellykket
- `dbt docs serve` åpen og lineage-grafen synlig

### Øvelse 2 — Selvstendig (siste 15 min, eller hjemmelekse)

Legg til en ny staging-modell for `supplies`-tabellen som foreløpig ikke har en.

Opprett `models/staging/stg_supplies.sql`:
- Velg fra `{{ source('ecom', 'raw_supplies') }}`
- Gi nytt navn til `id` → `supply_id`
- Gi nytt navn til `product_id` → `product_id` (ingen endring, men velg det eksplisitt)
- Kast `cost` fra heltall-øre til desimal: `cost / 100.0 as cost`
- Behold `name`, `perishable` som de er

Kjør `dbt run -s stg_supplies` og bekreft at modellen bygges.

**Strekk:** Opprett `models/staging/stg_order_items.sql` etter samme mønster, lag deretter en enkel mart-modell `models/marts/fct_product_revenue.sql` som joiner `stg_order_items` og `stg_products` ved hjelp av `ref()` og beregner total omsetning per produkt.

Forventede utdatakolonner: `product_id`, `product_name`, `product_type`, `total_items_sold`, `total_revenue`

---

## Sjekkliste for nøkkelbegreper

Innen slutten av sesjon 1 skal deltakerne kunne svare på:

- [ ] Hva er forskjellen mellom ETL og ELT?
- [ ] Hva gjør dbt? Hva gjør det ikke?
- [ ] Hva er en dbt-modell?
- [ ] Hva gjør `ref()` og hvorfor er det viktig?
- [ ] Hva er DAG-en og hvordan bygges den?
- [ ] Hva gjør `dbt run` egentlig?

---

## Vanlige spørsmål og svar

**«Hvordan er dette forskjellig fra bare å skrive stored procedures?»**  
SQL-en er lik. Forskjellen er alt rundt: filen er i Git, du kan se historikken, den har en deklarert avhengighetsgraf, du kan teste den, og du kan bygge hele greia på nytt i et ferskt miljø på fem minutter.

**«Hva med inkrementelle laster? Vi har tabeller med milliarder av rader.»**  
Godt spørsmål — det er det `incremental`-materialiseringen er for. Vi dekker materialiseringstyper i sesjon 2.

**«Hvor passer planlegging inn? Hvem kjører `dbt run` i produksjon?»**  
En orkestrator — Airflow, Cloud Composer, eller dbt Clouds innebygde planlegger. Vi dekker dette i sesjon 5. For nå kjører du det manuelt.

**«Vi bruker dbt Cloud på jobben — hvorfor bruker vi Core?»**  
SQL-en du skriver er identisk. Core lærer deg grunnleggende uten det administrerte laget på toppen. I sesjon 5 kobler vi alt du har lært til hvordan dbt Cloud fungerer.

---

## Forberedelsenotater (fra 6-timers forberedelsesguiden)

- Bekreft sjekklisten for oppsett med teknisk partner minst 5 dager før sesjonen
- Test at `dbt seed` og `dbt run` fungerer på kursprosjektet i BigQuery (via partner)
- Forbered en ferdigbygget `profiles.yml`-mal deltakerne kan kopiere og lime inn — reduserer oppsettfriksjon betydelig
- Orienter teknisk partner: jobben deres under blokk 3 er å feilsøke lokalt mens du kjører rommet
- Ha `solutions`-grenen av kursrepoet klar med øvelse 2 fullført, klar til å dele ved starten av sesjon 2
