# KDE Icon Exporter
A simple program to extract system icons as **.svg** and **.png** files.

## Installation

This command will download **install.sh** and run the **start.sh** script:
```bash
bash <(curl -s https://raw.githubusercontent.com/MeltingReactor/KDE-Icon-Exporter/main/install.sh) && bash start.sh
```
**The installation script is intended for use on:**
- Fedora 44

**With KDE versions:**
- 6.6.4

> [!TIP]
> **Arch Users**: Run this command to install:
> ```bash
> yes | sudo pacman -S python-pip && yes | sudo pacman -S python-pyqt6 && bash <(curl -s https://raw.githubusercontent.com/MeltingReactor/KDE-Icon-Exporter/main/installarch.sh) && bash start.sh
> ```


## Usage
Once installation has finished, the app will open. If you wish to reopen the app, navigate to the folder where you ran `install.sh` and from that folder run this command:
```bash
bash start.sh
```
> [!IMPORTANT]
> Currently, the .svg file conversion has some issues.
> I recommend just using the raster image.


---

<details>
  <summary><strong>Portable versions</strong></summary>

  If you wish to run the app standalone with python, download the [main.py](https://github.com/MeltingReactor/KDE-Icon-Exporter/blob/main/main.py) file and run it with
  ```bash
  python3 main.py
  ```

</details>

## Uninstallation
When installed with the **installation script**, the app will installed all the required dependencies:
- Python3
- Qt6
- kdialog
- git

To unistall, run this command from folder where you ran **install.sh**:
```bash
rm -rf KDEiconExporter start.sh install.log
```

For the portable version, delete **main.py**.

## License
This project is licenced under the [CC0 license](LICENSE).
