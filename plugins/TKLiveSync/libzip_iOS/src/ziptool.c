/*
  ziptool.c -- tool for modifying zip archive in multiple ways
  Copyright (C) 2012-2019 Dieter Baron and Thomas Klausner

  This file is part of libzip, a library to manipulate ZIP archives.
  The authors can be contacted at <libzip@nih.at>

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions
  are met:
  1. Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.
  2. Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in
     the documentation and/or other materials provided with the
     distribution.
  3. The names of the authors may not be used to endorse or promote
     products derived from this software without specific prior
     written permission.

  THIS SOFTWARE IS PROVIDED BY THE AUTHORS ``AS IS'' AND ANY EXPRESS
  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY
  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
  IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
  IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include "config.h"

#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif
#ifdef _WIN32
/* WIN32 needs <fcntl.h> for _O_BINARY */
#include <fcntl.h>
#ifndef STDIN_FILENO
#define STDIN_FILENO _fileno(stdin)
#endif
#endif

#ifndef HAVE_GETOPT
#include "getopt.h"
#endif
extern int optopt;

#include "compat.h"
#include "zip.h"

typedef struct dispatch_table_s {
    const char *cmdline_name;
    int argument_count;
    const char *arg_names;
    const char *description;
    int (*function)(int argc, char *argv[]);
} dispatch_table_t;

static zip_flags_t get_flags(const char *arg);
static zip_int32_t get_compression_method(const char *arg);
static zip_uint16_t get_encryption_method(const char *arg);
static void hexdump(const zip_uint8_t *data, zip_uint16_t len);
int ziptool_post_close(const char *archive);

#ifndef FOR_REGRESS
#define OPTIONS_REGRESS ""
#define USAGE_REGRESS ""
#endif

zip_t *za, *z_in[16];
unsigned int z_in_count;
zip_flags_t stat_flags;

static int
add(int argc, char *argv[]) {
    zip_source_t *zs;

    if ((zs = zip_source_buffer(za, argv[1], strlen(argv[1]), 0)) == NULL) {
	fprintf(stderr, "can't create zip_source from buffer: %s\n", zip_strerror(za));
	return -1;
    }

    if (zip_add(za, argv[0], zs) == -1) {
	zip_source_free(zs);
	fprintf(stderr, "can't add file '%s': %s\n", argv[0], zip_strerror(za));
	return -1;
    }
    return 0;
}

static int
add_dir(int argc, char *argv[]) {
    /* add directory */
    if (zip_add_dir(za, argv[0]) < 0) {
	fprintf(stderr, "can't add directory '%s': %s\n", argv[0], zip_strerror(za));
	return -1;
    }
    return 0;
}

static int
add_file(int argc, char *argv[]) {
    zip_source_t *zs;
    zip_uint64_t start = strtoull(argv[2], NULL, 10);
    zip_int64_t len = strtoll(argv[3], NULL, 10);

    if (strcmp(argv[1], "/dev/stdin") == 0) {
	if ((zs = zip_source_filep(za, stdin, start, len)) == NULL) {
	    fprintf(stderr, "can't create zip_source from stdin: %s\n", zip_strerror(za));
	    return -1;
	}
    }
    else {
	if ((zs = zip_source_file(za, argv[1], start, len)) == NULL) {
	    fprintf(stderr, "can't create zip_source from file: %s\n", zip_strerror(za));
	    return -1;
	}
    }

    if (zip_add(za, argv[0], zs) == -1) {
	zip_source_free(zs);
	fprintf(stderr, "can't add file '%s': %s\n", argv[0], zip_strerror(za));
	return -1;
    }
    return 0;
}

