#!/usr/bin/env python3
"""Write the reviewed Pune Metro reference dataset.

This file is the curated result of reading official pages and timetable
images on 4 November 2026. It does not scrape private endpoints and it does
not invent fares, train numbers, or per-station departure times.

Re-run after a manual review:

    python3 tool/build_dataset.py
"""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "data" / "pune_metro_dataset.json"

EXTRACTED_AT = "2026-11-04T08:30:00Z"


def osm(node_id: int, lat: float, lon: float, note: str) -> dict:
    return {
        "latitude": lat,
        "longitude": lon,
        "coordinate_verification": "secondary",
        "coordinate_source_key": "osm",
        "coordinate_notes": f"OpenStreetMap node {node_id}. {note}",
    }


def embed(lat: float, lon: float, note: str) -> dict:
    return {
        "latitude": lat,
        "longitude": lon,
        "coordinate_verification": "operator_map_embed",
        "coordinate_source_key": "pitcmrl-stations",
        "coordinate_notes": note,
    }


def station(
    code: str,
    name: str,
    status: str,
    status_verification: str,
    verification_status: str,
    source_key: str,
    *,
    coords: dict | None = None,
    aliases: list | None = None,
    notes: str | None = None,
    description: str | None = None,
    is_interchange: bool = False,
) -> dict:
    row = {
        "code": code,
        "name": name,
        "operational_status": status,
        "status_verification": status_verification,
        "verification_status": verification_status,
        "source_key": source_key,
        "address": None,
        "description": description,
        "opening_date": None,
        "is_interchange": is_interchange,
        "latitude": None,
        "longitude": None,
        "coordinate_verification": None,
        "coordinate_source_key": None,
        "coordinate_notes": None,
        "aliases": aliases or [],
        "notes": notes,
    }
    if coords:
        row.update(coords)
    return row


def alias(name: str, source_key: str, notes: str) -> dict:
    return {"name": name, "source_key": source_key, "notes": notes}


