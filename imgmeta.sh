#!/bin/bash
# imgmeta.sh - Filter image metadata for potential leaks (pentesting)
# Usage: ./imgmeta.sh [directory]  (defaults to current dir)
# Requires: exiftool

set -euo pipefail

# Relevant tags for security review (expandable)
RELEVANT_TAGS=(
  # Personal & Identity
  "Author" "Creator" "Artist" "By-line" "XMP:Creator" "Credit" "Contact"
  "Email" "WorkEmail" "CreatorWorkEmail" "Phone" "PersonInImage"
  
  # Ownership & Intellectual Property
  "Copyright" "Rights" "OwnerName" "CopyrightNotice" "UsageTerms"
  "CreditLine" "Source" "WebStatement" "License"
  
  # System & Application Environment
  "Software" "CreatorTool" "Make" "Model" "SerialNumber" "FirmwareVersion"
  "LensModel" "LensID" "Application" "Producer" "History" "DocumentID"
  "InstanceID" "OriginalDocumentID" "ToolName" "Version" "ModifyDate"
  "CreateDate" "DateTimeOriginal" "TimeZoneOffset" "FileSource"
  
  # Description & Contextual Data
  "Description" "Comment" "UserComment" "Title" "Subject" "Keywords"
  "Caption" "Caption-Abstract" "Instructions" "Headline" "Rating"
  
  # Geolocation & Mapping
  "GPSLatitude" "GPSLongitude" "GPSPosition" "GPSAltitude"
  "GPSMapDatum" "GPSDestBearing" "GPSImgDirection" "GPSTimeStamp"
  "GPSProcessingMethod" "GPSAreaInformation"
  
  # Organizational & Workflow
  "Company" "Organization" "Manager" "Department" "Project"
  "LastModifiedBy" "Company" "TotalEditTime" "Template" "Revision"
  "Manager" "AssetID" "RatingPercent"
  
  # Deep Technical & Hidden Tags
  "ICC_Profile" "ProfileDescription" "ProfileCreator"
  "ThumbnailImage" "PreviewImage" "XMP-xmpMM:History"
  "XMP-xmpMM:DerivedFrom" "XMP-xmpMM:DocumentID"
  "XMP-xmpMM:InstanceID" "XMP-xmpMM:OriginalDocumentID"
  "XMP-pdf:Producer" "XMP-pdf:Keywords"
)

DIR="${1:-.}"

echo "=== Image Metadata Leak Check ==="
echo "Scanning: $DIR"
echo "Relevant tags only (potential PII/leaks):"
echo "----------------------------------------"

# Process supported image files
find "$DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o \
                       -iname "*.gif" -o -iname "*.tiff" -o -iname "*.webp" -o \
                       -iname "*.bmp" -o -iname "*.heic" \) -print0 | \
while IFS= read -r -d '' file; do
    echo -e "\n📁 $file"
    
    # Run exiftool with only relevant tags + some common groups
    # Use -q -q for quieter output, -G for group names, -S for short format
    output=$(exiftool -q -q -G -S -s \
        "${RELEVANT_TAGS[@]/#/-}" "$file" 2>/dev/null || true)
    
    if [[ -n "$output" ]]; then
        echo "$output"
        
        # Highlight potential sensitive content (simple grep-based)
        if echo "$output" | grep -qE "Email|Creator|Author|GPS|Phone|Company|Serial"; then
            echo "⚠️  POTENTIAL LEAK detected in above tags"
        fi
    else
        echo "   (No relevant metadata found)"
    fi
done

echo -e "\nDone. Review highlighted items."