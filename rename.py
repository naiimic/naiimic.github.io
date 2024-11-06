import os
import argparse
from pathlib import Path

def increment_high_folders(directory):
    # Convert to absolute path and verify directory exists
    dir_path = Path(directory).resolve()
    if not dir_path.exists() or not dir_path.is_dir():
        print(f"Error: Directory '{directory}' does not exist or is not a directory")
        return
    
    # Get all folders and their numbers
    # Only consider folders that are named with numbers
    numbered_folders = []
    for f in dir_path.iterdir():
        if f.is_dir() and f.name.isdigit():
            numbered_folders.append((f, int(f.name)))
    
    # Sort by number in descending order to avoid conflicts
    # We need to process higher numbers first
    numbered_folders.sort(key=lambda x: x[1], reverse=True)
    
    # Store rename operations
    rename_map = {}
    for folder, number in numbered_folders:
        if number > 160:
            rename_map[folder] = str(number + 1)
    
    if not rename_map:
        print(f"No folders with numbers greater than 160 found in {dir_path}")
        return
    
    # Show preview of changes
    print("\nPlanned rename operations:")
    for old_path, new_name in rename_map.items():
        print(f"{old_path.name} -> {new_name}")
    
    # Ask for confirmation
    response = input("\nProceed with renaming? (y/n): ").lower()
    if response != 'y':
        print("Operation cancelled")
        return
    
    # Perform the renaming
    # Using a temporary prefix to avoid conflicts
    temp_prefix = "TEMP_RENAME_"
    
    # First pass: rename all to temporary names
    for old_path in rename_map:
        temp_name = f"{temp_prefix}{rename_map[old_path]}"
        try:
            old_path.rename(old_path.parent / temp_name)
            print(f"Temporary rename: {old_path.name} -> {temp_name}")
        except Exception as e:
            print(f"Error during temporary rename of {old_path}: {e}")
            continue
    
    # Second pass: rename from temporary names to final names
    for old_path in rename_map:
        temp_name = f"{temp_prefix}{rename_map[old_path]}"
        final_name = rename_map[old_path]
        try:
            (old_path.parent / temp_name).rename(old_path.parent / final_name)
            print(f"Final rename: {temp_name} -> {final_name}")
        except Exception as e:
            print(f"Error during final rename of {temp_name}: {e}")
            continue

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Increment folder numbers greater than 160')
    parser.add_argument('directory', nargs='?', default='.', 
                      help='Directory to process (default: current directory)')
    args = parser.parse_args()
    
    # Execute the renaming
    print(f"Processing directory: {args.directory}")
    increment_high_folders(args.directory)