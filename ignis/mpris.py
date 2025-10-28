from ignis.services.mpris import MprisService

mpris = MprisService.get_default()

mpris.connect("player_added", lambda x, player: print(player.desktop_entry, player.title))

print(mpris.players)

# 󰋙 󰫃 󰫄 󰫅 󰫆 󰫇 󰫈 󰋘