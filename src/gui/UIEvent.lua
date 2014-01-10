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
UIEvent.DIALOG_WILL_OPEN = "ui_dialogWillOpen"
UIEvent.DIALOG_OPEN = "ui_dialogOpen"
UIEvent.DIALOG_DID_CLOSE = "ui_dialogDidClose"
UIEvent.DIALOG_CLOSE = "ui_dialogClose"


return UIEvent