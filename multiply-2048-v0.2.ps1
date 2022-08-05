

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
    $num_len = $arr.Length
    $num_re = int-arr-zero($arr.Length)

    for ($element = 0; $element -lt $num_len; $element++){
        $num_re[$element] = $arr[- $element - 1]
    }

    return $num_re    
}

function to-num-array ([char[]] $arr){ #cast char value into int. or else char value will become two-digit int -> # value of ascii
    
    $num_len = $arr.Length
    $num = int-arr-zero($arr.Length)

    for ($element = 0; $element -lt $num_len; $element++){  
        $num[$element] = [int] $arr[$element] - 48
    }

    return $num
}



function add-numstr-base ([string]$a, [string]$b, [int]$base, [int]$max_num_length){            # base must be 2 to 10

    # add-numstr ("1")("1")

    $num_len = $max_num_length #155 # maximum for 512 bit integers

    $subtractbase = $base
    $carrybase = $base - 1

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

        if ($num[$element] -gt $carrybase){                               # for addition places will be no more than 9+9+1 (carry) 19, 
            $num[$element] = $num[$element] - $subtractbase                 # so repeated adding of carry (while loop) is not required
            $num[$element + 1] = $num[$element + 1] + 1
        }
    }

    $num_re = flip-int-arr-endian ($num)

    $num_re = $num_re -join ""
            
    return [string] $num_re -replace '^0+', ''

}


function multiply-by-base-shift([string]$a, [int]$shift, [int]$max_num_length){          # big endian only

    $num_len = $max_num_length

    $num = $a.PadLeft($num_len,"0").ToCharArray()

    $num = to-num-array ($num)
    $num_mult = int-arr-zero($num_len)
    
    for ($element = $shift; $element -lt $num_len; $element++){
    
        $num_mult[$element - $shift] = $num[$element]             # already set to zero as in above for the ones place.

    }
    
    $num_mult = $num_mult -join ""

    return [string] $num_mult -replace '^0+', ''

}

function single-digit-multiply ([string]$num, [string]$one_digit, [int]$base, [int]$max_num_length){

    $num_len = $max_num_length
    $multi = [int] $one_digit  # is a string not a char
    Switch ($multi) {

        2 { return add-numstr-base($num)($num)($base)($num_len) }
        3 { return add-numstr-base(add-numstr-base($num)($num)($base)($num_len))($num)($base)($num_len) }
        4 { $num2 = add-numstr-base($num)($num)($base)($num_len); return add-numstr-base($num2)($num2)($base)($num_len)}
        5 { $num2 = add-numstr-base($num)($num)($base)($num_len); $num3 = add-numstr-base($num2)($num)($base)($num_len); return add-numstr-base($num2)($num3)($base)($num_len)}
        6 { $num2 = add-numstr-base($num)($num)($base)($num_len); $num3 = add-numstr-base($num2)($num)($base)($num_len); return add-numstr-base($num3)($num3)($base)($num_len)}
        7 { $num2 = add-numstr-base($num)($num)($base)($num_len); $num3 = add-numstr-base($num2)($num)($base)($num_len); $num4 = add-numstr-base($num2)($num2)($base)($num_len); return add-numstr-base($num4)($num3)($base)($num_len)}
        8 { $num2 = add-numstr-base($num)($num)($base)($num_len); $num4 = add-numstr-base($num2)($num2)($base)($num_len); return add-numstr-base($num4)($num4)($base)($num_len)}
        9 { $num2 = add-numstr-base($num)($num)($base)($num_len); $num3 = add-numstr-base($num2)($num)($base)($num_len); $num6 = add-numstr-base($num3)($num3)($base)($num_len); return add-numstr-base($num6)($num3)($base)($num_len)}
         
        1 {return $num }
        0 {return "0" }
    }
}

# single-digit-multiply ("5454")("9")(10)

