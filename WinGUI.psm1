set-strictMode -version 3

$memberDefinition = @'

using System;
using System.Text;
using System.Runtime.InteropServices;

public class WinGUI {

  [StructLayout(LayoutKind.Sequential)]
   public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
   }

   public delegate bool enumChildWindowsProc(
      IntPtr               hWnd,
      IntPtr               lParam
   );

  [DllImport("user32.dll")]
   public static extern bool EnumChildWindows(
      IntPtr               hWnd,
      enumChildWindowsProc callback,
      IntPtr               lParam
   );

  [DllImport("user32.dll", SetLastError=true)]
   public static extern Int32 GetWindowTextLength(
      IntPtr               hWnd
   );

  [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
   public static extern int GetWindowText(
      IntPtr               hwnd,
      StringBuilder        lpString,
      int                  cch
   );

  [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
   public static extern int GetClassName(
      IntPtr               hwnd,
      StringBuilder        lpString,
      int                  cch
   );

  [DllImport("user32.dll", SetLastError = true)]
   public static extern IntPtr FindWindow(
      string               className,
      string               windowTitle
   );

  [DllImport("user32.dll", SetLastError = true)]
   public static extern IntPtr FindWindowEx(
      IntPtr               hWndParent,
      IntPtr               hWndChildAfter,
      string               className,
      string               windowTitle
   );

  [DllImport("user32.dll", CharSet = CharSet.Unicode, EntryPoint = "SendMessageW")]
   public static extern IntPtr SendMessageString(
       IntPtr                                   hWnd,
       int                                      msg,
       IntPtr                                   wParam,
      [MarshalAs(UnmanagedType.LPWStr)] string  lParam
   );

  [DllImport("user32.dll", SetLastError=true)]
   public static extern IntPtr SetActiveWindow(
        IntPtr                                  hWnd
   );

  [DllImport("user32.dll", SetLastError=true)]
   public static extern bool SetForegroundWindow(
        IntPtr                                  hWnd
   );

  [DllImport("user32.dll")]
   public static extern bool SetWindowPos(
        IntPtr                                  hWnd,
        IntPtr                                  hWndInsertAfter,
        Int32                                   x,
        Int32                                   y,
        Int32                                   cx,
        Int32                                   cy,
        UInt32                                  uFlags
   );

  [DllImport("user32.dll")]
   public static extern bool MoveWindow(
        IntPtr                                  hWnd,
        Int32                                   x,
        Int32                                   y,
        Int32                                   w,
        Int32                                   h,
        Boolean                                 repaint
   );

  [DllImport("user32.dll")]
  [return: MarshalAs(UnmanagedType.Bool)]
   public static extern bool GetWindowRect(
        IntPtr                                   hWnd,
    out RECT                                     lpRect
   );


// public static extern bool EnumChildWindows(
//   EnumWindowsProc enumProc,
//   IntPtr lParam);

}
'@

add-type -typeDef $memberDefinition # -name WinGUI # -namespace WinGUI


function get-childWindows {

   param (
      [scriptblock] $callBack,
      [IntPtr     ] $hWnd      = [IntPtr]::Zero,
      [IntPtr     ] $param     = [IntPtr]::Zero
   )

   $null = [WinGUI]::EnumChildWindows(
       $hWnd,
       $callBack,
       $param
   )
}

function get-childWindowsFiltered {
 #
 # Apply $filter on each window and
 # return windows for which $filter
 # returns true.
 #
 # It is assumed that $filter takes a
 # $hWnd parameter.
 #
 # get-childWindowsFiltered returns
 # a System.Collections.Generic.List[...win]
 #

   param (
      [scriptBlock] $filter
   )

   class win {

      [int   ] $hWnd
      [string] $title
      [string] $class

   }

   class prm {
      [System.Collections.Generic.List[win]]  $wins
      [scriptBlock]                           $flt
   }


   $callbackEnum = {

      param (
         [IntPtr] $hWnd,
         [IntPtr] $psObjPtr  # param
      )

      $gch  = [System.Runtime.InteropServices.GCHandle]::FromIntPtr($psObjPtr);
      $pp   = $gch.Target

      if (invoke-command $pp.flt -argumentList $hWnd) {

           $win       = new-object win
           $win.hWnd  = $hWnd
           $win.title = get-windowText      $hWnd
           $win.class = get-windowClassName $hWnd

           $pp.wins.Add($win)
       }

       return $true
   }

   $p      = new-object prm
   $p.flt  = $filter
   $p.wins = new-object 'System.Collections.Generic.List[win]'

   $g   = [System.Runtime.InteropServices.GCHandle]::Alloc($p);
   $ptr = [System.Runtime.InteropServices.GCHandle]::ToIntPtr($g)

   enum-childWindows $callbackEnum -param $ptr

   $g.Free()

  ,$p.wins
}

function get-windowText {

   param (
      [IntPtr] $hWnd
   )

   $len  = [WinGUI]::GetWindowTextLength($hWnd)
   $sb   = new-object Text.Stringbuilder ($len+1)
   $null = [WinGUI]::GetWindowText($hWnd, $sb, $sb.Capacity)

   $sb.ToString()

}

function get-windowClassName {

   param (
      [IntPtr] $hWnd
   )

   $sb   = new-object Text.Stringbuilder 256
   $null = [WinGUI]::GetClassName($hWnd, $sb, $sb.Capacity)

   $sb.ToString()
}

function set-windowPos {
   param (
      [IntPtr] $hWnd,
      [IntPtr] $hWndInsertAfter,
      [Int32 ] $x,
      [Int32 ] $y,
      [Int32 ] $cx,
      [Int32 ] $cy,
      [UInt32] $uFlags
   )

   [WinGUI]::SetWindowPos($hWnd, $hWndInsertAfter, $x, $y, $cx, $cy, $uFlags)
}

function move-window {
   param (
      [IntPtr ] $hWnd,
      [Int32  ] $x,
      [Int32  ] $y,
      [Int32  ] $w,
      [Int32  ] $h,
      [Boolean] $repaint
   )

   [WinGUI]::MoveWindow($hWnd, $x, $y, $w, $h, $repaint)
}

function get-windowRect {
   param (
      [IntPtr] $hWnd
   )

   $rect = new-object WinGUI+RECT

   if ([WinGUI]::GetWindowRect($hWnd, [ref] $rect)) {
      return $rect
   }

   return $null

}

function find-window {

   param (
      [string] $className    = '',
      [string] $windowTitle  = ''
   )

   $className_   = if ($className   -eq '') { [NullString]::Value} else { $className  }
   $windowTitle_ = if ($windowTitle -eq '') { [NullString]::Value} else { $windowTitle}

   return [WinGUI]::FindWindow($className_, $windowTitle_)
}

function find-windowEx {

   param (
      [IntPtr] $hWndParent,
      [IntPtr] $hWndChildAfter  =  0,
      [string] $className       = '',
      [string] $windowTitle     = ''
   )

   $className_   = if ($className   -eq '') { [NullString]::Value } else { $className   }
   $windowTitle_ = if ($windowTitle -eq '') { [NullString]::Value } else { $windowTitle }

   return [WinGUI]::FindWindowEx($hWndParent, $hWndChildAfter, $className_, $windowTitle_)
}

function send-windowMessage {

   param (
      [IntPtr] $hWnd       ,
      [int   ] $msg        ,
      [IntPtr] $wParam     ,
      [object] $lParam
   )

   if ($lParam -is [string]) {
      return [WinGUI]::SendMessageString($hWnd, $msg, $wParam, $lParam)
   }
   else {
      write-textinConsoleWarningColor "todo in send-windowMessage: implement me lParam is not string."
   }
}

function set-activeWindow {
   param (
     [IntPtr]   $hWnd
   )

   return [WinGUI]::SetActiveWindow($hWnd)
}

function set-foregroundWindow {
   param (
     [IntPtr]   $hWnd
   )

   return [WinGUI]::SetForegroundWindow($hWnd)
}

function set-windowTopmost {
 #
 # The following code was helpful:
 #    https://github.com/bkfarnsworth/Always-On-Top-PS-Script/blob/master/Always_On_Top.ps1
 #
   param (
     [IntPtr]   $hWnd,
     [bool]     $topMost = $true
   )

   if ($topMost) {
      $hWndInserAfter = ([IntPtr]::new(-1)) # HWND_TOPMOST
   }
   else {
      $hWndInserAfter = ([IntPtr]::new(-2)) # HWND_NOTOPMOST
   }

 #
 # 0x03 = 0x01 (SWP_NOSIZE) + 0x02 (SWP_NOMOVE)
 #
   set-windowPos $hWnd  $hWndInserAfter  0  0  0  0  0x03
}

new-alias enum-childWindows         get-childWindows
new-alias enum-childWindowsFiltered get-childWindowsFiltered
