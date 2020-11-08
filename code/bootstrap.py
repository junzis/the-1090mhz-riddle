import os
import matplotlib as mpl
import matplotlib.pyplot as plt

plt.style.use("grayscale")

blue = "#1f77b4"
orange = "#ff7f0e"
green = "#2ca02c"
red = "#d62728"
purple = "#e377c2"


def fig(x, y):
    mpl.rc("figure", figsize=(x, y))


mpl.rc("font", size=12)
mpl.rc("axes", labelpad=5, linewidth=1)
mpl.rc("font", family="Charter, Utopia, serif")
mpl.rc("lines", linewidth=1.5, markersize=8)
mpl.rc("grid", color="darkgray", linestyle=":")
mpl.rc("legend", markerscale=0.9, columnspacing=0.5, fontsize=10)
mpl.rc("savefig", bbox="tight")
plt.rc("axes", axisbelow=True)
mpl.rc("ytick", right=True, labelright=True, left=False, labelleft=False)

paper_root = os.path.dirname(os.path.realpath(__file__)) + "/../"


def handlefig(func):
    def wrapper_handlefig(*args, **kwargs):
        plot = func(*args, **kwargs)

        tight = kwargs.get("tight", True)
        save = kwargs.get("save", False)
        chap = kwargs.get("chap", False)
        name = kwargs.get("name", None)

        if tight:
            plot.tight_layout()

        if save:
            plot.savefig(
                paper_root + "figures/{}/{}.pdf".format(chap, name), bbox_inches="tight"
            )
            plot.close()
        else:
            plt.show()

    return wrapper_handlefig
