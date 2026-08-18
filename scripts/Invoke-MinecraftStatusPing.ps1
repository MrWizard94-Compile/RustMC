<#
.SYNOPSIS
  Minecraft Java Server List Ping against a live server. Prints JSON status.
#>
[CmdletBinding()]
param(
    [string]$HostName = "127.0.0.1",
    [int]$Port = 25565,
    [int]$ProtocolVersion = 776,
    [int]$TimeoutMs = 8000
)

$ErrorActionPreference = "Stop"

function Write-VarIntBytes([System.Collections.Generic.List[byte]]$Buf, [int]$Value) {
    $u = [BitConverter]::ToUInt32([BitConverter]::GetBytes($Value), 0)
    while ($true) {
        $byteVal = [int]($u -band 0x7F)
        $u = [uint32]($u -shr 7)
        if ($u -ne 0) { $byteVal = $byteVal -bor 0x80 }
        $Buf.Add([byte]$byteVal)
        if ($u -eq 0) { break }
    }
}

function Write-McStringBytes([System.Collections.Generic.List[byte]]$Buf, [string]$Text) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    Write-VarIntBytes $Buf $bytes.Length
    foreach ($b in $bytes) { $Buf.Add($b) }
}

function Read-VarInt([System.IO.Stream]$Stream) {
    $numRead = 0
    $result = 0
    while ($true) {
        $raw = $Stream.ReadByte()
        if ($raw -lt 0) { throw "EOF reading VarInt" }
        $result = $result -bor (($raw -band 0x7F) -shl (7 * $numRead))
        $numRead++
        if ($numRead -gt 5) { throw "VarInt too big" }
        if (($raw -band 0x80) -eq 0) { break }
    }
    return $result
}

function Read-Exact([System.IO.Stream]$Stream, [int]$Count) {
    $buf = New-Object byte[] $Count
    $off = 0
    while ($off -lt $Count) {
        $n = $Stream.Read($buf, $off, $Count - $off)
        if ($n -le 0) { throw "EOF reading $Count bytes" }
        $off += $n
    }
    return $buf
}

$client = New-Object System.Net.Sockets.TcpClient
$client.ReceiveTimeout = $TimeoutMs
$client.SendTimeout = $TimeoutMs
$iar = $client.BeginConnect($HostName, $Port, $null, $null)
if (-not $iar.AsyncWaitHandle.WaitOne($TimeoutMs, $false)) {
    $client.Close()
    throw "Connect timeout ${HostName}:${Port}"
}
$client.EndConnect($iar)
$stream = $client.GetStream()

# Handshake
$handshake = [System.Collections.Generic.List[byte]]::new()
Write-VarIntBytes $handshake 0
Write-VarIntBytes $handshake $ProtocolVersion
Write-McStringBytes $handshake $HostName
$portBytes = [BitConverter]::GetBytes([uint16]$Port)
if ([BitConverter]::IsLittleEndian) { [Array]::Reverse($portBytes) }
foreach ($b in $portBytes) { $handshake.Add($b) }
Write-VarIntBytes $handshake 1

$frame = [System.Collections.Generic.List[byte]]::new()
Write-VarIntBytes $frame $handshake.Count
$frame.AddRange($handshake)
$hb = $frame.ToArray()
$stream.Write($hb, 0, $hb.Length)

# Status request
$req = [System.Collections.Generic.List[byte]]::new()
Write-VarIntBytes $req 1
Write-VarIntBytes $req 0
$rb = $req.ToArray()
$stream.Write($rb, 0, $rb.Length)
$stream.Flush()

$packetLen = Read-VarInt $stream
$packet = Read-Exact $stream $packetLen
$ms = New-Object System.IO.MemoryStream(,$packet)
$packetId = Read-VarInt $ms
if ($packetId -ne 0) { throw "Unexpected packet id $packetId" }
$jsonLen = Read-VarInt $ms
$jsonBytes = Read-Exact $ms $jsonLen
$json = [System.Text.Encoding]::UTF8.GetString($jsonBytes)
$client.Close()

$obj = $json | ConvertFrom-Json
if (-not $obj.version -or -not $obj.version.name) {
    throw "Status JSON missing version.name: $json"
}
if ($null -eq $obj.description) {
    throw "Status JSON missing description: $json"
}

Write-Output $json
exit 0
