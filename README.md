# GMT Topography — Shaded-Relief Topographic and Bathymetric Mapping Scripts

A large collection of GMT (Generic Mapping Tools) shell scripts for producing publication-quality shaded-relief topographic and bathymetric maps of countries, regions, seas and trenches worldwide. The scripts have been used to generate map figures across numerous cartographic and geoscientific publications by the author.

## What the scripts do

Each script builds a complete map from a global digital elevation / bathymetry grid, typically chaining:

- grid clipping and subsetting (grdcut) over a study-area bounding box
- colour palette generation (makecpt) with custom and cpt-city CPTs
- shaded relief and raster rendering (grdgradient, grdimage) with illumination
- contour / isoline overlays (grdcontour)
- coastlines, political borders, rivers and lakes (pscoast / coast)
- Digital Chart of the World (DCW) polygon masking and psclip country clipping
- colour scale bars (psscale), grids, frames, scale bars and directional roses (psbasemap)
- annotations, city symbols, place and hydronym labels (pstext, psxy)
- global locator insets (psbasemap + pscoast, orthographic projection)
- export to raster (psconvert) at high resolution

## Data sources

Global elevation and bathymetry grids: ETOPO1, GEBCO (15 arc-second), SRTM and GLOBE. Vector overlays from GSHHG shorelines and the Digital Chart of the World (DCW) via GMT.

## File naming

Scripts follow GMT-01-XX.sh, where XX is an ISO 3166-1 country code (e.g. KE = Kenya, MN = Mongolia, BR = Brazil) or a region / feature tag. Variants encode the DEM or theme used, e.g. -ETOPO1, -GEBCO, -SRTM, -masked (clipped), -Poly (polygon), or a specific locality.

## Requirements

- GMT 6.x (Generic Mapping Tools): https://www.generic-mapping-tools.org
- A POSIX shell (bash/sh)
- The relevant global grid(s) (ETOPO1 / GEBCO / SRTM / GLOBE) available locally
- GDAL (optional) for grid statistics (gdalinfo)

## Usage

Place the required grid in the working directory, adjust the -R region and -J projection at the top of the chosen script, then run:

    bash GMT-01-KE.sh

The script writes a PostScript file and converts it to a raster image (JPG/PNG) via psconvert.

## Author and citation

Polina Lemenkova
ORCID: https://orcid.org/0000-0002-5759-1089

These scripts accompany figures in the author's cartographic and geoscientific papers; please cite the specific article a given map appears in. The full publication list is available via the ORCID record above.

## License

See the LICENSE file in this repository.
