

# all this script does is multiply two large numbers to form another large number.
# KGT 2022


#####
# Window UI settings
#####
$uisettings = (get-host).UI.RawUI
$x = $uisettings.WindowPosition
$x.x = 0
$x.y = 0
$uisettings.WindowPosition = $x

$bgcolour = $uisettings.BackgroundColor
$bgcolour = "Black"
$uisettings.BackgroundColor = $bgcolour

$b = $uisettings.WindowSize
$ba = $uisettings.MaxPhysicalWindowSize

# adjust buffer size according to max physical window size

$bf = $uisettings.BufferSize
$bf.Height = $ba.Height * 5
$bf.Width = $ba.Width * 5
$uisettings.BufferSize = $bf

[int] $heightwindow = 25 # --- minimum is 20
[int] $widthwindow = 100 # --- minimum is 20

# let window size be max physical window size
$b.Height = $heightwindow + 10 # larger than printed size
if ($widthwindow * 2 -lt 52){
    $b.Width = 52
} else {
    $b.Width = $widthwindow * 2 + 1 # 
}
$uisettings.WindowSize = $b # apply window size changes

function cursor-goto-fine ([int] $x_coordinate, [int] $y_coordinate){

    [Console]::SetCursorPosition($x_coordinate, $y_coordinate);
}

cls
cursor-goto-fine (0)(0)

function int-arr-zero ([int] $len){  # returns int array with length $len containing all zeroes.

    $arr = @(1..$len)

    for ($i = 0; $i -lt $len; $i++){
        $arr[$i] = 0
    }

    return $arr
}

function flip-int-arr-endian ([int[]] $arr){  #rearrange from big-endian to little-endian

    $num_re = int-arr-zero($arr.Length)

    for ($element = 0; $element -lt $num_len; $element++){
        $num_re[$element] = $arr[- $element - 1]
    }

    return $num_re    
}

function to-num-array ([char[]] $arr){ #cast char value into int. or else char value will become two-digit int -> # value of ascii
 
    $num = int-arr-zero($arr.Length)

    for ($element = 0; $element -lt $num_len; $element++){  
        $num[$element] = [int] $arr[$element] - 48
    }

    return $num
}


function pow2 ([int]$pow){

    # 115,​792,​089,​237,​316,​195,​423,​570,​985,​008,​687,​907,​853,​269,​984,​665,​640,​564,​039,​457,​584,​007,​913,​129,​639,​935

    # cycles
    
    $num_len = 155 # maximum for 512 bit integers
    $num = int-arr-zero($num_len) 

    $num[0] = 1

    for ($loops = 0; $loops -lt $pow; $loops++){
        for ($element = 0; $element -lt $num_len; $element++){  #double every int in array
            if ($num[$element] -ne 0){
                $num[$element] = $num[$element] * 2
            }
        }
        for ($element = 0; $element -lt $num_len; $element++){ #carry every int in array
            if ($num[$element] -gt 9){
                $num[$element] = $num[$element] - 10
                $num[$element + 1] = $num[$element + 1] + 1
            }
        }
    }

    $num_re = flip-int-arr-endian ($num)
            
    return $num_re -join ""  -replace '^0+', ''

}

function add-numstr ([string]$a, [string]$b){

    # add-numstr ("1")("1")

    $num_len = 155 # maximum for 512 bit integers

    $a_len = $a.Length
    $b_len = $b.Length
    if ($a_len -ge $b_len){$stop_len = $a_len + 2} else {$stop_len = $b_len + 2}
    if ($stop_len -ge $num_len){$stop_len = $num_len}

    $num_a = $a.PadLeft($num_len,"0").ToCharArray()  # ensure same number of digits for array later on
    $num_b = $b.PadLeft($num_len,"0").ToCharArray()
 
      
    $num = int-arr-zero ($num_len)

    $num_a_re = flip-int-arr-endian (to-num-array ($num_a))
    $num_b_re = flip-int-arr-endian (to-num-array ($num_b))

    
    for ($element = 0; $element -lt $stop_len; $element++){
        
        $num[$element] = $num_a_re[$element] + $num_b_re[$element]

    }
    for ($element = 0; $element -lt $stop_len - 1; $element++){  # carry places with more than 10

        if ($num[$element] -gt 9){                               # for addition places will be no more than 9+9+1 (carry) 19, 
            $num[$element] = $num[$element] - 10                 # so repeated adding of carry (while loop) is not required
            $num[$element + 1] = $num[$element + 1] + 1
        }
    }

    $num_re = flip-int-arr-endian ($num)

    $num_re = $num_re -join ""
            
    return [string] $num_re -replace '^0+', ''

}