def build() -> dict:
    stations = [
        station(
            "MM-PCMC",
            "PCMC",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            coords=osm(
                10214268972,
                18.629319,
                73.803286,
                "Community name is Pimpri Chinchwad Municipal Corporation (PCMC). Not an official surveyed coordinate.",
            ),
            aliases=[
                alias(
                    "Pimpri Chinchwad Municipal Corporation",
                    "osm",
                    "OpenStreetMap name. Official pages use PCMC.",
                )
            ],
        ),
        station(
            "MM-STN",
            "Sant Tukaram Nagar",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            coords=osm(
                7944597690,
                18.614525,
                73.815746,
                "Name matches the official station name. Community-mapped coordinate.",
            ),
        ),
        station(
            "MM-BHO",
            "Bhosari (Nashik Phata)",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            coords=osm(
                7944597706,
                18.609303,
                73.820097,
                "Node name is Nashik Phata. Assigned because the official station name includes Nashik Phata. Not an official survey.",
            ),
            aliases=[
                alias("Bhosari (N.P.)", "mm-project-profile", "Abbreviation used on the project profile."),
                alias("Bhosari [Nashik Phata]", "mm-route-map", "Route-map spelling."),
                alias("Nashik Phata", "osm", "OpenStreetMap node name."),
            ],
        ),
        station(
            "MM-KAS",
            "Kasarwadi",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            coords=osm(7944597699, 18.599620, 73.827264, "Unique name match. Community-mapped coordinate."),
        ),
        station(
            "MM-PHU",
            "Phugewadi",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            coords=osm(7944584963, 18.591106, 73.831147, "Unique name match. Community-mapped coordinate."),
        ),
        station(
            "MM-DAP",
            "Dapodi",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            coords=osm(
                7944584975,
                18.583765,
                73.833766,
                "A second node tagged operator=Central Railway was not used because it identifies the railway station rather than the metro station.",
            ),
        ),
        station(
            "MM-BOP",
            "Bopodi",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            coords=osm(7944597711, 18.569661, 73.838103, "Unique name match. Community-mapped coordinate."),
        ),
        station(
            "MM-KHA",
            "Khadki",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            coords=osm(
                13644302877,
                18.562262,
                73.842083,
                "Operator tag on the node is Maha Metro. Community-mapped coordinate.",
            ),
        ),
        station(
            "MM-RNG",
            "Range Hill",
            "not_open",
            "official_inferred",
            "official_inferred",
            "mm-project-profile",
            coords=osm(
                7944584969,
                18.550287,
                73.845807,
                "OpenStreetMap spells the node Range Hills. Official pages spell it Range Hill.",
            ),
            aliases=[alias("Range Hills", "osm", "OpenStreetMap spelling.")],
            notes=(
                "The project profile marks every other Line 1 station (Open) and leaves Range Hill unmarked. "
                "The homepage on 4 Nov 2026 reported 29 operational stations out of 30 line-stations. "
                "Range Hill is recorded as not open to passengers. This is an inference, not an explicit closure notice."
            ),
        ),
        station(
            "MM-SHN",
            "Shivaji Nagar",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            coords=osm(
                11097510271,
                18.532172,
                73.849660,
                "Maha Metro node. A separate Pink Line node exists for the Line 3 station and was not used here.",
            ),
            aliases=[alias("Shivajinagar", "mm-route-map", "Route map writes Shivaji Nagar as two words; some maps use one word.")],
            is_interchange=True,
            notes="Purple Line station. Not the same record as Line 3 Shivaji Nagar.",
        ),
        station(
            "MM-DCT",
            "District Court",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            aliases=[
                alias(
                    "Civil Court",
                    "mm-route-map",
                    "One route-map listing uses Civil Court where the project profile and the other listing use District Court.",
                )
            ],
            is_interchange=True,
            notes=(
                "Shared by the Purple and Aqua lines. No single coordinate is stored: OpenStreetMap has separate "
                "Purple Line and Aqua Line platform nodes, and those were not collapsed into one pin."
            ),
        ),
        station(
            "MM-KBP",
            "Kasba Peth",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            coords=osm(
                12211880200,
                18.521375,
                73.859623,
                "Node name is Kasba Peth.",
            ),
        ),
        station(
            "MM-MAN",
            "Mandai",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            aliases=[
                alias(
                    "Mahatma Phule Mandai",
                    "mm-route-map",
                    "Route-map name at this position. Treated as an alternate name, not a second station.",
                )
            ],
            notes="No coordinate was published officially, and OpenStreetMap had no unique node with this name.",
        ),
        station(
            "MM-SWG",
            "Swargate",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            coords=osm(
                7944597710,
                18.499745,
                73.857460,
                "Exact name match. A nearby node named Swargate North was not used as this station's coordinate.",
            ),
        ),
        station(
            "MM-VAN",
            "Vanaz",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            coords=osm(9599243853, 18.507185, 73.805195, "Unique name match. Community-mapped coordinate."),
        ),
        station(
            "MM-ANA",
            "Anand Nagar",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            coords=osm(
                9599243854,
                18.509572,
                73.814075,
                "OpenStreetMap spells the node Anandnagar.",
            ),
            aliases=[alias("Anandnagar", "osm", "OpenStreetMap spelling.")],
        ),
        station(
            "MM-IDC",
            "Ideal Colony",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            aliases=[
                alias(
                    "Paud Phata",
                    "mm-route-map",
                    "Route map uses Paud Phata in the same sequence position as Ideal Colony on the project profile. Not an explicit rename notice.",
                )
            ],
            notes="Coordinate left empty. An OpenStreetMap node named Paud Phata sits between Anand Nagar and Nal Stop, but the names differ, so that pin was not applied.",
        ),
        station(
            "MM-NAL",
            "Nal Stop",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            coords=osm(
                13652090805,
                18.505488,
                73.824285,
                "Unique node named Nal Stop, tagged Maha Metro. A separate SNDT College node was not copied onto this station.",
            ),
            aliases=[
                alias(
                    "S.N.D.T College",
                    "mm-route-map",
                    "Route map uses S.N.D.T College in the same sequence position as Nal Stop on the project profile. Not an explicit rename notice.",
                )
            ],
        ),
        station(
            "MM-GAR",
            "Garware College",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            coords=osm(9599243857, 18.511989, 73.838050, "Unique name match. Community-mapped coordinate."),
        ),
        station(
            "MM-DEC",
            "Deccan Gymkhana",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            coords=osm(11097527725, 18.516448, 73.844446, "Unique name match. Community-mapped coordinate."),
        ),
        station(
            "MM-CSU",
            "Chhatrapati Sambhaji Udyan",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            coords=osm(11097527718, 18.520081, 73.847383, "Unique name match. Community-mapped coordinate."),
        ),
        station(
            "MM-PMC",
            "PMC",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            coords=osm(
                7944584980,
                18.522744,
                73.853350,
                "OpenStreetMap name is PMC Bhavan. Official project profile says PMC.",
            ),
            aliases=[alias("PMC Bhavan", "osm", "OpenStreetMap name.")],
        ),
        station(
            "MM-MGP",
            "Mangalwar Peth",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            aliases=[
                alias(
                    "R.T.O Pune",
                    "mm-route-map",
                    "Route map uses R.T.O Pune in the same sequence position as Mangalwar Peth. Not an explicit rename notice.",
                )
            ],
            notes="No official coordinate and no unique OpenStreetMap name match.",
        ),
        station(
            "MM-PRS",
            "Pune Railway Station",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            aliases=[alias("Pune Rly. Station", "mm-route-map", "Route-map abbreviation.")],
            notes="The Indian Railways station coordinate was not used as a metro pin. No metro-station node with this name was found.",
        ),
        station(
            "MM-RHC",
            "Ruby Hall Clinic",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            coords=osm(7944584984, 18.532718, 73.877749, "Unique name match. Community-mapped coordinate."),
        ),
        station(
            "MM-BUN",
            "Bund Garden",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            coords=osm(11699340649, 18.540593, 73.883439, "Unique name match. Community-mapped coordinate."),
        ),
        station(
            "MM-YER",
            "Yerawada",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            coords=osm(
                11699340652,
                18.545317,
                73.886688,
                "OpenStreetMap spelling is Yerwada. Official pages use Yerawada.",
            ),
            aliases=[alias("Yerwada", "osm", "OpenStreetMap spelling.")],
        ),
        station(
            "MM-KAL",
            "Kalyani Nagar",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            coords=osm(11699340655, 18.544481, 73.905698, "Unique name match. Community-mapped coordinate."),
        ),
        station(
            "MM-RAM",
            "Ramwadi",
            "operational",
            "official",
            "official",
            "mm-project-profile",
            coords=osm(11699340657, 18.557028, 73.908563, "Operator tag Maha Metro. Community-mapped coordinate."),
        ),
        station(
            "MM-CHI",
            "Chinchwad",
            "under_construction",
            "official",
            "official",
            "mm-line-1b",
            coords=osm(13647412355, 18.639173, 73.794931, "Listed on the project profile and tagged Maha Metro on OpenStreetMap."),
            notes="Line 1A extension station. The Line 1B page says the PCMC–Nigdi extension is under construction. Not marked open.",
        ),
        station(
            "MM-AKU",
            "Akurdi",
            "under_construction",
            "official",
            "official",
            "mm-line-1b",
            coords=osm(13647412354, 18.651160, 73.784747, "Tagged Maha Metro on OpenStreetMap."),
        ),
        station(
            "MM-NIG",
            "Nigdi",
            "under_construction",
            "official",
            "official",
            "mm-line-1b",
            coords=osm(13647412352, 18.658399, 73.778398, "Tagged Maha Metro on OpenStreetMap."),
        ),
        station(
            "MM-BKS",
            "Bhakti Shakti",
            "under_construction",
            "official",
            "official",
            "mm-line-1b",
            coords=osm(13647412351, 18.662561, 73.774574, "Tagged Maha Metro on OpenStreetMap."),
        ),
        station(
            "MM-MKY",
            "Market Yard",
            "planned",
            "official",
            "official",
            "mm-line-1b",
            coords=osm(13659087340, 18.487786, 73.857518, "Named in the sanctioned Swargate–Katraj station list. Tagged Maha Metro on OpenStreetMap."),
            notes="Sanctioned underground extension. Not open to passengers.",
        ),
        station(
            "MM-PAD",
            "Padmavati",
            "planned",
            "official",
            "official",
            "mm-line-1b",
            coords=osm(13659087385, 18.461007, 73.858097, "Named in the sanctioned station list. Tagged Maha Metro on OpenStreetMap."),
        ),
        station(
            "MM-KAT",
            "Katraj",
            "planned",
            "official",
            "official",
            "mm-line-1b",
            coords=osm(13659088612, 18.446573, 73.859009, "Named in the sanctioned station list. Tagged Maha Metro on OpenStreetMap."),
        ),
        station(
            "MM-KBD",
            "Kothrud Bus Depot",
            "planned",
            "official",
            "official",
            "mm-line-2ab",
            coords=osm(
                7944597709,
                18.508126,
                73.792952,
                "Official station list name. A separate OpenStreetMap node named only Kothrud was not used.",
            ),
        ),
        station(
            "MM-CHC",
            "Chandani Chowk",
            "planned",
            "official",
            "official",
            "mm-line-2ab",
            coords=osm(13654973659, 18.507636, 73.786698, "Station-list spelling Chandani. The page heading also writes Chandni."),
            aliases=[
                alias(
                    "Chandni Chowk",
                    "mm-line-2ab",
                    "Heading spelling on the same official page. Station table uses Chandani Chowk.",
                )
            ],
        ),
        station("MM-VIM", "Viman Nagar", "planned", "official", "official", "mm-line-2ab", coords=osm(13651468961, 18.561482, 73.920388, "Official list name. Community-mapped coordinate.")),
        station("MM-SOM", "Somnath Nagar", "planned", "official", "official", "mm-line-2ab", coords=osm(13651468960, 18.562864, 73.928401, "Official list name. Community-mapped coordinate.")),
        station("MM-KBY", "Kharadi Bypass", "planned", "official", "official", "mm-line-2ab", coords=osm(13650679304, 18.562359, 73.937809, "Official list name. Community-mapped coordinate.")),
        station(
            "MM-TUL",
            "Tulaja Bhavani",
            "planned",
            "official",
            "official",
            "mm-line-2ab",
            coords=osm(
                13650679303,
                18.567097,
                73.946837,
                "OpenStreetMap name is Tuljabhavani Nagar. Official list says Tulaja Bhavani Station.",
            ),
            aliases=[alias("Tuljabhavani Nagar", "osm", "OpenStreetMap spelling.")],
        ),
        station("MM-UBA", "Ubale Nagar", "planned", "official", "official", "mm-line-2ab", coords=osm(13650679302, 18.572609, 73.955940, "Official list name. Community-mapped coordinate.")),
        station(
            "MM-UKR",
            "Upper Kharadi Road",
            "planned",
            "official",
            "official",
            "mm-line-2ab",
            coords=osm(
                13650679301,
                18.575658,
                73.962641,
                "OpenStreetMap abbreviates the official name as Upper Kharadi Rd.",
            ),
            aliases=[alias("Upper Kharadi Rd", "osm", "OpenStreetMap abbreviation.")],
        ),
        station("MM-WAG", "Wagheshwar Temple", "planned", "official", "official", "mm-line-2ab", coords=osm(13650652500, 18.580696, 73.978999, "Official list name. Community-mapped coordinate.")),
        station("MM-WGL", "Wagholi", "planned", "official", "official", "mm-line-2ab", coords=osm(13650652499, 18.580610, 73.983649, "Official list name. Community-mapped coordinate.")),
        station("MM-SID", "Siddharth Nagar", "planned", "official", "official", "mm-line-2ab", coords=osm(13650652498, 18.582664, 73.988709, "Official list name. Community-mapped coordinate.")),
        station(
            "MM-BAK",
            "Bakori Phata",
            "planned",
            "official",
            "official",
            "mm-line-2ab",
            notes="Coordinate is filled from the local OpenStreetMap extract when that file is present.",
        ),
        station("MM-VIT", "Vitthalwadi", "planned", "official", "official", "mm-line-2ab", coords=osm(13650652439, 18.598036, 74.004574, "Official list name. Community-mapped coordinate.")),
    ]

    line3_rows = [
        ("L3-01", "PMR 1", "Maan", "reported_open", 18.5791654, 73.6879852, "Maan village, near the metro depot in Hinjawadi."),
        ("L3-02", "PMR 2", "Maan - MIDC Circle, Phase II", "reported_open", 18.5841727, 73.6950536, "Near MIDC Circle in Hinjawadi Phase II."),
        ("L3-03", "PMR 3", "Maan Bus Depot", "reported_open", 18.5878977, 73.7023337, "Adjacent to the Maan bus depot in Hinjawadi."),
        ("L3-04", "PMR 4", "Hinjawadi Phase II - Circle II", "reported_open", 18.5944782, 73.7096912, "Near Hinjawadi Phase II, Circle II."),
        ("L3-05", "PMR 5", "Hinjawadi Phase II - Circle I", "reported_open", 18.5966158, 73.7172632, "Near Hinjawadi Phase II, Circle I."),
        ("L3-06", "PMR 6", "Padmabhushan Chowk", "reported_open", 18.5945896, 73.7274379, "Padmabhushan Chowk, Wakad."),
        ("L3-07", "PMR 7", "Shree Shiv Chhatrapati Shivaji Maharaj Chowk, Hinjawadi", "reported_open", 18.5923845, 73.7374066, "Shivaji Maharaj Chowk in Hinjawadi."),
        ("L3-08", "PMR 8", "Hinjawadi Phase I", "reported_open", 18.5909116, 73.746285, "Hinjawadi Phase I."),
        ("L3-09", "PMR 9", "Wakad Chowk", "reported_open", None, None, "Wakad Chowk on the Mumbai–Bengaluru highway. The operator page had no map embed."),
        ("L3-10", "PMR 10", "Shree Shiv Chhatrapati Sports Complex, Mahalunge", "reported_open", 18.5794173, 73.7617446, "Near Shiv Chhatrapati Sports Complex, Mahalunge."),
        ("L3-11", "PMR 11", "Mitcon Balewadi", "reported_open", 18.5749721, 73.7660563, "Near MITCON, Balewadi."),
        ("L3-12", "PMR 12", "R K Laxman Museum Balewadi", "reported_open", 18.574458, 73.7715713, "Near R K Laxman Museum, Balewadi."),
        ("L3-13", "PMR 13", "Balewadi High Street", "reported_closed", 18.5704141, 73.774852, "Balewadi High Street."),
        ("L3-14", "PMR 14", "Balewadi Phata", "reported_closed", 18.5642154, 73.7798481, "Balewadi Phata."),
        ("L3-15", "PMR 15", "Baner Gaon", "reported_closed", 18.5592815, 73.7905799, "Baner Gaon."),
        ("L3-16", "PMR 16", "Baner Pashan Link Road", "reported_closed", 18.5549601, 73.7977105, "Baner–Pashan Link Road."),
        ("L3-17", "PMR 17", "Aundh", "reported_open", 18.5503256, 73.8083801, "Aundh. The embedded map searches the locality name, so the pin may not be the station structure."),
        ("L3-18", "PMR 18", "Sakal Nagar", "reported_open", 18.5463522, 73.8198526, "Sakal Nagar."),
        ("L3-19", "PMR 19", "Savitribai Phule Pune University", "reported_open", 18.542486, 73.8266585, "Savitribai Phule Pune University. The embed searches the university, not necessarily the station building."),
        ("L3-20", "PMR 20", "Bhosale Nagar", "reported_closed", 18.536316, 73.8367825, "Bhosale Nagar. The operator description mentions the Reserve Bank of India office."),
        ("L3-21", "PMR 21", "Agriculture College", "reported_open", 18.5329714, 73.8415949, "Agriculture College. The embed searches the college name."),
        ("L3-22", "PMR 22", "Shivaji Nagar", "reported_closed", 18.5305464, 73.8485892, "Line 3 station. Separate from the Purple Line Shivaji Nagar station."),
        ("L3-23", "PMR 23", "District Court, Pune", "reported_open", 18.528453, 73.8558849, "Line 3 station named District Court, Pune. The embed place name is District Court Metro."),
    ]
    status_note = (
        "Name, code, order, and location text are from the operator station list. "
        "Passenger opening status is not on that list. It is taken from a Free Press Journal report published on 3 Nov 2026, "
        "which said 17 stations would open on 4 Nov 2026 and six would stay closed. "
        "Siemens Mobility's 3 Nov 2026 release confirms that passenger operations had commenced, but it does not list the closed stations."
    )
    for code, public_code, name, status, lat, lon, description in line3_rows:
        coords = None
        if lat is not None and lon is not None:
            coords = embed(
                lat,
                lon,
                "Latitude and longitude were read from the operator station page's embedded map URL. "
                "Several embeds search a locality or landmark rather than a surveyed station centroid.",
            )
        aliases = [alias(public_code, "pitcmrl-stations", "Operator station code as published.")]
        if code == "L3-13":
            aliases.append(alias("Balewadi High Street (Laxmi Nagar)", "fpj-line3", "Secondary report parenthetical. Not on the operator list."))
        if code == "L3-20":
            aliases.append(alias("Bhosale Nagar (RBI)", "fpj-line3", "Secondary report parenthetical. Operator description mentions RBI."))
        if code == "L3-09":
            notes = status_note + " Coordinate is the OpenStreetMap Pink Line node 7944597702 (18.590299, 73.757559), because the operator page had no embed."
            coords = osm(
                7944597702,
                18.5902986,
                73.7575587,
                "Line 3 node tagged Pune Metro Pink Line. Used only because the operator page published no coordinate. Pink is an OpenStreetMap network tag, not an official colour confirmed on PMRDA or the operator site.",
            )
        else:
            notes = status_note
        stations.append(
            station(
                code,
                name,
                status,
                "secondary",
                "operator_published",
                "pitcmrl-stations",
                coords=coords,
                aliases=aliases,
                notes=notes,
                description=description,
                is_interchange=code in {"L3-22", "L3-23"},
            )
        )

    attach_bakori(stations)

    orders = {
        "PPL": ("pcmc_to_swargate", "swargate_to_pcmc", [
            "MM-PCMC", "MM-STN", "MM-BHO", "MM-KAS", "MM-PHU", "MM-DAP", "MM-BOP",
            "MM-KHA", "MM-RNG", "MM-SHN", "MM-DCT", "MM-KBP", "MM-MAN", "MM-SWG",
        ]),
        "AQL": ("vanaz_to_ramwadi", "ramwadi_to_vanaz", [
            "MM-VAN", "MM-ANA", "MM-IDC", "MM-NAL", "MM-GAR", "MM-DEC", "MM-CSU",
            "MM-PMC", "MM-DCT", "MM-MGP", "MM-PRS", "MM-RHC", "MM-BUN", "MM-YER",
            "MM-KAL", "MM-RAM",
        ]),
        "PPL-N": ("pcmc_to_bhakti_shakti", "bhakti_shakti_to_pcmc", ["MM-CHI", "MM-AKU", "MM-NIG", "MM-BKS"]),
        "PPL-S": ("swargate_to_katraj", "katraj_to_swargate", ["MM-MKY", "MM-PAD", "MM-KAT"]),
        "AQL-W": ("vanaz_to_chandani_chowk", "chandani_chowk_to_vanaz", ["MM-KBD", "MM-CHC"]),
        "AQL-E": ("ramwadi_to_vitthalwadi", "vitthalwadi_to_ramwadi", [
            "MM-VIM", "MM-SOM", "MM-KBY", "MM-TUL", "MM-UBA", "MM-UKR",
            "MM-WAG", "MM-WGL", "MM-SID", "MM-BAK", "MM-VIT",
        ]),
        "L3": ("maan_to_district_court", "district_court_to_maan", [row[0] for row in line3_rows]),
    }

    line_stations = []
    for line_code, (forward, reverse, codes) in orders.items():
        for index, station_code in enumerate(codes, start=1):
            line_stations.append({
                "line_code": line_code,
                "station_code": station_code,
                "sequence_number": index,
                "direction": forward,
            })
        for index, station_code in enumerate(reversed(codes), start=1):
            line_stations.append({
                "line_code": line_code,
                "station_code": station_code,
                "sequence_number": index,
                "direction": reverse,
            })

    regular_note = (
        "Read from the English timetable image Time-Table-new-2-15Aug.jpg, titled New Time Table and marked "
        "W.E.F 15th August 2025. The Marathi image on the same official page states the same window, headways, "
        "travel times, and distances. The time-table page still displayed these images on 4 Nov 2026. "
        "No separate weekday, Saturday, or Sunday timetable was printed. "
        "Headways are published frequencies, not station departure times. "
        "No per-station departure table was printed, so none was generated."
    )

    dataset = {
        "dataset_version": "2026.11.04.1",
        "schema_version": 1,
        "extracted_at": EXTRACTED_AT,
        "operators": [
            {
                "key": "maha",
                "name": "Maharashtra Metro Rail Corporation Limited",
                "website": "https://www.punemetrorail.org/",
                "description": "Maha Metro operates Pune Metro Purple and Aqua lines. Published customer care: 1800 270 5501, customercare.pmrp@mahametro.org.",
            },
            {
                "key": "pitcmrl",
                "name": "Pune IT City Metro Rail Limited",
                "website": "https://punerimetro.in/",
                "description": (
                    "Special purpose vehicle named by PMRDA for the Hinjawadi–Shivajinagar DBFOT concession, "
                    "awarded to the joint venture of TRIL Urban Transport and Siemens Project Ventures. "
                    "punemetro.in identifies itself as this company. The PMRDA Line 3 page fetched on 4 Nov 2026 "
                    "did not link that domain."
                ),
            },
        ],
        "sources": sources(),
        "lines": lines(),
        "stations": stations,
        "line_stations": line_stations,
        "interchanges": [
            {
                "from_station_code": "MM-DCT",
                "to_station_code": "L3-23",
                "interchange_name": "District Court",
                "walking_minutes": None,
                "verification_status": "unconfirmed",
                "use_for_routing": True,
                "source_key": "pmrda-line3",
                "notes": (
                    "PMRDA describes Line 3 as the Hinjawadi to Shivajinagar corridor, and the operator's terminus is "
                    "District Court, Pune. Maha Metro's interchange is also named District Court, with Civil Court used "
                    "on one route-map listing. Walking time and whether the transfer is inside the paid area were not published. "
                    "Routing may use this link, and the app tells the passenger that transfer time is unknown."
                ),
            },
            {
                "from_station_code": "MM-SHN",
                "to_station_code": "L3-22",
                "interchange_name": "Shivaji Nagar",
                "walking_minutes": None,
                "verification_status": "unconfirmed",
                "use_for_routing": False,
                "source_key": "pitcmrl-stations",
                "notes": (
                    "The operator description calls the Line 3 station a major interchange. Maha Metro has a separate "
                    "Purple Line station named Shivaji Nagar. No walking time or confirmed paid-area link was published. "
                    "This record is shown for review and is not used for routing."
                ),
            },
        ],
        "timetables": [
            timetable("PPL", 34, 17.5, regular_note),
            timetable("AQL", 37, 14.5, regular_note),
            {
                "line_code": "PPL",
                "direction": "both",
                "service_type": "special",
                "service_day_type": "festival",
                "first_train_time": None,
                "last_train_time": None,
                "peak_headway_minutes": None,
                "off_peak_headway_minutes": None,
                "peak_windows": None,
                "off_peak_windows": None,
                "end_to_end_minutes": None,
                "published_distance_km": None,
                "valid_from": "2025-08-27",
                "valid_until": "2025-09-07",
                "verification_status": "historical_official",
                "source_key": "mm-ganeshotsav-en",
                "notes": (
                    "Ganeshotsav 2025 poster. 27–29 Aug 2025: 6:00 am to 11:00 pm. "
                    "30 Aug–5 Sep 2025: 6:00 am to 2:00 midnight. "
                    "Continuous service from 6 Sep 2025 at 6:00 am until 7 Sep 2025 at 11:00 pm. "
                    "Regular schedule resumed 8 Sep 2025. Expired. Not a current timetable."
                ),
            },
            {
                "line_code": "AQL",
                "direction": "both",
                "service_type": "special",
                "service_day_type": "festival",
                "first_train_time": None,
                "last_train_time": None,
                "peak_headway_minutes": None,
                "off_peak_headway_minutes": None,
                "peak_windows": None,
                "off_peak_windows": None,
                "end_to_end_minutes": None,
                "published_distance_km": None,
                "valid_from": "2025-08-27",
                "valid_until": "2025-09-07",
                "verification_status": "historical_official",
                "source_key": "mm-ganeshotsav-en",
                "notes": "Same Ganeshotsav 2025 poster as the Purple Line. The poster did not print different hours for each line. Expired.",
            },
        ],
        "station_timetables": [],
        "fares": [],
        "facilities": [],
        "alerts": [],
        "conflicts": conflicts(),
        "rejected_documents": rejected_documents(),
        "source_checks": source_checks(),
        "unavailable": [
            {
                "topic": "fare_matrix",
                "detail": "The official fare chart is an interactive form behind a CAPTCHA. No station-to-station fare was imported.",
            },
            {
                "topic": "current_station_departures",
                "detail": "The published timetable gives first train, last train, and headway. It does not list a departure time at each station.",
            },
            {
                "topic": "line3_timetable",
                "detail": "No official Line 3 timetable PDF or image was found on the PMRDA page or extracted from the operator pages checked.",
            },
            {
                "topic": "live_positions",
                "detail": "No authorised GTFS-Realtime or operator train-position feed is connected.",
            },
            {
                "topic": "station_facilities",
                "detail": "Maha Metro pages checked did not publish a per-station facility list. Line 3 publishes line-wide facility claims, which are kept on the line record rather than copied onto every station.",
            },
        ],
    }
    return dataset


