$wins = enum-childWindowsFiltered {

   param ([int] $hWnd)

   $title = get-windowText $hWnd

   return $title -match '\d'
}

$wins
