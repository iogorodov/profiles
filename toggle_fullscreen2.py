import sublime
import sublime_plugin


class ToggleFullscreen2(sublime_plugin.TextCommand):
    def run(self, edit):
        window = self.view.window()
        window.run_command("toggle_full_screen")
        if window.get_tabs_visible():
            window.set_tabs_visible(False)
            window.set_menu_visible(False)
            window.set_status_bar_visible(False)
        else:
            window.set_tabs_visible(True)
            window.set_menu_visible(True)
            window.set_status_bar_visible(True)
