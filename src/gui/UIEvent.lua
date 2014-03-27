--------------------------------------------------------------------------------
--
--
--
--------------------------------------------------------------------------------

local Event = require("core.Event")

UIEvent = class(Event)

UIEvent.UP = "ui_up"
UIEvent.DOWN = "ui_down"
UIEvent.CLICK = "ui_click"
UIEvent.CANCEL = "ui_cancel"
UIEvent.ENABLE = "ui_enabled"
UIEvent.DISABLE = "ui_disabled"
UIEvent.SCROLL_BEGIN = "ui_scrollBegin"
UIEvent.SCROLL_END = "ui_scrollEnd"
UIEvent.SCROLL_POSITION_CHANGED = "ui_scrollPositionChange"

return UIEvent