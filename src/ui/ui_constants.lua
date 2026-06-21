local UI = {}

UI.BORDER_RADIUS = 12
UI.MARGIN = 20

UI.COLORS = {
    PANEL_BACKGROUND = {0, 0, 0, 0.8},
    PANEL_BORDER = {1, 1, 1, 1},
    PANEL_TEXT = {1, 1, 1, 1},
}

UI.TEXTBOX = {
    MARGIN = UI.MARGIN,
    HEIGHT = 140,
    FONT_SIZE = 20,
}

UI.STATUS_BAR = {
    WIDTH = 200,
    PADDING = 20,
    BOX_PADDING = UI.MARGIN,
}

-- Altura del textbox más un margen de separación
-- entre la barra lateral y el cuadro de diálogo.
UI.RESERVED_BOTTOM_SPACE =
    UI.TEXTBOX.HEIGHT + UI.MARGIN

return UI