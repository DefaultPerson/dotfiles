# Fix: Nautilus Media Thumbnails (Fedora 43+)

## Problem
Image thumbnails not showing in Nautilus — only placeholders.

## Solution
```bash
sudo dnf install glycin-thumbnailer
nautilus -q
```