def attach_bakori(stations: list) -> None:
    osm_path = ROOT / "tool" / "sources" / "osm_stations.json"
    row = next(item for item in stations if item["code"] == "MM-BAK")
    if not osm_path.exists():
        row["notes"] = "Bakori Phata is an official planned station. Coordinate was not embedded because the local OSM extract was absent, and no official coordinate was published."
        return
    data = json.loads(osm_path.read_text())
    matches = [
        element
        for element in data["elements"]
        if element.get("tags", {}).get("name") == "Bakori Phata"
        and "Pink" not in (element.get("tags", {}).get("network") or "")
    ]
    if len(matches) != 1:
        row["notes"] = "Bakori Phata coordinate was not set because OpenStreetMap did not have exactly one matching node."
        return
    element = matches[0]
    row.update(
        osm(
            element["id"],
            round(element["lat"], 6),
            round(element["lon"], 6),
            "Official list name Bakori Phata. Community-mapped coordinate.",
        )
    )


def timetable(line_code: str, minutes: int, distance: float, notes: str) -> dict:
    return {
        "line_code": line_code,
        "direction": "both",
        "service_type": "regular",
        "service_day_type": "all_days",
        "first_train_time": "06:00",
        "last_train_time": "23:00",
        "peak_headway_minutes": 6,
        "off_peak_headway_minutes": 10,
        "peak_windows": "08:00-11:00 and 16:00-20:00",
        "off_peak_windows": "06:00-08:00, 11:00-16:00 and 20:00-23:00",
        "end_to_end_minutes": minutes,
        "published_distance_km": distance,
        "valid_from": "2025-08-15",
        "valid_until": None,
        "verification_status": "official",
        "source_key": "mm-timetable-en",
        "notes": notes,
    }


