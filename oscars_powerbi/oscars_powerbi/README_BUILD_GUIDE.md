# Oscars Power BI Project - Build Guide

I can't generate a `.pbix` directly, so this package gives you everything to assemble one in about 30 minutes: a clean star schema, DAX measures, Power Query loaders and a page-by-page dashboard spec.

## 1. What's in the package

| File | Purpose |
|---|---|
| `data/Fact_Nominations.csv` | One row per nomination (12,137) |
| `data/Dim_Ceremony.csv` | Ceremony/year table - use as your date table (98 rows) |
| `data/Dim_Category.csv` | Category, class, main-category flag (130 rows) |
| `data/Dim_Film.csv` | Distinct films (5,265) |
| `data/Dim_Nominee.csv` | Distinct people/companies (9,317) |
| `data/Bridge_Nomination_Film.csv` | Nomination <-> Film (many-to-many) |
| `data/Bridge_Nomination_Nominee.csv` | Nomination <-> Nominee (many-to-many) |
| `data/QA_*.csv` | Source reconciliation and data-quality log |
| `measures.dax` | All measures |
| `load_tables.pq` | Power Query loaders with types |

## 2. Why this model (the experiment)

I compared both source files before choosing a base:

- **`full_data.csv` is the base.** It has IMDb IDs, class, citations and every row (12,137).
- **`the_oscar_award.csv` is a flattened subset.** 11,240 rows, 6 exact duplicates, 5 blank winner flags, 363 blank films, and most SciTech/Special entries missing. It splits multi-film nominations into separate rows, so counting its rows overstates film-level nominations and understates others.
- **Where they overlap they agree.** Best Picture: 612 titles in each, zero titles in only one, identical winners.
- Winner is blank (not `False`) for losers in `full_data`; it is converted to 1/0 here.

Counting caveat: `full_data` has 3,515 winner rows versus 2,600 in the smaller file, because the larger one includes honorary, SciTech and special awards plus each co-nominee row.

## 3. Load and relate

1. Home -> Get Data -> Blank Query. Create the `DataFolder` parameter, `fnLoadCsv`, then the 7 table queries from `load_tables.pq`.
2. Model view -> create these relationships (all single direction, one-to-many, from the dimension side):

```
Dim_Ceremony[CeremonyNumber]  1 -> *  Fact_Nominations[CeremonyNumber]
Dim_Category[CategoryKey]     1 -> *  Fact_Nominations[CategoryKey]
Fact_Nominations[NominationID] 1 -> * Bridge_Nomination_Film[NominationID]
Fact_Nominations[NominationID] 1 -> * Bridge_Nomination_Nominee[NominationID]
Dim_Film[FilmKey]             1 -> *  Bridge_Nomination_Film[FilmKey]
Dim_Nominee[NomineeKey]       1 -> *  Bridge_Nomination_Nominee[NomineeKey]
```

3. Set a hierarchy on Dim_Ceremony: `Era > Decade > YearLabel`.
4. Sort `Dim_Ceremony[YearLabel]` by `CeremonyNumber`.
5. Hide key columns (CategoryKey, FilmKey, NomineeKey, NominationID) from report view.
6. Create a `_Measures` table and paste `measures.dax`.

Film- and person-level visuals filter through the bridges; the `Film ... (via Bridge)` measures use `CROSSFILTER` so they work on a Film or Nominee table visual.

## 4. Dashboard spec (4 pages)

**Page 1 - Overview**
- Cards: Nominations, Wins, Win Rate %, Films Nominated, Persons Nominated
- Line: Nominations by CeremonyYear, with Rolling 5 Ceremony Avg
- Column: Nominations by Decade, legend = Class
- Slicers: Era, Class, Is Main Category

**Page 2 - Categories**
- Bar: Nominations by CanonicalCategory (Top N 15)
- Matrix: Decade x Class, values Nominations and Win Rate %
- Decomposition tree: Class > Category > Decade

**Page 3 - Films**
- Table: Title, Film Nominations (via Bridge), Film Wins (via Bridge), Film Rank by Wins; filter Rank <= 20
- Scatter: Nominations vs Wins per film (size = nominations)
- Slicer: Decade

**Page 4 - People and data quality**
- Table: top nominees by Nominee Rank by Wins (filter NomineeType = Person)
- Cards: DQ Nominations Without Film, DQ Unlinked Nominees
- Table: `QA_Source_Reconciliation` (row_diff by ceremony)

Use one consistent palette (gold for wins, a neutral gray for nominations) and the `Headline` measure as a dynamic subtitle.

## 5. Known limitations

- 842 nominee records have no IMDb ID (mostly early years and companies); they are keyed by name, so spelling variants could double-count a person.
- 1,280 nominations have no film (SciTech and Special awards). Film visuals exclude them by design.
- Ceremony 1 spans 1927/28; `CeremonyYear` is set to 1929.
- Win Rate % mixes categories with several winners (ties, co-nominee rows); use it within a category for cleaner reading.
