# A continous line made of horizontal and verticle segments. A circle is drawn at points of intersection to give the appearance of nodes.
# The line changes color gradually based on the $colors defined.
# In this version, segments always traverse a boundry to an adjacent quadrant of the bitmap area. Added the glow feature to give depth to segments.

# source the color functions
$myscriptpath = $MyInvocation.MyCommand.Path
$myscriptpathparent = (get-item $myscriptpath).Directory
. "$myscriptpathparent\color_functions.ps1"

#==================================================
# Variables
#==================================================

# Configurable Variables
$picWidth = (1584/2)
$picHeight = (396/2)
$nodesize = 10
$linewidth = 3
$iterations = 100
$glow = $false

$workfolder = "c:\temp\nodelines"

# The list of colors in order. There are a few examples below
$colors1 = @{
    color01 = @{
        r = 20
        g = 0
        b = 20
    }
    color02 = @{
        r = 128
        g = 50
        b = 128
    }
}
$colors = @{
    color01 = @{
        r = 128
        g = 0
        b = 0
    }
    color02 = @{
        r = 128
        g = 128
        b = 0
    }
    color03 = @{
        r = 0
        g = 128
        b = 0
    }
    color04 = @{
        r = 0
        g = 128
        b = 128
    }
    color05 = @{
        r = 0
        g = 0
        b = 128
    }
    color06 = @{
        r = 128
        g = 0
        b = 128
    }
    color07 = @{
        r = 128
        g = 0
        b = 0
    }
}

# An object with current properties for colors
$currentColor = @{
    r = 0
    rIncrement = $null
    g = 0
    gIncrement = $null
    b = 0
    bIncrement = $null
    color1 = $null
    color2 = $null
    colorPhase = 1
    colorPhaseCounter = 1
    colorindex = 1
    colorIntervalCount = $iterations / ($colors.count + $colors.count -1)
    fade = $false
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
$bitmapGraphics.Clear("black")

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
            $y2 = ($picHeight / 2) - ($picHeight / 2) * $currentFactor
            $quadrant = "topright"
        }
        "topright" {
            # generate a random x2
            $y2 = $y1
            $x2 = ($picWidth / 2) + ($picWidth / 2) * $currentFactor
            $quadrant = "bottomright"
        }
        "bottomright" {
            # generate a random y2
            $x2 = $x1
            $y2 = ($picHeight / 2) + ($picHeight / 2) * $currentFactor
            $quadrant = "bottomleft"
        }
        "bottomleft" {
            # generate a random x2
            $y2 = $y1
            $x2 = ($picWidth / 2) - ($picWidth / 2) * $currentFactor
            $quadrant = "topleft"
        }
    }
    
    # set colors
	Set-Color
    
    $color1 = [System.Drawing.Color]::FromArgb($currentColor.r, $currentColor.g, $currentColor.b)
    $color2 = [System.Drawing.Color]::FromArgb($currentColor.r / 2, $currentColor.g / 2, $currentColor.b / 2)
    $pen = new-object Drawing.Pen $color1,($linewidth * $currentFactor)
    
    $brush = new-object Drawing.SolidBrush $color2

    # Draw the line
    if ($glow){

        $color3 = [System.Drawing.Color]::FromArgb($currentColor.r / 2, $currentColor.g / 2, $currentColor.b / 2)
        $glowpen3 = new-object Drawing.Pen $color3,($linewidth * 4 * $currentFactor)
        $bitmapGraphics.DrawLine($glowpen3,$x1,$y1,$x2,$y2)

        $color4 = [System.Drawing.Color]::FromArgb($currentColor.r / 4, $currentColor.g / 4, $currentColor.b / 4)
        $glowpen4 = new-object Drawing.Pen $color4,($linewidth * 3 * $currentFactor)
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

$outFile = "$workfolder\$scriptname-$(Get-Date -UFormat %Y%m%d_%H%M%S).png"
$bitmap.Save($outFile, [System.Drawing.Imaging.ImageFormat]::Png)
Invoke-Item $outFile
$bitmap.Dispose()
$bitmapGraphics.Dispose()
Write-Host "Complete"