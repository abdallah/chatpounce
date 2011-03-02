use Purple;
%PLUGIN_INFO = (
    perl_api_version => 2,
    name => "Chat Pounce Plugin",
    version => "0.3",
    summary => "Pounce inside XMPP chat window.",
    description => "Pounce inside XMPP chat window",
    author => "Abdallah Deeb <abdallah\@grat.in>",
    url => "http://rimuhosting.com/chat.jsp",
    load => "plugin_load",
    unload => "plugin_unload",
    prefs_info => "prefs_info_cb"
);
 
sub conv_received_msg {
    my ($account, $sender, $message, $conv, $flags, $data) = @_;
    Purple::Debug::info("chatpounce", 'message: '.$message);
    $sender_name = Purple::Prefs::get_string('/plugins/core/chatpounce/sender_name');
    $greet_message = Purple::Prefs::get_string('/plugins/core/chatpounce/greet_message');
    $beep_on_enter = Purple::Prefs::get_bool('/plugins/core/chatpounce/beep_on_enter');
    $enter_sound = Purple::Prefs::get_int('/plugins/core/chatpounce/enter_sound');
    $beep_on_leave = Purple::Prefs::get_bool('/plugins/core/chatpounce/beep_on_leave');
    $leave_sound = Purple::Prefs::get_int('/plugins/core/chatpounce/leave_sound');
    $greet_on_enter = Purple::Prefs::get_bool('/plugins/core/chatpounce/greet_on_enter');
    $enter_filter = Purple::Prefs::get_string("/plugins/core/chatpounce/enter_filter");
    $leave_filter = Purple::Prefs::get_string("/plugins/core/chatpounce/leave_filter");

    if ($sender==$sender_name && $message=~/$enter_filter/) {  
        @words = ($message =~ /(\w+)/);
        $name = $words[0];
        $chat = $conv->get_chat_data();
        if ($greet_on_enter) {
            $greet_message =~ s/\$NAME/$name/;
            $chat->send($greet_message);  
        }
        if ($beep_on_enter) {
            Purple::Sound::play_event($enter_sound, NULL);
        }
    }

    if ($sender==$sender_name && $message=~/$leave_filter/) {  
        if ($beep_on_leave) {
            Purple::Sound::play_event($leave_sound, NULL);
        }
    }
}
 