def lines() -> list:
    facility_note = (
        "The operator site lists line-wide facilities: lifts and escalators, wheelchair ramps, tactile paths, "
        "priority seating, accessible toilets, ticket counters, QR ticketing, drinking water, and first aid at all stations. "
        "It also says an occupational health centre is available at a few stations, without naming them. "
        "These are not stored as inspected facilities of each station."
    )
    return [
        line("PPL", "maha", "Purple Line", "#6D28D9", True, "MM-PCMC", "MM-SWG", "operational", 17.4, "official", "mm-project-profile", "PCMC to Swargate. Official colour name Purple Line is printed on the 15 Aug 2025 timetable. Alignment length 17.4 km is from the project profile. The timetable image prints 17.5 km and 34 minutes."),
        line("AQL", "maha", "Aqua Line", "#0E7490", True, "MM-VAN", "MM-RAM", "operational", 15.7, "official", "mm-project-profile", "Vanaz to Ramwadi. Official colour name Aqua Line is printed on the 15 Aug 2025 timetable. Alignment length 15.7 km is from the project profile. The timetable image prints 14.5 km and 37 minutes."),
        line("PPL-N", "maha", "Purple Line, Nigdi extension", "#6D28D9", True, "MM-CHI", "MM-BKS", "under_construction", 4.413, "official", "mm-project-profile", "PCMC to Nigdi, 4.413 km, four elevated stations. The Line 1B page says this northern extension is under construction. Station order is the order printed on the project profile, which does not explicitly say it runs from PCMC toward Bhakti Shakti."),
        line("PPL-S", "maha", "Purple Line, Katraj extension", "#6D28D9", True, "MM-MKY", "MM-KAT", "planned", 5.46, "official", "mm-line-1b", "Sanctioned Swargate to Katraj underground extension, 5.46 km. Stations named by Maha Metro: Market Yard, Padmavati, Katraj. Not open."),
        line("AQL-W", "maha", "Aqua Line, Chandani Chowk extension", "#0E7490", True, "MM-KBD", "MM-CHC", "planned", 1.12, "official", "mm-line-2ab", "Vanaz to Chandani Chowk, 1.12 km, two stations: Kothrud Bus Depot and Chandani Chowk. Not described as open."),
        line("AQL-E", "maha", "Aqua Line, Wagholi extension", "#0E7490", True, "MM-VIM", "MM-VIT", "planned", 11.63, "official", "mm-line-2ab", "Ramwadi to Wagholi/Vitthalwadi, 11.63 km, 11 stations in the official numbered list. Not described as open."),
        line("L4", "maha", "Line 4", "#475569", False, None, None, "planned", 25.52, "official", "mm-line-4", "Kharadi to Khadakwasla, 25.52 km, 22 elevated stations. The official page does not name the stations, so none were created."),
        line("L4A", "maha", "Line 4A", "#475569", False, None, None, "planned", 6.12, "official", "mm-line-4", "Spur described as Nal Stop–Warje–Manik Baug, 6.12 km, 6 elevated stations. Individual station names were not published, so none were created."),
        line("L3", "pitcmrl", "Line 3", "#C2410C", False, "L3-01", "L3-23", "partially_operational", 23.203, "official", "pmrda-line3", "Hinjawadi/Maan to District Court, 23.203 km, 23 elevated stations, published by PMRDA. Opening of individual stations is only partly documented. The amber colour is an app display colour. PMRDA and the operator pages checked on 4 Nov 2026 did not publish an official line colour. OpenStreetMap tags the corridor Pink Line; that tag was not adopted as branding. " + facility_note),
    ]


