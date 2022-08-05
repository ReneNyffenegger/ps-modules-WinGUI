get-process   notepad -errorAction ignore | stop-process
start-process notepad

start-sleep 1

$hwnd = find-window notepad

$rect = get-windowRect $hwnd

start-sleep 1

set-windowPos $hwnd 0   `
  ($rect.left   - 10)   `
  ($rect.top    - 10)   `
  ($rect.right  - $rect.left + 20) `
  ($rect.bottom - $rect.top  + 20)