sub prefs_info_cb {
    $frame = Purple::PluginPref::Frame->new();
 
    $ppref = Purple::PluginPref->new_with_name_and_label(
        "/plugins/core/chatpounce/beep_on_enter", "Beep on enter");
    $frame->add($ppref);

    $ppref = Purple::PluginPref->new_with_name_and_label(
        "/plugins/core/chatpounce/enter_sound", "Enter sound [Edit sounds in Preferences > Sounds]");
    $ppref->set_type(1);
    $ppref->add_choice("BUDDY_ARRIVE", Purple::SoundEventID::BUDDY_ARRIVE);
    $ppref->add_choice("BUDDY_LEAVE", Purple::SoundEventID::BUDDY_LEAVE);
    $ppref->add_choice("CHAT_JOIN", Purple::SoundEventID::CHAT_JOIN);
    $ppref->add_choice("CHAT_LEAVE", Purple::SoundEventID::CHAT_LEAVE);
    $ppref->add_choice("CHAT_NICK", Purple::SoundEventID::CHAT_NICK);
    $ppref->add_choice("CHAT_SAY", Purple::SoundEventID::CHAT_SAY);
    $ppref->add_choice("CHAT_YOU_SAY", Purple::SoundEventID::CHAT_YOU_SAY);
    $ppref->add_choice("FIRST_RECEIVE", Purple::SoundEventID::FIRST_RECEIVE);
    $ppref->add_choice("POUNCE_DEFAULT", Purple::SoundEventID::POUNCE_DEFAULT);
    $frame->add($ppref);

    $ppref = Purple::PluginPref->new_with_name_and_label(
        "/plugins/core/chatpounce/greet_on_enter", "Greet on enter");
    $frame->add($ppref);
    $ppref = Purple::PluginPref->new_with_name_and_label(
        "/plugins/core/chatpounce/greet_message", "Greeting message [\$NAME is replaced by sender name]");
    $ppref->set_type(2);
    $frame->add($ppref);
    $ppref = Purple::PluginPref->new_with_name_and_label(
        "/plugins/core/chatpounce/beep_on_leave", "Beep on leave");
    $frame->add($ppref);

    $ppref = Purple::PluginPref->new_with_name_and_label(
        "/plugins/core/chatpounce/leave_sound", "Leave sound [Edit sounds in Preferences > Sounds]");
    $ppref->set_type(1);
    $ppref->add_choice("BUDDY_ARRIVE", Purple::SoundEventID::BUDDY_ARRIVE);
    $ppref->add_choice("BUDDY_LEAVE", Purple::SoundEventID::BUDDY_LEAVE);
    $ppref->add_choice("CHAT_JOIN", Purple::SoundEventID::CHAT_JOIN);
    $ppref->add_choice("CHAT_LEAVE", Purple::SoundEventID::CHAT_LEAVE);
    $ppref->add_choice("CHAT_NICK", Purple::SoundEventID::CHAT_NICK);
    $ppref->add_choice("CHAT_SAY", Purple::SoundEventID::CHAT_SAY);
    $ppref->add_choice("CHAT_YOU_SAY", Purple::SoundEventID::CHAT_YOU_SAY);
    $ppref->add_choice("FIRST_RECEIVE", Purple::SoundEventID::FIRST_RECEIVE);
    $ppref->add_choice("POUNCE_DEFAULT", Purple::SoundEventID::POUNCE_DEFAULT);
    $frame->add($ppref);


    $ppref = Purple::PluginPref->new_with_name_and_label(
        "/plugins/core/chatpounce/sender_name", "Sender name");
    $ppref->set_type(2);
    $ppref->set_max_length(16);
    $frame->add($ppref);
    $ppref = Purple::PluginPref->new_with_name_and_label(
        "/plugins/core/chatpounce/enter_filter", "Enter filter [RegEx - CaseSensitive]");
    $ppref->set_type(2);
    $frame->add($ppref);
    $ppref = Purple::PluginPref->new_with_name_and_label(
        "/plugins/core/chatpounce/leave_filter", "Leave filter [RegEx - CaseSensitive]");
    $ppref->set_type(2);
    $frame->add($ppref);
    return $frame;
}
 
 
sub plugin_init {
    return %PLUGIN_INFO;
}
sub plugin_load {
    my $plugin = shift;
 
    Purple::Prefs::add_none("/plugins/core/chatpounce");
    Purple::Prefs::add_bool("/plugins/core/chatpounce/greet_on_enter", 0);
    Purple::Prefs::add_bool("/plugins/core/chatpounce/beep_on_enter", 1);
    Purple::Prefs::add_int("/plugins/core/chatpounce/enter_sound", Purple::SoundEventID::POUNCE_DEFAULT);
    Purple::Prefs::add_bool("/plugins/core/chatpounce/beep_on_leave", 1);
    Purple::Prefs::add_int("/plugins/core/chatpounce/leave_sound", Purple::SoundEventID::CHAT_LEAVE);
    Purple::Prefs::add_string("/plugins/core/chatpounce/sender_name", "Tinder");
    Purple::Prefs::add_string("/plugins/core/chatpounce/enter_filter", "EnterMessage");
    Purple::Prefs::add_string("/plugins/core/chatpounce/leave_filter", "LeaveMessage");
    Purple::Prefs::add_string("/plugins/core/chatpounce/greet_message", "\@tinder Hello $NAME, how can I help you?");
 
    $conv = Purple::Conversations::get_handle();
    Purple::Signal::connect($conv, "received-chat-msg", $plugin,
        \&conv_received_msg, 'chatpounce');
    Purple::Debug::info("chatpounce", "plugin_load() - ChatPounce Loaded.\n");
}
sub plugin_unload {
    my $plugin = shift;
    Purple::Debug::info("chatpounce", "plugin_unload() - ChatPounce Unloaded.\n");
}
