"""
Script to generate app launcher icons from the Island Ping logo.
This extracts the app icon from the combined image and generates all required sizes.
"""

from PIL import Image
import os

# Paths
base_path = r"C:\Users\Deze_Tingz\AndroidStudioProjects\Island_Ping"
source_image = os.path.join(base_path, "images", "island_ping_logo_.png")
android_res_path = os.path.join(base_path, "android", "app", "src", "main", "res")

# Android icon sizes (mipmap)
android_sizes = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

# Foreground icon sizes (drawable) - slightly larger for adaptive icons
foreground_sizes = {
    "drawable-mdpi": 108,
    "drawable-hdpi": 162,
    "drawable-xhdpi": 216,
    "drawable-xxhdpi": 324,
    "drawable-xxxhdpi": 432,
}

def extract_app_icon(source_path):
    """Extract the rounded app icon from the combined logo image."""
    img = Image.open(source_path)
    width, height = img.size

    # The app icon (rounded square) is in the top-right area of the image
    # Fine-tuned coordinates to capture the complete icon with full island
    left = 553
    top = 67
    right = 810
    bottom = 325  # Extended further to get full island

    app_icon = img.crop((left, top, right, bottom))
    return app_icon

def extract_foreground_icon(source_path):
    """Extract just the island+wifi symbol for adaptive icon foreground."""
    img = Image.open(source_path)
    width, height = img.size

    # The logo symbol (island with wifi) without text - top left area
    left = int(width * 0.08)
    top = int(height * 0.05)
    right = int(width * 0.35)
    bottom = int(height * 0.35)

    foreground = img.crop((left, top, right, bottom))
    return foreground

def generate_icons():
    """Generate all required icon sizes."""
    print("Loading source image...")

    # Extract the app icon
    app_icon = extract_app_icon(source_image)
    print(f"Extracted app icon: {app_icon.size}")

    # Save extracted icon for reference
    extracted_path = os.path.join(base_path, "images", "app_icon_extracted.png")
    app_icon.save(extracted_path)
    print(f"Saved extracted icon to: {extracted_path}")

    # Generate Android mipmap icons
    print("\nGenerating Android launcher icons...")
    for folder, size in android_sizes.items():
        output_dir = os.path.join(android_res_path, folder)
        os.makedirs(output_dir, exist_ok=True)

        resized = app_icon.resize((size, size), Image.Resampling.LANCZOS)
        output_path = os.path.join(output_dir, "ic_launcher.png")
        resized.save(output_path)
        print(f"  Created: {folder}/ic_launcher.png ({size}x{size})")

    # Extract and generate foreground icons for adaptive icons
    print("\nGenerating foreground icons for adaptive icons...")
    foreground = extract_foreground_icon(source_image)

    for folder, size in foreground_sizes.items():
        output_dir = os.path.join(android_res_path, folder)
        os.makedirs(output_dir, exist_ok=True)

        # Create a new image with padding for adaptive icon safe zone
        padded_size = size
        new_img = Image.new('RGBA', (padded_size, padded_size), (0, 0, 0, 0))

        # Resize foreground to fit within safe zone (66% of total)
        inner_size = int(size * 0.66)
        resized_fg = foreground.resize((inner_size, inner_size), Image.Resampling.LANCZOS)

        # Center it
        offset = (padded_size - inner_size) // 2
        new_img.paste(resized_fg, (offset, offset), resized_fg if resized_fg.mode == 'RGBA' else None)

        output_path = os.path.join(output_dir, "ic_launcher_foreground.png")
        new_img.save(output_path)
        print(f"  Created: {folder}/ic_launcher_foreground.png ({size}x{size})")

    print("\nDone! Icons generated successfully.")
    print("\nNote: You may need to uninstall and reinstall the app to see the new icon.")

if __name__ == "__main__":
    generate_icons()
