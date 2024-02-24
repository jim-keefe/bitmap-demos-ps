# Configurable Variables
$picWidth = 1920
$picHeight = 1080
$iterations = 300

$workfolder = "c:\temp\nodelines"

Add-Type -AssemblyName System.Drawing

New-Item -ItemType Directory -Path $workfolder -ErrorAction SilentlyContinue
$scriptname = $MyInvocation.MyCommand.Name.Split(".")[0]

Write-Host "Running . . ."
 
# Create a Bitmap and set the background
$bitmap = New-Object System.Drawing.Bitmap($picWidth, $picHeight)
$bitmapGraphics = [System.Drawing.Graphics]::FromImage($bitmap) 
$bitmapGraphics.Clear("black")

$x1 = Get-Random -Minimum 1 -Maximum $picWidth
$y1 = Get-Random -Minimum 1 -Maximum $picHeight
$x2 = Get-Random -Minimum 1 -Maximum $picWidth
$y2 = Get-Random -Minimum 1 -Maximum $picHeight
$changeX = $false

for ($i = 1;  $i -lt $iterations; $i++){

    # set colors
	$colorindex1 = 128 * $i / $iterations
    $colorindex2 = 64 * $i / $iterations
    $color1 = [System.Drawing.Color]::FromArgb($colorindex1, $colorindex1, $colorindex1)
    $color2 = [System.Drawing.Color]::FromArgb($colorindex2, $colorindex2, $colorindex2)
    $pen = new-object Drawing.Pen $color1,(2)
    $brush = new-object Drawing.SolidBrush $color2

    # Draw the line
    $bitmapGraphics.DrawLine($pen,$x1,$y1,$x2,$y2)

    # Draw the node
    $bitmapGraphics.FillEllipse($brush,$x1-10,$y1-10,20,20)
    $bitmapGraphics.DrawEllipse($pen,$x1-10,$y1-10,20,20)

    # plot new coordinates
    $x1 = $x2
    $y1 = $y2
    
    if ($changeX) {
        $x2 = Get-Random -Minimum 1 -Maximum $picWidth
        $changeX = $false
    } else {
        $y2 = Get-Random -Minimum 1 -Maximum $picHeight
        $changeX = $true
    }
}

# Draw the last node
$bitmapGraphics.FillEllipse($brush,$x1-10,$y1-10,20,20)
$bitmapGraphics.DrawEllipse($pen,$x1-10,$y1-10,20,20)

$outFile = "$workdir\$scriptname-$(Get-Date -UFormat %Y%m%d_%H%M%S).png"
$bitmap.Save($outFile, [System.Drawing.Imaging.ImageFormat]::Png)
Invoke-Item $outFile
$bitmap.Dispose()
$bitmapGraphics.Dispose()
Write-Host "Complete"