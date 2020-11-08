import sys
import numpy as np
import pyModeS as pms

import matplotlib.pyplot as plt
import cartopy.crs as ccrs

from cartopy import feature

import bootstrap

land = feature.NaturalEarthFeature(
    "physical", "land", "110m", edgecolor="gray", facecolor="#dddddd", linewidth=0
)


def flat(NL):
    NZ = 15
    a = 1 - np.cos(np.pi / (2 * NZ))
    b = 1 - np.cos(2 * np.pi / NL)
    lat = 180 / np.pi * np.arccos(np.sqrt(a / b))
    return lat


@bootstrap.handlefig
def plot_lat_zones(viewlat, **kwargs):
    projection = ccrs.NearsidePerspective(
        central_latitude=viewlat, central_longitude=5, satellite_height=8000000
    )
    # projection = ccrs.Orthographic(central_latitude=50, central_longitude=5)

    bootstrap.fig(5, 5)
    ax = plt.axes(projection=projection)
    ax.add_feature(land)

    for n in np.arange(1, 16):
        dlat = 360 / (4 * 15)
        lat = dlat * n

        ax.plot(
            np.linspace(-180, 180, 1000),
            lat * np.ones(1000),
            transform=ccrs.Geodetic(),
            color="k",
            lw=1,
        )

        ax.plot(
            np.linspace(-180, 180, 1000),
            -1 * lat * np.ones(1000),
            transform=ccrs.Geodetic(),
            color="k",
            lw=1,
        )

    for n in np.arange(1, 16):
        dlat = 360 / (4 * 15 - 1)
        lat = dlat * n
        # print(lat)

        ax.plot(
            np.linspace(-180, 180, 1000),
            lat * np.ones(1000),
            transform=ccrs.Geodetic(),
            color="k",
            ls="--",
            lw=1,
        )

        ax.plot(
            np.linspace(-180, 180, 1000),
            -1 * lat * np.ones(1000),
            transform=ccrs.Geodetic(),
            color="k",
            ls="--",
            lw=1,
        )

    ax.plot(
        np.linspace(-180, 180, 1000),
        np.zeros(1000),
        transform=ccrs.Geodetic(),
        color="k",
        lw=0.5,
    )

    return plt


@bootstrap.handlefig
def plot_lon_zones(view, **kwargs):

    if view == "full":
        projection = ccrs.NearsidePerspective(
            central_latitude=60, central_longitude=30, satellite_height=8000000
        )
        # projection = ccrs.Orthographic(central_latitude=50, central_longitude=5)
        # projection = ccrs.Miller()
    elif view == "zoom":
        projection = ccrs.Stereographic(central_latitude=60, central_longitude=20)
    else:
        raise RuntimeError("unknown view.")

    bootstrap.fig(5, 5)
    ax = plt.axes(projection=projection)
    ax.add_feature(land)

    lat_prev = 87
    for NL in np.arange(2, 60):
        lat = flat(NL)

        ax.plot(
            np.linspace(-180, 180, 1000),
            lat * np.ones(1000),
            transform=ccrs.Geodetic(),
            color="gray",
            lw=0.5,
        )

        dlon = 360 / NL
        for lon in np.arange(0, 360, dlon):
            ax.plot(
                (lon, lon), (lat, lat_prev), transform=ccrs.Geodetic(), color="k", lw=1
            )

        dlon = 360 / (NL - 1)
        for lon in np.arange(0, 360, dlon):
            ax.plot(
                (lon, lon),
                (lat, lat_prev),
                transform=ccrs.Geodetic(),
                color="gray",
                # ls=":",
                lw=1,
            )

        lat_prev = lat

    if view == "zoom":
        ax.set_extent([-5, 60, 60, 90])

    return plt


if __name__ == "__main__":

    save = sys.argv[1] if len(sys.argv) > 1 else False
    plot_lat_zones(viewlat=60, save=save, chap="adsb", name="cpr_lat_zone_high")
    plot_lat_zones(viewlat=0, save=save, chap="adsb", name="cpr_lat_zone_low")
    plot_lon_zones(view="full", save=save, chap="adsb", name="cpr_lon_zone_full")
    plot_lon_zones(view="zoom", save=save, chap="adsb", name="cpr_lon_zone_zoom")
