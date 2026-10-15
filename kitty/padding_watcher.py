# Padding proportionnel à la taille de la fenêtre (Kitty ne gère que des valeurs fixes).
# Chargé via `watcher padding_watcher.py` dans kitty.conf.

from kitty.fast_data_types import add_timer, pt_to_px

PAD_H = 0.07   # 7 % de la largeur, de chaque côté
PAD_V = 0.03   # 3 % de la hauteur, en haut et en bas
MIN_PT = 6     # plancher pour les petits splits


def _apply(window, h_pt, v_pt):
    if window.destroyed:
        return
    for edge, val in (('left', h_pt), ('right', h_pt), ('top', v_pt), ('bottom', v_pt)):
        window.patch_edge_width('padding', edge, val)
    tab = window.tabref()
    if tab is not None:
        tab.relayout()


def on_resize(boss, window, data):
    g = data['new_geometry']
    total_w = (g.right - g.left) + g.spaces.left + g.spaces.right
    total_h = (g.bottom - g.top) + g.spaces.top + g.spaces.bottom
    px_per_pt = pt_to_px(100, window.os_window_id) / 100 or 1
    h_pt = max(MIN_PT, round(total_w * PAD_H / px_per_pt))
    v_pt = max(MIN_PT, round(total_h * PAD_V / px_per_pt))
    # Évite la boucle : changer le padding redéclenche on_resize avec la même taille totale
    if window.padding.left == h_pt and window.padding.top == v_pt:
        return
    add_timer(lambda _: _apply(window, h_pt, v_pt), 0, False)
