AS = nasm
LD = ld
ASFLAGS = -f elf32
LDFLAGS = -m elf_i386 -no-pie
DEBUG = 

SRC_DIR = src
BIN = fetch86

SRCS = $(wildcard $(SRC_DIR)/*.asm)
OBJS = $(patsubst $(SRC_DIR)/%.asm, %.o, $(SRCS))

#TOOLS_DIR = ./tools

PREFIX = /usr/local

#all: $(TOOLS_DIR)/generate_ids.c.out $(BIN)
all: $(BIN)

$(BIN): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

#$(TOOLS_DIR)/generate_ids.c.out:
#	$(MAKE) -C $(TOOLS_DIR)
#	$(TOOLS_DIR)/generate_ids.c.out $(PCI_IDS) $(PCI_BIN) $(PCI_ARGS)

%.o: $(SRC_DIR)/%.asm
	$(AS) $(DEBUG) $(ASFLAGS) -o $@ $<

clean:
	rm -f $(OBJS) $(BIN)
#	$(MAKE) -C $(TOOLS_DIR) clean

install: $(BIN)
	cp $(BIN) $(PREFIX)/bin/$(BIN:.out=)
	chmod +x $(PREFIX)/bin/$(BIN:.out=)


