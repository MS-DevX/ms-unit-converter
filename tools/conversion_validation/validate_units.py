#!/usr/bin/env python3
"""Conversion validation tool for MS Unit Converter.

Reads sample_cases.json, runs the same conversion logic as the Dart
ConversionService, and reports pass/fail for every case.

Usage:
    python validate_units.py          # uses sample_cases.json
    python validate_units.py <file>   # uses a different JSON file

Exit code 0  → all cases pass.
Exit code >0 → one or more cases failed.
"""

import json
import math
import os
import sys


# ── Unit database (mirrors lib/data/units_data.dart) ──────────────

_UNITS: dict[str, dict[str, tuple[float, str | None]]] = {
    "length": {
        "Meter": (1, None),
        "Kilometer": (1000, None),
        "Centimeter": (0.01, None),
        "Millimeter": (0.001, None),
        "Mile": (1609.34, None),
        "Yard": (0.9144, None),
        "Foot": (0.3048, None),
        "Inch": (0.0254, None),
        "Nautical Mile": (1852, None),
    },
    "weight": {
        "Kilogram": (1, None),
        "Gram": (0.001, None),
        "Milligram": (0.000001, None),
        "Tonne": (1000, None),
        "Pound": (0.453592, None),
        "Ounce": (0.0283495, None),
        "Stone": (6.35029, None),
    },
    "temperature": {
        "Celsius": (1, None),
        "Fahrenheit": (1, None),
        "Kelvin": (1, None),
    },
    "area": {
        "Square Meter": (1, None),
        "Square Kilometer": (1e6, None),
        "Square Centimeter": (0.0001, None),
        "Square Millimeter": (1e-6, None),
        "Square Foot": (0.092903, None),
        "Square Inch": (0.00064516, None),
        "Square Yard": (0.836127, None),
        "Acre": (4046.86, None),
        "Hectare": (10000, None),
    },
    "volume": {
        "Liter": (0.001, None),
        "Milliliter": (0.000001, None),
        "Cubic Meter": (1, None),
        "Gallon (US)": (0.00378541, None),
        "Gallon (UK)": (0.00454609, None),
        "Cup": (0.000236588, None),
        "Fluid Ounce": (0.0000295735, None),
        "Pint": (0.000473176, None),
        "Quart": (0.000946353, None),
    },
    "speed": {
        "Meters per Second": (1, None),
        "Kilometers per Hour": (0.277778, None),
        "Miles per Hour": (0.44704, None),
        "Knot": (0.514444, None),
        "Foot per Second": (0.3048, None),
    },
    "data": {
        "Bit": (0.125, None),
        "Byte": (1, None),
        "Kilobyte": (1024, None),
        "Megabyte": (1048576, None),
        "Gigabyte": (1073741824, None),
        "Terabyte": (1099511627776, None),
        "Petabyte": (1125899906842624, None),
    },
    "time": {
        "Millisecond": (0.001, None),
        "Second": (1, None),
        "Minute": (60, None),
        "Hour": (3600, None),
        "Day": (86400, None),
        "Week": (604800, None),
        "Month": (2592000, None),
        "Year": (31536000, None),
    },
    "angle": {
        "Radian": (1, None),
        "Degree": (math.pi / 180, None),
        "Gradian": (math.pi / 200, None),
        "Arcminute": (math.pi / (180 * 60), None),
        "Arcsecond": (math.pi / (180 * 3600), None),
    },
    "energy": {
        "Joule": (1, None),
        "Kilojoule": (1000, None),
        "Calorie": (4.184, None),
        "Kilowatt-hour": (3600000, None),
        "BTU": (1055.06, None),
        "Electronvolt": (1.602176634e-19, None),
        "Foot-pound": (1.35581794833, None),
    },
    "power": {
        "Watt": (1, None),
        "Kilowatt": (1000, None),
        "Megawatt": (1000000, None),
        "Horsepower": (745.7, None),
        "BTU per Hour": (0.293071, None),
    },
    "pressure": {
        "Pascal": (1, None),
        "Kilopascal": (1000, None),
        "Bar": (100000, None),
        "PSI": (6894.757, None),
        "Atmosphere": (101325, None),
        "Torr": (133.322, None),
        "mmHg": (133.322, None),
    },
    "force": {
        "Newton": (1, None),
        "Dyne": (0.00001, None),
        "Pound-force": (4.448222, None),
        "Kilogram-force": (9.80665, None),
    },
    "frequency": {
        "Hertz": (1, None),
        "Kilohertz": (1000, None),
        "Megahertz": (1000000, None),
        "Gigahertz": (1000000000, None),
    },
    "fuelEconomy": {
        "Kilometers per Liter": (1, None),
        "Liters per 100km": (1, None),
        "MPG (US)": (0.425144, None),
        "MPG (UK)": (0.354006, None),
    },
    "cooking": {
        "Cup (US)": (237, "volume"),
        "Tablespoon": (14.787, "volume"),
        "Teaspoon": (4.929, "volume"),
        "Fluid Ounce": (29.574, "volume"),
        "Milliliter": (1, "volume"),
        "Gram": (1, "weight"),
        "Kilogram": (1000, "weight"),
        "Ounce": (28.35, "weight"),
        "Pound": (453.592, "weight"),
    },
    "shoeSize": {
        "EU": (1, None),
        "UK": (1, None),
        "US Men": (1, None),
        "US Women": (1, None),
        "CM": (1, None),
    },
    "clothingSize": {
        "US": (1, None),
        "EU": (1, None),
        "UK": (1, None),
        "Asian": (1, None),
    },
    "numberBase": {
        "Binary": (1, None),
        "Octal": (1, None),
        "Decimal": (1, None),
        "Hexadecimal": (1, None),
    },
    "typography": {
        "Pixels": (1, None),
        "DP": (0.6, None),
        "Points": (1.333, None),
        "EM": (1, None),
        "REM": (1, None),
        "Percent": (1, None),
        "Inch": (96, None),
        "Centimeter": (37.8, None),
        "Millimeter": (3.78, None),
        "Pica": (16, None),
    },
}


