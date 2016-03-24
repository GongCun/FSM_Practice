#!/usr/bin/env awk -f
# $Id: cdecl.awk,v 1.5 2016/03/24 13:28:18 gongcunjust Exp gongcunjust $

function classify_string() {
    if (this["string"] == "const") {
        this["string"] = "read-only"
        return "QUALIFIER"
    }
    if (this["string"] == "volatile") 
        return "QUALIFIER"
    if (this["string"] == "void")
        return "TYPE"
    if (this["string"] == "char")
        return "TYPE"
    if (this["string"] == "signed")
        return "TYPE"
    if (this["string"] == "unsigned")
        return "TYPE"
    if (this["string"] == "short")
        return "TYPE"
    if (this["string"] == "int")
        return "TYPE"
    if (this["string"] == "long")
        return "TYPE"
    if (this["string"] == "float")
        return "TYPE"
    if (this["string"] == "double")
        return "TYPE"
    if (this["string"] == "struct")
        return "TYPE"
    if (this["string"] == "union")
        return "TYPE"
    if (this["string"] == "enum")
        return "TYPE"

    return "IDENTIFIER"

}

function gettoken(  str,ch) {
    while ((this["string"] = substr(str,i++,1)) == " ")
        ;
    if (this["string"] ~ /[0-9a-zA-Z]/) {
        while ((ch = substr(str,i++,1)) ~ /[0-9a-zA-Z]/)
            this["string"] = this["string"] ch
        i--
        this["type"] = classify_string()
        return
    }
    this["type"] = this["string"]
    return
}

function push() {
    top++ # begin from 1
    stack[top, "string"] = this["string"]
    stack[top, "type"] = this["type"]
}

function pop() {
    top--
}

function initialize(  str) {
    gettoken(str)
    while (this["type"] != "IDENTIFIER") {
        push()
        gettoken(str) # exception not handle
    }
    printf("%s is ", this["string"]);
    gettoken(str)
    nextstate = "get_array"
}

function get_array( str) {
    nextstate = "get_params"
    while (this["string"] == "[") {
        printf("array ")
        gettoken(str) # a number or ']'
        if (this["string"] ~ /^[0-9]+$/) {
            printf("0..%d ", this["string"])
            gettoken(str) # read the ']'
        }
        gettoken(str) # read the next past the ']'
        printf("of ")
        nextstate = "get_lparen"
    }
}

function get_params( str) {
    nextstate = "get_lparen"
    if (this["type"] == "(") {
        while (this["type"] != ")")
            gettoken(str)
        gettoken(str)
        printf("function returning ")
    }
}

function get_lparen( str) {
    nextstate = "get_ptr_part"
    if (top >= 1) {
        if (stack[top, "type"] == "(") {
            pop()
            gettoken(str) # read past ')'
            nextstate = "get_array"
        }
    }
}

function get_ptr_part( str) {
    nextstate = "get_type"
    if(stack[top, "type"] == "*") {
        printf("pointer to ")
        pop()
        nextstate = "get_lparen"
    } else if (stack[top, "type"] == "QUALIFIER") {
        printf("%s ", stack[top--, "string"])
        nextstate = "get_lparen"
    }
}


function get_type( str) {
    nextstate = "NULL"
    while (top >= 1)
        printf("%s ", stack[top--, "string"])
    printf("\n")
}

BEGIN {
    i = 1
}


{
    nextstate = "initialize"
    while (nextstate != "NULL")
        @nextstate($0)
}
