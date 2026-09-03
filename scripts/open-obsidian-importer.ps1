# Double-click this file, or run it from PowerShell, to open a drag-and-drop importer.
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Obsidian → Hugo importer'
$form.Size = New-Object System.Drawing.Size(720, 355)
$form.StartPosition = 'CenterScreen'
$form.AllowDrop = $true
$form.Font = New-Object System.Drawing.Font('Segoe UI', 10)

function Add-Label([string]$text, [int]$left, [int]$top) {
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $text; $label.Left = $left; $label.Top = $top; $label.Width = 130
    $form.Controls.Add($label)
}
function Add-TextBox([int]$left, [int]$top, [int]$width) {
    $box = New-Object System.Windows.Forms.TextBox
    $box.Left = $left; $box.Top = $top; $box.Width = $width; $box.AllowDrop = $true
    $box.Add_DragEnter({ if ($_.Data.GetDataPresent([System.Windows.Forms.DataFormats]::FileDrop)) { $_.Effect = 'Copy' } })
    $box.Add_DragDrop({ $this.Text = @($_.Data.GetData([System.Windows.Forms.DataFormats]::FileDrop))[0] })
    $form.Controls.Add($box); return $box
}
function Add-BrowseButton($box, [string]$filter, [bool]$folder) {
    $button = New-Object System.Windows.Forms.Button
    $button.Text = 'Browse…'; $button.Left = 590; $button.Top = $box.Top - 2; $button.Width = 100
    $button.Add_Click({
        if ($folder) {
            $picker = New-Object System.Windows.Forms.FolderBrowserDialog
            if ($picker.ShowDialog() -eq 'OK') { $box.Text = $picker.SelectedPath }
        } else {
            $picker = New-Object System.Windows.Forms.OpenFileDialog; $picker.Filter = $filter
            if ($picker.ShowDialog() -eq 'OK') { $box.Text = $picker.FileName }
        }
    })
    $form.Controls.Add($button)
}

Add-Label 'Obsidian note' 15 20
$source = Add-TextBox 145 18 435
Add-BrowseButton $source 'Markdown files (*.md)|*.md' $false
Add-Label 'Attachment folder' 15 65
$attachments = Add-TextBox 145 63 435
Add-BrowseButton $attachments '' $true
Add-Label 'Publish as' 15 110
$type = New-Object System.Windows.Forms.ComboBox
$type.Left = 145; $type.Top = 108; $type.Width = 180; $type.DropDownStyle = 'DropDownList'
[void]$type.Items.AddRange(@('Writeup', 'Posts', 'Notes')); $type.SelectedIndex = 0; $form.Controls.Add($type)
Add-Label 'URL slug' 15 155
$slug = Add-TextBox 145 153 435
Add-Label 'Title (optional)' 15 200
$title = Add-TextBox 145 198 435

$hint = New-Object System.Windows.Forms.Label
$hint.Text = 'Drag a .md file or folder into a field. Leave slug blank to use the filename.'
$hint.Left = 15; $hint.Top = 244; $hint.Width = 670; $hint.ForeColor = [System.Drawing.Color]::DimGray
$form.Controls.Add($hint)

$run = New-Object System.Windows.Forms.Button
$run.Text = 'Import and open preview'; $run.Left = 15; $run.Top = 275; $run.Width = 220; $run.Height = 35
$run.Add_Click({
    if (-not (Test-Path -LiteralPath $source.Text -PathType Leaf)) {
        [System.Windows.Forms.MessageBox]::Show('Choose a valid Markdown note first.', 'Obsidian importer'); return
    }
    $scriptPath = Join-Path $PSScriptRoot 'import-obsidian-note.ps1'
    $arguments = @('-NoExit', '-File', ('"' + $scriptPath + '"'), '-Source', ('"' + $source.Text + '"'), '-ContentType', $type.SelectedItem)
    if ($attachments.Text) { $arguments += @('-AttachmentRoot', ('"' + $attachments.Text + '"')) }
    if ($slug.Text) { $arguments += @('-Slug', ('"' + $slug.Text + '"')) }
    if ($title.Text) { $arguments += @('-Title', ('"' + $title.Text + '"')) }
    Start-Process powershell.exe -ArgumentList $arguments
})
$form.Controls.Add($run)

[void]$form.ShowDialog()
