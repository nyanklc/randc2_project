import tkinter as tk
from PIL import Image, ImageTk
import os
import csv
from datetime import datetime
import math


#############################
maze_file = "data/pacman_maze.png"
WIDTH = 800
HEIGHT = 800
SMOOTH_STEPS = 20
#############################

def add_pts(pt1, pt2):
    return [pt1[0] + pt2[0], pt1[1] + pt2[1]]


class Canvas:
    def __init__(self, root):
        self.root = root
        self.root.title("R&C2 Project")

        control_frame = tk.Frame(root)
        control_frame.pack(side="top", fill="x")

        tk.Button(control_frame, text="Clear", command=self.clear_points).pack(side="left", padx=5)
        tk.Button(control_frame, text="Print Path", command=self.print_path).pack(side="left", padx=5)
        tk.Button(control_frame, text="Print SMooth Path", command=self.print_smooth_path).pack(side="left", padx=5)
        tk.Button(control_frame, text="SAVE", command=self.save).pack(side="left", padx=5)

        instructions = (
            "left click to insert points, the smoothed path is calculated on the fly.\n"
            "at the end, hold right mouse button and draw an arrow for the setpoint and orientation (regulation task), then you can save.\n"
            "green: start of the path, red: end of the path, black: intermediate points, magenta: setpoint (regulation task)\n"
            "the y coordinates are negated during save, since y direction is downwards here.\n"
            "the setpoint coordinates are the second to last entry in the saved csv files, and the last one is the angle it has (written twice)"
        )
        tk.Label(root, text=instructions, justify="left").pack(anchor="w", padx=5, pady=10)

        self.canvas = tk.Canvas(
            root,
            width=WIDTH,
            height=HEIGHT,
            bg="white"
        )
        self.canvas.pack()

        # maze
        overlay = Image.open(maze_file).convert("RGBA")
        overlay = overlay.resize((WIDTH, HEIGHT))
        self.overlay = ImageTk.PhotoImage(overlay)
        self.canvas.create_image(0, 0, image=self.overlay, anchor="nw")

        # path
        self.points = []
        self.offset = None
        self.smooth_points = []
        self.setpoint = None
        self.setpoint_angle = None
        self.setpoint_arrow = None

        # binds
        self.canvas.bind("<Button-1>", self.add_point)

        self.canvas.bind("<Button-3>", self.start_setpoint)
        self.canvas.bind("<B3-Motion>", self.update_setpoint)
        self.canvas.bind("<ButtonRelease-3>", self.finish_setpoint)

    def redraw(self):
        self.canvas.delete("all")
        self.canvas.create_image(0, 0, image=self.overlay, anchor="nw")

        if not self.offset: return

        # curve
        curve = []
        pts = [self.points[0]] + self.points + [self.points[-1]]
        for i in range(1, len(self.smooth_points)):
            x1, y1 = add_pts(self.smooth_points[i-1] , self.offset)
            x2, y2 = add_pts(self.smooth_points[i] , self.offset)
            self.canvas.create_line(x1, y1, x2, y2, fill="blue", width=5)

        # points
        r = 10
        for p in self.points:
            x, y = add_pts(p , self.offset)
            self.canvas.create_oval(x-r, y-r, x+r, y+r, fill="black", outline="")

        if len(self.points) < 2:
            return

        # start/end
        spoint = add_pts(self.points[0] , self.offset)
        epoint = add_pts(self.points[-1] , self.offset)
        r = 12
        self.canvas.create_oval(spoint[0]-r, spoint[1]-r, spoint[0]+r, spoint[1]+r, fill="green", outline="")
        r = 12
        self.canvas.create_oval(epoint[0]-r, epoint[1]-r, epoint[0]+r, epoint[1]+r, fill="red", outline="")

    def add_point(self, event):
        point = [event.x, event.y]

        if len(self.points) == 0:
            self.offset = point
        self.points.append([point[0] - self.offset[0], point[1] - self.offset[1]])
        self.build_smooth_path()

        self.redraw()

    def build_smooth_path(self):
        self.smooth_points.clear()

        if len(self.points) < 2:
            return

        pts = [self.points[0]] + self.points + [self.points[-1]]

        for i in range(len(pts) - 3):
            p0, p1, p2, p3 = pts[i:i+4]

            for step in range(SMOOTH_STEPS):
                t = step / SMOOTH_STEPS
                x, y = self.catmull_rom(p0, p1, p2, p3, t)
                self.smooth_points.append([x, y])

    # TODO: add citation
    '''
    @incollection{CATMULL1974317,
    title = {A CLASS OF LOCAL INTERPOLATING SPLINES},
    editor = {ROBERT E. BARNHILL and RICHARD F. RIESENFELD},
    booktitle = {Computer Aided Geometric Design},
    publisher = {Academic Press},
    pages = {317-326},
    year = {1974},
    isbn = {978-0-12-079050-0},
    doi = {https://doi.org/10.1016/B978-0-12-079050-0.50020-5},
    url = {https://www.sciencedirect.com/science/article/pii/B9780120790500500205},
    author = {Edwin Catmull and Raphael Rom},
    abstract = {Publisher Summary
    This chapter discusses a general class of splines having some useful characteristics for design purposes. Some known splines are special cases of these splines. Of particular interest, however, is the subclass of these splines, which is local and interpolating. The chapter discusses the following parameters for blending polynomials to demonstrate a class of splines: differentiability, degree of polynomials to be blended , the localness of the spline, which determines whether it interpolates or approximates, and the type of blending function. By taking the Cartesian cross product of two splines, one can get a bivariate surface that interpolates a grid of points.}
    }
    '''
    # P(t)=0.5∗((2∗P1)+(−P0+P2)∗t+(2∗P0−5∗P1+4∗P2−P3)∗t2+(−P0+3∗P1−3∗P2+P3)∗t3)
    # maybe use the generalized version so we can tweak it
    def catmull_rom(self, p0, p1, p2, p3, t):
        t2 = t * t
        t3 = t2 * t3 if False else t * t * t  # avoids recompute confusion

        x = 0.5 * (
            2*p1[0] +
            (-p0[0] + p2[0]) * t +
            (2*p0[0] - 5*p1[0] + 4*p2[0] - p3[0]) * t2 +
            (-p0[0] + 3*p1[0] - 3*p2[0] + p3[0]) * t3
        )

        y = 0.5 * (
            2*p1[1] +
            (-p0[1] + p2[1]) * t +
            (2*p0[1] - 5*p1[1] + 4*p2[1] - p3[1]) * t2 +
            (-p0[1] + 3*p1[1] - 3*p2[1] + p3[1]) * t3
        )

        return x, y

    def start_setpoint(self, event):
        if not self.offset: return
        self.setpoint = (event.x - self.offset[0], event.y - self.offset[1])
        if self.setpoint_arrow:
            self.canvas.delete(self.setpoint_arrow)
            self.setpoint_arrow = None

    def update_setpoint(self, event):
        if not self.setpoint:
            return

        x0, y0 = self.setpoint
        x1, y1 = event.x, event.y

        if self.setpoint_arrow:
            self.canvas.delete(self.setpoint_arrow)

        self.setpoint_arrow = self.canvas.create_line(
            x0 + self.offset[0], y0 + self.offset[1], x1, y1,
            arrow=tk.LAST, fill="magenta", width=8
        )

    def finish_setpoint(self, event):
        if not self.setpoint:
            return

        x0, y0 = self.setpoint
        x1, y1 = event.x - self.offset[0], event.y - self.offset[1]

        self.setpoint_angle = math.atan2(y0 - y1, x1 - x0) # reverse y

    def clear_points(self):
        self.points.clear()
        self.offset = None
        self.smooth_points.clear()
        self.setpoint = None
        self.setpoint_angle = None
        self.redraw()

    def print_path(self):
        print("path = [")
        for p in self.points:
            print(f"{p[0]}, {-p[1]};")
        print("];")
        print(f"setpoint: ({self.setpoint[0]}, {-self.setpoint[1]}), angle: {self.setpoint_angle} ({math.degrees(self.setpoint_angle) if self.setpoint_angle is not None else "None"} degrees)")

    def print_smooth_path(self):
        print("smooth_path = [")
        for p in self.smooth_points:
            print(f"{p[0]}, {-p[1]};")
        print("];")

    def save(self):
        if not self.points or not self.smooth_points or self.setpoint is None or self.setpoint_angle is None:
            print("sth missing.")
            return

        self.print_path()
        # self.print_smooth_path()

        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        folder = f"data/path_{timestamp}"
        os.makedirs(folder, exist_ok=True)

        control_csv = os.path.join(folder, "control_path.csv")
        with open(control_csv, "w", newline="") as f:
            writer = csv.writer(f)
            for p in self.points:
                writer.writerow([p[0], -p[1]])
            writer.writerow([self.setpoint[0], -self.setpoint[1]])
            writer.writerow([self.setpoint_angle, self.setpoint_angle])

        smooth_csv = os.path.join(folder, "smooth_path.csv")
        with open(smooth_csv, "w", newline="") as f:
            writer = csv.writer(f)
            for p in self.smooth_points:
                writer.writerow([p[0], -p[1]])
            writer.writerow([self.setpoint[0], -self.setpoint[1]])
            writer.writerow([self.setpoint_angle, self.setpoint_angle])

        ps_path = os.path.join(folder, "canvas.ps")
        png_path = os.path.join(folder, "canvas.png")

        self.canvas.postscript(file=ps_path, colormode="color")
        img = Image.open(ps_path)
        img.save(png_path, "png")

        print(f"saved to folder: {folder}")


if __name__ == "__main__":
    root = tk.Tk()
    app = Canvas(root)
    root.mainloop()
