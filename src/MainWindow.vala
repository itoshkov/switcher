public class Switcher.MainWindow: Hdy.Window {

    private GLib.Settings settings;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application
        );
    }        
    
    construct {

        Hdy.init ();

        var icon_mode = new Granite.Widgets.ModeButton ();
        icon_mode.append_icon ("ionicons-sun-symbolic", Gtk.IconSize.BUTTON);
        icon_mode.append_icon ("ionicons-moon-symbolic", Gtk.IconSize.BUTTON);


        var header = new Hdy.HeaderBar () {
            custom_title = icon_mode,
            decoration_layout = "close:",
            has_subtitle = false,
            show_close_button = true,
            can_focus = false
        };
        header.get_style_context ().add_class ("flat");

        var deck = new Hdy.Deck () {
            can_swipe_back = true,
            can_swipe_forward = true,
            vhomogeneous = true,
            hhomogeneous = true,
            expand = true,
            transition_type = Hdy.DeckTransitionType.SLIDE
        };

        var light_mode_view = new Switcher.Views.LightModeView ();
        var dark_mode_view = new Switcher.Views.DarkModeView ();

        deck.add (light_mode_view);
        deck.add (dark_mode_view);

        var gtk_settings = Gtk.Settings.get_default ();

        deck.notify["transition-running"].connect (() => {
            if (!deck.transition_running) {
                if(deck.visible_child == light_mode_view) {
                    icon_mode.set_active (0);
                    gtk_settings.gtk_application_prefer_dark_theme = (false);
                }

                if(deck.visible_child == dark_mode_view) {
                    icon_mode.set_active (1);
                    gtk_settings.gtk_application_prefer_dark_theme = (true);
                }
            }
        });

        icon_mode.mode_changed.connect ((widget) => {
            if(icon_mode.selected == 0) {
                deck.visible_child = light_mode_view;
                gtk_settings.gtk_application_prefer_dark_theme = (false);
            }

            if(icon_mode.selected == 1) {
                deck.visible_child = dark_mode_view;
                gtk_settings.gtk_application_prefer_dark_theme = (true);
            }
        });

        var grid = new Gtk.Grid (){
            column_homogeneous = true,
            expand = true,
            orientation = Gtk.Orientation.VERTICAL
        };
        grid.add (header);
        grid.add (deck);

        icon_mode.set_active (0);

        settings = new GLib.Settings ("com.github.jeysonflores.switcher");

        move (settings.get_int ("pos-x"), settings.get_int ("pos-y"));
        resize (settings.get_int ("window-width"), settings.get_int ("window-height"));

        add (grid);
        /* 
        File file = File.new_for_path ("/home/jeyson/Imágenes/a.jpg");
        var contractor = App.Contractor.get_contract ();

        App.Contractor.set_wallpaper_by_contract (file);*/
    }

    public override bool delete_event (Gdk.EventAny event) {   

        int root_x, root_y;
        get_position (out root_x, out root_y);

        int width, height;
        get_size (out width, out height);

        settings.set_int ("window-width", width);
        settings.set_int ("window-height", height);

        settings.set_int ("pos-x", root_x);
        settings.set_int ("pos-y", root_y);
        
        return false;
    }
}