import sys
import subprocess
from PyQt6.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QLabel, QLineEdit, QPushButton, QMessageBox
)
from PyQt6.QtGui import QIcon

class IconExporter(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("KDE Icon Exporter")
        self.setGeometry(400, 400, 400, 180)

        layout = QVBoxLayout()
        layout.addWidget(QLabel("Icon Name:"))

        self.icon_name_input = QLineEdit()
        layout.addWidget(self.icon_name_input)

        self.button_pick_icon = QPushButton("Pick Icon")
        self.button_pick_icon.clicked.connect(self.pick_icon)
        layout.addWidget(self.button_pick_icon)

        self.button_export_svg = QPushButton("Export SVG")
        self.button_export_svg.clicked.connect(self.export_svg)
        layout.addWidget(self.button_export_svg)

        self.setLayout(layout)

    def pick_icon(self):
        """Open KDE icon picker using kdialog --geticon"""
        try:
            # '--geticon' opens the icon chooser; optional arguments: group and context
            result = subprocess.run(
                ["kdialog", "--geticon", "--title", "Select an Icon"],
                capture_output=True,
                text=True
            )
            icon_name = result.stdout.strip()
            if icon_name:
                self.icon_name_input.setText(icon_name)
        except FileNotFoundError:
            QMessageBox.critical(
                self, "Error",
                "kdialog is not installed. Install it with: sudo dnf install kdialog"
            )

    def export_svg(self):
        icon_name = self.icon_name_input.text().strip()
        if not icon_name:
            QMessageBox.warning(self, "Error", "Please enter an icon name")
            return

        icon = QIcon.fromTheme(icon_name)
        if icon.isNull():
            QMessageBox.critical(
                self, "Error",
                f"Icon '{icon_name}' not found in current theme."
            )
            return

        sizes = icon.availableSizes()
        size = max(max(s.width(), s.height()) for s in sizes) if sizes else 512

        png_file = f"{icon_name}.png"
        pixmap = icon.pixmap(size, size)
        pixmap.save(png_file)

        svg_file = f"{icon_name}.svg"
        command = ["magick", png_file, "-background", "none", "-colors", "16", svg_file]

        try:
            subprocess.run(command, check=True)
            QMessageBox.information(
                self, "Success",
                f"Saved PNG: '{png_file}'\nSaved SVG: '{svg_file}'"
            )
        except subprocess.CalledProcessError as e:
            QMessageBox.critical(
                self, "Error",
                f"ImageMagick conversion failed: {e}"
            )

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = IconExporter()
    window.show()
    sys.exit(app.exec())
