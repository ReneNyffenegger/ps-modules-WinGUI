$foundWindows = @()

$callback = {

   param (
      [IntPtr] $hWnd,
      [IntPtr] $unused_in_this_example
   )

   $winTxt    = get-windowText      $hWnd
   $className = get-windowClassName $hWnd

   if ( ($className -notIn 'IME', 'MSCTFIME UI') -and
        ($winTxt                               )       ) {

       $script:foundWindows += new-object psCustomObject -property ([ordered] @{ hWnd = $hWnd; windowText = $winTxt; className = $className })

       return $true
   }

   return $true
}


enum-childWindows $callback

$foundWindows