def line(code, operator, name, color, official_color, origin, destination, status, length, length_verification, source, notes):
    return {
        "code": code,
        "operator_key": operator,
        "name": name,
        "color": color,
        "color_is_official": official_color,
        "origin_station_code": origin,
        "destination_station_code": destination,
        "operational_status": status,
        "route_length_km": length,
        "length_verification": length_verification,
        "verification_status": "official" if code != "L3" else "mixed",
        "source_key": source,
        "notes": notes,
    }


def sources() -> list:
    return [
        src("mm-homepage", "Maha Metro Pune homepage", "https://www.punemetrorail.org/", "html", "official", "Fetched 4 Nov 2026. Reported 2 lines, 30 stations, 5 underground, 29 operational, network length 33.1 km."),
        src("mm-project-profile", "Maha Metro project profile", "https://www.punemetrorail.org/project-profile", "html", "official", "Station lists with Open tags, corridor lengths, and extension names."),
        src("mm-route-map", "Maha Metro route map", "https://www.punemetrorail.org/route-map?lang=en-US", "html", "official", "Two corridor listings. Includes depot names and alternate station names."),
        src("mm-timetable-page", "Maha Metro time table page", "https://www.punemetrorail.org/time-table", "html", "official", "The page body is timetable images, not a station-by-station table."),
        src("mm-timetable-en", "New Time Table, English image", "https://www.punemetrorail.org/assets/images/Time-Table-new-2-15Aug.jpg", "image", "official", "Effective 15 August 2025. Read and checked against the Marathi image."),
        src("mm-timetable-mr", "New timetable, Marathi image", "https://www.punemetrorail.org/assets/images/Time-Table-new-1-15Aug.jpg", "image", "official", "Cross-check of the English timetable. Same figures."),
        src("mm-ganeshotsav-en", "Ganeshotsav 2025 timetable image", "https://www.punemetrorail.org/assets/images/Time-Table-new-2.jpg", "image", "historical_official", "Special service notice for August–September 2025. Expired."),
        src("mm-line-1b", "Line 1B extension page", "https://www.punemetrorail.org/Line_b.aspx", "html", "official", "Names the Katraj stations and says the Nigdi extension is under construction. Also contains an older sentence about District Court to Swargate."),
        src("mm-line-2ab", "Line 2A and 2B page", "https://www.punemetrorail.org/Line_2a_b.aspx", "html", "official", "Named station lists and lengths for the two Aqua extensions."),
        src("mm-line-4", "Line 4 and 4A page", "https://www.punemetrorail.org/Line_4a_b.aspx", "html", "official", "Corridor lengths and station counts only. Station names were not published."),
        src("mm-alignment", "Alignment map page", "https://www.punemetrorail.org/alignment-map", "html", "official", "Fetched. No station table was present in the page text."),
        src("mm-fare", "Metro fare chart", "https://www.punemetrorail.org/fare_chart.aspx", "html", "unavailable", "Interactive form with a CAPTCHA. Fare matrix was not extracted."),
        src("mm-robots", "Maha Metro robots.txt", "https://www.punemetrorail.org/robots.txt", "text", "official", "User-agent * is allowed except /cgi-bin/."),
        src("pmrda-line3", "PMRDA Pune Metro Line 3", "https://www.pmrda.gov.in/en/pune-metro-line-3/", "html", "official", "23.203 km, 23 stations, PITCMRL named as the SPV. Individual stations are not listed."),
        src("pmrda-robots", "PMRDA robots.txt", "https://www.pmrda.gov.in/robots.txt", "text", "official", "Allows public pages. Disallows /wp-admin/ except admin-ajax."),
        src("pitcmrl-home", "PITCMRL public site", "https://punerimetro.in/", "html", "operator_published", "Identifies the company and lists line-wide facilities. Domain was not linked from the PMRDA page we fetched."),
        src("pitcmrl-stations", "PITCMRL station list", "https://punerimetro.in/route/station-list", "html", "operator_published", "23 stations, codes PMR 1 to PMR 23, embedded map URLs. robots.txt allows all."),
        src("osm", "OpenStreetMap", "https://www.openstreetmap.org/copyright", "map", "secondary", "Overpass query on 4 Nov 2026 for railway=station nodes tagged Pune Metro. Community coordinates, not an operator survey. ODbL."),
        src("siemens-line3", "Siemens Mobility press release", "https://press.siemens.com/global/en/pressrelease/pune-metro-indias-public-private-partnership-metro-rail-project-commences-passenger", "html", "secondary", "3 Nov 2026. Says commercial passenger operations had commenced. Does not list which stations were closed."),
        src("fpj-line3", "Free Press Journal, Line 3 opening report", "https://www.freepressjournal.in/pune/excited-to-travel-on-pune-metro-line-3-connecting-hinjawadi-shivajinagar-here-are-8-things-to-know-before-you-travel", "news", "secondary", "3 Nov 2026. Used only for which Line 3 stations were reported open or closed on 4 Nov 2026. Fares and headways in the article were not imported."),
    ]


