# Makefile for simulating packet extractor

TOP_MODULE=packet_extractor_tb
SRC=packet_extractor.v simple_fifo_1k.v packet_extractor_tb.v
OUT=simv

all: sim

sim:
	iverilog -g2012 -o $(OUT) $(SRC)
	vvp $(OUT)

clean:
	rm -f $(OUT) *.vcd
