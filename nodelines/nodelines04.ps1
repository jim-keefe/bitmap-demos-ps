# A continous line made of horizontal and verticle segments. A circle is drawn at points of intersection to give the appearance of nodes.
# The line changes color gradually from dark to light based on the rgb percentages specified.
# In this version, segments always traverse a boundry to an adjacent quadrant of the bitmap area. The glow feature actually makes the segments look like pipes.

# source the color functions
$myscriptpath = $MyInvocation.MyCommand.Path
$myscriptpathparent = (get-item $myscriptpath).Directory
. "$myscriptpathparent\color_functions.ps1"

#==================================================
# Variables
#==================================================

# Configurable Variables
$picWidth = (1200)
$picHeight = (627)
$nodesize = 120
$linewidth = 120
$iterations = 15
$glow = $false

$workfolder = "c:\temp\nodelines"

$colorpercent = @{ # a percent between 0 and 100
    r = 50
    g = 50
    b = 75
}

$backgroundcolorpercent = @{ # a percent between 0 and 100
    r = 30
    g = 30
    b = 40
}

#==================================================
# Main
#==================================================

Add-Type -AssemblyName System.Drawing

New-Item -ItemType Directory -Path $workfolder -ErrorAction SilentlyContinue
$scriptname = $MyInvocation.MyCommand.Name.Split(".")[0]

Write-Host "Running . . ."

# Create a Bitmap and set the background
$bitmap = New-Object System.Drawing.Bitmap($picWidth, $picHeight)
$bitmapGraphics = [System.Drawing.Graphics]::FromImage($bitmap) 
$bitmapGraphics.Clear([System.Drawing.Color]::FromArgb(255 * $backgroundcolorpercent.r * .01, 255 * $backgroundcolorpercent.g * .01, 255 * $backgroundcolorpercent.b * .01))

$quadrant = "topleft"
$x1 = ($picWidth / 2) - 1
$y1 = ($picHeight / 2) + 1

for ($i = 1;  $i -lt $iterations; $i++){
    
    $currentFactor = $i / $iterations
    # Write-Host $quadrant
    switch ($quadrant){
        "topleft" {
            # generate a random y2
            $x2 = $x1
            $y2 = ($picHeight / 2) - (Get-Random -Maximum ($picHeight / 2))
            $quadrant = "topright"
        }
        "topright" {
            # generate a random x2
            $y2 = $y1
            $x2 = ($picWidth / 2) + (Get-Random -Maximum ($picWidth / 2))
            $quadrant = "bottomright"
        }
        "bottomright" {
            # generate a random y2
            $x2 = $x1
            $y2 = ($picHeight / 2) + (Get-Random -Maximum ($picHeight / 2))
            $quadrant = "bottomleft"
        }
        "bottomleft" {
            # generate a random x2
            $y2 = $y1
            $x2 = ($picWidth / 2) - (Get-Random -Maximum ($picWidth / 2))
            $quadrant = "topleft"
        }
    }
    
    $colorindex1 = 255 * $i / $iterations
    $colorindex2 = $colorindex1 * .7
    
    $color1 = [System.Drawing.Color]::FromArgb($colorindex1*$colorpercent.r * .01, $colorindex1*$colorpercent.g * .01, $colorindex1*$colorpercent.b * .01)
    $color2 = [System.Drawing.Color]::FromArgb($colorindex2*$colorpercent.r * .01, $colorindex2*$colorpercent.g * .01, $colorindex2*$colorpercent.b * .01)
    $pen = new-object Drawing.Pen $color1,($linewidth)
    
    $brush = new-object Drawing.SolidBrush $color2

    # Draw the line
    if ($glow){

        $color3 = [System.Drawing.Color]::FromArgb($colorindex1*$colorpercent.r * .01 * .5, $colorindex1*$colorpercent.g * .01 * .5, $colorindex1*$colorpercent.b * .01 * .5)
        $glowpen3 = new-object Drawing.Pen $color3,($linewidth * 4)
        $bitmapGraphics.DrawLine($glowpen3,$x1,$y1,$x2,$y2)

        $color4 = [System.Drawing.Color]::FromArgb($colorindex2*$colorpercent.r * .01, $colorindex2*$colorpercent.g * .01, $colorindex2*$colorpercent.b * .01)
        $glowpen4 = new-object Drawing.Pen $color4,($linewidth * 3)
        $bitmapGraphics.DrawLine($glowpen4,$x1,$y1,$x2,$y2)
    }
    $bitmapGraphics.DrawLine($pen,$x1,$y1,$x2,$y2)

    # Draw the node
    $bitmapGraphics.FillEllipse($brush,$x1-($nodesize / 2),$y1-($nodesize / 2),($nodesize ),($nodesize ))
    $bitmapGraphics.DrawEllipse($pen,$x1-($nodesize / 2),$y1-($nodesize / 2),($nodesize ),($nodesize ))

    $x1 = $x2
    $y1 = $y2
}

$bitmapGraphics.FillEllipse($brush,$x1-($nodesize / 2),$y1-($nodesize / 2),($nodesize ),($nodesize ))
$bitmapGraphics.DrawEllipse($pen,$x1-($nodesize / 2),$y1-($nodesize / 2),($nodesize ),($nodesize ))

$outFile = "$workfolder\$scriptname-$(Get-Date -UFormat %Y%m%d_%H%M%S).png"
$bitmap.Save($outFile, [System.Drawing.Imaging.ImageFormat]::Png)
Invoke-Item $outFile
$bitmap.Dispose()
$bitmapGraphics.Dispose()
Write-Host "Complete"