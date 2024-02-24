#==================================================
# Functions
#==================================================

# This function uses the colors object to set an RGB color value and fade beween colors. It tracks current values for the color status values in the $currentColor object
function Set-Color {
    # If the iterations are low the increment amount may exceed the acceptable color range during fades. This function insures accptable values for RGB.
    function Check-Color ($tempColor){
        if ($tempColor -gt 255) { return 255}
        if ($tempColor -lt 0) { return 0 }
        return $tempColor
    }

    # If we are just starting, read in the first color
    if (!$currentColor.color1){
        $currentColor.color1 = $colors."color$('{0:d2}' -f [int]$currentColor.colorindex)"
        $currentColor.r = $currentColor.color1.r
        $currentColor.g = $currentColor.color1.g
        $currentColor.b = $currentColor.color1.b
        $currentColor.color2 = $colors."color$('{0:d2}' -f ([int]($currentColor.colorindex) + 1))"
    }

    # For every color in the list, show the color for a period, then fade to the next color
    if ($currentColor.colorPhaseCounter -lt $currentColor.colorIntervalCount)
    {
        # Increment the counter for the current phase
        $currentColor.colorPhaseCounter ++

    } else {
        # Reset the phase counter, 
        $currentColor.colorPhaseCounter = 1
        
        # Go to the next phase
        $currentColor.colorPhase ++
        
        # Flip the bit on whether this is a fade phase
        if ($currentColor.fade) { $currentColor.fade = $false } else { $currentColor.fade = $true }
        
        # If the next phase is a fade phase then load in the new colors
        if (!$currentColor.fade){
            $currentColor.colorindex ++
            $currentColor.color1 = $colors."color$('{0:d2}' -f [int]$currentColor.colorindex)"
            $currentColor.r = $currentColor.color1.r
            $currentColor.g = $currentColor.color1.g
            $currentColor.b = $currentColor.color1.b
            # Load the next color unless we are at the end of our colors
            if (!(($currentColor.colorindex + 1) -gt $colors.count)) {
                $currentColor.color2 = $colors."color$('{0:d2}' -f ([int]($currentColor.colorindex) + 1))"
            }
        } else {
            # The new phase is a fade. Determine the r,g and b color increment amount
            # for each interval to get from the current color to the next color
            $currentColor.rIncrement = ($currentColor.color2.r - $currentColor.color1.r) / $currentColor.colorIntervalCount
            $currentColor.gIncrement = ($currentColor.color2.g - $currentColor.color1.g) / $currentColor.colorIntervalCount
            $currentColor.bIncrement = ($currentColor.color2.b - $currentColor.color1.b) / $currentColor.colorIntervalCount
        }
    }

    if ($currentColor.fade){
        # Increment the colors during a fade phase
        $currentColor.r = Check-Color($currentColor.r + $currentColor.rIncrement)
        $currentColor.g = Check-Color($currentColor.g + $currentColor.gIncrement)
        $currentColor.b = Check-Color($currentColor.b + $currentColor.bIncrement)
    }
    
}

#==================================================
# Variables
#==================================================

# Configurable Variables
$picWidth = 1920 * 2
$picHeight = 1080 * 2
$nodesize = 10
$linewidth = 3
$iterations = 150
$glow = $true

# The list of colors in order. There are a few examples below
$colors = @{
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
$colors1 = @{
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


$outFile = $PSScriptRoot  + $runmode + "_" + (Get-Date -UFormat %Y%m%d_%H%M%S) + ".png"
$bitmap.Save($outFile, [System.Drawing.Imaging.ImageFormat]::Png)
Invoke-Item $outFile
$bitmap.Dispose()
$bitmapGraphics.Dispose()
Write-Host "Complete"