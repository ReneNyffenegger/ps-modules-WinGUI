#
#  make sure exactly one process of notepad is running
#
get-process   notepad -errorAction ignore | stop-process
start-process notepad

start-sleep 1

$hwnd_notepad     = find-window  'notepad'
$hwnd_notepadEdit = find-windowEx $hwnd_notepad 0 'Edit'

$WM_SETTEXT = 0x000C

$ret = send-windowMessage $hwnd_notepadEdit $WM_SETTEXT 0 "This text was`ninserted with`nsend-windowMessage."
"send message returned $ret"
