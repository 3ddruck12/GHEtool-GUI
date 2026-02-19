"""
script to start the GUI
"""
import logging

import sys
import matplotlib.pyplot as plt
from GHEtoolGUI.adapt_GHEtool import _plot_load_duration, _plot_temperature_profile
from pathlib import Path
from platform import system
from sys import argv
from ScenarioGUI import load_config
if getattr(sys, 'frozen', False):
    # we are running in a bundle
    bundle_dir = Path(sys._MEIPASS)
    load_config(bundle_dir.joinpath("GHEtoolGUI", "gui_config.ini"))
else:
    # we are running in a normal Python environment
    load_config(Path(__file__).parent.joinpath("gui_config.ini"))

os_system = system()
is_frozen = getattr(sys, 'frozen', False) # pragma: no cover


def run(path_list=None):  # pragma: no cover
    pyi_splash = None
    if is_frozen:
        try:
            import pyi_splash as _pyi_splash
            _pyi_splash.update_text('Loading .')
            pyi_splash = _pyi_splash
        except (ImportError, RuntimeError, KeyError):
            pyi_splash = None
    if os_system == 'Windows':
        from ctypes import windll as ctypes_windll
    from sys import exit as sys_exit

    if is_frozen and pyi_splash:
        pyi_splash.update_text('Loading ..')

    from PySide6.QtWidgets import QApplication as QtWidgets_QApplication
    from PySide6.QtWidgets import QMainWindow as QtWidgets_QMainWindow
    from GHEtool import Borefield
    from GHEtoolGUI.data_2_borefield_func import data_2_borefield
    from GHEtoolGUI.gui_classes.translation_class import Translations
    from GHEtoolGUI.gui_structure import GUI
    from GHEtoolGUI.gui_classes.gui_combine_window import MainWindow
    import ScenarioGUI.global_settings as globs

    # adapt borefield class
    Borefield._plot_temperature_profile = _plot_temperature_profile
    Borefield._plot_load_duration = _plot_load_duration

    if is_frozen and pyi_splash:
        pyi_splash.update_text('Loading ...')

    # init application
    app = QtWidgets_QApplication()
    # Set application icon for taskbar and window decorations (PNG works better on Linux)
    from PySide6.QtGui import QIcon
    icon_path = Path(globs.FOLDER) / "icons" / "icon_squared.png"
    if not icon_path.exists():
        icon_path = Path(globs.FOLDER) / "icons" / globs.ICON_NAME
    if icon_path.exists():
        app.setWindowIcon(QIcon(str(icon_path)))
    if os_system == 'Windows':
        # set version and id
        myAppID = f'{globs.GUI_NAME} v{globs.VERSION}'  # arbitrary string
        ctypes_windll.shell32.SetCurrentProcessExplicitAppUserModelID(myAppID)

    # init window
    window = QtWidgets_QMainWindow()
    # init gui window
    main_window = MainWindow(window, app, GUI, Translations, result_creating_class=Borefield, data_2_results_function=data_2_borefield)
    if is_frozen and pyi_splash:
        pyi_splash.update_text('Loading ...')
    # load file if it is in path list
    if path_list is not None:
        main_window.filename = ([path for path in path_list if path.endswith(f'.{globs.FILE_EXTENSION}')][0], 0)
        main_window.fun_load_known_filename()

    ghe_logger = logging.getLogger()
    ghe_logger.setLevel(logging.INFO)
    # show window
    if is_frozen and pyi_splash:
        try:
            pyi_splash.close()
        except (RuntimeError, AttributeError):
            pass

    ghe_logger.info(f'{globs.GUI_NAME} loaded!')
    window.showMaximized()
    # close app
    sys_exit(app.exec())


if __name__ == "__main__":  # pragma: no cover
    # pass system args like a file to read
    run(argv if len(argv) > 1 else None)
