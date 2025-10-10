from pathlib import Path

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

save_dir = Path(__file__).resolve().parent.parent

mpl.rcParams.update({
    "figure.constrained_layout.use": False,
    "axes.titlesize": 8, "axes.labelsize": 8,
    "xtick.labelsize": 8, "ytick.labelsize": 8,
    "savefig.dpi": 400,
    "savefig.bbox": "standard",
    "savefig.pad_inches": 0.01,
    "savefig.transparent": False,
})

save_path = Path(save_dir, "3d_square_function.png")

def square_function_3d():
    fig = plt.figure(figsize=(3.2, 2.6))
    ax = fig.add_subplot(111, projection='3d')

    def square_function(x, y):
        return x**2 + y**2

    x = y = np.linspace(-5, 5, 20)
    X, Y = np.meshgrid(x, y)
    Z = square_function(X, Y)

    ax.plot_surface(X, Y, Z, cmap='viridis')

    ax.set_xlabel('X')
    ax.set_ylabel('Y')
    ax.set_zlabel('Z')
    ax.set_title('Z = X² + Y²')

    fig.subplots_adjust(left=-0.3, right=1.1, top=0.9, bottom=0.1)

    plt.savefig(save_path)
    plt.close()

if __name__ == "__main__":
    square_function_3d()