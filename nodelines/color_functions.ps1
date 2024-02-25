#==================================================
# Functions
#==================================================

# This function uses the colors object to set an RGB color value and fade beween colors. It tracks current values for the color status values in the $currentColor object
function Set-Color {

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
        $currentColor.r = CheckColor($currentColor.r + $currentColor.rIncrement)
        $currentColor.g = CheckColor($currentColor.g + $currentColor.gIncrement)
        $currentColor.b = CheckColor($currentColor.b + $currentColor.bIncrement)
    }
    
}

# If the iterations are low the increment amount may exceed the acceptable color range during fades. This function insures accptable values for RGB.
function CheckColor ($tempColor){
    if ($tempColor -gt 255) { return 255}
    if ($tempColor -lt 0) { return 0 }
    return $tempColor
}