get-process   notepad -errorAction ignore | stop-process
start-process notepad

start-sleep 1

$hwnd = find-window notepad

get-windowText $hWnd