static int
add_from_zip(int argc, char *argv[]) {
    zip_uint64_t idx, start;
    zip_int64_t len;
    int err;
    zip_source_t *zs;
    /* add from another zip file */
    idx = strtoull(argv[2], NULL, 10);
    start = strtoull(argv[3], NULL, 10);
    len = strtoll(argv[4], NULL, 10);
    if ((z_in[z_in_count] = zip_open(argv[1], ZIP_CHECKCONS, &err)) == NULL) {
	zip_error_t error;
	zip_error_init_with_code(&error, err);
	fprintf(stderr, "can't open zip archive '%s': %s\n", argv[1], zip_error_strerror(&error));
	zip_error_fini(&error);
	return -1;
    }
    if ((zs = zip_source_zip(za, z_in[z_in_count], idx, 0, start, len)) == NULL) {
	fprintf(stderr, "error creating file source from '%s' index '%" PRIu64 "': %s\n", argv[1], idx, zip_strerror(za));
	zip_close(z_in[z_in_count]);
	return -1;
    }
    if (zip_add(za, argv[0], zs) == -1) {
	fprintf(stderr, "can't add file '%s': %s\n", argv[0], zip_strerror(za));
	zip_source_free(zs);
	zip_close(z_in[z_in_count]);
	return -1;
    }
    z_in_count++;
    return 0;
}

static int
cat(int argc, char *argv[]) {
    /* output file contents to stdout */
    zip_uint64_t idx;
    zip_int64_t n;
    zip_file_t *zf;
    char buf[8192];
    int err;
    idx = strtoull(argv[0], NULL, 10);

#ifdef _WIN32
    /* Need to set stdout to binary mode for Windows */
    setmode(fileno(stdout), _O_BINARY);
#endif
    if ((zf = zip_fopen_index(za, idx, 0)) == NULL) {
	fprintf(stderr, "can't open file at index '%" PRIu64 "': %s\n", idx, zip_strerror(za));
	return -1;
    }
    while ((n = zip_fread(zf, buf, sizeof(buf))) > 0) {
	if (fwrite(buf, (size_t)n, 1, stdout) != 1) {
	    zip_fclose(zf);
	    fprintf(stderr, "can't write file contents to stdout: %s\n", strerror(errno));
	    return -1;
	}
    }
    if (n == -1) {
	fprintf(stderr, "can't read file at index '%" PRIu64 "': %s\n", idx, zip_file_strerror(zf));
	zip_fclose(zf);
	return -1;
    }
    if ((err = zip_fclose(zf)) != 0) {
	zip_error_t error;

	zip_error_init_with_code(&error, err);
	fprintf(stderr, "can't close file at index '%" PRIu64 "': %s\n", idx, zip_error_strerror(&error));
	return -1;
    }

    return 0;
}

static int
count_extra(int argc, char *argv[]) {
    zip_int16_t count;
    zip_uint64_t idx;
    zip_flags_t ceflags = 0;
    idx = strtoull(argv[0], NULL, 10);
    ceflags = get_flags(argv[1]);
    if ((count = zip_file_extra_fields_count(za, idx, ceflags)) < 0) {
	fprintf(stderr, "can't get extra field count for file at index '%" PRIu64 "': %s\n", idx, zip_strerror(za));
	return -1;
    }
    else {
	printf("Extra field count: %d\n", count);
    }
    return 0;
}

static int
count_extra_by_id(int argc, char *argv[]) {
    zip_int16_t count;
    zip_uint16_t eid;
    zip_flags_t ceflags = 0;
    zip_uint64_t idx;
    idx = strtoull(argv[0], NULL, 10);
    eid = (zip_uint16_t)strtoull(argv[1], NULL, 10);
    ceflags = get_flags(argv[2]);
    if ((count = zip_file_extra_fields_count_by_id(za, idx, eid, ceflags)) < 0) {
	fprintf(stderr, "can't get extra field count for file at index '%" PRIu64 "' and for id '%d': %s\n", idx, eid, zip_strerror(za));
	return -1;
    }
    else {
	printf("Extra field count: %d\n", count);
    }
    return 0;
}

static int delete (int argc, char *argv[]) {
    zip_uint64_t idx;
    idx = strtoull(argv[0], NULL, 10);
    if (zip_delete(za, idx) < 0) {
	fprintf(stderr, "can't delete file at index '%" PRIu64 "': %s\n", idx, zip_strerror(za));
	return -1;
    }
    return 0;
}

