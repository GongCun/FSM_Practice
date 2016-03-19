#!/usr/bin/env awk -f
# $Id: com.awk,v 1.7 2016/03/19 13:59:08 gongcunjust Exp gongcunjust $

BEGIN { state = 1 }

{
    split($0, chars, "")

    for (i = 1; i <= length($0); i++) {
        ch = chars[i]
        switch(state) {
            case 1:
                if (ch == "/") state = 2
                break
            case 2:
                if (ch == "*") state = 3
                else state = 1
                break
            case 3:
                if (ch == "*") {
                    state = 4
                    undo = 1
                }
                else {
                    printf("%s", ch)
                    state = 3
                }
                break
            case 4:
                if (ch == "/") {
                    state = 5
                } else {
                    if (undo) {
                        printf("*"); undo = 0
                    }
                    if (ch == "*") { undo = 1; state = 4 }
                    else {
                        printf("%s", ch)
                        state = 3
                    }
                }
                break
            case 5:
                printf("\n")
                state = 1
                break
        }
    }

}

END {
    printf("\n")
    if (state == 3 || state == 4) {
        print "error"
        exit(1)
    }
}