# ── Conversion logic (mirrors lib/services/conversion_service.dart) ─


def convert_linear(value: float, from_to_base: float, to_to_base: float) -> float:
    return (value * from_to_base) / to_to_base


def convert_temperature(value: float, from_name: str, to_name: str) -> float:
    def to_celsius(v: float, name: str) -> float:
        if name == "Celsius":
            return v
        if name == "Fahrenheit":
            return (v - 32) * 5 / 9
        if name == "Kelvin":
            return v - 273.15
        return float("nan")

    def from_celsius(c: float, name: str) -> float:
        if name == "Celsius":
            return c
        if name == "Fahrenheit":
            return (c * 9 / 5) + 32
        if name == "Kelvin":
            return c + 273.15
        return float("nan")

    celsius = to_celsius(value, from_name)
    return from_celsius(celsius, to_name)


def convert_fuel_economy(value: float, from_name: str, to_name: str) -> float:
    def to_kmpl(v: float, name: str) -> float:
        if name == "Liters per 100km":
            return float("nan") if v == 0 else 100 / v
        return v * _UNITS["fuelEconomy"][name][0]

    def from_kmpl(kmpl: float, name: str) -> float:
        if name == "Liters per 100km":
            return float("nan") if kmpl == 0 else 100 / kmpl
        return kmpl / _UNITS["fuelEconomy"][name][0]

    kmpl = to_kmpl(value, from_name)
    return from_kmpl(kmpl, to_name)


def convert_cooking(value: float, from_name: str, to_name: str) -> float:
    from_group = _UNITS["cooking"][from_name][1]
    to_group = _UNITS["cooking"][to_name][1]
    if from_group != to_group:
        return float("nan")
    from_base = _UNITS["cooking"][from_name][0]
    to_base = _UNITS["cooking"][to_name][0]
    return (value * from_base) / to_base


def convert_shoe_size(value: float, from_name: str, to_name: str) -> float:
    def shoe_to_cm(v: float, name: str) -> float:
        if name == "CM":
            return v
        if name == "EU":
            return (v - 1.5) / 1.5
        if name == "UK":
            return (v + 31.5) / 1.5
        if name == "US Men":
            return (v + 30.5) / 1.5
        if name == "US Women":
            return (v + 29) / 1.5
        return float("nan")

    def cm_to_shoe(cm: float, name: str) -> float:
        if name == "CM":
            return cm
        if name == "EU":
            return cm * 1.5 + 1.5
        if name == "UK":
            return cm * 1.5 - 31.5
        if name == "US Men":
            return cm * 1.5 - 30.5
        if name == "US Women":
            return cm * 1.5 - 29
        return float("nan")

    cm = shoe_to_cm(value, from_name)
    if math.isnan(cm):
        return float("nan")
    result = cm_to_shoe(cm, to_name)
    if math.isnan(result):
        return float("nan")
    return round(result * 2) / 2


def convert_clothing_size(value: float, from_name: str, to_name: str) -> float:
    def clothing_to_us(v: float, name: str, is_men: bool) -> float:
        if name == "US":
            return v
        if name == "EU":
            return v - 10 if is_men else v - 30
        if name == "UK":
            return v + 1 if is_men else v - 4
        if name == "Asian":
            return v - 5
        return float("nan")

    def us_to_clothing(us: float, name: str, is_men: bool) -> float:
        if name == "US":
            return us
        if name == "EU":
            return us + 10 if is_men else us + 30
        if name == "UK":
            return us - 1 if is_men else us + 4
        if name == "Asian":
            return us + 5
        return float("nan")

    is_men = True  # default, matches Dart code (no isMen parameter in convert)
    us = clothing_to_us(value, from_name, is_men)
    if math.isnan(us):
        return float("nan")
    return us_to_clothing(us, to_name, is_men)