static int
delete_extra(int argc, char *argv[]) {
    zip_flags_t geflags;
    zip_uint16_t eid;
    zip_uint64_t idx;
    idx = strtoull(argv[0], NULL, 10);
    eid = (zip_uint16_t)strtoull(argv[1], NULL, 10);
    geflags = get_flags(argv[2]);
    if ((zip_file_extra_field_delete(za, idx, eid, geflags)) < 0) {
	fprintf(stderr, "can't delete extra field data for file at index '%" PRIu64 "', extra field id '%d': %s\n", idx, eid, zip_strerror(za));
	return -1;
    }
    return 0;
}

static int
delete_extra_by_id(int argc, char *argv[]) {
    zip_flags_t geflags;
    zip_uint16_t eid, eidx;
    zip_uint64_t idx;
    idx = strtoull(argv[0], NULL, 10);
    eid = (zip_uint16_t)strtoull(argv[1], NULL, 10);
    eidx = (zip_uint16_t)strtoull(argv[2], NULL, 10);
    geflags = get_flags(argv[3]);
    if ((zip_file_extra_field_delete_by_id(za, idx, eid, eidx, geflags)) < 0) {
	fprintf(stderr, "can't delete extra field data for file at index '%" PRIu64 "', extra field id '%d', extra field idx '%d': %s\n", idx, eid, eidx, zip_strerror(za));
	return -1;
    }
    return 0;
}

static int
get_archive_comment(int argc, char *argv[]) {
    const char *comment;
    int len;
    /* get archive comment */
    if ((comment = zip_get_archive_comment(za, &len, 0)) == NULL)
	printf("No archive comment\n");
    else
	printf("Archive comment: %.*s\n", len, comment);
    return 0;
}

static int
get_extra(int argc, char *argv[]) {
    zip_flags_t geflags;
    zip_uint16_t id, eidx, eflen;
    const zip_uint8_t *efdata;
    zip_uint64_t idx;
    /* get extra field data */
    idx = strtoull(argv[0], NULL, 10);
    eidx = (zip_uint16_t)strtoull(argv[1], NULL, 10);
    geflags = get_flags(argv[2]);
    if ((efdata = zip_file_extra_field_get(za, idx, eidx, &id, &eflen, geflags)) == NULL) {
	fprintf(stderr, "can't get extra field data for file at index %" PRIu64 ", extra field %d, flags %u: %s\n", idx, eidx, geflags, zip_strerror(za));
	return -1;
    }
    printf("Extra field 0x%04x: len %d", id, eflen);
    if (eflen > 0) {
	printf(", data ");
	hexdump(efdata, eflen);
    }
    printf("\n");
    return 0;
}

static int
get_extra_by_id(int argc, char *argv[]) {
    zip_flags_t geflags;
    zip_uint16_t eid, eidx, eflen;
    const zip_uint8_t *efdata;
    zip_uint64_t idx;
    idx = strtoull(argv[0], NULL, 10);
    eid = (zip_uint16_t)strtoull(argv[1], NULL, 10);
    eidx = (zip_uint16_t)strtoull(argv[2], NULL, 10);
    geflags = get_flags(argv[3]);
    if ((efdata = zip_file_extra_field_get_by_id(za, idx, eid, eidx, &eflen, geflags)) == NULL) {
	fprintf(stderr, "can't get extra field data for file at index %" PRIu64 ", extra field id %d, ef index %d, flags %u: %s\n", idx, eid, eidx, geflags, zip_strerror(za));
	return -1;
    }
    printf("Extra field 0x%04x: len %d", eid, eflen);
    if (eflen > 0) {
	printf(", data ");
	hexdump(efdata, eflen);
    }
    printf("\n");
    return 0;
}

static int
get_file_comment(int argc, char *argv[]) {
    const char *comment;
    int len;
    zip_uint64_t idx;
    /* get file comment */
    idx = strtoull(argv[0], NULL, 10);
    if ((comment = zip_get_file_comment(za, idx, &len, 0)) == NULL) {
	fprintf(stderr, "can't get comment for '%s': %s\n", zip_get_name(za, idx, 0), zip_strerror(za));
	return -1;
    }
    else if (len == 0)
	printf("No comment for '%s'\n", zip_get_name(za, idx, 0));
    else
	printf("File comment for '%s': %.*s\n", zip_get_name(za, idx, 0), len, comment);
    return 0;
}

