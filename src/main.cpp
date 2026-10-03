// Copyright 2026 wyteroze. Licensed under the Apache-2.0 license.

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <Luau/Parser.h>
#include <Luau/Ast.h>
#include <binaryen-c.h>
#define FLAG_IMPLEMENTATION
#include <flag.hpp>

void usage(FILE* stream) {
    fprintf(stream, "Usage: ./syzygy [OPTIONS] [--] [ARGS]\n");
    fprintf(stream, "OPTIONS:\n");
    flag_print_options(stream);
}

int main(int argc, char *argv[]) {
    bool* help = flag_bool("help", false, "Print this help message to stdout");
    char** path = flag_str("i", NULL, "Path to the .luau file to compile");

    if (!flag_parse(argc, argv)) {
        usage(stderr);
        flag_print_error(stderr);
        exit(1);
    }

    argc = flag_rest_argc();
    argv = flag_rest_argv();

    if (*help) {
        usage(stdout);
        exit(0);
    }

    if (*path == NULL) {
        fprintf(stderr, "Please provide the path to a file to compile.\n");
        exit(0);
    }

    printf("File provided: %s\n", *path);
    return 0;
}