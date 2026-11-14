// =====================================================================
// POWER QUERY (M) - load all tables from the data folder
// Power BI Desktop -> Home -> Get Data -> Blank Query -> Advanced Editor
// Paste this, then change DataFolder to where you saved the "data" folder.
// Then right-click each query -> Reference is NOT needed; use the helper below.
// =====================================================================

// ---- 1. Parameter query (name it: DataFolder) ----
// "C:\Users\YOU\Documents\oscars_powerbi\data\"

// ---- 2. Function query (name it: fnLoadCsv) ----
(fileName as text, types as list) as table =>
let
    Source = Csv.Document(
        File.Contents(DataFolder & fileName),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    Typed = Table.TransformColumnTypes(Promoted, types)
in
    Typed

// ---- 3. One query per table (create 7 blank queries, paste each) ----

// Fact_Nominations
let
    T = fnLoadCsv("Fact_Nominations.csv", {
        {"NominationID", Int64.Type}, {"CeremonyNumber", Int64.Type},
        {"CategoryKey", type text}, {"IsWinner", Int64.Type},
        {"NomineeDisplay", type text}, {"Detail", type text},
        {"Note", type text}, {"Citation", type text},
        {"FilmCount", Int64.Type}, {"NomineeCount", Int64.Type},
        {"PrimaryFilmKey", type text}, {"NominationCount", Int64.Type}})
in T

// Dim_Ceremony
let
    T = fnLoadCsv("Dim_Ceremony.csv", {
        {"CeremonyNumber", Int64.Type}, {"YearLabel", type text},
        {"StartYear", Int64.Type}, {"CeremonyYear", Int64.Type},
        {"Decade", type text}, {"Era", type text}, {"CeremonyLabel", type text}})
in T

// Dim_Category
let
    T = fnLoadCsv("Dim_Category.csv", {
        {"CategoryKey", type text}, {"CanonicalCategory", type text},
        {"Category", type text}, {"Class", type text},
        {"IsMainCategory", Int64.Type}, {"IsHonoraryOrTech", Int64.Type}})
in T

// Dim_Film
let
    T = fnLoadCsv("Dim_Film.csv", {
        {"FilmKey", type text}, {"FilmId", type text}, {"Title", type text}})
in T

// Dim_Nominee
let
    T = fnLoadCsv("Dim_Nominee.csv", {
        {"NomineeKey", type text}, {"NomineeId", type text},
        {"NomineeName", type text}, {"NomineeType", type text}})
in T

// Bridge_Nomination_Film
let
    T = fnLoadCsv("Bridge_Nomination_Film.csv", {
        {"NominationID", Int64.Type}, {"FilmKey", type text}})
in T

// Bridge_Nomination_Nominee
let
    T = fnLoadCsv("Bridge_Nomination_Nominee.csv", {
        {"NominationID", Int64.Type}, {"NomineeKey", type text}})
in T

// ---- 4. Optional QA tables (load as-is, keep out of the report model) ----
// QA_Source_Reconciliation.csv, QA_Data_Quality_Log.csv