static int
get_num_entries(int argc, char *argv[]) {
    zip_int64_t count;
    zip_flags_t flags;
    /* get number of entries in archive */
    flags = get_flags(argv[0]);
    count = zip_get_num_entries(za, flags);
    printf("%" PRId64 " entr%s in archive\n", count, count == 1 ? "y" : "ies");
    return 0;
}

static int
name_locate(int argc, char *argv[]) {
    zip_flags_t flags;
    zip_int64_t idx;
    flags = get_flags(argv[1]);

    if ((idx = zip_name_locate(za, argv[0], flags)) < 0) {
	fprintf(stderr, "can't find entry with name '%s' using flags '%s'\n", argv[0], argv[1]);
    }
    else {
	printf("name '%s' using flags '%s' found at index %" PRId64 "\n", argv[0], argv[1], idx);
    }

    return 0;
}

static void
progress_callback(zip_t *archive, double percentage, void *ud) {
    printf("%.1lf%% done\n", percentage * 100);
}

static int
print_progress(int argc, char *argv[]) {
    zip_register_progress_callback_with_state(za, 0.001, progress_callback, NULL, NULL);
    return 0;
}

static int
zrename(int argc, char *argv[]) {
    zip_uint64_t idx;
    idx = strtoull(argv[0], NULL, 10);
    if (zip_rename(za, idx, argv[1]) < 0) {
	fprintf(stderr, "can't rename file at index '%" PRIu64 "' to '%s': %s\n", idx, argv[1], zip_strerror(za));
	return -1;
    }
    return 0;
}

static int
replace_file_contents(int argc, char *argv[]) {
    /* replace file contents with data from command line */
    const char *content;
    zip_source_t *s;
    zip_uint64_t idx;
    idx = strtoull(argv[0], NULL, 10);
    content = argv[1];
    if ((s = zip_source_buffer(za, content, strlen(content), 0)) == NULL || zip_file_replace(za, idx, s, 0) < 0) {
	zip_source_free(s);
	fprintf(stderr, "error replacing file data: %s\n", zip_strerror(za));
	return -1;
    }
    return 0;
}

static int
set_extra(int argc, char *argv[]) {
    zip_flags_t geflags;
    zip_uint16_t eid, eidx;
    const zip_uint8_t *efdata;
    zip_uint64_t idx;
    idx = strtoull(argv[0], NULL, 10);
    eid = (zip_uint16_t)strtoull(argv[1], NULL, 10);
    eidx = (zip_uint16_t)strtoull(argv[2], NULL, 10);
    geflags = get_flags(argv[3]);
    efdata = (zip_uint8_t *)argv[4];
    if ((zip_file_extra_field_set(za, idx, eid, eidx, efdata, (zip_uint16_t)strlen((const char *)efdata), geflags)) < 0) {
	fprintf(stderr, "can't set extra field data for file at index '%" PRIu64 "', extra field id '%d', index '%d': %s\n", idx, eid, eidx, zip_strerror(za));
	return -1;
    }
    return 0;
}

static int
set_archive_comment(int argc, char *argv[]) {
    if (zip_set_archive_comment(za, argv[0], (zip_uint16_t)strlen(argv[0])) < 0) {
	fprintf(stderr, "can't set archive comment to '%s': %s\n", argv[0], zip_strerror(za));
	return -1;
    }
    return 0;
}

static int
set_file_comment(int argc, char *argv[]) {
    zip_uint64_t idx;
    idx = strtoull(argv[0], NULL, 10);
    if (zip_file_set_comment(za, idx, argv[1], (zip_uint16_t)strlen(argv[1]), 0) < 0) {
	fprintf(stderr, "can't set file comment at index '%" PRIu64 "' to '%s': %s\n", idx, argv[1], zip_strerror(za));
	return -1;
    }
    return 0;
}

static int
set_file_compression(int argc, char *argv[]) {
    zip_int32_t method;
    zip_uint32_t flags;
    zip_uint64_t idx;
    idx = strtoull(argv[0], NULL, 10);
    method = get_compression_method(argv[1]);
    flags = (zip_uint32_t)strtoull(argv[2], NULL, 10);
    if (zip_set_file_compression(za, idx, method, flags) < 0) {
	fprintf(stderr, "can't set file compression method at index '%" PRIu64 "' to '%s', flags '%d': %s\n", idx, argv[1], flags, zip_strerror(za));
	return -1;
    }
    return 0;
}

