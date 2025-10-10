from pathlib import Path

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

save_dir = Path(__file__).resolve().parent.parent

mpl.rcParams.update({
    "figure.constrained_layout.use": True,
    "axes.titlesize": 8, "axes.labelsize": 8,
    "xtick.labelsize": 8, "ytick.labelsize": 8,
    "savefig.dpi": 400,
    "savefig.bbox": "standard",
    "savefig.pad_inches": 0.01,
    "savefig.transparent": False,
})

save_path = Path(save_dir, "layers_of_square_function.png")

def layers_of_square_function():
    fig, ax = plt.subplots(figsize=(3.2, 2.6))

    x = np.linspace(-5, 5, 100)
    y = np.linspace(-5, 5, 100)
    X, Y = np.meshgrid(x, y)
    Z = X**2 + Y**2

    levels = np.array([1, 4, 8, 16])
    cs = ax.contour(X, Y, Z, levels=levels, colors='0.3', linewidths=0.8)

    fmt = {lev: rf"{lev:g}" for lev in levels}
    ax.clabel(cs, fmt=fmt, inline=True, fontsize=7)

    C = 8.0
    x0, y0 = -2.0, 2.0

    def inter_y_at_x(x0, C, pick_sign=+1):
        val = C - x0**2
        return np.nan if val < 0 else pick_sign * np.sqrt(val)

    def inter_x_at_y(y0, C, pick_sign=+1):
        val = C - y0**2
        return np.nan if val < 0 else pick_sign * np.sqrt(val)

    ys = inter_y_at_x(x0, C, np.sign(y0) or 1)
    xs = inter_x_at_y(y0, C, np.sign(x0) or 1)

    P = np.array([xs, ys])

    ax.plot([x0, x0], [0, ys], ls='--', lw=1.0, color='black')
    ax.plot([0, xs], [y0, y0], ls='--', lw=1.0, color='black')
    ax.scatter(*P, s=18, facecolors='white', edgecolors='black', zorder=2)
    ax.text(P[0]-0.5, P[1]+0.3, "(-2)² + 2²", fontsize=6, rotation=30)

    ax.set_xlabel('X')
    ax.set_ylabel('Y')
    ax.axhline(0, color='black', lw=0.8)
    ax.axvline(0, color='black', lw=0.8)

    ax.set_aspect('equal', 'box')


    plt.savefig(save_path)

if __name__ == "__main__":
    layers_of_square_function()