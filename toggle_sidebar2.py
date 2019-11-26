import sublime
import sublime_plugin


class ToggleSidebar2(sublime_plugin.TextCommand):
    def run(self, edit):
        window = self.view.window()
        if window.is_sidebar_visible():
            window.set_sidebar_visible(False)
        else:
            window.set_sidebar_visible(True)
            window.run_command("reveal_in_side_bar")