function multiply-by-ten-shift([string]$a, [int]$shift){          # big endian only

    $num_len = 155

    $num = $a.PadLeft($num_len,"0").ToCharArray()

    $num = to-num-array ($num)
    $num_mult = int-arr-zero($num_len)
    
    for ($element = $shift; $element -lt $num_len; $element++){
    
        $num_mult[$element - $shift] = $num[$element]             # already set to zero as in above for the ones place.

    }
    
    $num_mult = $num_mult -join ""

    return [string] $num_mult -replace '^0+', ''

}


#incomplete
#strip commas and dots
function multiply-numstr ([string]$a, [string]$b){

        # multiply-numstr ("1")("1")
    

    $num_len = 155 # maximum for 512 bit integers

    $b_len = $b.Length
    $stop_b_len = $a_len + $b_len + 1

    $num_a = $a.PadLeft($num_len,"0")  # directly use string
    $num_b = $b.PadLeft($num_len,"0")

    $num_a2 = add-numstr($num_a)($num_a)
    $num_a3 = add-numstr($num_a)($num_a2)
    $num_a4 = add-numstr($num_a2)($num_a2)
    $num_a5 = add-numstr($num_a2)($num_a3)
    $num_a6 = add-numstr($num_a3)($num_a3)
    $num_a7 = add-numstr($num_a3)($num_a4)
    $num_a8 = add-numstr($num_a4)($num_a4)
    $num_a9 = add-numstr($num_a4)($num_a5)

    $num_b_little_endian = flip-int-arr-endian (to-num-array($num_b.ToCharArray()))  # for multiplier index

    $result = int-arr-zero($num_len) -join ""
 
    for ($i = 0; $i -lt $stop_b_len; $i++){
        
        $current_place_result = int-arr-zero($num_len) -join ""

        [int] $b_mult = $num_b_little_endian[$i]
        if (!($b_mult -eq 0)){                                 # if position #j of $a is non-zero,
             
            Switch ($b_mult) {
            1 {$current_place_result = $num_a}
            2 {$current_place_result = $num_a2}
            3 {$current_place_result = $num_a3}
            4 {$current_place_result = $num_a4}
            5 {$current_place_result = $num_a5}
            6 {$current_place_result = $num_a6}
            7 {$current_place_result = $num_a7}
            8 {$current_place_result = $num_a8}
            9 {$current_place_result = $num_a9}
            }

            # calculate multiples of x10 
            if (!($i -eq 0)){  
                $current_place_result = multiply-by-ten-shift($current_place_result)($i)   
            }
        }

        $result = add-numstr($result)($current_place_result)

    }

    return $result -join ""  -replace '^0+', ''

}



#$pow = Read-Host ("`nInput power: ")
#$ans = pow2($pow)
#[console]::Write($ans)

#$ans = pow2 (212)


#$ans = add-numstr(pow2(212))(pow2(212))

#$ans = multiply-by-ten("47604524036730424631850294460894909302930821810983811727510334984391012367348")
[console]::Write("`n`n    Welcome to the Powershell multiply-512 script.`n")
[console]::Write("`n    This script multiplies up to two 78 character long integers.`n")
[console]::Write("    This means it supports the multiplication of two 256-bit numbers.`n")
[console]::Write("`n    Created by KohGT in 2022`n")
[console]::Write("`n    --------------------0----0----1----1----2----2----3----3----4----4----5----5----6----6----7----7--7")
[console]::Write("`n    --------------------0----5----0----5----0----5----0----5----0----5----0----5----0----5----0----5--8`n")
$a = Read-Host ("    Input first number ")
$a = [string] $a
$b = Read-Host ("    Input second number")
$b = [string] $b

$c = multiply-numstr($a)($b)

cls;
#length check
$alen = $a.Length
$blen = $b.Length
$clen = $c.Length

$offset_a = $clen - $alen
$offset_b = $clen - $blen
cursor-goto-fine(0)(0)
[console]::Write("`n`n`n")
[console]::Write(" "*(12+$offset_a))
[console]::Write("$a`n")
[console]::Write(" "*7)
[console]::Write("x")
[console]::Write(" "*(4+$offset_b))
[console]::Write("$b`n")
[console]::Write(" "*5)
[console]::Write("-"*($clen + 9))
[console]::Write("`n")
[console]::Write(" "*12)
[console]::Write("$c`n`n")

$a = Read-Host ("Press enter to continue")

