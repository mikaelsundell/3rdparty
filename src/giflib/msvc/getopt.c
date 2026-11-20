/* SPDX-License-Identifier: BSD-3-Clause */

#include "getopt.h"
#include <stdio.h>
#include <string.h>

char *optarg;
int optind = 1;

/* giftool uses single-letter options, each with a required argument. */
int getopt(int argc, char *const argv[], const char *options)
{
    optarg = NULL;
    if (optind >= argc || argv[optind][0] != '-' || argv[optind][1] == '\0')
        return EOF;

    char *argument = argv[optind++];
    if (strcmp(argument, "--") == 0)
        return EOF;
    const char *option = strchr(options, argument[1]);
    if (option == NULL || option[1] != ':')
        return '?';
    if (argument[2] != '\0')
        optarg = argument + 2;
    else if (optind < argc)
        optarg = argv[optind++];
    else
        return '?';
    return argument[1];
}