def convert_number_base(value: float, from_name: str, to_name: str) -> float:
    radix_map = {"Binary": 2, "Octal": 8, "Decimal": 10, "Hexadecimal": 16}
    from_radix = radix_map.get(from_name, 10)
    to_radix = radix_map.get(to_name, 10)
    input_str = str(int(value))
    try:
        int_value = int(input_str, from_radix)
    except ValueError:
        return float("nan")
    result_str = format(int_value, "x") if to_radix == 16 else format(int_value, "o") if to_radix == 8 else format(int_value, "b") if to_radix == 2 else str(int_value)
    try:
        return float(result_str)
    except ValueError:
        return float(int_value)


def convert_typography(value: float, from_name: str, to_name: str) -> float:
    base_font_size = 16.0

    def typo_to_px(v: float, name: str) -> float:
        if name in ("Pixels", "DP", "Points", "Inch", "Centimeter", "Millimeter", "Pica"):
            return v * _UNITS["typography"][name][0]
        if name == "EM":
            return v * base_font_size
        if name == "REM":
            return v * base_font_size
        if name == "Percent":
            return (v / 100) * base_font_size
        return float("nan")

    def px_to_typo(px: float, name: str) -> float:
        if name in ("Pixels", "DP", "Points", "Inch", "Centimeter", "Millimeter", "Pica"):
            return px / _UNITS["typography"][name][0]
        if name == "EM":
            return px / base_font_size
        if name == "REM":
            return px / base_font_size
        if name == "Percent":
            return (px / base_font_size) * 100
        return float("nan")

    px = typo_to_px(value, from_name)
    if math.isnan(px):
        return float("nan")
    return px_to_typo(px, to_name)


# ── Conversion dispatcher ─────────────────────────────────────────


def convert(value: float, from_name: str, to_name: str, category: str) -> float:
    if math.isnan(value) or math.isinf(value):
        return float("nan")
    if from_name == to_name:
        return value
    try:
        if category == "temperature":
            return convert_temperature(value, from_name, to_name)
        if category == "fuelEconomy":
            return convert_fuel_economy(value, from_name, to_name)
        if category == "cooking":
            return convert_cooking(value, from_name, to_name)
        if category == "shoeSize":
            return convert_shoe_size(value, from_name, to_name)
        if category == "clothingSize":
            return convert_clothing_size(value, from_name, to_name)
        if category == "numberBase":
            return convert_number_base(value, from_name, to_name)
        if category == "typography":
            return convert_typography(value, from_name, to_name)
        from_to_base = _UNITS[category][from_name][0]
        to_to_base = _UNITS[category][to_name][0]
        return convert_linear(value, from_to_base, to_to_base)
    except (KeyError, IndexError):
        return float("nan")


# ── Validation runner ─────────────────────────────────────────────


def validate_case(case: dict) -> tuple[bool, str]:
    category = case["category"]
    from_unit = case["fromUnit"]
    to_unit = case["toUnit"]
    input_val = case["input"]
    expected = case.get("expected")
    tolerance = case.get("tolerance", 1e-6)
    should_fail = case.get("shouldFail", False)
    desc = case.get("description", f"{input_val} {from_unit} → {to_unit}")

    result = convert(input_val, from_unit, to_unit, category)

    if should_fail:
        if math.isnan(result) or math.isinf(result):
            return True, f"PASS  {desc}  (correctly fails)"
        return False, f"FAIL  {desc}  expected failure but got {result}"

    if expected is None:
        if math.isnan(result):
            return True, f"PASS  {desc}  (returns NaN as expected)"
        return False, f"FAIL  {desc}  expected NaN, got {result}"

    if math.isnan(result):
        return False, f"FAIL  {desc}  got NaN, expected ~{expected}"
    if math.isinf(result):
        return False, f"FAIL  {desc}  got inf, expected ~{expected}"

    diff = abs(result - expected)
    if diff <= tolerance:
        return True, f"PASS  {desc}  → {result}"
    return False, f"FAIL  {desc}  → {result} (expected ~{expected}, diff {diff})"


def main() -> int:
    script_dir = os.path.dirname(os.path.abspath(__file__))
    json_path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(script_dir, "sample_cases.json")

    if not os.path.exists(json_path):
        print(f"Error: file not found: {json_path}")
        return 1

    with open(json_path) as f:
        data = json.load(f)

    cases = data.get("cases", [])
    if not cases:
        print("Error: no cases found in JSON file")
        return 1

    total = len(cases)
    passed = 0
    failed = 0
    failures: list[str] = []

    print(f"Validating {total} conversion cases from {json_path}")
    print("━" * 72)

    for case in cases:
        ok, msg = validate_case(case)
        print(msg)
        if ok:
            passed += 1
        else:
            failed += 1
            failures.append(msg)

    print("━" * 72)
    print(f"Results: {passed}/{total} passed, {failed}/{total} failed")

    print()
    if failed > 0:
        print("Failed cases:")
        for f_msg in failures:
            print(f"  {f_msg}")
        return 1

    print("All cases passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
