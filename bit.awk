#!/usr/bin/env awk -f

#
# LIZ 0 LIZ 0
# LIZ 1 LIO 0
# LIO 0 LIZ 0
# LIO 1 LIO 1
# start LIZ
#



run == 1 {
    print out[state, $1]; state = trans[state, $1] 
}

run == 0 {
    if ($1 == "start") {run = 1; state = $2}
    else {
        trans[$1, $2] = $3
        out[$1, $2] = $4
    }
}

