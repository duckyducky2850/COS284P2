TASKS := task1 task2 task3 task4 task5

.PHONY: all clean $(TASKS)

all: $(TASKS)

$(TASKS): %: %.o
	ld -o $@ $<

%.o: %.asm
	yasm -f elf64 -g dwarf2 $< -o $@

clean:
	rm -f $(TASKS) *.o