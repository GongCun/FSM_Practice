#!/usr/bin/env awk -f
# $Id: com.awk,v 1.6 2016/03/19 13:19:11 gongcunjust Exp gongcunjust $

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
                    tag = 1
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
                    if (tag) {
                        printf("*"); tag = 0
                    }
                    printf("%s", ch)
                    if (ch == "*") state = 4
                    else state = 3
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


