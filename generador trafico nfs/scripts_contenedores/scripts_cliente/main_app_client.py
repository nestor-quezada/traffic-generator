#!/usr/bin/env python3

from traffic_generator_client import TrafficGeneratorClient
import argparse


parser = argparse.ArgumentParser(description='Lanza el generador de tráfico SMB/NFS')
parser.add_argument("-bs", "--block_size", default=4096, type=int, help="Block size, in bytes, default: 4096 ")

args = parser.parse_args()
block_size = args.block_size

cliente = TrafficGeneratorClient(block_size)
cliente.start()
