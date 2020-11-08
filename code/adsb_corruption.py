import sys
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import bootstrap

R = 6371000

Hr = np.arange(0, 301, 100)
Ht = np.arange(0, 12000, 100)


@bootstrap.handlefig
def plot(*args, **kwargs):
    df = pd.read_csv("adsb_corruption.csv")
    df = df.groupby("hour").mean().reset_index()
    df["total"] = df["error"] + df["correct"]
    df["error_rate"] = df["error"] / df["total"]

    bootstrap.fig(7, 5)

    f, (ax1, ax2) = plt.subplots(
        2, 1, gridspec_kw={"height_ratios": [3, 2]}, sharex=True
    )

    ax1.plot(df.hour, df["correct"], label="Correct", color="k", ls="--")
    ax1.plot(df.hour, df["error"], label="Corrupted", color="k", ls=":")
    ax1.plot(df.hour, df["total"], label="Total", color="k")
    ax1.grid()
    ax1.set_ylabel("ADS-B rate (per second)")
    ax1.legend(loc="upper left", fontsize=11)

    ax2.plot(df.hour, df["error_rate"], color="k", marker=".")
    ax2.set_ylim(0, 1)
    ax2.set_xticks(df.hour.unique()[::2])
    ax2.set_ylabel("Error rate")
    ax2.set_yticks(np.arange(0, 1.1, 0.25))
    ax2.grid()

    plt.xticks(rotation=45)

    return plt


if __name__ == "__main__":

    save = sys.argv[1] if len(sys.argv) > 1 else False
    plot(save=save, chap="conclusion", name="adsb_corruption")
