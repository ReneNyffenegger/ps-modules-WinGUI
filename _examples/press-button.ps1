$winTitle = 'Button press test'

start-process  C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe  "-c `"Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('Let the script press OK', '$winTitle')`""

while ( ($hwndMsgBox = find-window -windowTitle $winTitle) -eq 0 ) {
   write-host "No window with title '$winTitle' found, sleeping for a second"
   start-sleep 1
}

write-host "hwndMsgBox = $hwndMsgBox"

$callback = {

   param (
      [IntPtr] $hWnd,
      [IntPtr] $unused_in_this_example
   )

   $className = get-windowClassName $hWnd

   if ($className -eq 'Button') {
      $winTxt    = get-windowText      $hWnd

      if ($winTxt -eq 'Ok') {
         $script:hwndOk = $hwnd
      }
   }

   return $true
}

enum-childWindows $callback $hwndMsgBox

write-host "Clicking OK on hwndMsgBox = $hwndMsgBox in three seconds"
start-sleep 3

$BM_CLICK = 0x00F5
$null = send-windowMessage $hwndOK $BM_CLICK 0 0
