$win_xyz = enum-childWindowsFiltered {
   param (
      [int] $hWnd
   )

   $title = get-windowText $hWnd

   return $title -match '07-29'
}

if ($win_xyz.count -ne 1) {
  'expected ONE window'
   return
}

$rect = get-windowRect $win_xyz[0].hwnd

move-window $win_xyz[0].hwnd 0 0 ($rect.right - $rect.left) ($rect.bottom - $rect.top) $false
