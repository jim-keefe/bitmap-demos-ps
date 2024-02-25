function Set-Color {

    # If we are just starting, read in the first color
    if (!$current.color1){
        "color$('{0:d2}' -f [int]$current.colorindex)"
        "color$('{0:d2}' -f ([int]($current.colorindex) + 1))"
        $current.color1 = $colors."color$('{0:d2}' -f [int]$current.colorindex)"
        $current.r = $current.color1.r
        $current.g = $current.color1.g
        $current.b = $current.color1.b
        $current.color2 = $colors."color$('{0:d2}' -f ([int]($current.colorindex) + 1))"
    }

    # For every color in the list, show the color for a period, then fade to the next color
    if ($current.colorPhaseCounter -lt $current.colorIntervalCount)
    {
        # Increment the counter for the current phase
        $current.colorPhaseCounter ++

    } else {
        # Reset the phase counter, 
        $current.colorPhaseCounter = 0
        $current.colorPhaseCounter ++
        
        # Go to the next phase
        $current.colorPhase ++
        
        # Flip the bit on whether this is a fade phase
        if ($current.fade) { $current.fade = $false } else { $current.fade = $true }
        
        # If the next phase is a fade phase then load in the new colors
        if (!$current.fade){
            $colors[$current.colorindex] ++
            "color$('{0:d2}' -f [int]$current.colorindex)"
            "color$('{0:d2}' -f ([int]($current.colorindex) + 1))"
            $current.color1 = $colors."color$('{0:d2}' -f [int]$current.colorindex)"
            $current.r = $current.color1.r
            $current.g = $current.color1.g
            $current.b = $current.color1.b
            # Load the next color unless we are at the end of our colors
            if (!(($current.colorindex + 1) -gt $colors.count)) {
                $current.color2 = $colors."color$('{0:d2}' -f ([int]($current.colorindex) + 1))"
            }
        } else {
            # The new phase is a fade. Determine the r,g and b color increment amount
            # for each interval to get from the current color to the next color
            $current.rIncrement = ($current.color2.r - $current.color1.r) / $current.colorIntervalCount
            $current.gIncrement = ($current.color2.g - $current.color1.g) / $current.colorIntervalCount
            $current.bIncrement = ($current.color2.b - $current.color1.b) / $current.colorIntervalCount
        }
    }
}

$iterations = 100

# The list of colors in order
$colors = @{
    color01 = @{
        r = 255
        g = 0
        b = 0
    }
    color02 = @{
        r = 0
        g = 255
        b = 0
    }
    color03 = @{
        r = 0
        g = 0
        b = 255
    }
}

# An object with current properties for colors
$current = @{
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

#currently not used
$colorplan = @{
    stage01 = @{
        mode = "solid"
        count = 1
    }
    stage02 = @{
        mode = "crossfade"
        count = 2
    }
}

# $colorIntervalCount = 100 / ($colors.count + $colors.count -1)

for ($i = 1;  $i -lt $iterations; $i++){

    Set-Color

    "=============================================="
    $current
    #"Phase: $($current.colorPhase)"
    #"Fade:  $($current.fade)"
    #"Counter: $($current.colorPhaseCounter)"
    #"Red: $($current.r)"
    #"Green: $($current.g)"
    #"Blue: $($current.b)"

}


