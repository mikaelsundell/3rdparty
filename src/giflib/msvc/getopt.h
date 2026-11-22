/* SPDX-License-Identifier: BSD-3-Clause */

#pragma once

extern char *optarg;
extern int optind;
int getopt(int argc, char *const argv[], const char *options);