static int
set_file_encryption(int argc, char *argv[]) {
    zip_uint16_t method;
    zip_uint64_t idx;
    char *password;
    idx = strtoull(argv[0], NULL, 10);
    method = get_encryption_method(argv[1]);
    password = argv[2];
    if (strlen(password) == 0) {
	password = NULL;
    }
    if (zip_file_set_encryption(za, idx, method, password) < 0) {
	fprintf(stderr, "can't set file encryption method at index '%" PRIu64 "' to '%s': %s\n", idx, argv[1], zip_strerror(za));
	return -1;
    }
    return 0;
}

static int
set_file_mtime(int argc, char *argv[]) {
    /* set file last modification time (mtime) */
    time_t mtime;
    zip_uint64_t idx;
    idx = strtoull(argv[0], NULL, 10);
    mtime = (time_t)strtoull(argv[1], NULL, 10);
    if (zip_file_set_mtime(za, idx, mtime, 0) < 0) {
	fprintf(stderr, "can't set file mtime at index '%" PRIu64 "' to '%ld': %s\n", idx, mtime, zip_strerror(za));
	return -1;
    }
    return 0;
}

static int
set_file_mtime_all(int argc, char *argv[]) {
    /* set last modification time (mtime) for all files */
    time_t mtime;
    zip_int64_t num_entries;
    zip_uint64_t idx;
    mtime = (time_t)strtoull(argv[0], NULL, 10);

    if ((num_entries = zip_get_num_entries(za, 0)) < 0) {
	fprintf(stderr, "can't get number of entries: %s\n", zip_strerror(za));
	return -1;
    }
    for (idx = 0; idx < (zip_uint64_t)num_entries; idx++) {
	if (zip_file_set_mtime(za, idx, mtime, 0) < 0) {
	    fprintf(stderr, "can't set file mtime at index '%" PRIu64 "' to '%ld': %s\n", idx, mtime, zip_strerror(za));
	    return -1;
	}
    }
    return 0;
}

static int
set_password(int argc, char *argv[]) {
    /* set default password */
    if (zip_set_default_password(za, argv[0]) < 0) {
	fprintf(stderr, "can't set default password to '%s'\n", argv[0]);
	return -1;
    }
    return 0;
}

static int
zstat(int argc, char *argv[]) {
    zip_uint64_t idx;
    char buf[100];
    struct zip_stat sb;
    idx = strtoull(argv[0], NULL, 10);

    if (zip_stat_index(za, idx, stat_flags, &sb) < 0) {
	fprintf(stderr, "zip_stat_index failed on '%" PRIu64 "' failed: %s\n", idx, zip_strerror(za));
	return -1;
    }

    if (sb.valid & ZIP_STAT_NAME)
	printf("name: '%s'\n", sb.name);
    if (sb.valid & ZIP_STAT_INDEX)
	printf("index: '%" PRIu64 "'\n", sb.index);
    if (sb.valid & ZIP_STAT_SIZE)
	printf("size: '%" PRIu64 "'\n", sb.size);
    if (sb.valid & ZIP_STAT_COMP_SIZE)
	printf("compressed size: '%" PRIu64 "'\n", sb.comp_size);
    if (sb.valid & ZIP_STAT_MTIME) {
	struct tm *tpm;
	tpm = localtime(&sb.mtime);
	if (tpm == NULL) {
	    printf("mtime: <not valid>\n");
	}
	else {
	    strftime(buf, sizeof(buf), "%a %b %d %Y %H:%M:%S", tpm);
	    printf("mtime: '%s'\n", buf);
	}
    }
    if (sb.valid & ZIP_STAT_CRC)
	printf("crc: '%0x'\n", sb.crc);
    if (sb.valid & ZIP_STAT_COMP_METHOD)
	printf("compression method: '%d'\n", sb.comp_method);
    if (sb.valid & ZIP_STAT_ENCRYPTION_METHOD)
	printf("encryption method: '%d'\n", sb.encryption_method);
    if (sb.valid & ZIP_STAT_FLAGS)
	printf("flags: '%ld'\n", (long)sb.flags);
    printf("\n");

    return 0;
}

