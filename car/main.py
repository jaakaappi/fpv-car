import RPi.GPIO as GPIO

import argparse
import socket
import struct
import time

parser = argparse.ArgumentParser()
#parser.add_argument("ip")
parser.add_argument("port")
args = parser.parse_args()

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(("0.0.0.0", int(args.port)))

servoPIN = 14
GPIO.setmode(GPIO.BCM)
GPIO.setup(servoPIN, GPIO.OUT)
p = GPIO.PWM(servoPIN, 50) # GPIO 17 for PWM with 50Hz

#servo range 5-7.5
p.start(6.25)
time.sleep(1)
# p.stop()
# GPIO.cleanup()
# exit()

try:
    print("Waiting for connection")
    while True:
        data, addr = sock.recvfrom(32) # buffer size is 1024 bytes
        print("received message: %s" % data)
        print("steering", struct.unpack('<f', data)[0])
        steering = struct.unpack('<f', data)[0]
        if steering >= -50 and steering <= 50:
            servo_steering = (((steering - -50) * 2.5) / 100) + 5
            print(servo_steering)
            p.ChangeDutyCycle(servo_steering)
except KeyboardInterrupt:
  socket.close()
  p.stop()
  GPIO.cleanup()