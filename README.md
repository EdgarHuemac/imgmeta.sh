# imgmeta.sh

A small bash wrapper for ExifTool that filters image metadata to show only potential leaks (author, email, GPS, software, etc.). Intended for quick pentesting recon. 

## Usage
```bash
./imgmeta.sh          # current directory
./imgmeta.sh /path/to/folder
```

## Usage
```
exiftool
```

## Features
- Clean output focused on security-relevant tags
- Highlights potential leaks
- Supports JPG, PNG, GIF, TIFF, WebP, etc.

## future improvements? 
- add a -csv mode for bulk export: exiftool -csv ... > report.csv
- option to strip metadata: Add a -clean flag that runs exiftool -all= -overwrite_original file
- recurse with progress: Already recursive via find; add | pv if you install it.
- colors?

### ^M error quick fix
For Windows, there's an issue is Windows line endings (^M). This happens when copying code from Windows or certain web pages. Here's a quick fix. Perhaps I'll fix it later.
```bash
# using dos2unix
dos2unix imgmeta.sh
chmod +x imgmeta.sh
./imgmeta.sh
```
alternatives if you don't have dos2unix:
```bash
# Option 1: using sed
sed -i 's/\r$//' imgmeta.sh
```
```bash
# Option 2: using tr
tr -d '\r' < imgmeta.sh > imgmeta.sh.tmp && mv imgmeta.sh.tmp imgmeta.sh
```

