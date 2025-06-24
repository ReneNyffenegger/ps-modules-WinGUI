@{
   RootModule         = 'WinGUI'
   ModuleVersion      = '0.3'

   RequiredAssemblies = @()

   RequiredModules    = @()

   FunctionsToExport  = @(
    #
    # WinAPI functions
    #
     'get-childWindows'         ,
     'get-windowRect'           ,
     'get-windowText'           ,
     'get-windowClassName'      ,
     'set-windowPos'            ,
     'find-window'              ,
     'find-windowEx'            ,
     'move-window'              ,
     'send-windowMessage'       ,
     'set-foregroundWindow'     ,
     'set-activeWindow'         ,
    #
    # Non-WinAPI functions
    #
     'get-childWindowsFiltered' ,
     'set-windowTopMost'
   )

   AliasesToExport    = @(
     'enum-childWindows'        ,
     'enum-childWindowsFiltered'
   )

   FormatsToProcess   = @()
}
