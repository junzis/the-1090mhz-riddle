import sys
import numpy as np
import matplotlib.pyplot as plt
import bootstrap

R = 6371000

Hr = np.arange(0, 301, 100)
Ht = np.arange(0, 12000, 100)


@bootstrap.handlefig
def plot(*args, **kwargs):
    bootstrap.fig(6, 4)
    ax = plt.subplot(111)

    for hr in Hr:
        d = (np.arccos(R / (R + hr)) + np.arccos(R / (R + Ht))) * R
        d = d / 1000
        ax.plot(Ht / 1000, d, label="Receiver height: {} m".format(hr))

    ax.set_ylabel("Maximum range (km)")
    ax.set_xlabel("Aicraft altitude (km)")
    ax.set_ylim([0, 500])
    plt.legend(loc="lower right")
    plt.grid()
    return plt


if __name__ == "__main__":

    save = sys.argv[1] if len(sys.argv) > 1 else False
    plot(save=save, chap="quickstart", name="max_range_curve")