static zip_flags_t
get_flags(const char *arg) {
    zip_flags_t flags = 0;
    if (strchr(arg, 'C') != NULL)
	flags |= ZIP_FL_NOCASE;
    if (strchr(arg, 'c') != NULL)
	flags |= ZIP_FL_CENTRAL;
    if (strchr(arg, 'd') != NULL)
	flags |= ZIP_FL_NODIR;
    if (strchr(arg, 'l') != NULL)
	flags |= ZIP_FL_LOCAL;
    if (strchr(arg, 'u') != NULL)
	flags |= ZIP_FL_UNCHANGED;
    return flags;
}

static zip_int32_t
get_compression_method(const char *arg) {
    if (strcmp(arg, "default") == 0)
	return ZIP_CM_DEFAULT;
    else if (strcmp(arg, "store") == 0)
	return ZIP_CM_STORE;
    else if (strcmp(arg, "deflate") == 0)
	return ZIP_CM_DEFLATE;
#if defined(HAVE_LIBBZ2)
    else if (strcmp(arg, "bzip2") == 0)
	return ZIP_CM_BZIP2;
#endif
    else if (strcmp(arg, "unknown") == 0)
	return 100;
    return 0; /* TODO: error handling */
}

static zip_uint16_t
get_encryption_method(const char *arg) {
    if (strcmp(arg, "none") == 0)
	return ZIP_EM_NONE;
    else if (strcmp(arg, "AES-128") == 0)
	return ZIP_EM_AES_128;
    else if (strcmp(arg, "AES-192") == 0)
	return ZIP_EM_AES_192;
    else if (strcmp(arg, "AES-256") == 0)
	return ZIP_EM_AES_256;
    else if (strcmp(arg, "unknown") == 0)
	return 100;
    return (zip_uint16_t)-1; /* TODO: error handling */
}

static void
hexdump(const zip_uint8_t *data, zip_uint16_t len) {
    zip_uint16_t i;

    if (len <= 0)
	return;

    printf("0x");

    for (i = 0; i < len; i++)
	printf("%02x", data[i]);

    return;
}


static zip_t *
read_from_file(const char *archive, int flags, zip_error_t *error, zip_uint64_t offset, zip_uint64_t length) {
    zip_t *zaa;
    zip_source_t *source;
    int err;

    if (offset == 0 && length == 0) {
	if (strcmp(archive, "/dev/stdin") == 0) {
	    zaa = zip_fdopen(STDIN_FILENO, flags & ~ZIP_CREATE, &err);
	}
	else {
	    zaa = zip_open(archive, flags, &err);
	}
	if (zaa == NULL) {
	    zip_error_set(error, err, errno);
	    return NULL;
	}
    }
    else {
	if (length > ZIP_INT64_MAX) {
	    zip_error_set(error, ZIP_ER_INVAL, 0);
	    return NULL;
	}
	if ((source = zip_source_file_create(archive, offset, (zip_int64_t)length, error)) == NULL || (zaa = zip_open_from_source(source, flags, error)) == NULL) {
	    zip_source_free(source);
	    return NULL;
	}
    }

    return zaa;
}

