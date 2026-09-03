[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$Source,

    [ValidateSet('Notes', 'Posts', 'Writeup')]
    [string]$ContentType = 'Notes',

    # Used for Posts and Writeups. Defaults to a safe form of the note filename.
    [string]$Slug,

    # The vault root lets the importer preserve the note's folder path and find attachments.
    [string]$VaultRoot,

    # Use this when a vault keeps all attachments in a central folder, such as "996 Images".
    [string]$AttachmentRoot,

    [string]$ContentRoot = "content/notes",
    [string]$ImageRoot = "static/images/notes",
    [string]$Title,
    [switch]$Draft
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-FullPath([string]$Path) {
    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Path))
}

function Get-SafeName([string]$Name) {
    return ($Name -replace '[\\/:*?"<>|]', '-' -replace '\s+', '-').Trim('-')
}

function Get-UrlPath([string]$Path) {
    return (($Path -split '[\\/]') | ForEach-Object { [uri]::EscapeDataString($_) }) -join '/'
}

$sourcePath = (Resolve-Path -LiteralPath $Source).Path
if ([string]::IsNullOrWhiteSpace($VaultRoot)) {
    $vaultPath = Split-Path -Parent $sourcePath
} else {
    $vaultPath = (Resolve-Path -LiteralPath $VaultRoot).Path
}

$contentRootPath = Get-FullPath $ContentRoot
$imageRootPath = Get-FullPath $ImageRoot
if (-not (Test-Path -LiteralPath $contentRootPath)) { throw "Content root does not exist: $contentRootPath" }

$relativeNote = [System.IO.Path]::GetRelativePath($vaultPath, $sourcePath)
if ($relativeNote.StartsWith("..")) { $relativeNote = Split-Path -Leaf $sourcePath }
$relativeStem = [System.IO.Path]::ChangeExtension($relativeNote, $null).TrimEnd([char[]]'.\\/')
if ([string]::IsNullOrWhiteSpace($Slug)) { $Slug = Get-SafeName ([System.IO.Path]::GetFileNameWithoutExtension($sourcePath)).ToLowerInvariant() }

switch ($ContentType) {
    'Writeup' {
        $targetPath = Join-Path (Get-FullPath 'content/writeups') (Join-Path $Slug '_index.md')
        $assetFolder = Join-Path (Get-FullPath 'static/images') $Slug
    }
    'Posts' {
        $targetPath = Join-Path (Get-FullPath 'content/posts') ($Slug + '.md')
        $assetFolder = Join-Path (Get-FullPath 'static/images') $Slug
    }
    default {
        $targetPath = Join-Path $contentRootPath ($relativeStem + '.md')
        $assetFolder = Join-Path $imageRootPath $relativeStem
    }
}

if ($AttachmentRoot) { $attachmentRootPath = (Resolve-Path -LiteralPath $AttachmentRoot).Path }

function Find-Attachment([string]$Reference) {
    $cleanReference = ($Reference -replace '#.*$', '').Trim()
    if ([string]::IsNullOrWhiteSpace($cleanReference)) { return $null }
    $cleanReference = [uri]::UnescapeDataString($cleanReference)
    $candidates = @(
        (Join-Path (Split-Path -Parent $sourcePath) $cleanReference),
        (Join-Path $vaultPath $cleanReference)
    )
    if ($AttachmentRoot) { $candidates += (Join-Path $attachmentRootPath $cleanReference) }
    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { return (Resolve-Path -LiteralPath $candidate).Path }
    }

    # Obsidian commonly stores assets in a vault-level attachments folder and links by filename.
    $leaf = Split-Path -Leaf $cleanReference
    $searchRoot = if ($AttachmentRoot) { $attachmentRootPath } else { $vaultPath }
    $matches = @(Get-ChildItem -LiteralPath $searchRoot -Recurse -File -Filter $leaf -ErrorAction SilentlyContinue)
    if ($matches.Count -eq 1) { return $matches[0].FullName }
    if ($matches.Count -gt 1) { Write-Warning "More than one attachment matches '$Reference'; leaving the link unchanged." }
    return $null
}

