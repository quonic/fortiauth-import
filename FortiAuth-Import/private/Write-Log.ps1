<#
EventID 0: Info, Starting
EventID 1: Warn, Something happened unexpectedly, but it is being handled. <Details of what is happening>
EventID 2: Error, Something happened unexpectedly, and can't be handled. <Details of what is happening>
EventID 4: Fatal, Something happened and exiting. <Details of what is happening>

EventID 100: Fatal, Failed to get tokens
EventID 101: Fatal, Failed to connect to server
EventID 101: Info, Completed Sucessfully
EventID 102: Fatal, Failed to get tokens
#>

Function Write-Log
{
    <#
.SYNOPSIS
    Standard Event Log entry writer
.DESCRIPTION
    Writes an entry to the local system's Event Log in a predictable and dependable way
.PARAMETER Level
    Sets the what type of entry this is.
.PARAMETER Message
    The information that you wish to convey in the Event Log
.PARAMETER EventID
    The Event ID of this log entry
.INPUTS
    None
.OUTPUTS
    None
.NOTES
    Version:        1.0
    Author:         Jim Caten
    Creation Date:  3/16/2017
    Purpose/Change: Initial Event Log Writer
.EXAMPLE
    Write-Log -Level Info -Message "Did task" -EventID 0
.EXAMPLE
    Write-Log -EntryType Info -Message "Did task" -EventID 0
#>
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Message,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateCount(0, 65535)]
        [int]
        $EventID,
        [Parameter(Mandatory = $false)]
        [ValidateSet("Error", "Warn", "Info", "Fatal", "Debug", "Verbose")]
        [Alias("EntryType")]
        [string]
        $Level = "Info",
        [Parameter(Mandatory = $false)]
        [ValidateSet("EventLog", "Console", "LogFile")]
        [string]
        $Method = "EventLog",
        [Parameter(Mandatory = $false)]
        [string]
        $File
    )

    $Message = "{0}: {1}" -f $Level, $Message

    switch ($Method)
    {
        'EventLog'
        {
            switch ($Level)
            {
                'Error' { Write-EventLog -LogName "Application" -Source $ScriptName -EntryType FailureAudit -EventId $EventID -Message $Message }
                'Warn' { Write-EventLog -LogName "Application" -Source $ScriptName -EntryType Warning -EventId $EventID -Message $Message }
                'Info' { Write-EventLog -LogName "Application" -Source $ScriptName -EntryType Information -EventId $EventID -Message $Message }
                'Fatal' { Write-EventLog -LogName "Application" -Source $ScriptName -EntryType Error -EventId $EventID -Message $Message }
                'Debug' { Write-EventLog -LogName "Application" -Source $ScriptName -EntryType Information -EventId $EventID -Message $Message }
                'Verbose' { Write-EventLog -LogName "Application" -Source $ScriptName -EntryType SuccessAudit -EventId $EventID -Message $Message }
            }
        }
        'Console'
        {
            switch ($Level)
            {
                'Error' { Write-Error -Message "$Message" -ErrorId $EventID }
                'Warn' { Write-Warning "Warning $EventID : $Message"}
                'Info' { Write-Information "Warning $EventID : $Message" -ForegroundColor White}
                'Fatal' { Write-Error -Message "$Message" -ErrorId $EventID}
                'Debug' { Write-Debug -Message "$EventID : $Message"}
                'Verbose' { Write-Verbose "Warning $EventID : $Message"}
            }
        }
        'LogFile'
        {
            switch ($Level)
            {
                'Error' { Write-EventLog -LogName "Application" -Source $ScriptName -EntryType FailureAudit -EventId $EventID -Message $Message }
                'Warn' { Write-EventLog -LogName "Application" -Source $ScriptName -EntryType Warning -EventId $EventID -Message $Message }
                'Info' { Write-EventLog -LogName "Application" -Source $ScriptName -EntryType Information -EventId $EventID -Message $Message }
                'Fatal' { Write-EventLog -LogName "Application" -Source $ScriptName -EntryType Error -EventId $EventID -Message $Message }
                'Debug' { Write-EventLog -LogName "Application" -Source $ScriptName -EntryType Information -EventId $EventID -Message $Message }
                'Verbose' { Write-EventLog -LogName "Application" -Source $ScriptName -EntryType SuccessAudit -EventId $EventID -Message $Message }
            }
        }
    }
}