#incomplete
function multiply-numstr-base ([string]$a, [string]$b, [int]$base_system, [int]$max_num_length){

    $base = $base_system #base

    $num_len = $max_num_length  #155 # maximum for 512 bit integers

    $num_a = $a -replace '^0+', '' #.PadLeft($num_len,"0")  # directly use string
    $num_b = $b -replace '^0+', '' #.PadLeft($num_len,"0")

    #$num_b = $num_b.PadLeft(2,"0")

    $a_len = $num_a.Length
    $b_len = $num_b.Length

    # check string length
    if (($num_a -eq "") -or ($num_b -eq "")){
        [string] $reply = "0" 
        return $reply
    }
    if ($num_a -eq "1") {return $b}           
    if ($num_b -eq "1") {return $a}
    if (($a_len -eq 1) -or ($b_len -eq 1)){  #base system
        if ($a_len -eq 1){
            return single-digit-multiply($num_b)($num_a)($base)($num_len)
        }
        if ($b_len -eq 1){
            return single-digit-multiply($num_a)($num_b)($base)($num_len)
        }
    }

    

    #### script below only works if strings are more than 1 character long excluding trailing zeroes.
    # multiply-numstr ("8")("9")  wont work
    # multiply-numstr ("18")("9")  wont work
    # multiply-numstr ("1")("29")  wont work
    # multiply-numstr ("18")("29")  yes!

    [string[]] $num_ax  = @(1..($base))

    
    $num_ax[1] = $num_a

    for ($i = 2; $i -lt $base; $i++){
        $num_a_mult_temp = add-numstr-base($num_a)($num_ax[$i - 1])($base)($num_len)            # pre calculate multiply
        # $num_a_mult_temp = $num_a_mult_temp.PadLeft($num_len,"0")
        $num_ax[$i] = $num_a_mult_temp

    }   
    

    $num_b_little_endian = flip-int-arr-endian (to-num-array($num_b.ToCharArray()))  # for multiplier index

    $result = int-arr-zero($num_len)
    $result = $result -join ""
 
    for ($i = 0; $i -lt $b_len; $i++){

        [int] $b_mult = $num_b_little_endian[$i]
        if (!($b_mult -eq 0)){                                 # if position #j of $a is non-zero, add.
             
            $current_place_result = $num_ax[$b_mult]

            # calculate multiples of x (base)   -  adds a zero. by shifting to the left in big endian
            if (!($i -eq 0)){  
                $current_place_result = multiply-by-base-shift($current_place_result)($i)($num_len) 
            }


           $result = add-numstr-base($result)($current_place_result)($base)($num_len)                        # skipped if b_mult is zero, 0

           
        }

        #$current_place_result -join ""

        

    }
    
    return $result -join ""  -replace '^0+', ''

}



function prompt(){


    #$pow = Read-Host ("`nInput power: ")
    #$ans = pow2($pow)
    #[console]::Write($ans)

    #$ans = pow2 (212)


    #$ans = add-numstr(pow2(212))(pow2(212))

    #$ans = multiply-by-ten("47604524036730424631850294460894909302930821810983811727510334984391012367348")

    [console]::Write("`n`n    Welcome to the Powershell multiply script.`n")
    [console]::Write("`n    This script multiplies up to two arbitrary integers. Tested up to 16384 characters.`n")
    [console]::Write("    It also supports multiplication in any base from base 2-10`n")
    [console]::Write("`n    Created by KohGT in 2022`n")
    [console]::Write("`n                                                                                                                                        1    1    1    1    1    1    1       ")
    [console]::Write("`n                                              1    1    2    2    3    3    4    4    5    5    6    6    7    7    8    8    9    9    0    0    1    1    2    2    3       ")
    [console]::Write("`n                                    0    5    0    5    0    5    0    5    0    5    0    5    0    5    0    5    0    5    0    5    0    5    0    5    0    5    0       ")
    [console]::Write("`n                                    >    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |`n")
    $a = Read-Host ("                 Input first number")
    $a = [string] $a
    $b = Read-Host ("                Input second number")
    $b = [string] $b

    $d = Read-Host ("    Input base [2-10] (Default: 10)")

    if ([string]::IsNullOrWhiteSpace($d)){
        [int] $d = 10
        [console]::Write("`nNo input detected, setting base 10.`n")
    }
    $d = [int] $d  # convert from input string to int



    #length check
    $alen = $a.Length
    $blen = $b.Length

    [int] $num_len = $alen + $blen + 1
    $ans = multiply-numstr-base($a)($b)($d)($num_len)


    $clen = $ans.Length
    if ($clen -gt $heightwindow +88){
        [console]::Write("`nNumber extremely large, may not fit in window. Please extend the window from the right side outwards ---------------------->>> `n")
    }

    $offset_a = $clen - $alen
    $offset_b = $clen - $blen
    cursor-goto-fine(0)(18)
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
    [console]::Write("$ans`n`n")

    while (1 -eq 1){

        cursor-goto-fine(4)(28)
        [console]::Write("                                                             ")
        cursor-goto-fine(4)(28)
        $a = Read-Host ("Do you want to [r]eset, or [q]uit?")
        $a = [string]$a
        Switch ($a){
            r { return $true }
            R { return $true }
            q { return $false }
            Q { return $false }
            default {[console]::Write("`nInvalid response!`n")}           #; [console]::Beep(1500,200)}
        }
    }

}

function main(){

    $loop = $true
    while ($loop -eq $true){

        $loop = prompt
        cls;

    }

}

main

#  87943789324987777777777777777777777777777777777777777777777777777777777777779999999999999999999999999999999999999999999999999999999883
#                                                                                                                                      x22222222222222222222222222222222222333333333333333333333333333333322222222222222222222222333333333333333333333333333333222222222222222
# 1954306429444172839506172839506172849277704986727037037037037037036059883822364333333333343104865480554197530864444444434672912297220960703849261113827160493827160494061074074074074074074074074073828460493827159999999999987000000000000000000000000000013000000000000026