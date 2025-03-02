CC:=cc
CFLAGS:=-Wall -Wextra -std=c99 -pedantic -g -I./include/
LIBS:=
BIN:=mpu

BIN_DIR:=bin
SRC_DIR:=src
CACHE_DIR:=cache

SRC:=$(wildcard ${SRC_DIR}/*.c)
OBJ:=${SRC:.c=.o}
OBJ:=$(addprefix ${CACHE_DIR}/, $(notdir ${OBJ}))

all: ${OBJ}
	${CC} ${LIBS} ${OBJ} -o ${BIN_DIR}/${BIN}

${CACHE_DIR}/%.o: ${SRC_DIR}/%.c
	@mkdir -p ${CACHE_DIR}
	${CC} ${CFLAGS} -c $< -o $@

.PHONY: clean
clean:
	@rm -rfv ${CACHE_DIR} ${BIN_DIR}/${BIN}
