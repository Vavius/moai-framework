--------------------------------------------------------------------------------
--
--
--
--------------------------------------------------------------------------------

local Event = require("event.Event")

UIEvent = class(Event)

UIEvent.UP = "ui_up"
UIEvent.DOWN = "ui_down"
UIEvent.CLICK = "ui_click"
UIEvent.CANCEL = "ui_cancel"
UIEvent.ENABLE = "ui_enabled"
UIEvent.DISABLE = "ui_disabled"

return UIEvent