dispatch_table_t dispatch_table[] = {{"add", 2, "name content", "add file called name using content", add},
				     {"add_dir", 1, "name", "add directory", add_dir},
				     {"add_file", 4, "name file_to_add offset len", "add file to archive, len bytes starting from offset", add_file},
				     {"add_from_zip", 5, "name archivename index offset len", "add file from another archive, len bytes starting from offset", add_from_zip},
				     {"cat", 1, "index", "output file contents to stdout", cat},
				     {"count_extra", 2, "index flags", "show number of extra fields for archive entry", count_extra},
				     {"count_extra_by_id", 3, "index extra_id flags", "show number of extra fields of type extra_id for archive entry", count_extra_by_id},
				     {"delete", 1, "index", "remove entry", delete},
				     {"delete_extra", 3, "index extra_idx flags", "remove extra field", delete_extra},
				     {"delete_extra_by_id", 4, "index extra_id extra_index flags", "remove extra field of type extra_id", delete_extra_by_id},
				     {"get_archive_comment", 0, "", "show archive comment", get_archive_comment},
				     {"get_extra", 3, "index extra_index flags", "show extra field", get_extra},
				     {"get_extra_by_id", 4, "index extra_id extra_index flags", "show extra field of type extra_id", get_extra_by_id},
				     {"get_file_comment", 1, "index", "get file comment", get_file_comment},
				     {"get_num_entries", 1, "flags", "get number of entries in archive", get_num_entries},
				     {"name_locate", 2, "name flags", "find entry in archive", name_locate},
				     {"print_progress", 0, "", "print progress during zip_close()", print_progress},
				     {"rename", 2, "index name", "rename entry", zrename},
				     {"replace_file_contents", 2, "index data", "replace entry with data", replace_file_contents},
				     {"set_archive_comment", 1, "comment", "set archive comment", set_archive_comment},
				     {"set_extra", 5, "index extra_id extra_index flags value", "set extra field", set_extra},
				     {"set_file_comment", 2, "index comment", "set file comment", set_file_comment},
				     {"set_file_compression", 3, "index method compression_flags", "set file compression method", set_file_compression},
				     {"set_file_encryption", 3, "index method password", "set file encryption method", set_file_encryption},
				     {"set_file_mtime", 2, "index timestamp", "set file modification time", set_file_mtime},
				     {"set_file_mtime_all", 1, "timestamp", "set file modification time for all files", set_file_mtime_all},
				     {"set_password", 1, "password", "set default password for encryption", set_password},
				     {"stat", 1, "index", "print information about entry", zstat}
#ifdef DISPATCH_REGRESS
				     ,
				     DISPATCH_REGRESS
#endif
};

static int
dispatch(int argc, char *argv[]) {
    unsigned int i;
    for (i = 0; i < sizeof(dispatch_table) / sizeof(dispatch_table_t); i++) {
	if (strcmp(dispatch_table[i].cmdline_name, argv[0]) == 0) {
	    argc--;
	    argv++;
	    /* 1 for the command, argument_count for the arguments */
	    if (argc < dispatch_table[i].argument_count) {
		fprintf(stderr, "not enough arguments for command '%s': %d available, %d needed\n", dispatch_table[i].cmdline_name, argc, dispatch_table[i].argument_count);
		return -1;
	    }
	    if (dispatch_table[i].function(argc, argv) == 0)
		return 1 + dispatch_table[i].argument_count;
	    return -1;
	}
    }

    fprintf(stderr, "unknown command '%s'\n", argv[0]);
    return -1;
}


static void
usage(const char *progname, const char *reason) {
    unsigned int i;
    FILE *out;
    if (reason == NULL)
	out = stdout;
    else
	out = stderr;
    fprintf(out, "usage: %s [-ceghnrst]" USAGE_REGRESS " [-l len] [-o offset] archive command1 [args] [command2 [args] ...]\n", progname);
    if (reason != NULL) {
	fprintf(out, "%s\n", reason);
	exit(1);
    }

    fprintf(out, "\nSupported options are:\n"
		 "\t-c\t\tcheck consistency\n"
		 "\t-e\t\terror if archive already exists (only useful with -n)\n"
#ifdef FOR_REGRESS
		 "\t-F size\t\tfragment size for in memory archive\n"
#endif
		 "\t-g\t\tguess file name encoding (for stat)\n"
#ifdef FOR_REGRESS
		 "\t-H\t\twrite files with holes compactly\n"
#endif
		 "\t-h\t\tdisplay this usage\n"
		 "\t-l len\t\tonly use len bytes of file\n"
#ifdef FOR_REGRESS
		 "\t-m\t\tread archive into memory, and modify there; write out at end\n"
#endif
		 "\t-n\t\tcreate archive if it doesn't exist\n"
		 "\t-o offset\tstart reading file at offset\n"
		 "\t-r\t\tprint raw file name encoding without translation (for stat)\n"
		 "\t-s\t\tfollow file name convention strictly (for stat)\n"
		 "\t-t\t\tdisregard current archive contents, if any\n");
    fprintf(out, "\nSupported commands and arguments are:\n");
    for (i = 0; i < sizeof(dispatch_table) / sizeof(dispatch_table_t); i++) {
	fprintf(out, "\t%s %s\n\t    %s\n\n", dispatch_table[i].cmdline_name, dispatch_table[i].arg_names, dispatch_table[i].description);
    }
    fprintf(out, "\nSupported flags are:\n"
		 "\t0\t(no flags)\n"
		 "\tC\tZIP_FL_NOCASE\n"
		 "\tc\tZIP_FL_CENTRAL\n"
		 "\td\tZIP_FL_NODIR\n"
		 "\tl\tZIP_FL_LOCAL\n"
		 "\tu\tZIP_FL_UNCHANGED\n");
    fprintf(out, "\nSupported compression methods are:\n"
		 "\tdefault\n"
#if defined(HAVE_LIBBZ2)
		 "\tbzip2\n"
#endif
		 "\tdeflate\n"
		 "\tstore\n");
    fprintf(out, "\nSupported compression methods are:\n"
		 "\tnone\n"
		 "\tAES-128\n"
		 "\tAES-192\n"
		 "\tAES-256\n");
    fprintf(out, "\nThe index is zero-based.\n");
    exit(0);
}

