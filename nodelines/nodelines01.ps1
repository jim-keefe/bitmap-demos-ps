# A continous line made of horizontal and verticle segments. A circle is drawn at points of intersection to give the appearance of nodes.
# The line grows from dark to light to give the appearance of depth

# Configurable Variables
$picWidth = 1584/2
$picHeight = 396/2
$iterations = 100
$lineweight = 1
$nodesize = 12

$workfolder = "c:\temp\nodelines"

$colorpercent = @{ # a percent between 0 and 100
    r = 75
    g = 75
    b = 80
}

$backgroundcolorpercent = @{ # a percent between 0 and 100
    r = 25
    g = 25
    b = 25
}

Add-Type -AssemblyName System.Drawing

New-Item -ItemType Directory -Path $workfolder -ErrorAction SilentlyContinue
$scriptname = $MyInvocation.MyCommand.Name.Split(".")[0]

Write-Host "Running . . ."
 
# Create a Bitmap and set the background
$bitmap = New-Object System.Drawing.Bitmap($picWidth, $picHeight)
$bitmapGraphics = [System.Drawing.Graphics]::FromImage($bitmap) 
$bitmapGraphics.Clear([System.Drawing.Color]::FromArgb(255 * $backgroundcolorpercent.r * .01, 255 * $backgroundcolorpercent.g * .01, 255 * $backgroundcolorpercent.b * .01))

# The first segment. Because the x coordinate is the same this is a vertical line
$x1 = Get-Random -Minimum 1 -Maximum $picWidth
$y1 = Get-Random -Minimum 1 -Maximum $picHeight
$x2 = Get-Random -Minimum 1 -Maximum $picWidth
$y2 = $y1
# because x did not change this time, change it on the next iteration
$changeX = $true

for ($i = 1;  $i -lt $iterations; $i++){

    # set colors
	$colorindex1 = 255 * $i / $iterations
    $colorindex2 = $colorindex1 * .7
    $color1 = [System.Drawing.Color]::FromArgb($colorindex1*$colorpercent.r * .01, $colorindex1*$colorpercent.g * .01, $colorindex1*$colorpercent.b * .01)
    $color2 = [System.Drawing.Color]::FromArgb($colorindex2*$colorpercent.r * .01, $colorindex2*$colorpercent.g * .01, $colorindex2*$colorpercent.b * .01)
    $pen = new-object Drawing.Pen $color1,($lineweight)
    $brush = new-object Drawing.SolidBrush $color2

    # Draw the line
    $bitmapGraphics.DrawLine($pen,$x1,$y1,$x2,$y2)

    # Draw the node
    $bitmapGraphics.FillEllipse($brush,$x1-($nodesize / 2),$y1-($nodesize / 2),($nodesize ),($nodesize ))
    $bitmapGraphics.DrawEllipse($pen,$x1-($nodesize / 2),$y1-($nodesize / 2),($nodesize ),($nodesize ))

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
$bitmapGraphics.FillEllipse($brush,$x1-($nodesize / 2),$y1-($nodesize / 2),($nodesize ),($nodesize ))
$bitmapGraphics.DrawEllipse($pen,$x1-($nodesize / 2),$y1-($nodesize / 2),($nodesize ),($nodesize ))

$outFile = "$workfolder\$scriptname-$(Get-Date -UFormat %Y%m%d_%H%M%S).png"
$bitmap.Save($outFile, [System.Drawing.Imaging.ImageFormat]::Png)
Invoke-Item $outFile
$bitmap.Dispose()
$bitmapGraphics.Dispose()
Write-Host "Complete"