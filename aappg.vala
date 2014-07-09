public class AappgControl : Object {
	protected Gtk.Grid grid;

	public Gtk.Widget get_widget() {
		return this.grid;
	}
}

public class ModeMenuControl : AappgControl {
	public signal void mode_changed(uchar mode);

	private Gtk.Label label;
	private Gtk.ListStore liststore;
	private Gtk.ComboBox combo_box;
	private Gtk.CellRendererText renderer;
	private string[] mode_strings = {"Mode switching","Simple remote","Advanced remote"};
	private uchar[] mode_data = {0x00,0x02,0x04};

	public ModeMenuControl() {
		// Grid for the label and the combo box
		this.grid = new Gtk.Grid();

		// Control's label
		this.label = new Gtk.Label("Mode : ");
		this.grid.add(label);

		// Dropdown list
		this.liststore = new Gtk.ListStore(2,typeof(string),typeof(uchar));

		for (int i = 0; i < this.mode_strings.length; i++) {
			Gtk.TreeIter iter;
			this.liststore.append(out iter);
			this.liststore.set(iter,0,this.mode_strings[i]);
			this.liststore.set(iter,1,this.mode_data[i]);
		}
		this.combo_box = new Gtk.ComboBox.with_model(liststore);
		this.grid.add(combo_box);
		this.renderer = new Gtk.CellRendererText();
		this.combo_box.pack_start(this.renderer,false);
		this.combo_box.set_attributes (renderer,"text",0);
		this.combo_box.set_active(0);
		this.combo_box.changed.connect(() => {
			mode_changed(this.getCurrentValue());
		});
	}
	public uchar getCurrentValue() {
		Gtk.TreeIter iter;
		Value value;
		this.combo_box.get_active_iter(out iter);
		this.liststore.get_value(iter,1,out value);

		return (uchar)value;
	}
}

public class CommandMenuControl : AappgControl {
	private struct Command {
		public string purpose;
		public uchar[] data;

		public Command(string purpose, uchar[] data) {
			this.purpose = purpose;
			this.data = data;
		}
	}

	private Gtk.Label label;
	private Gtk.ListStore liststore;
	private Gtk.ComboBox combo_box;
	private Gtk.CellRendererText renderer;
	private uchar mode = 0x00;
	private Command[] mode_switching_commands = {
		Command(
			"Switch to voice recorder mode",
			{0x01,0x01}
		),
		Command(
			"Switch to simple remote mode",
			{0x01,0x02}
		),
		Command(
			"Switch to advanced remote mode",
			{0x01,0x04}
		),
		Command(
			"Get current mode status",
			{0x03}
		)
	};
	private Command[] simple_remote_commands = {
		Command(
			"Button released",
			{0x00,0x00}
		),
		Command(
			"Play/Pause",
			{0x00,0x01}
		),
		Command(
			"Volume +",
			{0x00,0x02}
		),
		Command(
			"Volume -",
			{0x00,0x04}
		),
		Command(
			"Skip next",
			{0x00,0x08}
		),
		Command(
			"Skip previous",
			{0x00,0x10}
		),
		Command(
			"Next album",
			{0x00,0x20}
		),
		Command(
			"Previous album",
			{0x00,0x40}
		),
		Command(
			"Stop",
			{0x00,0x80}
		),
		Command(
			"Play (won't pause if already playing)",
			{0x00,0x00,0x01}
		),
		Command(
			"Pause (won't play if already paused)",
			{0x00,0x00,0x02}
		),
		Command(
			"Mute mode (toggle)",
			{0x00,0x00,0x04}
		),
		Command(
			"Next playlist",
			{0x00,0x00,0x20}
		),
		Command(
			"Previous playlist",
			{0x00,0x00,0x40}
		),
		Command(
			"Shuffle mode (toggle)",
			{0x00,0x00,0x80}
		),
		Command(
			"Repeat mode (toggle)",
			{0x00,0x00,0x00,0x01}
		),
		Command(
			"iPod off",
			{0x00,0x00,0x00,0x04}
		),
		Command(
			"iPod on",
			{0x00,0x00,0x00,0x08}
		),
		Command(
			"Menu button",
			{0x00,0x00,0x00,0x40}
		),
		Command(
			"OK/select button",
			{0x00,0x00,0x00,0x80}
		),
		Command(
			"Scroll up",
			{0x00,0x00,0x00,0x00,0x01}
		),
		Command(
			"Scroll down",
			{0x00,0x00,0x00,0x00,0x02}
		)
	};
	private Command[] advanced_remote_commands = {
		Command(
			"Get iPod name",
			{0x00,0x14}
		),
		Command(
			"Get Time and Status info",
			{0x00,0x1C}
		),
		Command(
			"Get number of songs in the current playlist",
			{0x00,0x35}
		)
	};

