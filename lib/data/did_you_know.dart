/// Bundled "Did You Know?" facts for Educational Mode.
///
/// All facts are static and offline — no internet required.
/// Facts rotate on the home screen every 30 seconds.
library;

/// A single educational fact.
class DidYouKnowFact {
  /// The fact text displayed to the user.
  final String fact;

  /// Optional emoji prefix for visual interest.
  final String emoji;

  const DidYouKnowFact({required this.fact, required this.emoji});
}

/// All bundled educational conversion facts (85+ facts).
const List<DidYouKnowFact> didYouKnowFacts = [
  // ── Length ───────────────────────────────────────────────────────────────
  DidYouKnowFact(emoji: '📏', fact: '1 inch is exactly 2.54 centimeters — defined since 1959.'),
  DidYouKnowFact(emoji: '🌍', fact: '1 nautical mile equals 1,852 meters — based on one arcminute of latitude.'),
  DidYouKnowFact(emoji: '🏔️', fact: 'Mount Everest is 8,848.86 meters (29,031.7 ft) tall.'),
  DidYouKnowFact(emoji: '🌌', fact: 'A light-year is about 9.46 × 10¹² kilometers — the distance light travels in one year.'),
  DidYouKnowFact(emoji: '📐', fact: 'The meter was originally defined as 1/10,000,000th of the distance from the equator to the North Pole.'),
  // ── Weight & Mass ────────────────────────────────────────────────────────
  DidYouKnowFact(emoji: '⚖️', fact: '1 kilogram was redefined in 2019 based on Planck\'s constant, not a physical artifact.'),
  DidYouKnowFact(emoji: '🐘', fact: 'An African elephant weighs about 6,000 kg — roughly 13,200 lbs.'),
  DidYouKnowFact(emoji: '💎', fact: 'One carat (used for gemstones) equals exactly 0.2 grams.'),
  DidYouKnowFact(emoji: '🧂', fact: '1 pound = 16 ounces. The word "pound" comes from the Latin "libra pondo" — hence the symbol lb.'),
  // ── Temperature ─────────────────────────────────────────────────────────
  DidYouKnowFact(emoji: '🌡️', fact: 'Absolute zero is −273.15 °C or −459.67 °F — the coldest possible temperature.'),
  DidYouKnowFact(emoji: '🔥', fact: 'Water boils at 100 °C at sea level, but only at 89.8 °C on Mount Everest.'),
  DidYouKnowFact(emoji: '❄️', fact: 'Liquid nitrogen boils at −195.79 °C (77 K).'),
  DidYouKnowFact(emoji: '☀️', fact: 'The surface of the Sun is about 5,778 K (5,505 °C).'),
  DidYouKnowFact(emoji: '🧊', fact: '−40 °C and −40 °F are exactly the same temperature — the unique crossover point.'),
  // ── Area ─────────────────────────────────────────────────────────────────
  DidYouKnowFact(emoji: '🌾', fact: '1 hectare = 10,000 m² — roughly the size of an international rugby field.'),
  DidYouKnowFact(emoji: '🏡', fact: '1 acre = 4,047 m² — originally the land a man could plow in one day with an ox.'),
  // ── Volume ───────────────────────────────────────────────────────────────
  DidYouKnowFact(emoji: '🥛', fact: '1 US gallon = 3.785 liters. A UK gallon is larger at 4.546 liters.'),
  DidYouKnowFact(emoji: '💧', fact: '1 milliliter of water weighs exactly 1 gram at 4 °C.'),
  DidYouKnowFact(emoji: '🍺', fact: 'A US pint is 473 ml, but a UK pint is 568 ml — 20% larger!'),
  // ── Speed ────────────────────────────────────────────────────────────────
  DidYouKnowFact(emoji: '🚀', fact: 'The speed of light is 299,792,458 m/s — exactly, by definition since 1983.'),
  DidYouKnowFact(emoji: '🔊', fact: 'Sound travels at about 343 m/s in air at 20 °C (1,235 km/h).'),
  DidYouKnowFact(emoji: '🏎️', fact: 'The fastest land speed record is 1,228 km/h (763 mph) set by ThrustSSC in 1997.'),
  DidYouKnowFact(emoji: '✈️', fact: '1 knot = 1.852 km/h. Knots are still used in aviation and maritime navigation worldwide.'),
  // ── Data ─────────────────────────────────────────────────────────────────
  DidYouKnowFact(emoji: '💾', fact: '1 byte = 8 bits. The term "byte" was coined by Werner Buchholz in 1956.'),
  DidYouKnowFact(emoji: '📀', fact: 'A terabyte = 1,000 GB (decimal), but Windows reports it as ~910 GiB (binary).'),
  DidYouKnowFact(emoji: '🧮', fact: 'The first hard drive (IBM 350, 1956) stored just 3.75 MB and weighed over 900 kg.'),
  // ── Time ─────────────────────────────────────────────────────────────────
  DidYouKnowFact(emoji: '⏱️', fact: 'A light-nanosecond is about 30 cm — the distance light travels in one nanosecond.'),
  DidYouKnowFact(emoji: '📅', fact: 'A leap year occurs every 4 years, except century years unless divisible by 400.'),
  DidYouKnowFact(emoji: '🌕', fact: 'A lunar month (synodic) is 29.53 days — the basis of most ancient calendars.'),
  // ── Pressure ─────────────────────────────────────────────────────────────
  DidYouKnowFact(emoji: '🌬️', fact: 'Standard atmospheric pressure is 101,325 Pa (1 atm) — the air pressure at sea level.'),
  DidYouKnowFact(emoji: '🏊', fact: 'At 10 meters underwater, pressure doubles to about 2 atm.'),
  // ── Energy ───────────────────────────────────────────────────────────────
  DidYouKnowFact(emoji: '⚡', fact: '1 kilowatt-hour (kWh) = 3,600,000 joules = the energy to run a 100 W bulb for 10 hours.'),
  DidYouKnowFact(emoji: '💥', fact: '1 calorie = 4.184 joules. The food Calorie (kcal) is 1,000 times larger.'),
  // ── Electrical ───────────────────────────────────────────────────────────
  DidYouKnowFact(emoji: '🔋', fact: 'Ohm\'s Law: Voltage (V) = Current (A) × Resistance (Ω). Discovered by Georg Ohm in 1827.'),
  DidYouKnowFact(emoji: '⚡', fact: 'Lightning bolts carry about 300,000 volts but only about 5 amperes — for a very short time.'),
  DidYouKnowFact(emoji: '🔌', fact: 'The US uses 120 V AC at 60 Hz. Europe uses 230 V at 50 Hz.'),
  // ── Astronomy ────────────────────────────────────────────────────────────
  DidYouKnowFact(emoji: '🪐', fact: '1 Astronomical Unit (AU) = 149,597,870.7 km — the average Earth–Sun distance.'),
  DidYouKnowFact(emoji: '✨', fact: 'The nearest star, Proxima Centauri, is 4.24 light-years (268,770 AU) away.'),
  DidYouKnowFact(emoji: '🌌', fact: 'The Milky Way is about 100,000 light-years (30.7 kpc) in diameter.'),
  // ── Science ──────────────────────────────────────────────────────────────
  DidYouKnowFact(emoji: '🔬', fact: 'Avogadro\'s number (6.022 × 10²³) defines one mole — the SI unit of amount of substance.'),
  DidYouKnowFact(emoji: '🧲', fact: 'The Earth\'s magnetic field strength is about 25–65 microteslas (0.25–0.65 Gauss).'),
  DidYouKnowFact(emoji: '💡', fact: '1 candela is approximately the luminous intensity of a single birthday candle.'),
  DidYouKnowFact(emoji: '🌊', fact: 'Pascal\'s principle: pressure applied to a confined fluid transmits equally in all directions.'),
  // ── Fitness & Health ─────────────────────────────────────────────────────
  DidYouKnowFact(emoji: '❤️', fact: 'A normal resting heart rate for adults is 60–100 beats per minute.'),
  DidYouKnowFact(emoji: '🩸', fact: 'Normal blood glucose is 70–100 mg/dL (3.9–5.6 mmol/L) when fasting.'),
  DidYouKnowFact(emoji: '🏃', fact: 'A 4:00 min/km pace equals 15 km/h — typical for competitive distance runners.'),
  DidYouKnowFact(emoji: '🏋️', fact: 'BMI = weight (kg) / height² (m²). A value of 18.5–24.9 is considered healthy.'),
  // ── Cooking ──────────────────────────────────────────────────────────────
  DidYouKnowFact(emoji: '🥄', fact: '1 tablespoon = 3 teaspoons = 14.79 ml (US). UK tablespoons are slightly larger.'),
  DidYouKnowFact(emoji: '🍳', fact: 'Butter burns at 150 °C (302 °F). Clarified butter (ghee) tolerates up to 250 °C.'),
  DidYouKnowFact(emoji: '🫙', fact: '1 US cup = 236.6 ml. A metric cup used in Australia/Canada = 250 ml.'),
  // ── Everyday & Fun ───────────────────────────────────────────────────────
  DidYouKnowFact(emoji: '🖥️', fact: 'A standard 72 DPI screen has 72 pixels per inch — a convention from early Mac typography.'),
  DidYouKnowFact(emoji: '🎵', fact: 'Concert pitch A4 = 440 Hz. The BBC uses this since 1936 as the international standard.'),
  DidYouKnowFact(emoji: '📐', fact: '1 point (typography) = 1/72 inch = 0.353 mm — used in fonts since the 18th century.'),
  DidYouKnowFact(emoji: '🔢', fact: '0xFF in hexadecimal = 255 in decimal = 11111111 in binary.'),
  DidYouKnowFact(emoji: '🗺️', fact: 'GPS uses WGS84 — an ellipsoidal model of Earth with an equatorial radius of 6,378.137 km.'),
  DidYouKnowFact(emoji: '⛽', fact: 'A car achieving 40 mpg (US) uses 5.88 L/100 km. Lower L/100km = more efficient.'),
  DidYouKnowFact(emoji: '🌡️', fact: 'Room temperature is conventionally 20–25 °C (68–77 °F).'),
  DidYouKnowFact(emoji: '🧪', fact: 'pH is a logarithmic scale. Each unit represents a 10× change in acidity.'),
  DidYouKnowFact(emoji: '📡', fact: 'Wi-Fi 6 (802.11ax) operates at 2.4 GHz and 5 GHz. 5G NR can reach 52.6 GHz.'),
  // ── Extra Science, Tech & Everyday Facts ─────────────────────────────────
  DidYouKnowFact(emoji: '🛰️', fact: 'Voyager 1 is over 24 billion kilometers (160 AU) away — the farthest human artifact.'),
  DidYouKnowFact(emoji: '⚛️', fact: '1 electronvolt (eV) = 1.602 × 10⁻¹⁹ joules — the energy of an electron accelerating across 1 volt.'),
  DidYouKnowFact(emoji: '🛸', fact: 'The International Space Station orbits Earth at 27,600 km/h (7.66 km/s) — orbiting every 90 minutes.'),
  DidYouKnowFact(emoji: '🧲', fact: 'A medical MRI scanner uses magnetic fields of 1.5 to 3 Tesla (15,000–30,000 Gauss).'),
  DidYouKnowFact(emoji: '☀️', fact: 'The core of the Sun reaches an incredible 15 million °C (27 million °F).'),
  DidYouKnowFact(emoji: '⚓', fact: '1 fathom = 6 feet (1.8288 m) — historically measured by a sailor\'s outstretched arms.'),
  DidYouKnowFact(emoji: '👑', fact: 'Gold purity is measured in karats: 24k is 100% pure gold; 18k is 75% pure gold.'),
  DidYouKnowFact(emoji: '👟', fact: 'EU shoe sizes use "Paris Points" — each point equals exactly 2/3 of a centimeter (6.67 mm).'),
  DidYouKnowFact(emoji: '👗', fact: 'US and UK women\'s clothing sizes differ by 4 numbers — a US size 8 is a UK size 12.'),
  DidYouKnowFact(emoji: '☕', fact: 'An 8 oz (240 ml) cup of brewed coffee contains approximately 95 mg of caffeine.'),
  DidYouKnowFact(emoji: '📱', fact: 'Phone battery capacities are measured in milliamp-hours (mAh). A 5,000 mAh battery delivers 5A for 1 hour.'),
  DidYouKnowFact(emoji: '🐎', fact: '1 Horsepower = 745.7 Watts — coined by James Watt to compare steam engines to draft horses.'),
  DidYouKnowFact(emoji: '🌊', fact: 'The Mariana Trench is 10,994 meters (36,070 ft) deep — where pressure exceeds 1,000 atmospheres.'),
  DidYouKnowFact(emoji: '🛢️', fact: '1 barrel of crude oil equals 42 US gallons or 158.987 liters.'),
  DidYouKnowFact(emoji: '🏡', fact: '1 marla (South Asian land area) equals 272.25 sq ft or 25.29 m².'),
  DidYouKnowFact(emoji: '🌀', fact: 'A Category 5 hurricane has sustained wind speeds exceeding 252 km/h (157 mph).'),
  DidYouKnowFact(emoji: '⚡', fact: 'High-voltage grid transmission lines carry up to 765,000 V to minimize power loss over long distances.'),
  DidYouKnowFact(emoji: '🥑', fact: '1 gram of fat supplies 9 Calories, while 1 gram of protein or carbohydrate supplies 4 Calories.'),
  DidYouKnowFact(emoji: '⏱️', fact: 'The cesium-133 atom vibrates 9,192,631,770 times per second — defining the official SI second since 1967.'),
  DidYouKnowFact(emoji: '📐', fact: '1 radian equals approximately 57.2958 degrees — the angle subtended when arc length equals radius.'),
  DidYouKnowFact(emoji: '🏎️', fact: 'Engine torque (N·m) measures rotational force; engine power (kW/HP) measures how quickly work is performed.'),
  DidYouKnowFact(emoji: '📦', fact: '1 petabyte (PB) = 1,000 terabytes (TB) — enough storage to hold 13 years of HD video.'),
  DidYouKnowFact(emoji: '📡', fact: 'GPS satellites orbit Earth at an altitude of 20,200 km (12,550 miles).'),
  DidYouKnowFact(emoji: '🩸', fact: 'Fasting blood sugar of 126 mg/dL (7.0 mmol/L) or higher is used to diagnose diabetes.'),
  DidYouKnowFact(emoji: '🔊', fact: 'Decibels are logarithmic: a +10 dB increase represents a 10× increase in acoustic energy.'),
];
