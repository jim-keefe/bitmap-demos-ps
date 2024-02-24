# Configurable Variables
$picWidth = 1920
$picHeight = 1080
$iterations = 4000

Add-Type -AssemblyName System.Drawing

Write-Host "Running . . ."
 
# Create a Bitmap and set the background
$bitmap = New-Object System.Drawing.Bitmap($picWidth, $picHeight)
$bitmapGraphics = [System.Drawing.Graphics]::FromImage($bitmap) 
$bitmapGraphics.Clear("black")

#$color2 = [System.Drawing.Color]::FromArgb($r2, $b2, $g2)
#$brush = new-object Drawing.SolidBrush $color2
#$bitmapGraphics.FillEllipse($brush,$x2-50,$y2-50,100,100)
#$bitmapGraphics.DrawEllipse($pen,$x2-50,$y2-50,100,100)

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

# $runmode = notelines
# $bitmap.SetPixel($xPixel, $yPixel, [System.Drawing.Color]::FromArgb($red, $green, $blue))

$outFile = $PSScriptRoot  + $runmode + "_" + (Get-Date -UFormat %Y%m%d_%H%M%S) + ".png"
$bitmap.Save($outFile, [System.Drawing.Imaging.ImageFormat]::Png)
Invoke-Item $outFile
$bitmap.Dispose()
$bitmapGraphics.Dispose()
Write-Host "Complete"