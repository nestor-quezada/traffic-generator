#!/usr/bin/env python3
import os
import sys

#with open("/mnt/shared/server-directories/directory-0/F915.pdf", 'rb', 0) as myfile:
bytes_left_to_read = 65524
block_size = 4096
    #while bytes_left_to_read >= block_size or bytes_left_to_read > 0:
        #if bytes_left_to_read >= block_size:
    #b = myfile.read(block_size)
    #print(sys.getsizeof(b))
        #else:
        #    b = myfile.read(bytes_left_to_read)
        # Fuerza a escribir en disco los bytes
        #myfile.flush()
        #os.fsync(myfile.fileno())
    #bytes_left_to_read -= block_size

path = "/mnt/shared/server-directories/directory-0/F915.pdf"

# Open the file and get
# the file descriptor associated
# with it using os.open() method
fd = os.open(path, os.O_RDONLY)

# Number of bytes to be read
n = 4096

# Read at most n bytes
# from file descriptor fd
# using os.read() method
readBytes = os.read(fd, n)

# Print the bytes read
print(readBytes)

# close the file descriptor
os.close(fd)