def src(key, name, url, source_type, status, notes):
    return {
        "key": key,
        "source_name": name,
        "source_url": url,
        "source_type": source_type,
        "extracted_at": EXTRACTED_AT,
        "last_verified_at": EXTRACTED_AT,
        "verification_status": status,
        "notes": notes,
    }


def conflicts() -> list:
    return [
        {
            "entity_type": "metro_line",
            "entity_key": "PPL",
            "field_name": "distance_km",
            "value_a": "17.4 alignment km",
            "source_a": "mm-project-profile",
            "value_b": "17.5 km on the timetable image",
            "source_b": "mm-timetable-en",
            "status": "open",
            "notes": "Both values are kept. The line record stores the project-profile alignment length. The timetable stores 17.5 km as published travel distance.",
        },
        {
            "entity_type": "metro_line",
            "entity_key": "AQL",
            "field_name": "distance_km",
            "value_a": "15.7 alignment km",
            "source_a": "mm-project-profile",
            "value_b": "14.5 km on the timetable image",
            "source_b": "mm-timetable-en",
            "status": "open",
            "notes": "Both values are kept. They are not averaged.",
        },
        {
            "entity_type": "network",
            "entity_key": "phase1",
            "field_name": "operational_extent",
            "value_a": "Homepage: 30 stations, 29 operational, 33.1 km. Project profile marks Kasba Peth, Mandai, and Swargate Open.",
            "source_a": "mm-homepage",
            "value_b": "Line 1B page says Phase 1 is operational for 29.66 km and that District Court to Swargate is on the verge of completion.",
            "source_b": "mm-line-1b",
            "status": "open",
            "notes": "Passenger status follows the homepage and the project-profile Open tags. The Line 1B sentence is retained as a conflict, not silently dropped.",
        },
        {
            "entity_type": "station",
            "entity_key": "MM-RNG",
            "field_name": "operational_status",
            "value_a": "Not tagged Open, and 29 of 30 stations are operational",
            "source_a": "mm-project-profile",
            "value_b": "Still drawn on the route map",
            "source_b": "mm-route-map",
            "status": "open",
            "notes": "Stored as not_open with verification official_inferred.",
        },
        {
            "entity_type": "station",
            "entity_key": "MM-DCT",
            "field_name": "name",
            "value_a": "District Court",
            "source_a": "mm-project-profile",
            "value_b": "Civil Court",
            "source_b": "mm-route-map",
            "status": "open",
            "notes": "One canonical station. Civil Court is an alias.",
        },
        {
            "entity_type": "station",
            "entity_key": "MM-IDC",
            "field_name": "name",
            "value_a": "Ideal Colony",
            "source_a": "mm-project-profile",
            "value_b": "Paud Phata",
            "source_b": "mm-route-map",
            "status": "open",
            "notes": "Positional correspondence only. Coordinate from the Paud Phata OSM node was not applied.",
        },
        {
            "entity_type": "station",
            "entity_key": "MM-NAL",
            "field_name": "name",
            "value_a": "Nal Stop",
            "source_a": "mm-project-profile",
            "value_b": "S.N.D.T College",
            "source_b": "mm-route-map",
            "status": "open",
            "notes": "Positional correspondence. The Nal Stop OSM node was used. The separate SNDT College OSM node was not merged.",
        },
        {
            "entity_type": "station",
            "entity_key": "MM-MGP",
            "field_name": "name",
            "value_a": "Mangalwar Peth",
            "source_a": "mm-project-profile",
            "value_b": "R.T.O Pune",
            "source_b": "mm-route-map",
            "status": "open",
            "notes": "Positional correspondence. No coordinate applied.",
        },
        {
            "entity_type": "station",
            "entity_key": "MM-CHC",
            "field_name": "name",
            "value_a": "Chandani Chowk Station",
            "source_a": "mm-line-2ab",
            "value_b": "Chandni Chowk in the page heading",
            "source_b": "mm-line-2ab",
            "status": "open",
            "notes": "Canonical name follows the station table.",
        },
        {
            "entity_type": "station",
            "entity_key": "MM-DCT",
            "field_name": "coordinates",
            "value_a": "OSM Purple Line platform node 11097510274",
            "source_a": "osm",
            "value_b": "OSM Aqua Line platform node 7944597685",
            "source_b": "osm",
            "status": "open",
            "notes": "Neither pin was stored on the shared station.",
        },
        {
            "entity_type": "station",
            "entity_key": "MM-SWG",
            "field_name": "coordinates",
            "value_a": "OSM node Swargate 7944597710",
            "source_a": "osm",
            "value_b": "OSM node Swargate North 13654857952",
            "source_b": "osm",
            "status": "open",
            "notes": "The exact-name node was stored. Swargate North was not used as a second station.",
        },
        {
            "entity_type": "line",
            "entity_key": "L3",
            "field_name": "station_opening",
            "value_a": "Operator list publishes 23 stations and does not say which are open",
            "source_a": "pitcmrl-stations",
            "value_b": "Free Press Journal, 3 Nov 2026: 17 open on 4 Nov 2026, six closed",
            "source_b": "fpj-line3",
            "status": "open",
            "notes": "The news sentence splits Shree Shiv Chhatrapati Sports Complex, Mahalunge with a comma. It was read as one station, matching the operator list, which is what makes the open count 17.",
        },
        {
            "entity_type": "line",
            "entity_key": "L3",
            "field_name": "colour_name",
            "value_a": "No colour name on PMRDA or the operator pages checked",
            "source_a": "pmrda-line3",
            "value_b": "OpenStreetMap network tag Pune Metro Pink Line",
            "source_b": "osm",
            "status": "open",
            "notes": "The app uses amber only as a display colour and does not call the line Pink.",
        },
        {
            "entity_type": "import",
            "entity_key": "osm-extra-names",
            "field_name": "station_list",
            "value_a": "Official Line 4 page gives a count of 22 stations and no names",
            "source_a": "mm-line-4",
            "value_b": "OpenStreetMap includes many extra names such as Hadapsar, Warje, and Manik Baug",
            "source_b": "osm",
            "status": "open",
            "notes": "Those OSM names were not imported.",
        },
    ]