function Copy-Attachment([string]$Reference) {
    $attachment = Find-Attachment $Reference
    if ($null -eq $attachment) {
        Write-Warning "Could not find local attachment '$Reference'."
        return $null
    }
    $destination = Join-Path $assetFolder (Get-SafeName (Split-Path -Leaf $attachment))
    if ($PSCmdlet.ShouldProcess($destination, "Copy attachment")) {
        New-Item -ItemType Directory -Force -Path $assetFolder | Out-Null
        Copy-Item -LiteralPath $attachment -Destination $destination -Force
    }
    $relativeAsset = [System.IO.Path]::GetRelativePath((Get-FullPath 'static'), $destination)
    return '/' + (Get-UrlPath $relativeAsset)
}

$body = Get-Content -LiteralPath $sourcePath -Raw

# Obsidian embeds: ![[diagram.png]], ![[diagram.png|Caption]], and ![[diagram.png|300]].
$body = [regex]::Replace($body, '!\[\[([^\]|]+)(?:\|([^\]]*))?\]\]', [System.Text.RegularExpressions.MatchEvaluator]{
    param($match)
    $url = Copy-Attachment $match.Groups[1].Value
    if ($null -eq $url) { return $match.Value }
    $caption = $match.Groups[2].Value.Trim()
    if ([string]::IsNullOrWhiteSpace($caption) -or $caption -match '^\d+(?:x\d+)?$') { $caption = [System.IO.Path]::GetFileNameWithoutExtension($match.Groups[1].Value) }
    return ('![' + $caption.Replace(']', '\]') + '](' + $url + ')')
})

# Standard Markdown images that point to a local file also get copied, so either Obsidian style works.
$body = [regex]::Replace($body, '!\[([^\]]*)\]\(([^\s)]+)(?:\s+"[^"]*")?\)', [System.Text.RegularExpressions.MatchEvaluator]{
    param($match)
    $reference = $match.Groups[2].Value
    if ($reference -match '^(https?:|/|data:)') { return $match.Value }
    $url = Copy-Attachment $reference
    if ($null -eq $url) { return $match.Value }
    return ('![' + $match.Groups[1].Value + '](' + $url + ')')
})

if ($body -notmatch '^(?s)---\s*\r?\n.*?\r?\n---\s*(\r?\n|$)') {
    $pageTitle = if ($Title) { $Title } else { ([System.IO.Path]::GetFileNameWithoutExtension($sourcePath) -replace '[-_]+', ' ') }
    $frontMatter = "---`n" + "title: `"$pageTitle`"`n"
    if ($ContentType -eq 'Writeup') { $frontMatter += "layout: `"Notes`"`n" }
    if ($Draft) { $frontMatter += "draft: true`n" }
    $body = $frontMatter + "---`n`n" + $body.TrimStart()
}

if ($PSCmdlet.ShouldProcess($targetPath, "Write Hugo note")) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $targetPath) | Out-Null
    Set-Content -LiteralPath $targetPath -Value $body -NoNewline -Encoding utf8
}

# The custom Notes browser needs an _index.md in every folder it shows.
if ($ContentType -eq 'Notes') {
    $folder = Split-Path -Parent $targetPath
    while ($folder.StartsWith($contentRootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
        $index = Join-Path $folder '_index.md'
        if (-not (Test-Path -LiteralPath $index) -and $PSCmdlet.ShouldProcess($index, "Create Notes section index")) {
            $folderTitle = Split-Path -Leaf $folder
            Set-Content -LiteralPath $index -Value ("---`ntitle: `"$folderTitle`"`nlayout: notes`n---`n") -Encoding utf8
        }
        if ($folder -eq $contentRootPath) { break }
        $folder = Split-Path -Parent $folder
    }
}

Write-Host "Imported: $targetPath"
