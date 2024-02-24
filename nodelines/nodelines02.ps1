# Configurable Variables
$picWidth = 1920
$picHeight = 1080
$nodesize = 12
$linewidth = 2
$iterations = 250
$glow = $true

Add-Type -AssemblyName System.Drawing

Write-Host "Running . . ."

# Create a Bitmap and set the background
$bitmap = New-Object System.Drawing.Bitmap($picWidth, $picHeight)
$bitmapGraphics = [System.Drawing.Graphics]::FromImage($bitmap) 
$bitmapGraphics.Clear("black")

$quadrant = "topleft"
$x1 = ($picHeight / 2) - 10
$y1 = ($picHeight / 2) + 10

for ($i = 1;  $i -lt $iterations; $i++){
    
    $currentFactor = $i / $iterations
    # Write-Host $quadrant
    switch ($quadrant){
        "topleft" {
            # generate a random y2
            $x2 = $x1
            $y2 = ($picHeight / 2) - (Get-Random -Maximum ($picHeight / 2)) * $currentFactor
            $quadrant = "topright"
        }
        "topright" {
            # generate a random x2
            $y2 = $y1
            $x2 = ($picWidth / 2) + (Get-Random -Maximum ($picWidth / 2)) * $currentFactor
            $quadrant = "bottomright"
        }
        "bottomright" {
            # generate a random y2
            $x2 = $x1
            $y2 = ($picHeight / 2) + (Get-Random -Maximum ($picHeight / 2)) * $currentFactor
            $quadrant = "bottomleft"
        }
        "bottomleft" {
            # generate a random x2
            $y2 = $y1
            $x2 = ($picWidth / 2) - (Get-Random -Maximum ($picWidth / 2)) * $currentFactor
            $quadrant = "topleft"
        }
    }
    
    # set colors
	$colorindex1 = 128 * $currentFactor
    $colorindex2 = 64 * $currentFactor
    
    $color1 = [System.Drawing.Color]::FromArgb($colorindex1, $colorindex1, $colorindex1)
    $color2 = [System.Drawing.Color]::FromArgb($colorindex2, $colorindex2, $colorindex2)
    $pen = new-object Drawing.Pen $color1,($linewidth * $currentFactor)
    
    $brush = new-object Drawing.SolidBrush $color2

    # Draw the line
    if ($glow){
        $colorindex3 = $colorindex1 / 3
        $color3 = [System.Drawing.Color]::FromArgb($colorindex3, $colorindex3, $colorindex3)
        $glowpen3 = new-object Drawing.Pen $color3,($linewidth * 3 * $currentFactor)
        $bitmapGraphics.DrawLine($glowpen3,$x1,$y1,$x2,$y2)
        $colorindex4 = $colorindex1 / 2
        $color4 = [System.Drawing.Color]::FromArgb($colorindex4, $colorindex4, $colorindex4)
        $glowpen4 = new-object Drawing.Pen $color4,($linewidth * 2 * $currentFactor)
        $bitmapGraphics.DrawLine($glowpen4,$x1,$y1,$x2,$y2)
    }
    $bitmapGraphics.DrawLine($pen,$x1,$y1,$x2,$y2)

    # Draw the node
    $bitmapGraphics.FillEllipse($brush,$x1-($nodesize / 2 * $currentFactor),$y1-($nodesize / 2 * $currentFactor),($nodesize  * $currentFactor),($nodesize  * $currentFactor))
    $bitmapGraphics.DrawEllipse($pen,$x1-($nodesize / 2 * $currentFactor),$y1-($nodesize / 2 * $currentFactor),($nodesize  * $currentFactor),($nodesize  * $currentFactor))


    $x1 = $x2
    $y1 = $y2
}

$bitmapGraphics.FillEllipse($brush,$x1-($nodesize / 2 * $currentFactor),$y1-($nodesize / 2 * $currentFactor),($nodesize  * $currentFactor),($nodesize  * $currentFactor))
$bitmapGraphics.DrawEllipse($pen,$x1-($nodesize / 2 * $currentFactor),$y1-($nodesize / 2 * $currentFactor),($nodesize  * $currentFactor),($nodesize  * $currentFactor))


$outFile = $PSScriptRoot  + $runmode + "_" + (Get-Date -UFormat %Y%m%d_%H%M%S) + ".png"
$bitmap.Save($outFile, [System.Drawing.Imaging.ImageFormat]::Png)
Invoke-Item $outFile
$bitmap.Dispose()
$bitmapGraphics.Dispose()
Write-Host "Complete"