	public CommandMenuControl() {
		// Grid for the label and the combo box
		this.grid = new Gtk.Grid();

		// Control's label
		this.label = new Gtk.Label("Command : ");
		this.grid.add(label);

		// Combo box
		this.buildListstore(0x00);
		this.combo_box = new Gtk.ComboBox.with_model(liststore);
		this.grid.add(combo_box);
		this.renderer = new Gtk.CellRendererText();
		this.combo_box.pack_start(this.renderer,false);
		this.combo_box.set_attributes (renderer,"text",0);
		this.combo_box.set_active(0);
	}
	private void buildListstore(uchar mode) {
		Command[] commands = this.getCommandsForMode(mode);

		this.liststore = new Gtk.ListStore(2,typeof(string),typeof(string));

		for (int i = 0; i < commands.length; i++) {
			Gtk.TreeIter iter;
			this.liststore.append(out iter);
			this.liststore.set(iter,0,commands[i].purpose);
			this.liststore.set(iter,1,(string)commands[i].data);
		}
	}
	private Command[] getCommandsForMode(uchar mode) {
		Command[] commands;

		switch (mode) {
		case 0x00:
			commands = this.mode_switching_commands;
			break;

		case 0x02:
			commands = this.simple_remote_commands;
			break;

		case 0x04:
			commands = this.advanced_remote_commands;
			break;

		default:
			commands = {};
			break;
		}

		return commands;
	}
	public void updateForNewMode(uchar mode) {
		this.mode = mode;
		this.buildListstore(mode);
		this.combo_box.set_model(this.liststore);
		this.combo_box.clear();
		this.combo_box.set_active(0);
		this.combo_box.pack_start(this.renderer,false);
		this.combo_box.set_attributes(renderer,"text",0);
		this.combo_box.set_active(0);
	}
	public uchar[] getCurrentValue() {
		Gtk.TreeIter iter;
		Value value;
		this.combo_box.get_active_iter(out iter);
		this.liststore.get_value(iter,0,out value);

		string command_name = (string)value;
		Command[] commands = getCommandsForMode(this.mode);

		for (int i = 0; i < commands.length; i++) {
			if (commands[i].purpose == command_name) {
				return commands[i].data;
			}
		}

		return {};
	}
}

public class GenerateButtonControl : Object {
	public signal void button_clicked();

	private Gtk.Button button;

	public GenerateButtonControl() {
		this.button = new Gtk.Button.with_label("Generate");
		this.button.clicked.connect(() => {
			button_clicked();
		});
	}
	public Gtk.Widget get_widget() {
		return this.button;
	}
}

public class PacketContentControl : Object {
	private Gtk.TextView view;

	public PacketContentControl() {
		this.view = new Gtk.TextView();
		this.view.set_wrap_mode(Gtk.WrapMode.WORD);
		this.view.buffer.text = "";
		this.view.editable = false;
		this.view.set_border_width(10);
	}
	public void displayPacket(Array<uchar> packet) {
		var string_builder = new StringBuilder();

		for (int i = 0; i < packet.length; i++) {
			string_builder.append(packet.index(i).to_string("%02X "));
		}

		this.view.buffer.text = string_builder.str;
	}

	public Gtk.Widget get_widget() {
		return (Gtk.Widget)this.view;
	}
}

public class Aappg : Gtk.Window {
	private const uchar[] header = {0xff,0x55};
	private ModeMenuControl mode_menu_control;
	private CommandMenuControl command_menu_control;
	private GenerateButtonControl generate_button_control;
	private Gtk.Grid main_grid;
	private PacketContentControl packet_content_control;

	public Aappg() {
		// Preparing the window
		this.title = "Apple Accessory Protocol Packet Generator";
		this.window_position = Gtk.WindowPosition.CENTER;
		this.destroy.connect(Gtk.main_quit);
		this.border_width = 10;

		this.main_grid = new Gtk.Grid();

		Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
		separator.set_margin_top(10);
		separator.set_margin_bottom(10);
		Gtk.Separator separator2 = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);
		separator2.set_margin_top(10);
		separator2.set_margin_bottom(10);

		this.command_menu_control = new CommandMenuControl();
		this.mode_menu_control = new ModeMenuControl();
		this.generate_button_control = new GenerateButtonControl();
		this.packet_content_control = new PacketContentControl();

		this.mode_menu_control.mode_changed.connect(this.command_menu_control.updateForNewMode);

		this.generate_button_control.button_clicked.connect(() => {
			var packet = this.makePacket(
				this.mode_menu_control.getCurrentValue(),
				this.command_menu_control.getCurrentValue(),
				{}
			);

			this.packet_content_control.displayPacket(packet);
		});

		this.main_grid.attach(this.mode_menu_control.get_widget(),0,0,1,1);
		this.main_grid.attach(this.command_menu_control.get_widget(),0,1,1,1);
		this.main_grid.attach(separator,0,2,1,1);
		this.main_grid.attach(this.generate_button_control.get_widget(),0,3,1,1);
		this.main_grid.attach(separator2,0,4,1,1);
		this.main_grid.attach(this.packet_content_control.get_widget(),0,5,1,1);

		this.add(main_grid);
	}
	private uchar makeChecksum(Array<uchar> data) {
		int sum_buffer = 0;

		for (int i = 0; i < data.length; i++) {
			sum_buffer += (int)data.index(i);
		}

		return (uchar)(0x100 - (sum_buffer & 0xFF));
	}
	private Array<uchar> makePacket(uchar mode, uchar[] command, uchar[] parameters) {
		uchar data_length = (uchar)(1 + command.length + parameters.length);

		var packet = new Array<uchar>();
		packet.append_val(data_length);
		packet.append_val(mode);
		packet.append_vals(command,command.length);
		packet.append_vals(parameters,parameters.length);
		packet.append_val(makeChecksum(packet));
		packet.prepend_vals(this.header,this.header.length);

		return packet;
	}

	public static int main(string[] args) {
		Gtk.init(ref args);

		Aappg application = new Aappg();
		application.show_all();
		Gtk.main();

		return 0;
	}
}