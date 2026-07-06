import json
import os
import re

def clean_keys(obj):
    """Recursively strips whitespaces from all dictionary keys."""
    if isinstance(obj, dict):
        return {k.strip(): clean_keys(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [clean_keys(item) for item in obj]
    return obj

def normalize_record(record):
    """Normalizes polymorphic fields and flattens Mongo metadata structures."""
    normalized = {}
    
    # 1. Map ID structural token
    if '_id' in record and isinstance(record['_id'], dict):
        normalized['id'] = record['_id'].get('$oid', '').strip()
    else:
        normalized['id'] = str(record.get('id', '')).strip()

    # 2. Extract and flatten Date values cleanly
    if 'date' in record:
        if isinstance(record['date'], dict):
            normalized['date'] = record['date'].get('$date', '').strip()
        else:
            normalized['date'] = str(record['date']).strip()
    else:
        normalized['date'] = ""

    # 3. Handle Polymorphic Weight Conversion safely
    weight_raw = record.get('weight', 0.0)
    try:
        if isinstance(weight_raw, str):
            # Strip any trailing characters or units if they exist
            weight_clean = re.sub(r'[^\d\.]', '', weight_raw)
            normalized['weight'] = float(weight_clean) if weight_clean else 0.0
        else:
            normalized['weight'] = float(weight_raw)
    except (ValueError, TypeError):
        normalized['weight'] = 0.0

    # 4. Extract Core Categorizations with Case-Insensitive Trim normalization
    normalized['species'] = str(record.get('species', 'Unknown')).strip()
    normalized['reservoir'] = str(record.get('reservoir', 'Unknown')).strip()
    normalized['angler'] = str(record.get('angler', 'Unknown')).strip()
    
    # 5. Fallback strings and optional coordinates
    normalized['image'] = str(record.get('image', '')).strip()
    normalized['comment'] = str(record.get('comment', '')).strip()
    
    # Map coordinates safely to strings (empty string represents nil value in app)
    normalized['latitude'] = str(record.get('latitude', '')).strip()
    normalized['longitude'] = str(record.get('longitude', '')).strip()
    
    return normalized

def main():
    input_filename = "production_snapshot.json"
    output_filename = "cleaned_production_snapshot.json"
    
    if not os.path.exists(input_filename):
        print(f"Error: Target initialization source '{input_filename}' not found.")
        return

    print(f"Reading {input_filename}...")
    with open(input_filename, 'r', encoding='utf-8') as f:
        try:
            raw_data = json.load(f)
        except json.JSONDecodeError as e:
            print(f"Failed to decode initial file formatting structure: {e}")
            return

    # Phase 1: Strip leading and trailing whitespace hidden inside key definitions
    sanitized_keys_data = clean_keys(raw_data)

    # Phase 2: Process collection rows
    processed_records = []
    if isinstance(sanitized_keys_data, list):
        for index, item in enumerate(sanitized_keys_data):
            processed_records.append(normalize_record(item))
    else:
        processed_records.append(normalize_record(sanitized_keys_data))

    print(f"Writing parsed results ({len(processed_records)} records) to {output_filename}...")
    with open(output_filename, 'w', encoding='utf-8') as f:
        json.dump(processed_records, f, indent=2, ensure_ascii=False)
        
    print("Optimization execution complete.")

if __name__ == "__main__":
    main()