#ifndef FOR_REGRESS
#define ziptool_open read_from_file
int
ziptool_post_close(const char *archive) {
    return 0;
}
#endif

int
main(int argc, char *argv[]) {
    const char *archive;
    unsigned int i;
    int c, arg, err, flags;
    const char *prg;
    zip_uint64_t len = 0, offset = 0;
    zip_error_t error;

    flags = 0;
    prg = argv[0];

    while ((c = getopt(argc, argv, "ceghl:no:rst" OPTIONS_REGRESS)) != -1) {
	switch (c) {
	case 'c':
	    flags |= ZIP_CHECKCONS;
	    break;
	case 'e':
	    flags |= ZIP_EXCL;
	    break;
	case 'g':
	    stat_flags = ZIP_FL_ENC_GUESS;
	    break;
	case 'h':
	    usage(prg, NULL);
	    break;
	case 'l':
	    len = strtoull(optarg, NULL, 10);
	    break;
	case 'n':
	    flags |= ZIP_CREATE;
	    break;
	case 'o':
	    offset = strtoull(optarg, NULL, 10);
	    break;
	case 'r':
	    stat_flags = ZIP_FL_ENC_RAW;
	    break;
	case 's':
	    stat_flags = ZIP_FL_ENC_STRICT;
	    break;
	case 't':
	    flags |= ZIP_TRUNCATE;
	    break;
#ifdef GETOPT_REGRESS
	    GETOPT_REGRESS
#endif

	default: {
	    char reason[128];
	    snprintf(reason, sizeof(reason), "invalid option -%c", optopt);
	    usage(prg, reason);
	}
	}
    }

    if (optind >= argc - 1)
	usage(prg, "too few arguments");

    arg = optind;

    archive = argv[arg++];

    if (flags == 0)
	flags = ZIP_CREATE;

    zip_error_init(&error);
    za = ziptool_open(archive, flags, &error, offset, len);
    if (za == NULL) {
	fprintf(stderr, "can't open zip archive '%s': %s\n", archive, zip_error_strerror(&error));
	zip_error_fini(&error);
	return 1;
    }
    zip_error_fini(&error);

    err = 0;
    while (arg < argc) {
	int ret;
	ret = dispatch(argc - arg, argv + arg);
	if (ret > 0) {
	    arg += ret;
	}
	else {
	    err = 1;
	    break;
	}
    }

    if (zip_close(za) == -1) {
	fprintf(stderr, "can't close zip archive '%s': %s\n", archive, zip_strerror(za));
	return 1;
    }
    if (ziptool_post_close(archive) < 0) {
	err = 1;
    }

    for (i = 0; i < z_in_count; i++) {
	if (zip_close(z_in[i]) < 0) {
	    err = 1;
	}
    }

    return err;
}
