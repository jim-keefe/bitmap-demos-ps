# Configurable Variables
$picWidth = 1920
$picHeight = 1080
$iterations = 400

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

for ($i = 1;  $i -lt $iterations; $i++){
	$colorindex = 255 * $i / $iterations
    $color1 = [System.Drawing.Color]::FromArgb(0, $colorindex, $colorindex)
    $pen = new-object Drawing.Pen $color1,(Get-Random -Minimum 1 -Maximum 10)
    $x1 = Get-Random -Minimum 1 -Maximum $picWidth
    $y1 = Get-Random -Minimum 1 -Maximum $picHeight
    $x2 = Get-Random -Minimum 1 -Maximum $picWidth
    $y2 = Get-Random -Minimum 1 -Maximum $picHeight
    $bitmapGraphics.DrawLine($pen,$x1,$y1,$x2,$y2)
}

# $runmode = notelines
# $bitmap.SetPixel($xPixel, $yPixel, [System.Drawing.Color]::FromArgb($red, $green, $blue))

$outFile = $PSScriptRoot  + $runmode + "_" + (Get-Date -UFormat %Y%m%d_%H%M%S) + ".png"
$bitmap.Save($outFile, [System.Drawing.Imaging.ImageFormat]::Png)
Invoke-Item $outFile
$bitmap.Dispose()
$bitmapGraphics.Dispose()
Write-Host "Complete"