def rejected_documents() -> list:
    return [
        {
            "title": "PCMC–Phugewadi priority section timetable",
            "url": "https://www.punemetrorail.org/download/time-table/PCMC-Phugewadi.pdf",
            "reason": "Dated 23 Apr 2023. Ten-hour priority-section timetable with trip rows. It is not the current full-network timetable, so its trip times were not imported as present-day departures.",
        },
        {
            "title": "Pune Metro Commuter Guide",
            "url": "https://www.punemetrorail.org/download/commuters_guide/Pune-Metro-Commuter-Guide.pdf",
            "reason": "Last-Modified 6 Mar 2024. Describes Civil Court–Swargate as work in progress and Ruby Hall–Ramwadi as not yet inaugurated, and prints fares of Rs 10 to Rs 35. Superseded by later Open tags and the Aug 2025 timetable. Fares from this PDF were not imported.",
        },
        {
            "title": "Know your metro stations",
            "url": "https://www.punemetrorail.org/know-your-metro-stations?lang=en-US",
            "reason": "Page fetched. Station facts were not exposed as text. No station details were guessed from it.",
        },
    ]


def source_checks() -> list:
    return [
        {
            "source_key": "mm-project-profile",
            "url": "https://www.punemetrorail.org/project-profile",
            "must_contain": ["PCMC", "Swargate", "Range Hill", "Vanaz", "Ramwadi", "District Court"],
        },
        {
            "source_key": "mm-route-map",
            "url": "https://www.punemetrorail.org/route-map?lang=en-US",
            "must_contain": ["PCMC", "Swargate", "Vanaz", "Ramwadi"],
        },
        {
            "source_key": "mm-timetable-page",
            "url": "https://www.punemetrorail.org/time-table",
            "must_contain": ["Time-Table-new-2-15Aug.jpg", "Train Time Table"],
        },
        {
            "source_key": "pmrda-line3",
            "url": "https://www.pmrda.gov.in/en/pune-metro-line-3/",
            "must_contain": ["23.203", "Pune IT City Metro Rail Limited"],
        },
        {
            "source_key": "pitcmrl-stations",
            "url": "https://punerimetro.in/route/station-list",
            "must_contain": ["Maan", "District Court", "PMR 23"],
        },
    ]


def main() -> None:
    dataset = build()
    codes = [row["code"] for row in dataset["stations"]]
    if len(codes) != len(set(codes)):
        raise SystemExit("Duplicate station codes")
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(dataset, indent=2, ensure_ascii=False) + "\n")
    print(f"Wrote {OUT}")
    print(f"stations={len(dataset['stations'])} lines={len(dataset['lines'])} conflicts={len(dataset['conflicts'])}")


if __name__ == "__main__":
    main()
